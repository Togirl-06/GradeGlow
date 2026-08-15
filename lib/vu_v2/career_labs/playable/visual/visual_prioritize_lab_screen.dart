import 'package:flutter/material.dart';

import 'visual_lab_models.dart';
import 'visual_lab_shell.dart';

/// Drag items into ranked priority slots (1 Immediate → 4 Low).
class VisualPrioritizeLabScreen extends StatefulWidget {
  const VisualPrioritizeLabScreen({super.key, required this.spec});

  final VisualLabSpec spec;

  @override
  State<VisualPrioritizeLabScreen> createState() => _VisualPrioritizeLabScreenState();
}

class _VisualPrioritizeLabScreenState extends State<VisualPrioritizeLabScreen> {
  late List<PrioritizeItem> _pool;
  final Map<int, PrioritizeItem?> _ranks = <int, PrioritizeItem?>{
    1: null,
    2: null,
    3: null,
    4: null,
  };

  VisualLabSpec get spec => widget.spec;
  List<PrioritizeItem> get items =>
      spec.prioritizeItems ?? const <PrioritizeItem>[];

  static const List<String> _rankLabels = <String>[
    '',
    'Immediate',
    'High',
    'Moderate',
    'Low',
  ];

  @override
  void initState() {
    super.initState();
    _pool = List<PrioritizeItem>.from(items)..shuffle();
  }

  bool get _filled => _ranks.values.every((PrioritizeItem? i) => i != null);

  bool get _correct {
    for (final MapEntry<int, PrioritizeItem?> e in _ranks.entries) {
      if (e.value == null || e.value!.correctRank != e.key) return false;
    }
    return true;
  }

  Future<void> _submit() async {
    final bool passed = _filled && _correct;
    await showVisualLabResult(
      context: context,
      spec: spec,
      passed: passed,
      body: passed
          ? 'Priority order matches acuity. Board cleared.'
          : 'Order is off. Re-rank Immediate → Low by true urgency.',
    );
    if (passed && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return VisualLabShell(
      spec: spec,
      badgeLabel: 'PRIORITIZE',
      footer: visualPrimaryButton(
        accent: spec.accent,
        label: 'CONFIRM ORDER',
        onPressed: _filled ? _submit : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  for (int rank = 1; rank <= 4; rank++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: DragTarget<PrioritizeItem>(
                        onAcceptWithDetails: (DragTargetDetails<PrioritizeItem> d) {
                          setState(() {
                            // Remove from other ranks / pool
                            _ranks.updateAll(
                              (int k, PrioritizeItem? v) => v?.id == d.data.id ? null : v,
                            );
                            _pool.removeWhere((PrioritizeItem i) => i.id == d.data.id);
                            final PrioritizeItem? displaced = _ranks[rank];
                            if (displaced != null) _pool.add(displaced);
                            _ranks[rank] = d.data;
                          });
                        },
                        builder: (BuildContext context, List<PrioritizeItem?> pending, _) {
                          final PrioritizeItem? item = _ranks[rank];
                          final bool hot = pending.isNotEmpty;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: hot
                                  ? spec.accent.withValues(alpha: 0.25)
                                  : Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: hot
                                    ? spec.accent
                                    : spec.accent.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 36,
                                  height: 36,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: spec.accent.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$rank',
                                    style: TextStyle(
                                      color: spec.accent,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: item == null
                                      ? Text(
                                          'Drop → ${_rankLabels[rank]}',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.45),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      : Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              item.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            Text(
                                              item.subtitle,
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.6),
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                                Text(
                                  _rankLabels[rank],
                                  style: TextStyle(
                                    color: spec.accent.withValues(alpha: 0.85),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _pool.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (BuildContext context, int i) {
                  final PrioritizeItem item = _pool[i];
                  return Draggable<PrioritizeItem>(
                    data: item,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _card(item, glowing: true),
                    ),
                    childWhenDragging: Opacity(opacity: 0.25, child: _card(item)),
                    child: _card(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(PrioritizeItem item, {bool glowing = false}) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: glowing ? spec.accent : spec.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: spec.accent.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${item.glyph} ${item.title}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: glowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.acuity.isNotEmpty ? item.acuity : item.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: glowing ? Colors.black87 : Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
