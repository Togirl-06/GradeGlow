import 'package:flutter/material.dart';

import 'science_badges.dart';
import 'science_lab_theme.dart';
import 'science_notebook_store.dart';

/// Shared lab notebook: Notes | Diagrams | Experiments | Data | Graphs | Conclusions | Completed.
class ScienceNotebookScreen extends StatefulWidget {
  const ScienceNotebookScreen({
    super.key,
    required this.theme,
    required this.store,
  });

  final ScienceLabTheme theme;
  final ScienceNotebookStore store;

  @override
  State<ScienceNotebookScreen> createState() => _ScienceNotebookScreenState();
}

class _ScienceNotebookScreenState extends State<ScienceNotebookScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _ready = false;

  ScienceLabTheme get t => widget.theme;
  ScienceNotebookStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 7, vsync: this);
    _boot();
  }

  Future<void> _boot() async {
    await store.ensureLoaded();
    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _addNote() async {
    final String? text = await _prompt('Add note', 'Observation or reminder…');
    if (text == null) return;
    await store.addNote(text);
    setState(() {});
  }

  Future<void> _addConclusion() async {
    final String? text =
        await _prompt('Add conclusion', 'What does the evidence support?');
    if (text == null) return;
    await store.addConclusion(text);
    setState(() {});
  }

  Future<void> _addExperiment() async {
    final ExperimentEntry? entry = await showDialog<ExperimentEntry>(
      context: context,
      builder: (BuildContext ctx) => _ExperimentEditorDialog(theme: t),
    );
    if (entry == null) return;
    await store.addExperiment(entry);
    setState(() {});
  }

  Future<String?> _prompt(String title, String hint) async {
    final TextEditingController ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: t.surface,
          title: Text(title, style: TextStyle(color: t.accent)),
          content: TextField(
            controller: ctrl,
            maxLines: 4,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: Text('Save', style: TextStyle(color: t.accent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.surface,
        foregroundColor: Colors.white,
        title: Text('${t.emoji} Lab Notebook'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          indicatorColor: t.accent,
          labelColor: t.accent,
          unselectedLabelColor: Colors.white54,
          tabs: const <Widget>[
            Tab(text: 'Notes'),
            Tab(text: 'Diagrams'),
            Tab(text: 'Experiments'),
            Tab(text: 'Data'),
            Tab(text: 'Graphs'),
            Tab(text: 'Conclusions'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      floatingActionButton: !_ready
          ? null
          : FloatingActionButton.extended(
              backgroundColor: t.accent,
              foregroundColor: Colors.black,
              onPressed: () {
                switch (_tabs.index) {
                  case 0:
                    _addNote();
                  case 2:
                    _addExperiment();
                  case 5:
                    _addConclusion();
                  default:
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Add from the active experiment or diagram tools.',
                        ),
                      ),
                    );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
      body: !_ready
          ? Center(child: CircularProgressIndicator(color: t.accent))
          : Column(
              children: <Widget>[
                _XpStrip(theme: t, store: store),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: <Widget>[
                      _StringListPane(
                        theme: t,
                        items: store.notes,
                        empty: 'No notes yet. Capture observations as you work.',
                      ),
                      _MapListPane(
                        theme: t,
                        items: store.diagrams,
                        titleKey: 'title',
                        empty: 'No saved diagrams yet.',
                      ),
                      _ExperimentsPane(theme: t, experiments: store.experiments),
                      _MapListPane(
                        theme: t,
                        items: store.dataTables,
                        titleKey: 'title',
                        empty: 'No data tables saved.',
                      ),
                      _MapListPane(
                        theme: t,
                        items: store.graphsMeta,
                        titleKey: 'title',
                        empty: 'No graph metadata yet.',
                      ),
                      _StringListPane(
                        theme: t,
                        items: store.conclusions,
                        empty: 'No conclusions written yet.',
                      ),
                      _StringListPane(
                        theme: t,
                        items: store.completedWorkIds.toList(),
                        empty: 'No completed work yet.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _XpStrip extends StatelessWidget {
  const _XpStrip({required this.theme, required this.store});

  final ScienceLabTheme theme;
  final ScienceNotebookStore store;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          bottom: BorderSide(color: theme.accent.withValues(alpha: 0.25)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _StatPill(label: 'XP', value: '${store.xp}', color: theme.accent),
              const SizedBox(width: 8),
              _StatPill(
                label: 'Coins',
                value: '${store.labCoins}',
                color: const Color(0xFFFBBF24),
              ),
              const Spacer(),
              Text(
                '${store.badges.length} badges',
                style: TextStyle(
                  color: theme.accent.withValues(alpha: 0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (store.badges.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: store.badges
                  .map(
                    (String id) => ScienceBadgeChip(
                      badgeId: id,
                      accent: theme.accent,
                      compact: true,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StringListPane extends StatelessWidget {
  const _StringListPane({
    required this.theme,
    required this.items,
    required this.empty,
  });

  final ScienceLabTheme theme;
  final List<String> items;
  final String empty;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _Empty(theme: theme, message: empty);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int i) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.accent.withValues(alpha: 0.2)),
          ),
          child: Text(items[i], style: const TextStyle(color: Colors.white)),
        );
      },
    );
  }
}

class _MapListPane extends StatelessWidget {
  const _MapListPane({
    required this.theme,
    required this.items,
    required this.titleKey,
    required this.empty,
  });

  final ScienceLabTheme theme;
  final List<Map<String, dynamic>> items;
  final String titleKey;
  final String empty;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _Empty(theme: theme, message: empty);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int i) {
        final Map<String, dynamic> m = items[i];
        final String title = '${m[titleKey] ?? 'Entry ${i + 1}'}';
        final String subtitle = m['at']?.toString() ?? '';
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.accent.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: theme.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle.isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ExperimentsPane extends StatelessWidget {
  const _ExperimentsPane({required this.theme, required this.experiments});

  final ScienceLabTheme theme;
  final List<ExperimentEntry> experiments;

  @override
  Widget build(BuildContext context) {
    if (experiments.isEmpty) {
      return _Empty(
        theme: theme,
        message: 'No experiments yet. Log question, hypothesis, and results.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: experiments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int i) {
        final ExperimentEntry e = experiments[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.accent.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                e.question.isEmpty ? 'Experiment ${i + 1}' : e.question,
                style: TextStyle(
                  color: theme.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              if (e.hypothesis.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  'H: ${e.hypothesis}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
              if (e.independent.isNotEmpty || e.dependent.isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  'IV: ${e.independent}  ·  DV: ${e.dependent}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
              if (e.conclusion.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  e.conclusion,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.theme, required this.message});

  final ScienceLabTheme theme;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: theme.accent.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}

class _ExperimentEditorDialog extends StatefulWidget {
  const _ExperimentEditorDialog({required this.theme});

  final ScienceLabTheme theme;

  @override
  State<_ExperimentEditorDialog> createState() =>
      _ExperimentEditorDialogState();
}

class _ExperimentEditorDialogState extends State<_ExperimentEditorDialog> {
  final TextEditingController question = TextEditingController();
  final TextEditingController hypothesis = TextEditingController();
  final TextEditingController independent = TextEditingController();
  final TextEditingController dependent = TextEditingController();
  final TextEditingController controls = TextEditingController();
  final TextEditingController procedure = TextEditingController();
  final TextEditingController observations = TextEditingController();
  final TextEditingController data = TextEditingController();
  final TextEditingController conclusion = TextEditingController();

  @override
  void dispose() {
    question.dispose();
    hypothesis.dispose();
    independent.dispose();
    dependent.dispose();
    controls.dispose();
    procedure.dispose();
    observations.dispose();
    data.dispose();
    conclusion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScienceLabTheme t = widget.theme;
    return AlertDialog(
      backgroundColor: t.surface,
      title: Text('New experiment', style: TextStyle(color: t.accent)),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _field('Question', question),
              _field('Hypothesis', hypothesis),
              _field('Independent variable (IV)', independent),
              _field('Dependent variable (DV)', dependent),
              _field('Controls', controls),
              _field('Procedure', procedure, lines: 3),
              _field('Observations', observations, lines: 3),
              _field('Data', data, lines: 3),
              _field('Conclusion', conclusion, lines: 3),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              ExperimentEntry(
                id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
                question: question.text.trim(),
                hypothesis: hypothesis.text.trim(),
                independent: independent.text.trim(),
                dependent: dependent.text.trim(),
                controls: controls.text.trim(),
                procedure: procedure.text.trim(),
                observations: observations.text.trim(),
                data: data.text.trim(),
                conclusion: conclusion.text.trim(),
              ),
            );
          },
          child: Text('Save', style: TextStyle(color: t.accent)),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController c, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        maxLines: lines,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: widget.theme.accent.withValues(alpha: 0.8)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: widget.theme.accent.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }
}
