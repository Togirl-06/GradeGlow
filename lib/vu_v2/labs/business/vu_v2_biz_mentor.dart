import 'package:flutter/material.dart';

import 'vu_v2_biz_company_state.dart';
import 'vu_v2_biz_decision_engine.dart';
import 'vu_v2_biz_department_catalog.dart';
import 'vu_v2_biz_theme.dart';

class VuV2BizMentorPanel extends StatefulWidget {
  const VuV2BizMentorPanel({
    super.key,
    required this.company,
    this.compact = false,
    this.pulse = false,
  });

  final VuV2BizCompanyState company;
  final bool compact;
  final bool pulse;

  @override
  State<VuV2BizMentorPanel> createState() => _VuV2BizMentorPanelState();
}

class _VuV2BizMentorPanelState extends State<VuV2BizMentorPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  String _mode = 'advice';
  String _message = '';

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.pulse) {
      _pulse.repeat(reverse: true);
    }
    _message = VuV2BizDecisionEngine.mentorAdvice(widget.company);
  }

  @override
  void didUpdateWidget(covariant VuV2BizMentorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.pulse && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
    if (oldWidget.company.currentChallenge != widget.company.currentChallenge ||
        oldWidget.company.cash != widget.company.cash ||
        oldWidget.company.styleAdHeavy != widget.company.styleAdHeavy) {
      if (_mode == 'advice') {
        setState(() {
          _message = VuV2BizDecisionEngine.mentorAdvice(widget.company);
        });
      }
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _setMode(String mode) {
    setState(() {
      _mode = mode;
      if (mode == 'advice') {
        _message = VuV2BizDecisionEngine.mentorAdvice(widget.company);
      } else if (mode == 'explain') {
        _message =
            'Pattern coaching: ${widget.company.decisionStyleSummary} '
            'Look at acquisition vs retention and quality vs speed — those habits compound across courses.';
      } else if (mode == 'teach') {
        _message =
            'The lab loop is Brief → Decide → Consequence → Debrief → Next. '
            'Grades on soft skills use a visible rubric (clarity, tone, concessions, prep) — '
            'not a black-box vibe check.';
      } else if (mode == 'example') {
        _message =
            'Example: cut social ads 50% → profit up this month, awareness fell, '
            'next-quarter sales −9%. Balance cost cuts with pipeline health.';
      } else {
        _message =
            'Practice: Competitor undercuts 20%. Match, differentiate, or niche upmarket — '
            'justify with one KPI from YOUR books.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget avatar = ScaleTransition(
      scale: Tween<double>(begin: 1, end: widget.pulse ? 1.06 : 1).animate(
        CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: <Color>[VuV2BizColors.royal, VuV2BizColors.emerald],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: VuV2BizColors.royal.withValues(alpha: 0.35),
              blurRadius: 12,
            ),
          ],
        ),
        child: const Icon(Icons.psychology_alt, color: Colors.white),
      ),
    );

    return VuV2BizGlassCard(
      borderColor: VuV2BizColors.royal.withValues(alpha: 0.5),
      glowColor: VuV2BizColors.royal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              avatar,
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'AI CEO Mentor',
                      style: TextStyle(
                        color: VuV2BizColors.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Remembers your decision style — not just KPIs.',
                      style: TextStyle(
                        color: VuV2BizColors.mute,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _mode == 'advice' ? "Today's coaching" : _modeLabel(_mode),
            style: const TextStyle(
              color: VuV2BizColors.gold,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _message,
            style: const TextStyle(
              color: VuV2BizColors.ink,
              height: 1.45,
              fontSize: 13.5,
            ),
          ),
          if (!widget.compact) ...<Widget>[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _chip('Advice', 'advice'),
                _chip('Explain', 'explain'),
                _chip('Teach', 'teach'),
                _chip('Example', 'example'),
                _chip('Practice', 'practice'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _modeLabel(String mode) {
    if (mode == 'explain') return 'Style memory';
    if (mode == 'teach') return 'Executive lesson';
    if (mode == 'example') return 'Worked example';
    return 'Practice drill';
  }

  Widget _chip(String label, String mode) {
    final bool on = _mode == mode;
    return InkWell(
      onTap: () => _setMode(mode),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: on
              ? VuV2BizColors.royal.withValues(alpha: 0.25)
              : Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: on ? VuV2BizColors.royal : VuV2BizColors.stroke,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: on ? VuV2BizColors.ink : VuV2BizColors.mute,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/// Full loop: Brief → Consequence → Debrief → Next challenge.
Future<VuV2BizRoomId?> showBizLoopDialog(
  BuildContext context, {
  required VuV2BizCompanyState company,
  required VuV2BizOutcome outcome,
}) {
  return showDialog<VuV2BizRoomId?>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return Dialog(
        backgroundColor: VuV2BizColors.elevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VuV2BizRadii.lg),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Consequence',
                  style: TextStyle(
                    color: VuV2BizColors.gold,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  outcome.title,
                  style: const TextStyle(
                    color: VuV2BizColors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                if (outcome.brief.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: VuV2BizColors.midnight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: VuV2BizColors.stroke),
                    ),
                    child: Text(
                      'Brief recalled: ${outcome.brief}',
                      style: const TextStyle(
                        color: VuV2BizColors.mute,
                        height: 1.4,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  outcome.narrative,
                  style: const TextStyle(
                    color: VuV2BizColors.ink,
                    height: 1.45,
                  ),
                ),
                if (outcome.rubric != null) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(
                    'Visible rubric · ${outcome.rubric!.total}/${outcome.rubric!.maxTotal}',
                    style: const TextStyle(
                      color: VuV2BizColors.emerald,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (int i = 0; i < outcome.rubric!.criteria.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _RubricRow(c: outcome.rubric!.criteria[i]),
                    ),
                ],
                const SizedBox(height: 14),
                VuV2BizGlassCard(
                  borderColor: VuV2BizColors.royal.withValues(alpha: 0.45),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Mentor debrief',
                        style: TextStyle(
                          color: VuV2BizColors.royal,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        outcome.debriefPrompt.isNotEmpty
                            ? outcome.debriefPrompt
                            : VuV2BizDecisionEngine.mentorAdvice(company),
                        style: const TextStyle(
                          color: VuV2BizColors.ink,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        company.decisionStyleSummary,
                        style: const TextStyle(
                          color: VuV2BizColors.mute,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Next: ${VuV2BizDecisionEngine.nextChallengeHint(company)}',
                  style: const TextStyle(
                    color: VuV2BizColors.warning,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () {
                    if (company.crisisInterruptActive) {
                      Navigator.pop(ctx, VuV2BizRoomId.crisis);
                    } else {
                      Navigator.pop(ctx, null);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: company.crisisInterruptActive
                        ? VuV2BizColors.danger
                        : VuV2BizColors.royal,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    company.crisisInterruptActive
                        ? 'Crisis interrupt — enter Crisis Center'
                        : 'Next challenge',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _RubricRow extends StatelessWidget {
  const _RubricRow({required this.c});
  final VuV2BizRubricCriterion c;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                c.label,
                style: const TextStyle(
                  color: VuV2BizColors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              '${c.score}/${c.maxScore}',
              style: const TextStyle(
                color: VuV2BizColors.gold,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: c.maxScore == 0 ? 0 : c.score / c.maxScore,
          minHeight: 6,
          borderRadius: BorderRadius.circular(6),
          color: VuV2BizColors.emerald,
          backgroundColor: VuV2BizColors.stroke,
        ),
        const SizedBox(height: 4),
        Text(
          c.note,
          style: const TextStyle(
            color: VuV2BizColors.mute,
            fontSize: 12,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

/// Back-compat wrapper used by rooms.
Future<void> showBizOutcomeDialog(
  BuildContext context,
  VuV2BizOutcome outcome, {
  VuV2BizCompanyState? company,
  void Function(VuV2BizRoomId room)? onNavigate,
}) async {
  final VuV2BizCompanyState c = company ?? VuV2BizCompanyState();
  final VuV2BizRoomId? next = await showBizLoopDialog(
    context,
    company: c,
    outcome: outcome,
  );
  if (next != null && onNavigate != null) {
    onNavigate(next);
  }
}
