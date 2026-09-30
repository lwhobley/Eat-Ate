import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../services/store.dart';
import '../theme/vibrant_theme.dart';
import '../widgets/vibrant_led_components.dart';

class AvatarScreen extends StatefulWidget {
  final Store store;
  final VoidCallback? onOpenReel;

  const AvatarScreen({
    super.key,
    required this.store,
    this.onOpenReel,
  });

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  bool _rendering = false;
  bool _isFemaleModel = false;

  Future<void> _pickBase() async {
    // multi-photo onboard (up to 10), best-first kept in store
    final pics = await ImagePicker().pickMultiImage();
    if (pics.isEmpty) return;
    final bytes = <Uint8List>[];
    for (final p in pics.take(10)) {
      bytes.add(Uint8List.fromList(await p.readAsBytes()));
    }
    widget.store.addBaseAvatarPhotos(bytes);
  }

  Future<void> _share() async {
    final rendered = widget.store.avatarImageBytes;
    final lean = widget.store.projectedLean;
    final text =
        'Future me check: ${lean >= 0.2 ? "sculpted & shredded" : lean <= -0.2 ? "bulking & softened" : "locked in on track"} '
        '(${(widget.store.adherence * 100).round()}% locked in on Eat Or Ate. We move!)';
    if (rendered != null) {
      await Share.shareXFiles(
        [XFile.fromData(rendered, name: 'future-you.jpg', mimeType: 'image/jpeg')],
        text: text,
      );
    } else {
      await Share.share(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final store = widget.store;
        final lean = store.projectedLean;
        final rendered = store.avatarImageBytes;
        final base = store.baseAvatarPhoto;

        Widget visual;
        if (rendered != null) {
          visual = ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.memory(rendered, height: 260, fit: BoxFit.cover),
          );
        } else if (base != null) {
          visual = ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.memory(base, width: 220, height: 260, fit: BoxFit.cover),
          );
        } else {
          // Dynamic AI Physique Evolution View
          final shredProgress = ((lean + 0.5) / 1.0).clamp(0.0, 1.0);
          final beforeImg = _isFemaleModel
              ? 'assets/images/woman_before.jpg'
              : 'assets/images/man_before.jpg';
          final afterImg = _isFemaleModel
              ? 'assets/images/woman_after.jpg'
              : 'assets/images/man_after.jpg';

          visual = Container(
            width: 220,
            height: 290,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: VibrantColors.neonLime,
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    beforeImg,
                    fit: BoxFit.cover,
                  ),
                  Opacity(
                    opacity: shredProgress,
                    child: Image.asset(
                      afterImg,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Bottom gradient overlay with real-time physique readout
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            shredProgress > 0.65
                                ? '🔥 SHREDDED PEAK'
                                : shredProgress > 0.35
                                    ? '⚡ METABOLIC BURN'
                                    : '🌱 DAY 1 BASELINE',
                            style: TextStyle(
                              color: shredProgress > 0.65
                                  ? VibrantColors.neonLime
                                  : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            '${(shredProgress * 100).round()}%',
                            style: const TextStyle(
                              color: VibrantColors.neonCyan,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final statusDesc = lean >= 0.2
            ? 'Shredded / Vascular'
            : lean <= -0.2
                ? 'Bulking / Softened'
                : 'Locked In / On Track';

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            // Prominent Cinematic Transformation Reel Promo Card
            if (widget.onOpenReel != null)
              VibrantLedCard(
                title: 'CINEMATIC GLOW-UP REEL',
                ledColor: VibrantColors.neonLime,
                accentColor: VibrantColors.neonLime,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: VibrantColors.neonLime.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: VibrantColors.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.asset(
                          'assets/images/eat_or_ate_icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.movie_creation_rounded,
                            color: VibrantColors.neonLime,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Evolution Reel',
                            style: TextStyle(
                              color: VibrantColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            'Watch 90-day physique transformation',
                            style: TextStyle(
                              color: VibrantColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    LedCyberButton(
                      onPressed: widget.onOpenReel,
                      label: 'WATCH REEL',
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      chamfer: 10,
                      gradientColors: const [VibrantColors.neonLime, VibrantColors.neonCyan],
                      ledColor: VibrantColors.neonLime,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),

            // Avatar Visual Hologram Card
            VibrantLedCard(
              title: 'FUTURE PHYSIQUE PROJECTION',
              ledColor: VibrantColors.neonMagenta,
              accentColor: VibrantColors.neonMagenta,
              trailing: LedPillBadge(
                label: statusDesc.toUpperCase(),
                color: VibrantColors.neonMagenta,
              ),
              child: Column(
                children: [
                  // Model Gender Selector & Preview Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildModelPill('🏋️ MAN MODEL', !_isFemaleModel, () => setState(() => _isFemaleModel = false)),
                      const SizedBox(width: 10),
                      _buildModelPill('🏃‍♀️ WOMAN MODEL', _isFemaleModel, () => setState(() => _isFemaleModel = true)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Center(
                    child: visual,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${store.baseAvatarPhotos.length}/10 Photos Linked • ${(store.adherence * 100).round()}% Lock-In Rate',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: VibrantColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Lean Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('← Soft', style: TextStyle(color: VibrantColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                      Text('Recomp Dial', style: TextStyle(color: VibrantColors.neonCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text('Shredded →', style: TextStyle(color: VibrantColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: VibrantColors.neonLime,
                      inactiveTrackColor: VibrantColors.border,
                      thumbColor: VibrantColors.neonCyan,
                      overlayColor: VibrantColors.neonCyan.withValues(alpha: 0.15),
                    ),
                    child: Slider(
                      value: store.avatarLean,
                      min: -1,
                      max: 1,
                      divisions: 20,
                      label: store.avatarLean.toStringAsFixed(1),
                      onChanged: store.setAvatarLean,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Quick Milestone Jump Buttons
                  Row(
                    children: [
                      _buildMilestonePill('Day 1: Base', -0.5, store),
                      const SizedBox(width: 6),
                      _buildMilestonePill('Day 30: Burn', -0.1, store),
                      const SizedBox(width: 6),
                      _buildMilestonePill('Day 60: Sculpt', 0.3, store),
                      const SizedBox(width: 6),
                      _buildMilestonePill('Day 90: Shred', 0.8, store),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Auto-drift switch
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: VibrantColors.border),
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        'Auto-drift with adherence',
                        style: TextStyle(color: VibrantColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      subtitle: const Text(
                        'Physique evolves automatically based on logged meals and workouts',
                        style: TextStyle(color: VibrantColors.textSecondary, fontSize: 11),
                      ),
                      activeThumbColor: VibrantColors.neonLime,
                      value: store.avatarAutoDrift,
                      onChanged: store.setAvatarAutoDrift,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Action Buttons
            VibrantLedCard(
              title: 'PHYSIQUE LAB ACTIONS',
              ledColor: VibrantColors.neonCyan,
              accentColor: VibrantColors.neonCyan,
              child: Column(
                children: [
                  LedCyberButton(
                    onPressed: _rendering
                        ? null
                        : () async {
                            setState(() => _rendering = true);
                            final msg = await store.renderAvatar();
                            setState(() => _rendering = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                   .showSnackBar(SnackBar(content: Text(msg)));
                            }
                          },
                    label: _rendering
                        ? 'Generating Neural Glow-Up…'
                        : 'Render Neural Future You',
                    icon: const Icon(Icons.auto_awesome),
                    gradientColors: const [VibrantColors.neonMagenta, Color(0xFF9333EA)],
                    ledColor: VibrantColors.neonMagenta,
                    fullWidth: true,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: LedCyberButton(
                          onPressed: _pickBase,
                          label: store.baseAvatarPhotos.isEmpty ? 'Upload Selfies' : 'Add Selfies',
                          icon: const Icon(Icons.upload),
                          gradientColors: const [Color(0xFF0284C7), Color(0xFF0369A1)],
                          ledColor: VibrantColors.neonCyan,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          chamfer: 10,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: LedCyberButton(
                          onPressed: _share,
                          label: 'Share Glow-Up',
                          icon: const Icon(Icons.share),
                          gradientColors: const [Color(0xFF059669), Color(0xFF047857)],
                          ledColor: VibrantColors.neonLime,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          chamfer: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LedCyberButton(
                    onPressed: store.skipWeek,
                    label: 'Simulate 1-Week Gym Hiatus',
                    icon: const Icon(Icons.history_toggle_off),
                    gradientColors: const [Color(0xFFE11D48), Color(0xFFBE123C)],
                    ledColor: VibrantColors.neonMagenta,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    chamfer: 10,
                    fullWidth: true,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModelPill(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? VibrantColors.neonCyan.withValues(alpha: 0.12)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? VibrantColors.neonCyan
                : VibrantColors.border,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? VibrantColors.neonCyan : VibrantColors.textSecondary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMilestonePill(String label, double targetLean, Store store) {
    final isSelected = (store.avatarLean - targetLean).abs() < 0.25;
    return Expanded(
      child: GestureDetector(
        onTap: () => store.setAvatarLean(targetLean),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? VibrantColors.neonLime.withValues(alpha: 0.12)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? VibrantColors.neonLime
                  : VibrantColors.border,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? VibrantColors.neonLime : VibrantColors.textSecondary,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
