import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'university_lab_result.dart';

/// Full-screen celebration judges remember — stars, confetti, score burst.
Future<void> showLabMissionCelebration({
  required BuildContext context,
  required UniversityLabResult result,
  String title = 'UNIVERSITY LAB COMPLETE',
  String accentLabel = '3D Anatomist',
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    transitionDuration: const Duration(milliseconds: 420),
    pageBuilder: (BuildContext ctx, Animation<double> a1, Animation<double> a2) {
      return _LabCelebrationPage(
        result: result,
        title: title,
        accentLabel: accentLabel,
      );
    },
    transitionBuilder: (
      BuildContext ctx,
      Animation<double> anim,
      Animation<double> secondary,
      Widget child,
    ) {
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: child,
        ),
      );
    },
  );
}

class _LabCelebrationPage extends StatefulWidget {
  const _LabCelebrationPage({
    required this.result,
    required this.title,
    required this.accentLabel,
  });

  final UniversityLabResult result;
  final String title;
  final String accentLabel;

  @override
  State<_LabCelebrationPage> createState() => _LabCelebrationPageState();
}

class _LabCelebrationPageState extends State<_LabCelebrationPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int get _stars {
    final double a = widget.result.accuracy;
    if (a >= 0.92) return 3;
    if (a >= 0.75) return 2;
    if (a >= 0.6) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final UniversityLabResult r = widget.result;
    final Color accent = r.passed ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24);

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AnimatedBuilder(
            animation: _ctrl,
            builder: (BuildContext context, Widget? child) {
              return CustomPaint(
                painter: _ConfettiPainter(progress: _ctrl.value, seed: 42),
              );
            },
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C2214),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: accent.withValues(alpha: 0.55), width: 1.4),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: accent.withValues(alpha: 0.28),
                      blurRadius: 36,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(3, (int i) {
                        final bool on = i < _stars;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            on ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: on ? const Color(0xFFF5D76E) : Colors.white24,
                            size: 36,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      r.scoreLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 48,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      r.passed ? 'Practical standard met' : 'Retry recommended',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _statRow('Spatial views', '${r.viewsVisited}/3'),
                    _statRow(
                      'Bone IDs',
                      '${r.identifyCorrect}/${r.identifyAttempts}',
                    ),
                    _statRow(
                      'Clinical viva',
                      r.clinicalSolved
                          ? 'Passed (${(r.clinicalReasoningScore * 100).round()}%)'
                          : 'Incomplete',
                    ),
                    _statRow(
                      'Label drill',
                      r.labelDrillComplete ? 'Complete' : 'Incomplete',
                    ),
                    _statRow('XP earned', '+${r.xpEarned}'),
                    if (r.badgeId != null) ...<Widget>[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '🏅 Badge unlocked: ${widget.accentLabel}',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: const Color(0xFF04110C),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'CONTINUE TO PROFESSOR DEBRIEF',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.seed});

  final double progress;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final math.Random rng = math.Random(seed);
    final List<Color> colors = <Color>[
      const Color(0xFF4ADE80),
      const Color(0xFFF5D76E),
      const Color(0xFF38BDF8),
      const Color(0xFFF472B6),
      Colors.white,
    ];
    for (int i = 0; i < 48; i++) {
      final double x = rng.nextDouble() * size.width;
      final double startY = -40 - rng.nextDouble() * 80;
      final double y = startY + progress * (size.height + 160) * (0.55 + rng.nextDouble() * 0.6);
      final Paint p = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 0.85);
      final double w = 4 + rng.nextDouble() * 6;
      final double h = 8 + rng.nextDouble() * 10;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * (1 + rng.nextDouble() * 3));
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(2)),
        p,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
