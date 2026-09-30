import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/vibrant_theme.dart';
import 'vibrant_led_components.dart';

enum TransformationSubject { man, woman }

class CinematicTransformationReel extends StatefulWidget {
  final VoidCallback onDismiss;
  final bool isModal;

  const CinematicTransformationReel({
    super.key,
    required this.onDismiss,
    this.isModal = false,
  });

  @override
  State<CinematicTransformationReel> createState() =>
      _CinematicTransformationReelState();
}

class _CinematicTransformationReelState
    extends State<CinematicTransformationReel>
    with TickerProviderStateMixin {
  TransformationSubject _subject = TransformationSubject.man;
  bool _isPlaying = true;
  double _splitProgress = 0.5; // 0.0 = full before, 1.0 = full after
  bool _isManualDragging = false;

  late final AnimationController _scannerCtrl;
  late final AnimationController _kenBurnsCtrl;
  late final AnimationController _equalizerCtrl;
  Timer? _autoPlayTimer;

  int _currentPhase = 1; // 0: Baseline, 1: Transforming, 2: Sculpted Peak

  @override
  void initState() {
    super.initState();

    _scannerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _kenBurnsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _equalizerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);

    _startAutoPlayLoop();
  }

  void _startAutoPlayLoop() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!_isPlaying || _isManualDragging || !mounted) return;
      setState(() {
        _splitProgress += 0.007;
        if (_splitProgress > 1.0) {
          _splitProgress = 0.0;
        }
        _updatePhase();
      });
    });
  }

  void _updatePhase() {
    if (_splitProgress < 0.33) {
      _currentPhase = 0;
    } else if (_splitProgress < 0.68) {
      _currentPhase = 1;
    } else {
      _currentPhase = 2;
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _scannerCtrl.dispose();
    _kenBurnsCtrl.dispose();
    _equalizerCtrl.dispose();
    super.dispose();
  }

  String get _beforeAsset => _subject == TransformationSubject.man
      ? 'assets/images/man_before.jpg'
      : 'assets/images/woman_before.jpg';

  String get _afterAsset => _subject == TransformationSubject.man
      ? 'assets/images/man_after.jpg'
      : 'assets/images/woman_after.jpg';

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: VibrantColors.obsidianVoid,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Picturesque Hero Background Canvas
          Positioned.fill(
            child: Image.asset(
              'assets/images/vibrant_hero_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF020617)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // 2. High-energy Vignette & Cyber Aurora overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [
                    Colors.transparent,
                    VibrantColors.obsidianVoid.withValues(alpha: 0.6),
                    VibrantColors.obsidianVoid.withValues(alpha: 0.96),
                  ],
                  stops: const [0.2, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // 3. Transformation Main Stage (Ken Burns + Interactive Wipe)
          SafeArea(
            child: Column(
              children: [
                _buildCinematicHeader(),
                const SizedBox(height: 12),
                _buildGenderToggle(),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: _buildTransformationViewport(media.size),
                  ),
                ),
                const SizedBox(height: 14),
                _buildTelemetryHud(),
                const SizedBox(height: 12),
                _buildPlaybackControls(),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // 4. Close/Skip Button top right
          Positioned(
            top: media.padding.top + 10,
            right: 18,
            child: IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.6),
                side: BorderSide(color: VibrantColors.neonLime.withValues(alpha: 0.4)),
              ),
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: widget.onDismiss,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCinematicHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LedStatusDiode(
                color: VibrantColors.neonLime,
                size: 8,
              ),
              const SizedBox(width: 8),
              Text(
                'CINEMATIC TRANSFORMATION REEL'.toUpperCase(),
                style: const TextStyle(
                  color: VibrantColors.neonCyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'From Average to Toned & Peak Condition',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              shadows: [
                Shadow(color: VibrantColors.neonLime, blurRadius: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: VibrantColors.neonLime.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            title: 'MAN EVOLUTION',
            subject: TransformationSubject.man,
            icon: Icons.male,
            activeColor: VibrantColors.neonCyan,
          ),
          const SizedBox(width: 6),
          _buildToggleOption(
            title: 'WOMAN EVOLUTION',
            subject: TransformationSubject.woman,
            icon: Icons.female,
            activeColor: VibrantColors.neonMagenta,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String title,
    required TransformationSubject subject,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = _subject == subject;
    return GestureDetector(
      onTap: () => setState(() => _subject = subject),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.24) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.35),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? activeColor : Colors.white60,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransformationViewport(Size screenSize) {
    final viewportWidth = math.min(screenSize.width * 0.92, 420.0);
    final viewportHeight = math.min(screenSize.height * 0.46, 380.0);

    return Container(
      width: viewportWidth,
      height: viewportHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: VibrantColors.neonLime.withValues(alpha: 0.45),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: VibrantColors.neonLime.withValues(alpha: 0.22),
            blurRadius: 30,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: DAY 1 Baseline Soft Physique (Base Before Image)
            AnimatedBuilder(
              animation: _kenBurnsCtrl,
              builder: (context, _) {
                final scale = 1.02 + 0.04 * math.sin(_kenBurnsCtrl.value * math.pi);
                return Transform.scale(
                  scale: scale,
                  child: Image.asset(
                    _beforeAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => _buildFallbackVisual(),
                  ),
                );
              },
            ),

            // Layer 2: DAY 90 Peak Shredded Sculpted Physique (Revealed via Split Slider)
            ClipRect(
              clipper: _SplitRevealClipper(_splitProgress),
              child: AnimatedBuilder(
                animation: _kenBurnsCtrl,
                builder: (context, _) {
                  final scale = 1.02 + 0.04 * math.sin(_kenBurnsCtrl.value * math.pi);
                  return Transform.scale(
                    scale: scale,
                    child: Image.asset(
                      _afterAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => _buildFallbackVisual(),
                    ),
                  );
                },
              ),
            ),

            // Neon laser scanner beam along the split divider
            Positioned(
              left: _splitProgress * viewportWidth - 1.5,
              top: 0,
              bottom: 0,
              width: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: VibrantColors.neonLime,
                  boxShadow: [
                    BoxShadow(
                      color: VibrantColors.neonLime.withValues(alpha: 0.9),
                      blurRadius: 14,
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: VibrantColors.neonCyan.withValues(alpha: 0.6),
                      blurRadius: 26,
                      spreadRadius: 6,
                    ),
                  ],
                ),
              ),
            ),

            // Interactive Hologram Split Divider Handle
            Positioned(
              left: _splitProgress * viewportWidth - 14,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (_) => setState(() {
                  _isManualDragging = true;
                  _isPlaying = false;
                }),
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _splitProgress = (_splitProgress +
                            details.primaryDelta! / viewportWidth)
                        .clamp(0.0, 1.0);
                    _updatePhase();
                  });
                },
                onHorizontalDragEnd: (_) => setState(() {
                  _isManualDragging = false;
                }),
                child: Center(
                  child: Container(
                    width: 28,
                    height: 52,
                    decoration: BoxDecoration(
                      color: VibrantColors.obsidianVoid,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: VibrantColors.neonLime,
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: VibrantColors.neonLime.withValues(alpha: 0.6),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.compare_arrows,
                      color: VibrantColors.neonLime,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),

            // Top Badges: BEFORE (Average) vs AFTER (Toned & Sculpted)
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Text(
                  'DAY 1 • BASELINE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: VibrantColors.neonLime.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: VibrantColors.neonLime),
                  boxShadow: [
                    BoxShadow(
                      color: VibrantColors.neonLime.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    LedStatusDiode(color: VibrantColors.neonLime, size: 5),
                    SizedBox(width: 5),
                    Text(
                      'DAY 90 • SCULPTED',
                      style: TextStyle(
                        color: VibrantColors.neonLime,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Phase indicator overlay at bottom of viewport
            Positioned(
              bottom: 12,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: VibrantColors.neonCyan.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _currentPhase == 0
                            ? 'PHASE 1: Starting Baseline Lore'
                            : _currentPhase == 1
                                ? 'PHASE 2: Metabolic Shift & Kinetic Shred'
                                : 'PHASE 3: Peak Vascular Definition',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _currentPhase == 2
                              ? VibrantColors.neonLime
                              : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(_splitProgress * 100).round()}%',
                      style: const TextStyle(
                        color: VibrantColors.neonCyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
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

  Widget _buildFallbackVisual() {
    return Container(
      color: const Color(0xFF1E293B),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fitness_center, size: 54, color: VibrantColors.neonLime),
            const SizedBox(height: 8),
            Text(
              '${_subject == TransformationSubject.man ? "Man" : "Woman"} Transformation Journey',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryHud() {
    final bf = (24.0 - _splitProgress * 12.2).toStringAsFixed(1);
    final leanMass = (_splitProgress * 8.4).toStringAsFixed(1);
    final metabolism = '+${(_splitProgress * 420).round()}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1E293B),
              Color(0xFF152033),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: VibrantColors.neonCyan.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('BODY FAT', '$bf%', VibrantColors.neonMagenta),
            Container(width: 1, height: 32, color: Colors.white12),
            _buildStatItem('LEAN MUSCLE', '+$leanMass lbs', VibrantColors.neonLime),
            Container(width: 1, height: 32, color: Colors.white12),
            _buildStatItem('METABOLISM', '$metabolism kcal', VibrantColors.neonGold),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(color: color.withValues(alpha: 0.6), blurRadius: 10),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          // Play / Pause motion button
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.6),
              side: BorderSide(
                color: _isPlaying
                    ? VibrantColors.neonLime
                    : Colors.white30,
              ),
            ),
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: _isPlaying ? VibrantColors.neonLime : Colors.white,
              size: 22,
            ),
            onPressed: () => setState(() => _isPlaying = !_isPlaying),
          ),
          const SizedBox(width: 8),

          // Animated Audio/Energy Equalizer bars
          AnimatedBuilder(
            animation: _equalizerCtrl,
            builder: (context, _) {
              return Row(
                children: List.generate(5, (i) {
                  final h = 6.0 +
                      18.0 *
                          math.sin(
                              _equalizerCtrl.value * math.pi + (i * 0.7))
                              .abs();
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 3.5,
                    height: _isPlaying ? h : 4,
                    decoration: BoxDecoration(
                      color: VibrantColors.neonCyan,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: VibrantColors.neonCyan.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(width: 14),

          // Uniquely shaped LED cyber button to launch full app
          Expanded(
            child: LedCyberButton(
              onPressed: widget.onDismiss,
              label: 'LET\'S GET IT • START JOURNEY',
              subtitle: 'Lock In Your Transformation',
              icon: const Icon(Icons.bolt, color: VibrantColors.obsidianVoid),
              gradientColors: const [
                VibrantColors.neonLime,
                VibrantColors.neonCyan,
              ],
              ledColor: VibrantColors.neonLime,
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom clipper that clips from splitProgress * width to width
class _SplitRevealClipper extends CustomClipper<Rect> {
  final double splitProgress;
  _SplitRevealClipper(this.splitProgress);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      splitProgress * size.width,
      0,
      size.width,
      size.height,
    );
  }

  @override
  bool shouldReclip(covariant _SplitRevealClipper oldClipper) =>
      oldClipper.splitProgress != splitProgress;
}
