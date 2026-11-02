import 'package:flutter/material.dart';

import 'law_case_data.dart';

/// Interactive case folder — open docs, tag evidence, build timeline.
class LawCaseFileScreen extends StatefulWidget {
  const LawCaseFileScreen({super.key, required this.intakeScore});

  final int intakeScore;

  @override
  State<LawCaseFileScreen> createState() => _LawCaseFileScreenState();
}

class _LawCaseFileScreenState extends State<LawCaseFileScreen> {
  final Map<String, LawEvidenceTag> _tags = <String, LawEvidenceTag>{};
  final List<String> _timeline = <String>[];
  String? _openDocId;
  bool _mayaAsk = false;
  final TextEditingController _why = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (final LawDocument d in LawCaseVault.documents) {
      _tags[d.id] = LawEvidenceTag.none;
    }
  }

  @override
  void dispose() {
    _why.dispose();
    super.dispose();
  }

  LawDocument? get _open {
    if (_openDocId == null) return null;
    for (final LawDocument d in LawCaseVault.documents) {
      if (d.id == _openDocId) return d;
    }
    return null;
  }

  int get _importantCount =>
      _tags.values.where((LawEvidenceTag t) => t == LawEvidenceTag.important).length;

  bool get _readyToFinish => _importantCount >= 3 && _timeline.length >= 3;

  void _tag(LawEvidenceTag tag) {
    final String? id = _openDocId;
    if (id == null) return;
    setState(() => _tags[id] = tag);
  }

  void _addToTimeline() {
    final LawDocument? d = _open;
    if (d == null) return;
    if (_timeline.contains(d.id)) return;
    setState(() => _timeline.add(d.id));
  }

  void _finish() {
    if (!_readyToFinish) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tag at least 3 Important items and place 3 on the timeline.'),
        ),
      );
      return;
    }
    final bool taggedEmail =
        _tags['email_wet'] == LawEvidenceTag.important;
    if (taggedEmail && !_mayaAsk) {
      setState(() => _mayaAsk = true);
      return;
    }
    _complete(withWhy: _why.text);
  }

  void _complete({required String withWhy}) {
    final bool goodWhy = withWhy.toLowerCase().contains('wet') ||
        withWhy.toLowerCase().contains('notice') ||
        withWhy.toLowerCase().contains('warn') ||
        withWhy.toLowerCase().contains('prior') ||
        withWhy.toLowerCase().contains('negligen');
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1510),
          title: const Text(
            'Maya Chen — Case file review',
            style: TextStyle(color: Color(0xFFD4A574), fontWeight: FontWeight.w800),
          ),
          content: Text(
            goodWhy || !_mayaAsk
                ? 'Good. You\'re treating this like evidence, not homework. '
                    'Next: legal research in the library.\n\n'
                    'Intake carried forward: ${widget.intakeScore}/100'
                : 'You tagged the wet-floor email but your explanation was thin. '
                    'Prior notice is the heart of the negligence theory — remember that.\n\n'
                    'Research desk is next.',
            style: const TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD4A574),
                foregroundColor: Colors.black,
              ),
              child: const Text('Return to firm', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final LawDocument? open = _open;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0A08),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'EVIDENCE ROOM',
                          style: TextStyle(
                            color: Color(0xFFD4A574),
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          LawCaseVault.caseCaption,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_mayaAsk)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text(
                        'Maya Chen',
                        style: TextStyle(
                          color: Color(0xFFD4A574),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '“Why did you consider the wet-floor email important?”',
                        style: TextStyle(color: Colors.white, fontSize: 18, height: 1.35),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _why,
                        minLines: 3,
                        maxLines: 5,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Explain your reasoning…',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                          filled: true,
                          fillColor: const Color(0xFF161310),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () => _complete(withWhy: _why.text),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFD4A574),
                          foregroundColor: Colors.black,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text(
                          'Answer Maya',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (open == null) ...<Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Open each document. Tag it. Drag key events onto the timeline.\n'
                  'Progress: $_importantCount/3 important · ${_timeline.length}/3 timeline',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: <Widget>[
                    ...LawCaseVault.documents.map((LawDocument d) {
                      final LawEvidenceTag tag = _tags[d.id] ?? LawEvidenceTag.none;
                      final bool onTl = _timeline.contains(d.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: const Color(0xFF161310),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() => _openDocId = d.id),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: <Widget>[
                                  Text(_kindGlyph(d.kind), style: const TextStyle(fontSize: 22)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          d.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          '${_tagLabel(tag)}${onTl ? ' · on timeline' : ''}',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.45),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: Colors.white38),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    const Text(
                      'TIMELINE',
                      style: TextStyle(
                        color: Color(0xFFD4A574),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_timeline.isEmpty)
                      Text(
                        'No events yet — open a document and add it.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                      )
                    else
                      ..._timeline.map((String id) {
                        final LawDocument d = LawCaseVault.documents
                            .firstWhere((LawDocument x) => x.id == id);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: const Color(0xFFD4A574).withValues(alpha: 0.8),
                                width: 3,
                              ),
                            ),
                            color: const Color(0xFF12100E),
                          ),
                          child: Text(
                            d.timelineHint,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        );
                      }),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _finish,
                      style: FilledButton.styleFrom(
                        backgroundColor: _readyToFinish
                            ? const Color(0xFFD4A574)
                            : Colors.white12,
                        foregroundColor: _readyToFinish ? Colors.black : Colors.white38,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text(
                        'Submit case file to Maya',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ] else ...<Widget>[
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: <Widget>[
                    Text(
                      open.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161310),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2E261F)),
                      ),
                      child: Text(
                        open.body,
                        style: const TextStyle(
                          color: Colors.white,
                          height: 1.5,
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'MARK EVIDENCE',
                      style: TextStyle(
                        color: Color(0xFFD4A574),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _tagChip('Important', LawEvidenceTag.important),
                        _tagChip('Irrelevant', LawEvidenceTag.irrelevant),
                        _tagChip('Needs verification', LawEvidenceTag.needsVerification),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _addToTimeline,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD4A574),
                        side: const BorderSide(color: Color(0xFFD4A574)),
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: Text(
                        _timeline.contains(open.id)
                            ? 'Already on timeline'
                            : 'Add to timeline — ${open.timelineHint}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => setState(() => _openDocId = null),
                      child: const Text('Back to folder'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tagChip(String label, LawEvidenceTag tag) {
    final bool selected = _openDocId != null && _tags[_openDocId!] == tag;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => _tag(tag),
      selectedColor: const Color(0xFFD4A574),
      labelStyle: TextStyle(
        color: selected ? Colors.black : Colors.white70,
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: const Color(0xFF161310),
    );
  }

  String _kindGlyph(LawDocKind k) {
    switch (k) {
      case LawDocKind.report:
        return '📄';
      case LawDocKind.contract:
        return '📜';
      case LawDocKind.email:
        return '✉️';
      case LawDocKind.statement:
        return '🗣️';
      case LawDocKind.photo:
        return '📷';
      case LawDocKind.medical:
        return '🏥';
      case LawDocKind.note:
        return '📝';
    }
  }

  String _tagLabel(LawEvidenceTag t) {
    switch (t) {
      case LawEvidenceTag.none:
        return 'Untagged';
      case LawEvidenceTag.important:
        return 'Important';
      case LawEvidenceTag.irrelevant:
        return 'Irrelevant';
      case LawEvidenceTag.needsVerification:
        return 'Needs verification';
    }
  }
}
