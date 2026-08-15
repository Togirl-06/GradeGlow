import 'package:flutter/material.dart';

import '../../data/ai_practice_catalog.dart';
import '../../models/ai_practice_mode.dart';
import '../../theme/study_theme.dart';
import 'ai_practice_avatar.dart';

/// Step label like "1. Choose Your Major".
class PracticeStepLabel extends StatelessWidget {
  const PracticeStepLabel({super.key, required this.step, required this.title});

  final int step;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        '$step. $title',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      ),
    );
  }
}

/// Major tile for the 3-column grid.
class MajorGridTile extends StatelessWidget {
  const MajorGridTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.selected = false,
    this.emoji,
  });

  final String label;
  final IconData icon;
  final String? emoji;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color border = selected ? StudyColors.primary : StudyColors.border(brightness);

    return Material(
      color: selected ? StudyColors.primary.withValues(alpha: 0.08) : StudyColors.surface(brightness),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: selected ? 2 : 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(emoji ?? '', style: const TextStyle(fontSize: 26)),
              if (emoji == null || emoji!.isEmpty)
                Icon(icon, size: 30, color: StudyColors.primary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Scenario list card matching the mockup layout.
class ScenarioListCard extends StatelessWidget {
  const ScenarioListCard({
    super.key,
    required this.scenario,
    required this.onStart,
  });

  final PracticeScenarioTemplate scenario;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final Color diffColor = AiPracticeCatalog.difficultyColor(scenario.defaultDifficulty);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: StudyColors.surface(Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: StudyColors.border(Theme.of(context).brightness)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ScenarioThumbnail(role: scenario.avatarRole),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(scenario.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: diffColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          scenario.defaultDifficulty.label,
                          style: TextStyle(color: diffColor, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scenario.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: textSecondary, fontSize: 12, height: 1.35),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: onStart,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(80, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                      ),
                      child: const Text('Start'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenarioThumbnail extends StatelessWidget {
  const _ScenarioThumbnail({required this.role});

  final AvatarRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 112,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            role.accentColor.withValues(alpha: 0.35),
            role.accentColor.withValues(alpha: 0.12),
          ],
        ),
      ),
      child: Center(
        child: AiPracticeAvatar(role: role, isSpeaking: false, size: 64),
      ),
    );
  }
}

/// Circular score ring for performance feedback.
class PracticeScoreRing extends StatelessWidget {
  const PracticeScoreRing({super.key, required this.score, this.size = 140});

  final int score;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bool great = score >= 80;
    final Color ringColor = great ? StudyColors.success : StudyColors.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 10,
              backgroundColor: StudyColors.border(Theme.of(context).brightness),
              color: ringColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('$score', style: TextStyle(fontSize: size * 0.28, fontWeight: FontWeight.w900, color: ringColor)),
              Text('/100', style: TextStyle(fontSize: 12, color: StudyColors.textSecondary(Theme.of(context).brightness))),
            ],
          ),
        ],
      ),
    );
  }
}

/// Simple progress line chart from session history.
class PracticeProgressChart extends StatelessWidget {
  const PracticeProgressChart({super.key, required this.scores});

