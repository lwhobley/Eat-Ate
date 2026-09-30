import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

// Custom avatar via Gemini image generation (no Replicate).
// Uses gemini-2.0-flash-preview-image-generation over REST because the
// Dart SDK (0.4.x) can't send responseModalities yet.
// Pass key via --dart-define=GEMINI_API_KEY=xxx
class AvatarService {
  final String? geminiKey;
  AvatarService({this.geminiKey});

  bool get hasKey => geminiKey != null && geminiKey!.isNotEmpty;

  /// Last render diagnostics for live-verify.
  int? lastStatus;
  String? lastError;

  String promptFor(double lean) {
    final direction = lean >= 0.2
        ? 'noticeably leaner and more muscular, defined shoulders and arms, athletic'
        : lean <= -0.2
            ? 'slightly softer, less defined, a bit more body fat'
            : 'healthy athletic, toned';
    return 'Edit this photo of the same person to look $direction. '
        'Keep the same face, identity, hairstyle, and photo style. '
        'Photorealistic full-body result, no text, no watermark.';
  }

  // Returns PNG/JPEG bytes on success, null otherwise.
  // If basePhotoBytes is null, does a text-only generation (no identity).
  Future<Uint8List?> renderFutureYou({
    required double lean,
    Uint8List? basePhotoBytes,
  }) async {
    if (!hasKey) return null;
    try {
      final parts = <Map<String, dynamic>>[
        {'text': promptFor(lean)},
      ];
      if (basePhotoBytes != null) {
        parts.add({
          'inline_data': {
            'mime_type': 'image/jpeg',
            'data': base64Encode(basePhotoBytes),
          }
        });
      }
      final res = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-preview-image-generation:generateContent?key=$geminiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': parts,
            }
          ],
          'generationConfig': {
            'responseModalities': ['TEXT', 'IMAGE'],
          },
        }),
      );
      if (res.statusCode != 200) {
        lastStatus = res.statusCode;
        lastError =
            'HTTP ${res.statusCode}: ${res.body.length > 200 ? res.body.substring(0, 200) : res.body}';
        return null;
      }
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      final candidates = map['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        lastStatus = 200;
        lastError = 'No candidates in response';
        return null;
      }
      final contentParts =
          (candidates.first as Map<String, dynamic>)['content']?['parts'] as List?;
      if (contentParts == null) {
        lastStatus = 200;
        lastError = 'No content parts in response';
        return null;
      }
      for (final p in contentParts) {
        final pm = p as Map<String, dynamic>;
        final inline = pm['inlineData'] ?? pm['inline_data'];
        if (inline is Map<String, dynamic> && inline['data'] is String) {
          lastStatus = 200;
          lastError = null;
          return base64Decode(inline['data'] as String);
        }
      }
      lastStatus = 200;
      lastError = 'Response had text only, no image part';
      return null;
    } catch (e) {
      lastStatus = -1;
      final s = '$e';
      lastError = s.length > 200 ? '${s.substring(0, 200)}…' : s;
      return null;
    }
  }
}
