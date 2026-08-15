import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Minimal Code Bench editor — language picker + code area (Flutter web safe).
class VuV2VsCodeEditor extends StatefulWidget {
  const VuV2VsCodeEditor({
    super.key,
    required this.controller,
    required this.languageLabel,
    required this.languageId,
    required this.onPickLanguage,
    required this.onReset,
    this.scrollController,
  });

  final TextEditingController controller;
  final String languageLabel;
  final String languageId;
  final VoidCallback onPickLanguage;
  final VoidCallback onReset;
  final ScrollController? scrollController;

  @override
  State<VuV2VsCodeEditor> createState() => _VuV2VsCodeEditorState();
}

class _VuV2VsCodeEditorState extends State<VuV2VsCodeEditor> {
  static const Color _bg = Color(0xFF1E1E1E);
  static const Color _bar = Color(0xFF252526);
  static const Color _border = Color(0xFF3C3C3C);
  static const Color _fg = Color(0xFFD4D4D4);
  static const Color _mute = Color(0xFF858585);
  static const Color _accent = Color(0xFF007ACC);

  int _lines = 14;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_recount);
    _recount();
  }

  @override
  void didUpdateWidget(covariant VuV2VsCodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_recount);
      widget.controller.addListener(_recount);
      _recount();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_recount);
    super.dispose();
  }

  void _recount() {
    final String text = widget.controller.text;
    int lines = 1;
    for (int i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) == 10) {
        lines++;
      }
    }
    if (lines < 14) {
      lines = 14;
    }
    if (!mounted) {
      return;
    }
    if (lines != _lines) {
      setState(() {
        _lines = lines;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final StringBuffer gutter = StringBuffer();
    for (int i = 1; i <= _lines; i++) {
      if (i > 1) {
        gutter.writeln();
      }
      gutter.write('$i');
    }

    return ColoredBox(
      color: _bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 44,
            color: _bar,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: <Widget>[
                const Text(
                  'Language',
                  style: TextStyle(
                    color: _mute,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    onTap: widget.onPickLanguage,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _accent),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            widget.languageLabel,
                            style: const TextStyle(
                              color: _fg,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: _accent,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: EdgeInsets.zero,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 44,
                    color: _bg,
                    padding: const EdgeInsets.only(top: 8, right: 8),
                    child: Text(
                      gutter.toString(),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13.5,
                        height: 1.55,
                        color: _mute,
                      ),
                    ),
                  ),
                  Container(width: 1, color: _border),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      cursorColor: const Color(0xFFAEAFAD),
                      cursorWidth: 2,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13.5,
                        height: 1.55,
                        color: _fg,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.fromLTRB(10, 8, 12, 8),
                        hintText: 'Write your solution...',
                        hintStyle: TextStyle(
                          color: _mute,
                          fontFamily: 'monospace',
                          fontSize: 13.5,
                          height: 1.55,
                        ),
                      ),
                      inputFormatters: const <TextInputFormatter>[],
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
