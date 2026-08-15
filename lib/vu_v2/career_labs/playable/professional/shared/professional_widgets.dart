import 'package:flutter/material.dart';

import 'professional_theme.dart';

/// Drag-free evidence board: tap chips to pin evidence, connect reasoning.
class ProEvidenceBoard extends StatelessWidget {
  const ProEvidenceBoard({
    super.key,
    required this.theme,
    required this.available,
    required this.pinned,
    required this.onToggle,
    this.title = 'EVIDENCE BOARD',
  });

  final ProSimTheme theme;
  final List<String> available;
  final List<String> pinned;
  final ValueChanged<String> onToggle;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: theme.accent,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: available.map((String e) {
              final bool on = pinned.contains(e);
              return FilterChip(
                selected: on,
                label: Text(e, style: const TextStyle(fontSize: 11)),
                onSelected: (_) => onToggle(e),
                selectedColor: theme.accent,
                checkmarkColor: Colors.black,
                backgroundColor: const Color(0xFF1A2438),
                labelStyle: TextStyle(
                  color: on ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList(),
          ),
          if (pinned.length >= 2) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              pinned.join('  →  '),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Consequence panel after RUN simulation.
class ProConsequencePanel extends StatelessWidget {
  const ProConsequencePanel({
    super.key,
    required this.theme,
    required this.title,
    required this.deltas,
    required this.interpretation,
  });

  final ProSimTheme theme;
  final String title;
  final Map<String, String> deltas;
  final String interpretation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.accent.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: theme.accent,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          ...deltas.entries.map(
            (MapEntry<String, String> e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      e.key,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  Text(
                    e.value,
                    style: TextStyle(
                      color: e.value.startsWith('-')
                          ? const Color(0xFFF87171)
                          : theme.accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            interpretation,
            style: const TextStyle(color: Colors.white60, height: 1.35, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Shared dark card chrome for mission workspaces.
class ProPanel extends StatelessWidget {
  const ProPanel({
    super.key,
    required this.theme,
    required this.title,
    required this.child,
    this.flex,
  });

  final ProSimTheme theme;
  final String title;
  final Widget child;
  final int? flex;

  @override
  Widget build(BuildContext context) {
    final Widget box = Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: theme.accent,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: child),
        ],
      ),
    );
    if (flex != null) return Expanded(flex: flex!, child: box);
    return box;
  }
}

/// Simple single-select list (avoids deprecated RadioListTile APIs).
class ProSelectList extends StatelessWidget {
  const ProSelectList({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    required this.accent,
  });

  final List<String> options;
  final String? value;
  final ValueChanged<String> onChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((String o) {
        final bool on = value == o;
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: InkWell(
            onTap: () => onChanged(o),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: on ? accent.withValues(alpha: 0.16) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: on ? accent : Colors.white12),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    on ? Icons.check_circle : Icons.circle_outlined,
                    size: 16,
                    color: on ? accent : Colors.white38,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      o,
                      style: TextStyle(
                        color: on ? accent : Colors.white70,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
