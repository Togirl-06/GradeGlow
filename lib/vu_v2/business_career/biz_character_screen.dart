import 'package:flutter/material.dart';

import 'business_career_progress.dart';
import 'business_career_theme.dart';

class BizCharacterScreen extends StatefulWidget {
  const BizCharacterScreen({
    super.key,
    required this.progress,
    required this.onDone,
  });

  final BusinessCareerProgress progress;
  final VoidCallback onDone;

  @override
  State<BizCharacterScreen> createState() => _BizCharacterScreenState();
}

class _BizCharacterScreenState extends State<BizCharacterScreen> {
  late final TextEditingController _name;
  late int _skin;
  late int _hair;
  late int _hairColor;
  late int _outfit;
  late String _presentation;

  @override
  void initState() {
    super.initState();
    final BusinessCareerProgress p = widget.progress;
    _name = TextEditingController(text: p.hasCharacter ? p.displayName : '');
    _skin = p.avatarSkin.clamp(0, 2);
    _hair = p.avatarHair.clamp(0, 2);
    _hairColor = p.avatarHairColor.clamp(0, 2);
    _outfit = p.avatarOutfit.clamp(0, 2);
    _presentation = p.preferredPresentation;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await widget.progress.saveCharacter(
      name: _name.text,
      skin: _skin,
      hair: _hair,
      hairColor: _hairColor,
      outfit: _outfit,
      presentation: _presentation,
    );
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    const List<Color> skins = <Color>[
      Color(0xFFF6D7B0),
      Color(0xFFD4A574),
      Color(0xFF8D5524),
    ];
    const List<Color> hairColors = <Color>[
      Color(0xFF1F2937),
      Color(0xFF92400E),
      Color(0xFFD97706),
    ];
    const List<String> outfits = <String>['Business casual', 'Suit', 'Smart casual'];
    const List<String> presentations = <String>[
      'professional',
      'creative',
      'analytical',
    ];

    return Scaffold(
      backgroundColor: BizCosmic.bg,
      appBar: BizCosmic.appBar(
        context: context,
        title: widget.progress.hasCharacter
            ? 'Change Appearance'
            : 'Create Character',
        icon: Icons.person_outline_rounded,
      ),
      body: BizStarfield(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: <Widget>[
            Center(
              child: _AvatarPreview(
                skin: skins[_skin],
                hairColor: hairColors[_hairColor],
                hairStyle: _hair,
                outfit: _outfit,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _name,
              style: const TextStyle(color: BizCosmic.ink),
              decoration: InputDecoration(
                labelText: 'Character name',
                labelStyle: const TextStyle(color: BizCosmic.mute),
                filled: true,
                fillColor: BizCosmic.panelAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _Section(
              title: 'Skin tone',
              child: Wrap(
                spacing: 10,
                children: List<Widget>.generate(3, (int i) {
                  return _Swatch(
                    color: skins[i],
                    selected: _skin == i,
                    onTap: () => setState(() => _skin = i),
                  );
                }),
              ),
            ),
            _Section(
              title: 'Hairstyle',
              child: Wrap(
                spacing: 8,
                children: List<Widget>.generate(3, (int i) {
                  final List<String> labels = <String>['Short', 'Waves', 'Pulled back'];
                  return ChoiceChip(
                    label: Text(labels[i]),
                    selected: _hair == i,
                    onSelected: (_) => setState(() => _hair = i),
                    selectedColor: BizCosmic.emerald.withValues(alpha: 0.35),
                    labelStyle: const TextStyle(color: BizCosmic.ink),
                    backgroundColor: BizCosmic.panelAlt,
                  );
                }),
              ),
            ),
            _Section(
              title: 'Hair color',
              child: Wrap(
                spacing: 10,
                children: List<Widget>.generate(3, (int i) {
                  return _Swatch(
                    color: hairColors[i],
                    selected: _hairColor == i,
                    onTap: () => setState(() => _hairColor = i),
                  );
                }),
              ),
            ),
            _Section(
              title: 'Outfit',
              child: Wrap(
                spacing: 8,
                children: List<Widget>.generate(3, (int i) {
                  return ChoiceChip(
                    label: Text(outfits[i]),
                    selected: _outfit == i,
                    onSelected: (_) => setState(() => _outfit = i),
                    selectedColor: BizCosmic.royal.withValues(alpha: 0.35),
                    labelStyle: const TextStyle(color: BizCosmic.ink),
                    backgroundColor: BizCosmic.panelAlt,
                  );
                }),
              ),
            ),
            _Section(
              title: 'Starting strength',
              child: Wrap(
                spacing: 8,
                children: presentations.map((String p) {
                  return ChoiceChip(
                    label: Text(p),
                    selected: _presentation == p,
                    onSelected: (_) => setState(() => _presentation = p),
                    selectedColor: BizCosmic.gold.withValues(alpha: 0.35),
                    labelStyle: const TextStyle(color: BizCosmic.ink),
                    backgroundColor: BizCosmic.panelAlt,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: BizCosmic.emerald,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(
                widget.progress.hasCharacter
                    ? 'Save & continue'
                    : 'Enter campus',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: BizCosmic.mute,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? BizCosmic.ink : BizCosmic.stroke,
            width: selected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({
    required this.skin,
    required this.hairColor,
    required this.hairStyle,
    required this.outfit,
  });

  final Color skin;
  final Color hairColor;
  final int hairStyle;
  final int outfit;

  @override
  Widget build(BuildContext context) {
    final Color suit = switch (outfit) {
      1 => const Color(0xFF1E3A5F),
      2 => const Color(0xFF334155),
      _ => const Color(0xFF0F766E),
    };
    return Container(
      width: 140,
      height: 160,
      decoration: BizCosmic.panelBox(radius: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: skin,
                  shape: BoxShape.circle,
                ),
              ),
              Positioned(
                top: hairStyle == 2 ? 2 : 0,
                child: Container(
                  width: hairStyle == 1 ? 78 : 64,
                  height: hairStyle == 0 ? 18 : 28,
                  decoration: BoxDecoration(
                    color: hairColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: 88,
            height: 40,
            decoration: BoxDecoration(
              color: suit,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}
