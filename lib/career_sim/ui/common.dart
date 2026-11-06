import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../vu_v2/design/vu_v2_theme.dart';
import '../ai/career_ai.dart';
import '../model/career_models.dart';
import '../store/career_sim_store.dart';

CareerSimStore careerStore(BuildContext context, {bool listen = false}) =>
    Provider.of<CareerSimStore>(context, listen: listen);

/// Runs a store action with a loading state, a success message and the
/// rule's own error message. Returns the value, or null on failure.
Future<T?> runCareerAction<T>(
  BuildContext context,
  Future<T> Function() action, {
  String? success,
}) async {
  final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final T value = await action();
    if (success != null) {
      messenger?.showSnackBar(SnackBar(content: Text(success)));
    }
    return value;
  } on CareerActionException catch (e) {
    messenger?.showSnackBar(SnackBar(content: Text(e.message), backgroundColor: VuV2Colors.danger));
    return null;
  } catch (e) {
    messenger?.showSnackBar(SnackBar(content: Text('Something went wrong: $e'), backgroundColor: VuV2Colors.danger));
    return null;
  }
}

/// A button that disables itself and shows a spinner while [onPressed] runs.
class BusyButton extends StatefulWidget {
  const BusyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.tonal = false,
    this.outlined = false,
  });

  final String label;
  final Future<void> Function()? onPressed;
  final IconData? icon;
  final bool tonal;
  final bool outlined;

  @override
  State<BusyButton> createState() => _BusyButtonState();
}

class _BusyButtonState extends State<BusyButton> {
  bool _busy = false;

  Future<void> _go() async {
    final Future<void> Function()? f = widget.onPressed;
    if (f == null || _busy) return;
    setState(() => _busy = true);
    try {
      await f();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final VoidCallback? tap = widget.onPressed == null || _busy ? null : _go;
    final Widget child = _busy
        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
        : Text(widget.label);
    final Widget icon = _busy ? const SizedBox.shrink() : Icon(widget.icon ?? Icons.arrow_forward_rounded, size: 18);
    if (widget.outlined) {
      return widget.icon == null
          ? OutlinedButton(onPressed: tap, child: child)
          : OutlinedButton.icon(onPressed: tap, icon: icon, label: child);
    }
    if (widget.tonal) {
      return widget.icon == null
          ? FilledButton.tonal(onPressed: tap, child: child)
          : FilledButton.tonalIcon(onPressed: tap, icon: icon, label: child);
    }
    return widget.icon == null
        ? FilledButton(onPressed: tap, child: child)
        : FilledButton.icon(onPressed: tap, icon: icon, label: child);
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, required this.child, this.trailing, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: VuV2Colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VuV2Radii.lg),
        side: BorderSide(color: VuV2Colors.stroke),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800, fontSize: 16)),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(subtitle!, style: TextStyle(color: VuV2Colors.mute, fontSize: 12.5)),
                        ),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key, this.color});
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 11.5)),
    );
  }
}

Color statusColor(ApplicationStatus s) => switch (s) {
      ApplicationStatus.hired || ApplicationStatus.offerReceived => VuV2Colors.success,
      ApplicationStatus.rejected || ApplicationStatus.withdrawn || ApplicationStatus.offerDeclined => VuV2Colors.danger,
      ApplicationStatus.shortlisted || ApplicationStatus.interviewScheduled || ApplicationStatus.interviewCompleted =>
        const Color(0xFF3B82F6),
      ApplicationStatus.furtherAssessment => const Color(0xFFF59E0B),
      _ => VuV2Colors.mute,
    };

/// Marks content as coming from the validated rule (not AI).
class ValidatedBadge extends StatelessWidget {
  const ValidatedBadge({super.key, this.label = 'Validated score'});
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.verified_rounded, size: 16, color: VuV2Colors.success),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: VuV2Colors.success, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      );
}

class LabeledBar extends StatelessWidget {
  const LabeledBar({super.key, required this.label, required this.value, this.detail});
  final String label;

  /// 0–100.
  final int value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(label, style: TextStyle(color: VuV2Colors.ink, fontSize: 13))),
              Text('$value', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (value.clamp(0, 100)) / 100,
              minHeight: 7,
              backgroundColor: VuV2Colors.stroke,
            ),
          ),
          if (detail != null)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(detail!, style: TextStyle(color: VuV2Colors.mute, fontSize: 11.5)),
            ),
        ],
      ),
    );
  }
}

class BulletList extends StatelessWidget {
  const BulletList(this.items, {super.key, this.icon = Icons.chevron_right_rounded, this.color});
  final List<String> items;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final String s in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(icon, size: 16, color: color ?? VuV2Colors.mute),
                  const SizedBox(width: 6),
                  Expanded(child: Text(s, style: TextStyle(color: VuV2Colors.ink, fontSize: 13.5, height: 1.35))),
                ],
              ),
            ),
        ],
      );
}

String money(int amount, String period) {
  if (amount == 0) return 'Unpaid placement';
  final String s = amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (Match m) => '${m[1]},');
  return '\$$s / ${period == 'hour' ? 'hour' : period} (virtual USD)';
}

/// AI help that is clearly separated from grading.
class AiAssistPanel extends StatefulWidget {
  const AiAssistPanel({super.key, required this.role, required this.contextText, this.suggestion = ''});

  final CareerAiRole role;
  final String contextText;
  final String suggestion;

  @override
  State<AiAssistPanel> createState() => _AiAssistPanelState();
}

class _AiAssistPanelState extends State<AiAssistPanel> {
  final TextEditingController _q = TextEditingController();
  String? _reply;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _q.text = widget.suggestion;
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final String q = _q.text.trim();
    if (q.isEmpty) {
      setState(() => _error = 'Type a question first.');
      return;
    }
    final CareerAi? ai = careerStore(context).ai;
    if (ai == null) {
      setState(() => _error = 'The AI assistant is not available right now.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final String r = await ai.ask(role: widget.role, context: widget.contextText, question: q);
      if (mounted) setState(() => _reply = r);
    } catch (e) {
      if (mounted) setState(() => _error = 'AI assistant unavailable: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VuV2Radii.md),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.5)),
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.06),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.auto_awesome_rounded, size: 16, color: Color(0xFF8B5CF6)),
              const SizedBox(width: 6),
              Expanded(
                child: Text('${widget.role.label} — guidance only, never part of your score',
                    style: const TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey<String>('ai_question'),
            controller: _q,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(isDense: true, hintText: 'Ask for an explanation or a hint', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _ask,
              icon: _busy
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send_rounded, size: 16),
              label: const Text('Ask'),
            ),
          ),
          if (_error != null) Text(_error!, style: const TextStyle(color: VuV2Colors.danger, fontSize: 12.5)),
          if (_reply != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: SelectableText(_reply!, style: TextStyle(color: VuV2Colors.ink, fontSize: 13.5, height: 1.4)),
            ),
        ],
      ),
    );
  }
}
