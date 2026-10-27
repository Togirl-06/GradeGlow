import 'package:flutter/material.dart';

import '../../careers/career_catalog.dart';
import '../../education/skills.dart';
import '../../game/life_game.dart';
import '../../education/university.dart';
import '../../social/relationships.dart';
import '../../world/city_map.dart';
import '../../world/interiors.dart';
import '../../world/world_model.dart';
import '../life_session.dart';
import '../life_widgets.dart';
import '../painters/avatar_painter.dart';
import '../../workplace/job_state.dart';

String educationName(int r) => const <String>['High school', 'Associate degree', "Bachelor's degree", "Master's degree", 'Doctorate'][r.clamp(0, 4)];

/// Status panel: needs, skills, education, career and money at a glance.
class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key, required this.life});
  final LifeSession life;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: life,
        builder: (BuildContext context, _) {
          final LifeGame g = life.game;
          final JobRecord? j = g.job;
          return LifePage(
            title: g.avatar.name,
            subtitle: g.statusLine,
            child: ListView(padding: const EdgeInsets.all(14), children: <Widget>[
              Panel(
                child: Row(children: <Widget>[
                  AvatarView(look: AvatarLook.fromProfile(g.avatar), emotion: life.emotion, size: 130),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Text('💵 ${money(g.economy.cash)} cash', style: const TextStyle(fontWeight: FontWeight.w900)),
                    Text('🏦 ${money(g.economy.savings)} savings'),
                    if (g.economy.debt > 0) Text('⚠️ ${money(g.economy.debt)} debt', style: const TextStyle(color: LifeColors.red)),
                    const SizedBox(height: 6),
                    Text('🎓 ${educationName(g.educationRank)}'),
                    Text('🏠 ${g.economy.housing.name}'),
                    if (g.avatar.traits.isNotEmpty) Wrap(spacing: 4, children: <Widget>[for (final String t in g.avatar.traits) Tag(t, color: LifeColors.purple)]),
                  ])),
                ]),
              ),
              const SectionTitle('Needs'),
              Panel(
                child: Column(children: <Widget>[
                  NeedBar(label: 'Energy', value: g.needs.energy, emoji: '⚡'),
                  NeedBar(label: 'Hunger', value: g.needs.hunger, emoji: '🍽️'),
                  NeedBar(label: 'Happiness', value: g.needs.happiness, emoji: '😊'),
                  NeedBar(label: 'Health', value: g.needs.health, emoji: '❤️'),
                  NeedBar(label: 'Social', value: g.needs.social, emoji: '👥'),
                  NeedBar(label: 'Hygiene', value: g.needs.hygiene, emoji: '🚿', color: LifeColors.teal),
                  NeedBar(label: 'Calm', value: 100 - g.needs.stress, emoji: '🧘', color: LifeColors.purple),
                  NeedBar(label: 'Knowledge', value: _knowledge(g), emoji: '📚', color: LifeColors.blue),
                  NeedBar(label: 'Finance', value: _financeScore(g), emoji: '💹', color: LifeColors.teal),
                  for (final String w in g.needs.warnings()) Padding(padding: const EdgeInsets.only(top: 4), child: Text('⚠️ $w', style: const TextStyle(color: LifeColors.amber, fontSize: 12.5))),
                ]),
              ),
              if (j != null) ...<Widget>[
                const SectionTitle('Career'),
                Panel(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Text('${j.contract.title} at ${j.employer.name}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text('${money(j.contract.monthlySalary)} / month · rank ${j.rank + 1}/${kTopRank + 1}'),
                    NeedBar(label: 'Performance', value: j.performance, emoji: '📈'),
                    Text('Workdays at rank ${j.workdaysAtRank.toStringAsFixed(1)} · total ${j.totalWorkdays.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12.5, color: LifeColors.muted)),
                    if (g.promotionStatus() != null && !g.promotionStatus()!.eligible) ...<Widget>[
                      const SizedBox(height: 6),
                      const Text('Next promotion needs:', style: TextStyle(fontWeight: FontWeight.w800)),
                      for (final String u in g.promotionStatus()!.unmet) Text('• $u', style: const TextStyle(fontSize: 12.5)),
                    ],
                    if (g.promotionStatus()?.eligible ?? false) const Text('✅ You qualify for a promotion — visit HR!', style: TextStyle(color: LifeColors.green, fontWeight: FontWeight.w900)),
                  ]),
                ),
              ],
              const SectionTitle('Skills'),
              Panel(
                child: Column(children: <Widget>[
                  for (final SkillDef s in Skills.all) NeedBar(label: s.name, value: g.skills.level(s.id), emoji: s.emoji, color: LifeColors.blue),
                  if (g.skills.certifications.isNotEmpty) Align(alignment: Alignment.centerLeft, child: Wrap(spacing: 6, runSpacing: 6, children: <Widget>[for (final String c in g.skills.certifications) Tag('🏅 ${CertificationCatalog.byId(c)?.name ?? c}', color: LifeColors.amber)])),
                ]),
              ),
              const SectionTitle('Education record'),
              Panel(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Text(UniversityEngine.gpa(g.university) == null ? 'GPA: — (pass a course to get one)' : 'GPA: ${UniversityEngine.gpa(g.university)!.toStringAsFixed(2)} / 4.00', style: const TextStyle(fontWeight: FontWeight.w900)),
                  if (g.pendingCeremonies.isNotEmpty) const Text('🎓 You are invited to a graduation ceremony — visit the University stage.', style: TextStyle(color: LifeColors.amber)),
                  for (final GraduationCertificate c in g.certificates)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('📜 ${c.title} ${c.honors} — GPA ${c.gpa.toStringAsFixed(2)}, Day ${c.day}', style: const TextStyle(fontSize: 13)),
                    ),
                  if (g.certificates.isNotEmpty) const Text('Game certificates only — not accredited qualifications or professional licences.', style: TextStyle(color: LifeColors.muted, fontSize: 11.5)),
                ]),
              ),
              const SectionTitle('Relationships'),
              Panel(
                child: g.relationships.entries.isEmpty
                    ? const Text('Talk to people around the city to build friendships.', style: TextStyle(color: LifeColors.muted))
                    : Column(children: <Widget>[
                        for (final MapEntry<String, RelationshipEntry> e in g.relationships.entries.entries)
                          NeedBar(label: '${_npcName(e.key)} · ${Relationships.title(e.value.level)}', value: e.value.level, emoji: '🤝', color: LifeColors.pink),
                      ]),
              ),
              const SectionTitle('Experience'),
              Panel(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  if (g.experience.isEmpty && g.jobHistory.isEmpty) const Text('No work experience yet.', style: TextStyle(color: LifeColors.muted)),
                  for (final MapEntry<String, int> e in g.experience.entries) Text('${CareerCatalog.byId(e.key)?.title ?? e.key}: ${e.value} workdays'),
                  for (final e in g.jobHistory) Text('• ${e.role}, ${e.employer} (${e.workdays} days)', style: const TextStyle(color: LifeColors.muted, fontSize: 12.5)),
                ]),
              ),
              const SizedBox(height: 20),
            ]),
          );
        },
      );

  static String _npcName(String id) {
    for (final Building b in CityMap.instance.buildings) {
      for (final NpcDef n in Interiors.of(b.id).npcs) {
        if (n.id == id) return n.name;
      }
    }
    return id;
  }

  double _knowledge(LifeGame g) {
    double sum = 0;
    int n = 0;
    for (final SkillDef s in Skills.all) {
      sum += g.skills.level(s.id);
      n++;
    }
    return (sum / n * 2.2).clamp(0, 100).toDouble();
  }

  double _financeScore(LifeGame g) {
    final double nw = g.economy.netWorth;
    return (nw / 50).clamp(0, 100).toDouble();
  }
}

