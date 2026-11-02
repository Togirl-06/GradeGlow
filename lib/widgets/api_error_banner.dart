import 'package:flutter/material.dart';

import '../theme/study_theme.dart';
import '../utils/api_error_messages.dart';

/// High-contrast error card for API failures (readable in dark mode).
class ApiErrorBanner extends StatelessWidget {
  const ApiErrorBanner({
    super.key,
    required this.error,
    this.onDismiss,
  });

  final ApiErrorInfo error;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDark = brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3F1D2E) : const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StudyColors.danger.withValues(alpha: isDark ? 0.6 : 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.error_outline_rounded, color: StudyColors.danger, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      error.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: isDark ? const Color(0xFFFECDD3) : const Color(0xFF9F1239),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      error.message,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: isDark ? const Color(0xFFFDA4AF) : const Color(0xFF881337),
                      ),
                    ),
                  ],
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: Icon(Icons.close_rounded, color: StudyColors.textSecondary(brightness), size: 20),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
            ],
          ),
          if (error.steps.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            ...error.steps.map(
              (String step) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '• ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFFDA4AF) : const Color(0xFFBE123C),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: isDark ? const Color(0xFFFECDD3) : const Color(0xFF9F1239),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