  final List<int> scores;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    if (scores.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        child: Text('Complete scenarios to see your trend', style: TextStyle(color: StudyColors.textSecondary(brightness))),
      );
    }

    return SizedBox(
      height: 120,
      child: CustomPaint(
        painter: _ProgressChartPainter(
          scores: scores,
          lineColor: StudyColors.primary,
          fillColor: StudyColors.primary.withValues(alpha: 0.12),
          gridColor: StudyColors.border(brightness),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ProgressChartPainter extends CustomPainter {
  _ProgressChartPainter({
    required this.scores,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
  });

  final List<int> scores;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.length < 2) return;

    final Paint grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      final double y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final List<Offset> points = <Offset>[];
    for (int i = 0; i < scores.length; i++) {
      final double x = size.width * i / (scores.length - 1);
      final double y = size.height - (scores[i] / 100) * size.height * 0.85 - size.height * 0.05;
      points.add(Offset(x, y));
    }

    final Path fill = Path()..moveTo(points.first.dx, size.height);
    for (final Offset p in points) {
      fill.lineTo(p.dx, p.dy);
    }
    fill.lineTo(points.last.dx, size.height);
    fill.close();
    canvas.drawPath(fill, Paint()..color = fillColor);

    final Path line = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      line.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    for (final Offset p in points) {
      canvas.drawCircle(p, 4, Paint()..color = lineColor);
    }
  }

  @override
  bool shouldRepaint(_ProgressChartPainter oldDelegate) => oldDelegate.scores != scores;
}

/// Immersive simulation scene with avatar and speech bubble.
class SimulationScene extends StatelessWidget {
  const SimulationScene({
    super.key,
    required this.role,
    required this.aiRole,
    required this.speechText,
    required this.isSpeaking,
    required this.emotion,
  });

  final AvatarRole role;
  final String aiRole;
  final String speechText;
  final bool isSpeaking;
  final AvatarEmotion emotion;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color surface = StudyColors.surface(brightness);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            role.accentColor.withValues(alpha: 0.32),
            role.accentColor.withValues(alpha: 0.12),
            surface,
          ],
          stops: const <double>[0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.35),
                  radius: 1.1,
                  colors: <Color>[
                    Colors.white.withValues(alpha: brightness == Brightness.dark ? 0.08 : 0.45),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              const SizedBox(height: 14),
              AiPracticeAvatar(role: role, isSpeaking: isSpeaking, emotion: emotion, size: 136),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: role.accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: role.accentColor.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(role.icon, size: 14, color: role.accentColor),
                    const SizedBox(width: 6),
                    Text(
                      aiRole,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: role.accentColor),
                    ),
                  ],
                ),
              ),
              if (speechText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: _SpeechBubble(text: speechText, isSpeaking: isSpeaking, accent: role.accentColor),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text, required this.isSpeaking, required this.accent});

  final String text;
  final bool isSpeaking;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: <Widget>[
        Positioned(
          top: -8,
          child: CustomPaint(
            size: const Size(18, 10),
            painter: _BubbleTailPainter(color: StudyColors.surface(brightness), border: StudyColors.border(brightness)),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: StudyColors.surface(brightness),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: StudyColors.border(brightness)),
            boxShadow: <BoxShadow>[
              BoxShadow(color: accent.withValues(alpha: 0.12), blurRadius: 18, offset: const Offset(0, 6)),
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (isSpeaking)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: <Widget>[
                      _SpeakingDots(accent: accent),
                      const SizedBox(width: 8),
                      Text('Speaking…', style: TextStyle(fontSize: 11, color: accent, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              Text(text, style: const TextStyle(height: 1.5, fontSize: 14.5, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpeakingDots extends StatefulWidget {
  const _SpeakingDots({required this.accent});

  final Color accent;

  @override
  State<_SpeakingDots> createState() => _SpeakingDotsState();
}

class _SpeakingDotsState extends State<_SpeakingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Row(
          children: List<Widget>.generate(3, (int i) {
            final double phase = (_controller.value + i * 0.2) % 1.0;
            final double scale = 0.55 + (phase < 0.5 ? phase : 1 - phase) * 0.9;
            return Padding(
              padding: EdgeInsets.only(right: i < 2 ? 3 : 0),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: widget.accent, shape: BoxShape.circle),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  _BubbleTailPainter({required this.color, required this.border});

  final Color color;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final Path tail = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(tail, Paint()..color = border);
    final Path inner = Path()
      ..moveTo(size.width / 2, 2)
      ..lineTo(2, size.height)
      ..lineTo(size.width - 2, size.height)
      ..close();
    canvas.drawPath(inner, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_BubbleTailPainter oldDelegate) => false;
}

/// Session timer display.
class SessionTimer extends StatelessWidget {
  const SessionTimer({super.key, required this.elapsed});

  final Duration elapsed;

  @override
  Widget build(BuildContext context) {
    final String mm = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String ss = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: StudyColors.surface(Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: StudyColors.border(Theme.of(context).brightness)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.timer_outlined, size: 14, color: StudyColors.textSecondary(Theme.of(context).brightness)),
          const SizedBox(width: 4),
          Text('$mm:$ss', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
        ],
      ),
    );
  }
}

/// Small score badge for recent sessions list.
class ScoreBadge extends StatelessWidget {
  const ScoreBadge({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final Color color = score >= 80 ? StudyColors.success : score >= 60 ? StudyColors.warning : StudyColors.danger;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2.5),
      ),
      child: Center(
        child: Text('$score', style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 13)),
      ),
    );
  }
}

/// Feedback section with icon bullets.
class FeedbackBulletList extends StatelessWidget {
  const FeedbackBulletList({
    super.key,
    required this.title,
    required this.items,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final List<String> items;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 10),
        ...items.map(
          (String item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: const TextStyle(height: 1.4))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
