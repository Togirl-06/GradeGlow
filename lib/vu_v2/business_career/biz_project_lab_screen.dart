import 'package:flutter/material.dart';

import 'biz_career_center_screen.dart';
import 'business_career_progress.dart';
import 'business_career_theme.dart';

/// Project Lab — build portfolio projects that unlock Career Center applies.
class BizProjectLabScreen extends StatefulWidget {
  const BizProjectLabScreen({super.key, required this.progress});

  final BusinessCareerProgress progress;

  @override
  State<BizProjectLabScreen> createState() => _BizProjectLabScreenState();
}

class _BizProjectLabScreenState extends State<BizProjectLabScreen> {
  @override
  void initState() {
    super.initState();
    widget.progress.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.progress.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  Future<void> _editProject({Map<String, dynamic>? existing}) async {
    final Map<String, dynamic>? saved =
        await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BizCosmic.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext ctx) => _ProjectEditorSheet(existing: existing),
    );
    if (saved == null) return;
    final String? id = existing?['id']?.toString();
    if (id != null && id.isNotEmpty) {
      await widget.progress.removePortfolioProject(id);
    }
    await widget.progress.addPortfolioProject(
      title: '${saved['title']}',
      summary: '${saved['summary']}',
      skills: List<String>.from(saved['skills'] as List? ?? const <String>[]),
    );
  }

  Future<void> _delete(String id) async {
    await widget.progress.removePortfolioProject(id);
  }

  @override
  Widget build(BuildContext context) {
    final BusinessCareerProgress p = widget.progress;
    final List<dynamic> projects = p.portfolioProjects;
    final bool ready = p.resumeReadyToApply;

    return Scaffold(
      backgroundColor: BizCosmic.bg,
      appBar: BizCosmic.appBar(
        context: context,
        title: 'Project Lab',
        icon: Icons.folder_special_rounded,
      ),
      body: BizStarfield(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BizCosmic.panelBox(radius: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Résumé strength',
                    style: TextStyle(
                      color: BizCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      BizCosmic.pill(
                        'Score ${p.resumeScore}/100',
                        bg: ready
                            ? BizCosmic.success.withValues(alpha: 0.2)
                            : BizCosmic.warning.withValues(alpha: 0.18),
                        fg: ready ? BizCosmic.success : BizCosmic.warning,
                      ),
                      const SizedBox(width: 8),
                      BizCosmic.pill('${projects.length} projects'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ready
                        ? 'Ready to apply — open Career Center when you are.'
                        : 'Add a project or raise score to 40+ to unlock Apply.',
                    style: const TextStyle(
                      color: BizCosmic.mute,
                      height: 1.35,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              BizCareerCenterScreen(progress: p),
                        ),
                      );
                    },
                    icon: const Icon(Icons.work_outline_rounded),
                    label: const Text('Open Career Center'),
                    style: FilledButton.styleFrom(
                      backgroundColor: BizCosmic.emerald,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(46),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Portfolio projects',
                    style: TextStyle(
                      color: BizCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _editProject(),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                  style: FilledButton.styleFrom(
                    foregroundColor: BizCosmic.ink,
                    backgroundColor: BizCosmic.panelAlt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (projects.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BizCosmic.panelBox(radius: 14),
                child: const Text(
                  'No projects yet. Add a title, short summary, and a few skills.',
                  style: TextStyle(color: BizCosmic.mute, height: 1.35),
                ),
              )
            else
              ...projects.map((dynamic raw) {
                final Map<String, dynamic>? m = _asMap(raw);
                if (m == null) return const SizedBox.shrink();
                final String id = '${m['id'] ?? ''}';
                final List<String> skills = List<String>.from(
                  m['skills'] as List? ?? const <String>[],
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BizCosmic.panelBox(radius: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                '${m['title'] ?? 'Untitled'}',
                                style: const TextStyle(
                                  color: BizCosmic.ink,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: () => _editProject(existing: m),
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: BizCosmic.mute,
                                size: 20,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: id.isEmpty ? null : () => _delete(id),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: BizCosmic.danger,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${m['summary'] ?? ''}',
                          style: const TextStyle(
                            color: BizCosmic.mute,
                            height: 1.35,
                            fontSize: 13,
                          ),
                        ),
                        if (skills.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: skills
                                .map((String s) => BizCosmic.pill(s))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _ProjectEditorSheet extends StatefulWidget {
  const _ProjectEditorSheet({this.existing});

  final Map<String, dynamic>? existing;

  @override
  State<_ProjectEditorSheet> createState() => _ProjectEditorSheetState();
}

class _ProjectEditorSheetState extends State<_ProjectEditorSheet> {
  late final TextEditingController _title;
  late final TextEditingController _summary;
  late final TextEditingController _skills;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic>? e = widget.existing;
    _title = TextEditingController(text: '${e?['title'] ?? ''}');
    _summary = TextEditingController(text: '${e?['summary'] ?? ''}');
    final List<String> skills = List<String>.from(
      e?['skills'] as List? ?? const <String>[],
    );
    _skills = TextEditingController(text: skills.join(', '));
  }

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    _skills.dispose();
    super.dispose();
  }

  void _save() {
    final String title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a project title.')),
      );
      return;
    }
    final List<String> skills = _skills.text
        .split(',')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();
    Navigator.of(context).pop(<String, dynamic>{
      'title': title,
      'summary': _summary.text.trim(),
      'skills': skills,
    });
  }

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: BizCosmic.stroke,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              widget.existing == null ? 'Add project' : 'Edit project',
              style: const TextStyle(
                color: BizCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              style: const TextStyle(color: BizCosmic.ink),
              decoration: _dec('Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _summary,
              maxLines: 4,
              style: const TextStyle(color: BizCosmic.ink),
              decoration: _dec('Summary'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _skills,
              style: const TextStyle(color: BizCosmic.ink),
              decoration: _dec('Skills (comma-separated)'),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: BizCosmic.emerald,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Save project'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: BizCosmic.mute),
      filled: true,
      fillColor: BizCosmic.panelAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
