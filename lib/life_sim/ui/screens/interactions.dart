import 'package:flutter/material.dart';

import '../../campus/campus_labs.dart';
import '../../employment/job_listing.dart';
import '../../game/life_game.dart';
import '../../interview/interview_session.dart';
import '../../services/life_ai_service.dart';
import '../../world/npc_motion.dart';
import '../../world/world_model.dart';
import '../../workplace/work_task.dart';
import '../life_session.dart';
import '../life_widgets.dart';
import '../painters/avatar_painter.dart';
import 'avatar_editor.dart';
import 'campus_screens.dart';
import 'interview_screen.dart';
import 'job_screens.dart';
import 'life_screens.dart';
import 'phone_screen.dart';
import 'work_screens.dart';
import '../../avatar/avatar_profile.dart';

/// Maps every world [ActionType] to a screen or a [LifeGame] action.
/// Nothing clickable in the world is decorative.
class Interactions {
  const Interactions._();

  static void _push(BuildContext c, Widget w) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => Theme(data: lifeTheme(), child: w)));

  static Future<void> run(BuildContext context, LifeSession life, Interactable item, {VoidCallback? openMap}) async {
    final LifeGame g = life.game;
    ActionResult act(ActionResult r, AvatarAction a) => life.report(r, animate: a);
    switch (item.type) {
      case ActionType.sleep:
        act(g.sleep(), AvatarAction.sleep);
      case ActionType.eatHome:
        act(g.eatHome(), AvatarAction.eat);
      case ActionType.relaxHome:
        act(g.relaxHome(shower: item.arg == 'shower'), AvatarAction.sit);
      case ActionType.laptop:
        _push(context, PhoneScreen(life: life, onOpenMap: openMap));
      case ActionType.wardrobe:
        _push(context, WardrobeScreen(profile: g.avatar, onChanged: life.changed));
      case ActionType.studyHome:
        if (item.arg == 'self') {
          act(g.selfStudy(), AvatarAction.study);
        } else {
          _push(context, CampusScreen(life: life, tab: CampusTab.study));
        }
      case ActionType.decorate:
        _push(context, ApartmentScreen(life: life, initialTab: 1));
      case ActionType.payBills:
        _push(context, ApartmentScreen(life: life, initialTab: 2));
      case ActionType.shop:
        _push(context, ShopScreen(life: life, shopId: item.arg ?? 'grocery'));
      case ActionType.bank:
        _push(context, BankScreen(life: life));
      case ActionType.jobBoard:
        _push(context, JobBoardScreen(life: life));
      case ActionType.resumeDesk:
        _push(context, ResumeScreen(life: life));
      case ActionType.interviewPractice:
        await _practice(context, life);
      case ActionType.hrDesk:
        final String? emp = item.arg ?? g.job?.contract.employerId;
        if (emp == null) {
          life.say('Apply for a job first — HR will contact you.');
        } else {
          _push(context, HrDeskScreen(life: life, employerId: emp));
        }
      case ActionType.clockIn:
        await _clockIn(context, life);
      case ActionType.workStation:
        _push(context, WorkStationScreen(life: life, stationId: item.arg ?? ''));
      case ActionType.breakRoom:
        act(g.breakRoom(), AvatarAction.sit);
      case ActionType.enrolDesk:
        _push(context, CampusScreen(life: life, tab: CampusTab.degrees));
      case ActionType.lectureHall:
        _push(context, CampusScreen(life: life, tab: CampusTab.lectures));
      case ActionType.studyDesk:
        _push(context, CampusScreen(life: life, tab: CampusTab.study));
      case ActionType.examHall:
        _push(context, CampusScreen(life: life, tab: CampusTab.exams));
      case ActionType.certDesk:
        _push(context, CertScreen(life: life));
      case ActionType.healthCheck:
        act(g.healthCheck(), AvatarAction.sit);
      case ActionType.watchMovie:
        act(g.watchMovie(), AvatarAction.sit);
      case ActionType.workout:
        act(g.workout(kind: item.arg ?? 'gym'), AvatarAction.work);
      case ActionType.relaxPark:
        act(g.relaxPark(), AvatarAction.sit);
      case ActionType.socialize:
        act(g.socialize(), AvatarAction.talk);
      case ActionType.observeCourt:
        act(g.observeCourt(records: item.arg == 'records'), AvatarAction.sit);
      case ActionType.companyRegistry:
        _push(context, CompanyScreen(life: life));
      case ActionType.graduation:
        act(g.attendCeremony(), AvatarAction.celebrate);
      case ActionType.openLab:
        await _openLab(context, life, item.arg ?? '');
      case ActionType.talkNpc:
        break;
    }
  }

  /// Opens a school's learning station; time actually spent there builds skill.
  static Future<void> _openLab(BuildContext context, LifeSession life, String labId) async {
    final CampusLab? lab = CampusLabs.byId(labId);
    if (lab == null) {
      life.say('This station is not open yet.');
      return;
    }
    final DateTime started = DateTime.now();
    await lab.open(context);
    final int seconds = DateTime.now().difference(started).inSeconds;
    life.report(life.game.practiceLab(title: lab.name, skill: lab.skill, seconds: seconds), animate: AvatarAction.study);
  }

  static Future<void> _clockIn(BuildContext context, LifeSession life) async {
    final r = life.game.clockIn();
    life.report(r.result, animate: r.result.ok ? AvatarAction.work : null);
    if (r.result.ok && r.tasks.isNotEmpty) {
      await showLifeSheet<void>(
        context,
        builder: (BuildContext c) => Padding(
          padding: const EdgeInsets.all(18),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            const Text("Today's tasks", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            for (final WorkScenario s in r.tasks) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('• ${s.title}  (${stationName(s.station)})')),
            const SizedBox(height: 8),
            const Text('Walk to the matching work stations to complete them.', style: TextStyle(color: LifeColors.muted)),
          ]),
        ),
      );
    }
  }

  static Future<void> _practice(BuildContext context, LifeSession life) async {
    final List<JobListing> jobs = life.game.openJobs();
    if (jobs.isEmpty) {
      life.say('No open positions to practise for right now.');
      return;
    }
    final JobListing? pick = await showLifeSheet<JobListing>(
      context,
      builder: (BuildContext c) => ListView(padding: const EdgeInsets.all(14), children: <Widget>[
        const Text('Practise an interview for…', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        for (final JobListing j in jobs.take(14))
          ListTile(
            title: Text(j.title),
            subtitle: Text(j.employer.name),
            trailing: const Icon(Icons.mic_rounded),
            onTap: () => Navigator.of(c).pop(j),
          ),
      ]),
    );
    if (pick == null || !context.mounted) return;
    final InterviewSession s = life.game.startPracticeInterview(pick, judge: AiInterviewJudge());
    _push(context, InterviewScreen(life: life, interview: s));
  }

  /// Chat sheet with a world NPC (AI-generated words, scripted fallback).
  static Future<void> talk(BuildContext context, LifeSession life, NpcDef npc) {
    life.report(life.game.talkToNpc(npc), animate: AvatarAction.talk);
    return showLifeSheet<void>(context, builder: (BuildContext c) => NpcChatSheet(life: life, npc: npc));
  }
}

