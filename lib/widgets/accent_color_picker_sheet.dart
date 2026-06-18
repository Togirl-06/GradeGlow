import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/appearance_service.dart';
import '../theme/study_theme.dart';

/// Preset accent colors users can pick from, plus a custom HSL slider.
class AccentColorPickerSheet extends StatefulWidget {
  const AccentColorPickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) => const AccentColorPickerSheet(),
    );
  }

  @override
  State<AccentColorPickerSheet> createState() => _AccentColorPickerSheetState();
}

class _AccentColorPickerSheetState extends State<AccentColorPickerSheet> {
  static const List<Color> _presets = <Color>[
    Color(0xFF2563EB),
    Color(0xFF6366F1),
    Color(0xFF9333EA),
    Color(0xFFEC4899),
    Color(0xFFEF4444),
    Color(0xFFF97316),
    Color(0xFFF59E0B),
    Color(0xFF22C55E),
    Color(0xFF14B8A6),
    Color(0xFF06B6D4),
    Color(0xFF64748B),
    Color(0xFFF43F5E),
  ];

  late HSLColor _hsl;
  bool _isCustom = false;

  @override
  void initState() {
    super.initState();
    final Color current = context.read<AppearanceService>().primaryColor;
    _hsl = HSLColor.fromColor(current);
    _isCustom = !_presets.contains(current);
  }

  Color get _previewColor => _hsl.toColor();

  void _selectPreset(Color color) {
    setState(() {
      _hsl = HSLColor.fromColor(color);
      _isCustom = false;
    });
    context.read<AppearanceService>().setPrimaryColor(color);
  }

  void _updateCustom(double hue, double saturation, double lightness) {
    setState(() {
      _hsl = HSLColor.fromAHSL(1, hue, saturation, lightness);
      _isCustom = true;
    });
    context.read<AppearanceService>().setPrimaryColor(_previewColor);
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textSecondary = StudyColors.textSecondary(brightness);
    final Color border = StudyColors.border(brightness);
    final Color current = context.watch<AppearanceService>().primaryColor;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('App color', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              'Pick a color for buttons, links, and highlights.',
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _presets.map((Color color) {
                final bool selected = !_isCustom && color == current;
                return GestureDetector(
                  onTap: () => _selectPreset(color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? StudyColors.textPrimary(brightness) : border,
                        width: selected ? 3 : 1,
                      ),
                      boxShadow: selected
                          ? <BoxShadow>[
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Custom', style: TextStyle(fontWeight: FontWeight.w700, color: textSecondary, fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _previewColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _ColorSlider(
                        label: 'Hue',
                        value: _hsl.hue,
                        max: 360,
                        activeColor: _previewColor,
                        onChanged: (double v) =>
                            _updateCustom(v, _hsl.saturation, _hsl.lightness),
                      ),
                      const SizedBox(height: 8),
                      _ColorSlider(
                        label: 'Saturation',
                        value: _hsl.saturation,
                        max: 1,
                        activeColor: _previewColor,
                        onChanged: (double v) => _updateCustom(_hsl.hue, v, _hsl.lightness),
                      ),
                      const SizedBox(height: 8),
                      _ColorSlider(
                        label: 'Lightness',
                        value: _hsl.lightness,
                        max: 1,
                        activeColor: _previewColor,
                        onChanged: (double v) => _updateCustom(_hsl.hue, _hsl.saturation, v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSlider extends StatelessWidget {
  const _ColorSlider({
    required this.label,
    required this.value,
    required this.max,
    required this.activeColor,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double max;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value.clamp(0, max),
              min: 0,
              max: max,
              activeColor: activeColor,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
