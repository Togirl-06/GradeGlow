import 'package:flutter/material.dart';

/// Short lecture caption above the scrubber (display only — no parent callbacks).
class LectureCaptionBar extends StatelessWidget {
  const LectureCaptionBar({
    super.key,
    required this.caption,
  });

  final String caption;

  @override
  Widget build(BuildContext context) {
    final String text = caption.trim();
    return IgnorePointer(
      child: SizedBox(
        height: 28,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: text.isEmpty
                ? const SizedBox.shrink()
                : Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                      shadows: <Shadow>[
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 6,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