/// A simple 2-D map of the ten districts. Tapping a building pops its id.
class CityMapScreen extends StatelessWidget {
  const CityMapScreen({super.key, required this.life});
  final LifeSession life;

  @override
  Widget build(BuildContext context) {
    final LifeGame g = life.game;
    return LifePage(
      title: '🗺️ City map',
      subtitle: 'Tap a building to walk there',
      child: Column(children: <Widget>[
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext c, BoxConstraints box) {
              final double sw = box.maxWidth / CityMap.width;
              final double sh = box.maxHeight / CityMap.height;
              final double s = sw < sh ? sw : sh;
              final double ox = (box.maxWidth - s * CityMap.width) / 2;
              final double oy = (box.maxHeight - s * CityMap.height) / 2;
              return GestureDetector(
                onTapUp: (TapUpDetails d) {
                  final double tx = (d.localPosition.dx - ox) / s;
                  final double ty = (d.localPosition.dy - oy) / s;
                  for (final Building b in CityMap.instance.buildings) {
                    if (tx >= b.x - 0.5 && tx <= b.x + b.w + 0.5 && ty >= b.y - 0.5 && ty <= b.y + b.h + 1.5) {
                      Navigator.of(context).pop(b.id);
                      return;
                    }
                  }
                },
                child: CustomPaint(size: Size(box.maxWidth, box.maxHeight), painter: _MapPainter(g, s, ox, oy)),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(spacing: 8, runSpacing: 4, children: <Widget>[for (final District d in CityMap.districts) Tag('${d.emoji} ${d.name}', color: Color(d.color))]),
        ),
      ]),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter(this.g, this.s, this.ox, this.oy);
  final LifeGame g;
  final double s;
  final double ox;
  final double oy;

  @override
  void paint(Canvas canvas, Size size) {
    final CityMap city = CityMap.instance;
    canvas.save();
    canvas.translate(ox, oy);
    for (int y = 0; y < CityMap.height; y++) {
      for (int x = 0; x < CityMap.width; x++) {
        final Tile t = city.tiles[y][x];
        final Paint p = Paint()
          ..color = t == Tile.road ? const Color(0xFF475569) : (t == Tile.plaza ? Color(city.districtAt(x, y).color).withValues(alpha: 0.5) : const Color(0xFF3B7A3F));
        canvas.drawRect(Rect.fromLTWH(x * s, y * s, s + 0.5, s + 0.5), p);
      }
    }
    for (final Building b in city.buildings) {
      final Rect r = Rect.fromLTWH(b.x * s, b.y * s, b.w * s, b.h * s);
      canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(s * 0.3)), Paint()..color = Color(b.color));
      final bool open = b.isOpen(g.day, g.minute);
      final TextPainter tp = TextPainter(text: TextSpan(text: b.emoji, style: TextStyle(fontSize: s * 2.4, color: open ? Colors.white : Colors.white54)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(r.center.dx - tp.width / 2, r.center.dy - tp.height / 2));
      final TextPainter name = TextPainter(text: TextSpan(text: b.name, style: TextStyle(fontSize: s * 0.95, color: Colors.white, fontWeight: FontWeight.w800)), textDirection: TextDirection.ltr, maxLines: 1, ellipsis: '…')..layout(maxWidth: b.w * s + 28);
      name.paint(canvas, Offset(r.center.dx - name.width / 2, r.bottom + 1));
    }
    final double px = g.isIndoors ? (g.currentBuilding!.doorX + 0.5) * s : (g.cityX + 0.5) * s;
    final double py = g.isIndoors ? (g.currentBuilding!.doorY + 0.5) * s : (g.cityY + 0.5) * s;
    canvas.drawCircle(Offset(px, py), s * 0.9, Paint()..color = const Color(0xFFFDE047));
    canvas.drawCircle(Offset(px, py), s * 0.9, Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MapPainter old) => true;
}
