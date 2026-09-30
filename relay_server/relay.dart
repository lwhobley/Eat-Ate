#!/usr/bin/env dart
import 'dart:convert';
import 'dart:io';

final File _dbFile = File('relay_db.json');

Future<Map<String, dynamic>> _loadDb() async {
  if (await _dbFile.exists()) {
    try {
      final raw = await _dbFile.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
  }
  return <String, dynamic>{};
}

Future<void> _saveDb(Map<String, dynamic> db) async {
  await _dbFile.writeAsString(jsonEncode(db));
}

Future<void> main() async {
  final port =
      int.tryParse(Platform.environment['RELAY_PORT'] ?? '8080') ?? 8080;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln(
      'Terra relay running at http://${server.address.host}:${server.port}');
  stdout.writeln(
      '  POST /ingest           — send Oura/Whoop/Garmin payload {userId, ...}');
  stdout.writeln('  GET  /recovery/:userId — Flutter app reads this');

  await for (final request in server) {
    try {
      final path = request.uri.path;
      final method = request.method;

      if (path.startsWith('/recovery/') && method == 'GET') {
        final segments = request.uri.pathSegments;
        final userId = segments.length > 1 ? segments[1] : '';
        if (userId.isEmpty) {
          request.response
            ..statusCode = HttpStatus.badRequest
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({'error': 'userId required'}))
            ..close();
          continue;
        }

        final db = await _loadDb();
        final rec = db[userId];
        if (rec == null) {
          request.response
            ..statusCode = HttpStatus.notFound
            ..headers.contentType = ContentType.json
            ..write(
                jsonEncode({'error': 'No recovery data for userId: $userId'}))
            ..close();
          continue;
        }

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(rec))
          ..close();
      } else if (path == '/ingest' && method == 'POST') {
        final body = await utf8.decoder.bind(request).join();
        final data = jsonDecode(body) as Map<String, dynamic>;
        final userId = data['userId']?.toString() ?? '';
        if (userId.isEmpty) {
          request.response
            ..statusCode = HttpStatus.badRequest
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({'error': 'userId required'}))
            ..close();
          continue;
        }

        final db = await _loadDb();
        db[userId] = {
          'sleepHours': (data['sleepHours'] as num? ?? 7.5).toDouble(),
          'readiness': (data['readiness'] as num? ?? 75).toInt(),
          'hrvMs': (data['hrvMs'] as num? ?? 0).toDouble(),
          'restingHr': (data['restingHr'] as num? ?? 60).toInt(),
          'steps': (data['steps'] as num? ?? 0).toInt(),
          'activeKcal': (data['activeKcal'] as num? ?? 0).toInt(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        await _saveDb(db);

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'ok': true, 'userId': userId}))
          ..close();
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'error': 'Not found'}))
          ..close();
      }
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'error': e.toString()}))
        ..close();
    }
  }
}