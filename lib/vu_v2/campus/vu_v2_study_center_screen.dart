import 'package:flutter/material.dart';

import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import '../labs/major_wow_router.dart';
import '../career_labs/playable/science/biology/anatomy_3d_viewer_screen.dart';
import 'vu_v2_adaptive_review_drill_screen.dart';
import 'vu_v2_flashcards_question_bank_flow.dart';
import 'vu_v2_planner_screen.dart';
import 'vu_v2_quizzes_exams_hub_screen.dart';

/// Study Center — matches the emerald flashcard mockup.
class VuV2StudyCenterScreen extends StatefulWidget {
  const VuV2StudyCenterScreen({
    super.key,
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  @override
  State<VuV2StudyCenterScreen> createState() => _VuV2StudyCenterScreenState();
}

class _VuV2StudyCenterScreenState extends State<VuV2StudyCenterScreen> {
  int _mode = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: <Widget>[
        const Text(
          'Study Center',
          style: TextStyle(
            color: VuV2Colors.ink,
            fontWeight: FontWeight.w900,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Flashcards, quizzes, adaptive review, and unlimited practice.',
          style: TextStyle(color: VuV2Colors.mute, height: 1.4),
        ),
        const SizedBox(height: 16),
        if (widget.progress.topDiagramMisconceptions.isNotEmpty ||
            widget.progress.dueAdaptiveReviews > 0) ...<Widget>[
          VuV2Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Adaptive Review',
                  style: TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.progress.dueAdaptiveReviews > 0
                      ? '${widget.progress.dueAdaptiveReviews} confusion pair${widget.progress.dueAdaptiveReviews == 1 ? '' : 's'} ready — targeted diagram drills beat generic flashcards.'
                      : 'Practice weak pairs before they hit your next lecture.',
                  style: const TextStyle(color: VuV2Colors.mute, height: 1.4),
                ),
                const SizedBox(height: 12),
                VuV2PrimaryButton(
                  label: 'Start 2-min review drill',
                  trailingArrow: true,
                  onPressed: () => VuV2AdaptiveReviewDrillScreen.open(
                    context,
                    progress: widget.progress,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        Row(
          children: <Widget>[
            Expanded(
              child: _ModeChip(
                label: 'Flashcards',
                icon: Icons.style_rounded,
                selected: _mode == 0,
                onTap: () => setState(() => _mode = 0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ModeChip(
                label: 'Quizzes',
                icon: Icons.help_outline_rounded,
                selected: _mode == 1,
                onTap: () => setState(() => _mode = 1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ModeChip(
                label: 'Question Bank',
                icon: Icons.menu_book_outlined,
                selected: _mode == 2,
                onTap: () => setState(() => _mode = 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (_mode == 0) _FlashcardsPreview(session: widget.session, progress: widget.progress),
        if (_mode == 1) ...<Widget>[
          VuV2Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  MajorWowRouter.studyQuizTitle(widget.session.majorId),
                  style: const TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  MajorWowRouter.studyQuizBody(widget.session.majorId),
                  style: const TextStyle(color: VuV2Colors.mute, height: 1.4),
                ),
                const SizedBox(height: 12),
                VuV2PrimaryButton(
                  label: 'Start ${MajorWowRouter.studyQuizTitle(widget.session.majorId)}',
                  trailingArrow: true,
                  onPressed: () => MajorWowRouter.openStudyQuizHero(
                    context,
                    widget.session.majorId,
                  ),
                ),
                if (widget.session.majorId.toLowerCase().contains('bio')) ...<Widget>[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => Anatomy3dViewerHubScreen.open(context),
                    icon: const Icon(Icons.threed_rotation, size: 18),
                    label: const Text('Open 3D anatomy viewers'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ModeLaunchCard(
            title: 'Quizzes & exams',
            body: 'Choose a course, select topics, then start a quiz or timed exam.',
            cta: 'Open course quizzes',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => VuV2QuizzesExamsHubScreen(
                    session: widget.session,
                    progress: widget.progress,
                  ),
                ),
              );
            },
          ),
        ],
        if (_mode == 2) _ModeLaunchCard(
          title: 'Question bank',
          body:
              'Pick a course and topics, set difficulty, then practice unlimited sets.',
          cta: 'Open question bank',
          onTap: () => VuV2QuestionBankFlow.open(
            context: context,
            session: widget.session,
            progress: widget.progress,
          ),
        ),
        const SizedBox(height: 14),
        Material(
          color: VuV2Colors.card,
          borderRadius: BorderRadius.circular(VuV2Radii.lg),
          child: ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => VuV2PlannerScreen(
                    session: widget.session,
                    progress: widget.progress,
                  ),
                ),
              );
            },
            leading: const Icon(Icons.calendar_month_outlined, color: VuV2Colors.mint),
            title: const Text(
              'Study planner',
              style: TextStyle(
                color: VuV2Colors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(
              'Weekly slots · ${widget.progress.studyMinutes} min logged',
              style: const TextStyle(color: VuV2Colors.mute),
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: VuV2Colors.mute),
          ),
        ),
        const SizedBox(height: 12),
        VuV2Surface(
          child: Text(
            'XP ${widget.progress.lessonXp} · streak ${widget.progress.streakDays}d · '
            'mastery clears ${widget.progress.masteryClearStreak} · '
            '${widget.progress.completedLessonIds.length} lessons done',
            style: const TextStyle(color: VuV2Colors.mute, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? VuV2Colors.mint : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? VuV2Colors.mint : VuV2Colors.stroke,
            ),
          ),
          child: Column(
            children: <Widget>[
              Icon(
                icon,
                size: 18,
                color: selected ? const Color(0xFF04110C) : VuV2Colors.ink,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? const Color(0xFF04110C) : VuV2Colors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlashcardsPreview extends StatelessWidget {
  const _FlashcardsPreview({
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: VuV2Colors.card,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: VuV2Colors.stroke),
              ),
              child: const Text(
                'Card 1 / 15',
                style: TextStyle(
                  color: VuV2Colors.mute,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: VuV2Colors.mint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: VuV2Colors.mint.withValues(alpha: 0.5)),
              ),
              child: Text(
                session.majorLabel.toUpperCase().length > 10
                    ? session.majorId.toUpperCase().replaceAll('_', '-').substring(0, 7)
                    : session.majorLabel.toUpperCase(),
                style: const TextStyle(
                  color: VuV2Colors.mint,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 220),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: VuV2Colors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: VuV2Colors.stroke),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'TERM',
                style: TextStyle(
                  color: VuV2Colors.mint,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Phospholipid bilayer',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Click Start to flip real cards from your courses',
                textAlign: TextAlign.center,
                style: TextStyle(color: VuV2Colors.mute),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: <Widget>[
            Expanded(
              child: _NavBtn(
                icon: Icons.arrow_back_rounded,
                label: 'Prev',
                filled: false,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _NavBtn(
                icon: Icons.flip_rounded,
                label: 'Flip',
                filled: false,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _NavBtn(
                icon: Icons.arrow_forward_rounded,
                label: 'Start',
                filled: true,
                onTap: () => VuV2FlashcardsFlow.open(
                  context: context,
                  session: session,
                  progress: progress,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? VuV2Colors.mint : VuV2Colors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: filled ? VuV2Colors.mint : VuV2Colors.stroke),
          ),
          child: Column(
            children: <Widget>[
              Icon(
                icon,
                color: filled ? const Color(0xFF04110C) : VuV2Colors.ink,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: filled ? const Color(0xFF04110C) : VuV2Colors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeLaunchCard extends StatelessWidget {
  const _ModeLaunchCard({
    required this.title,
    required this.body,
    required this.cta,
    required this.onTap,
  });

  final String title;
  final String body;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return VuV2Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: VuV2Colors.mute, height: 1.45)),
          const SizedBox(height: 14),
          VuV2PrimaryButton(label: cta, trailingArrow: true, onPressed: onTap),
        ],
      ),
    );
  }
}