class NpcChatSheet extends StatefulWidget {
  const NpcChatSheet({super.key, required this.life, required this.npc});
  final LifeSession life;
  final NpcDef npc;
  @override
  State<NpcChatSheet> createState() => _NpcChatSheetState();
}

class _NpcChatSheetState extends State<NpcChatSheet> {
  final List<(bool, String)> log = <(bool, String)>[];
  final TextEditingController ctl = TextEditingController();
  bool busy = false;

  @override
  void initState() {
    super.initState();
    log.add((false, widget.life.npcChat.greeting(widget.npc)));
  }

  @override
  void dispose() {
    ctl.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final String t = (preset ?? ctl.text).trim();
    if (t.isEmpty || busy) return;
    ctl.clear();
    setState(() {
      log.add((true, t));
      busy = true;
    });
    final LifeGame g = widget.life.game;
    final String reply = await widget.life.npcChat.reply(
      widget.npc,
      t,
      history: <String>[for (final (bool, String) e in log) if (e.$1) e.$2],
      context: 'Player works as: ${g.job?.contract.title ?? 'unemployed'}; day ${g.day}.',
    );
    if (!mounted) return;
    setState(() {
      log.add((false, reply));
      busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final NpcDef n = widget.npc;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(children: <Widget>[
        ListTile(
          leading: AvatarView(look: AvatarLook.fromNpc(n), size: 52),
          title: Text(n.name, style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Text('${n.role} · ${NpcMotion.activityLabel(NpcMotion.activityAt(n, widget.life.game.day, widget.life.game.minute))}'),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(12), children: <Widget>[
            for (final (bool, String) m in log)
              Align(
                alignment: m.$1 ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  constraints: const BoxConstraints(maxWidth: 420),
                  decoration: BoxDecoration(color: m.$1 ? LifeColors.blue : LifeColors.panel2, borderRadius: BorderRadius.circular(14)),
                  child: Text(m.$2),
                ),
              ),
            if (busy) const Padding(padding: EdgeInsets.all(8), child: Text('…', style: TextStyle(color: LifeColors.muted))),
          ]),
        ),
        Wrap(spacing: 6, children: <Widget>[
          for (final String q in <String>['How do I get hired?', 'Any career advice?', 'How is work here?'])
            ActionChip(label: Text(q, style: const TextStyle(fontSize: 12)), onPressed: () => _send(q)),
        ]),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: <Widget>[
            Expanded(child: TextField(controller: ctl, onSubmitted: (_) => _send(), decoration: const InputDecoration(hintText: 'Say something…', border: OutlineInputBorder()))),
            const SizedBox(width: 8),
            IconButton.filled(onPressed: busy ? null : _send, icon: const Icon(Icons.send_rounded)),
          ]),
        ),
      ]),
    );
  }
}
