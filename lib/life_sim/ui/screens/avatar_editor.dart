import 'package:flutter/material.dart';

import '../../avatar/avatar_profile.dart';
import '../life_widgets.dart';
import '../painters/avatar_painter.dart';

/// Live-preview avatar customiser (used by the creator and the wardrobe).
class AvatarEditor extends StatefulWidget {
  const AvatarEditor({super.key, required this.profile, required this.onChanged, this.showIdentity = true});
  final AvatarProfile profile;
  final VoidCallback onChanged;

  /// Name, gender presentation, traits (hidden in the wardrobe).
  final bool showIdentity;

  @override
  State<AvatarEditor> createState() => _AvatarEditorState();
}

class _AvatarEditorState extends State<AvatarEditor> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(vsync: this, duration: const Duration(seconds: 100))..repeat();
  late final TextEditingController _name = TextEditingController(text: widget.profile.name);
  AvatarAction _action = AvatarAction.idle;
  AvatarEmotion _emotion = AvatarEmotion.happy;

  AvatarProfile get p => widget.profile;

  void _set(VoidCallback f) {
    setState(f);
    widget.onChanged();
  }

  @override
  void dispose() {
    _anim.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(14), children: <Widget>[
      Panel(
        child: Column(children: <Widget>[
          SizedBox(
            height: 220,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (BuildContext c, _) => AvatarView(look: AvatarLook.fromProfile(p), action: _action, emotion: _emotion, t: _anim.value * 100, size: 220),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: <Widget>[
            for (final AvatarAction a in <AvatarAction>[AvatarAction.idle, AvatarAction.walk, AvatarAction.talk, AvatarAction.useComputer, AvatarAction.eat, AvatarAction.sleep, AvatarAction.celebrate, AvatarAction.frustrated])
              ChoiceChip(label: Text(a.name), selected: _action == a, onSelected: (_) => setState(() => _action = a), visualDensity: VisualDensity.compact),
          ]),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: <Widget>[
            for (final AvatarEmotion e in AvatarEmotion.values)
              ChoiceChip(label: Text(e.name), selected: _emotion == e, onSelected: (_) => setState(() => _emotion = e), visualDensity: VisualDensity.compact),
          ]),
        ]),
      ),
      if (widget.showIdentity) ...<Widget>[
        const SectionTitle('Name'),
        TextField(controller: _name, maxLength: 20, decoration: const InputDecoration(hintText: 'Your name'), onChanged: (String v) => _set(() => p.name = v.trim().isEmpty ? 'Student' : v.trim())),
        const SectionTitle('Presentation'),
        _choices(AvatarProfile.genderOptions, p.genderPresentation, (String v) => _set(() => p.genderPresentation = v)),
      ],
      const SectionTitle('Skin tone'),
      _colors(AvatarProfile.skinTones, p.skinTone, (int v) => _set(() => p.skinTone = v)),
      const SectionTitle('Face'),
      _choices(AvatarProfile.faceShapes, p.faceShape, (String v) => _set(() => p.faceShape = v)),
      const SectionTitle('Eyes'),
      _choices(AvatarProfile.eyeStyles, p.eyeStyle, (String v) => _set(() => p.eyeStyle = v)),
      const SectionTitle('Hair style'),
      _choices(AvatarProfile.hairStyles, p.hairStyle, (String v) => _set(() => p.hairStyle = v)),
      const SectionTitle('Hair colour'),
      _colors(AvatarProfile.hairColors, p.hairColor, (int v) => _set(() => p.hairColor = v)),
      const SectionTitle('Outfit colour'),
      _colors(AvatarProfile.outfitColors, p.outfitColor, (int v) => _set(() => p.outfitColor = v)),
      const SectionTitle('Accessory'),
      _choices(AvatarProfile.accessories, p.accessory, (String v) => _set(() => p.accessory = v)),
      if (widget.showIdentity) ...<Widget>[
        const SectionTitle('Traits (pick up to 2)'),
        for (final MapEntry<String, String> t in AvatarProfile.traitCatalog.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Panel(
              color: p.traits.contains(t.key) ? LifeColors.blue.withValues(alpha: 0.22) : null,
              border: p.traits.contains(t.key) ? LifeColors.blue : null,
              onTap: () => _set(() {
                if (p.traits.contains(t.key)) {
                  p.traits.remove(t.key);
                } else if (p.traits.length < 2) {
                  p.traits.add(t.key);
                }
              }),
              child: Row(children: <Widget>[
                Icon(p.traits.contains(t.key) ? Icons.check_circle : Icons.circle_outlined, color: LifeColors.blue),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(t.key[0].toUpperCase() + t.key.substring(1), style: const TextStyle(fontWeight: FontWeight.w900)), Text(t.value, style: const TextStyle(color: LifeColors.muted, fontSize: 12.5))])),
              ]),
            ),
          ),
      ],
    ]);
  }

  Widget _choices(List<String> opts, String current, ValueChanged<String> on) => Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
        for (final String o in opts) ChoiceChip(label: Text(o), selected: current == o, onSelected: (_) => on(o), selectedColor: LifeColors.blue),
      ]);

  Widget _colors(List<int> colors, int current, ValueChanged<int> on) => Wrap(spacing: 10, runSpacing: 10, children: <Widget>[
        for (final int c in colors)
          GestureDetector(
            onTap: () => on(c),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: Color(c), shape: BoxShape.circle, border: Border.all(color: current == c ? Colors.white : Colors.white24, width: current == c ? 3 : 1)),
            ),
          ),
      ]);
}

/// First-run character creator.
class CharacterCreatorScreen extends StatefulWidget {
  const CharacterCreatorScreen({super.key, required this.onStart});
  final void Function(AvatarProfile profile) onStart;
  @override
  State<CharacterCreatorScreen> createState() => _CharacterCreatorScreenState();
}

class _CharacterCreatorScreenState extends State<CharacterCreatorScreen> {
  final AvatarProfile _p = AvatarProfile(name: 'Student');

  @override
  Widget build(BuildContext context) => LifePage(
        title: 'Create your character',
        subtitle: 'Welcome to Glow City',
        child: Column(children: <Widget>[
          Expanded(child: AvatarEditor(profile: _p, onChanged: () => setState(() {}))),
          Padding(
            padding: const EdgeInsets.all(14),
            child: BigButton(label: 'Start my life in Glow City', icon: Icons.rocket_launch_rounded, color: LifeColors.green, onPressed: () => widget.onStart(_p)),
          ),
        ]),
      );
}

/// Wardrobe page (appearance only).
class WardrobeScreen extends StatelessWidget {
  const WardrobeScreen({super.key, required this.profile, required this.onChanged});
  final AvatarProfile profile;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => LifePage(
        title: 'Wardrobe',
        subtitle: 'Change your look',
        child: AvatarEditor(profile: profile, onChanged: onChanged, showIdentity: false),
      );
}
