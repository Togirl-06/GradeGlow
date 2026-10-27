import 'package:flutter/material.dart';

import '../../core/life_clock.dart';
import '../../economy/shop_catalog.dart';
import '../../employment/application.dart';
import '../../employment/phone_inbox.dart';
import '../../game/life_game.dart';
import '../../workplace/job_state.dart';
import '../life_session.dart';
import '../life_widgets.dart';
import 'job_screens.dart';
import 'life_screens.dart';
import 'status_screens.dart';

/// The in-game smartphone: email, messages, alerts, calendar and apps.
class PhoneScreen extends StatelessWidget {
  const PhoneScreen({super.key, required this.life, this.onOpenMap});
  final LifeSession life;
  final VoidCallback? onOpenMap;

  @override
  Widget build(BuildContext context) => Theme(
        data: lifeTheme(),
        child: DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('📱 Phone'),
              bottom: TabBar(tabs: <Tab>[
                const Tab(text: 'Apps'),
                Tab(child: _badge('Email', life.game.inbox.ofKind(MessageKind.email))),
                Tab(child: _badge('Messages', life.game.inbox.ofKind(MessageKind.sms))),
                Tab(child: _badge('Alerts', life.game.inbox.ofKind(MessageKind.alert))),
              ]),
            ),
            body: ListenableBuilder(
              listenable: life,
              builder: (BuildContext context, _) => TabBarView(children: <Widget>[
                _apps(context),
                _list(context, MessageKind.email),
                _list(context, MessageKind.sms),
                _list(context, MessageKind.alert),
              ]),
            ),
          ),
        ),
      );

  Widget _badge(String t, List<PhoneMessage> l) {
    final int n = l.where((PhoneMessage m) => !m.read).length;
    return Row(mainAxisSize: MainAxisSize.min, children: <Widget>[Text(t), if (n > 0) ...<Widget>[const SizedBox(width: 6), CircleAvatar(radius: 9, backgroundColor: LifeColors.red, child: Text('$n', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w900)))]]);
  }

  Widget _apps(BuildContext context) {
    final LifeGame g = life.game;
    void open(Widget w) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => w));
    final List<(String, String, VoidCallback)> apps = <(String, String, VoidCallback)>[
      ('💼', 'Jobs', () => open(JobBoardScreen(life: life))),
      ('📋', 'Applications', () => open(ApplicationsScreen(life: life))),
      ('📄', 'Resume', () => open(ResumeScreen(life: life))),
      ('🏦', 'Bank', () => open(BankScreen(life: life))),
      ('🧍', 'My status', () => open(StatusScreen(life: life))),
      ('🗓️', 'Calendar', () => open(CalendarScreen(life: life))),
      ('🗺️', 'City map', () {
        Navigator.of(context).pop();
        onOpenMap?.call();
      }),
      ('🏭', 'My company', () => open(CompanyScreen(life: life))),
      ('🏠', 'Apartment', () => open(ApartmentScreen(life: life))),
      ('💾', 'Save game', () async {
        await life.saveNow();
        life.say('Game saved.');
      }),
    ];
    return ListView(padding: const EdgeInsets.all(16), children: <Widget>[
      Panel(
        child: Row(children: <Widget>[
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(clockLabel(g.minute), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
            Text('${LifeClock.weekdayNames[g.clock.weekdayIndex]} · Day ${g.day}', style: const TextStyle(color: LifeColors.muted)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
            Text(money(g.economy.cash), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: LifeColors.green)),
            Text(g.statusLine, style: const TextStyle(color: LifeColors.muted, fontSize: 12)),
          ]),
        ]),
      ),
      const SizedBox(height: 14),
      GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.86,
        children: <Widget>[
          for (final (String, String, VoidCallback) a in apps)
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: a.$3,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: LifeColors.panel2, borderRadius: BorderRadius.circular(16), border: Border.all(color: LifeColors.line)),
                  child: Text(a.$1, style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(height: 6),
                Text(a.$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
              ]),
            ),
        ],
      ),
    ]);
  }

  Widget _list(BuildContext context, MessageKind k) {
    final List<PhoneMessage> msgs = life.game.inbox.ofKind(k);
    if (msgs.isEmpty) return const Center(child: Text('Nothing here yet.', style: TextStyle(color: LifeColors.muted)));
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: msgs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (BuildContext c, int i) {
        final PhoneMessage m = msgs[i];
        return Panel(
          color: m.read ? LifeColors.panel : LifeColors.panel2,
          border: m.read ? null : LifeColors.blue,
          onTap: () {
            m.read = true;
            life.changed();
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => MessageScreen(life: life, message: m)));
          },
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(k == MessageKind.email ? '✉️' : (k == MessageKind.sms ? '💬' : '🔔'), style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(m.subject, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: m.read ? FontWeight.w600 : FontWeight.w900)),
              Text(m.from, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: LifeColors.muted, fontSize: 12)),
              Text(m.body.replaceAll('\n', ' '), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5)),
            ])),
            Text('D${m.day}', style: const TextStyle(color: LifeColors.muted, fontSize: 11)),
          ]),
        );
      },
    );
  }
}

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key, required this.life, required this.message});
  final LifeSession life;
  final PhoneMessage message;

  @override
  Widget build(BuildContext context) {
    final String? type = message.action?['type'];
    final String? appId = message.action?['applicationId'];
    final ApplicationRecord? app = appId == null ? null : life.game.applicationById(appId);
    return LifePage(
      title: message.subject,
      subtitle: '${message.from} · Day ${message.day}, ${clockLabel(message.minuteOfDay)}',
      child: ListView(padding: const EdgeInsets.all(16), children: <Widget>[
        Panel(child: Text(message.body, style: const TextStyle(height: 1.5, fontSize: 15))),
        const SizedBox(height: 14),
        if (type == 'interview' && app != null) BigButton(label: 'View interview details', icon: Icons.event_rounded, onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ApplicationsScreen(life: life)))),
        if (type == 'offer' && app != null && app.status == ApplicationStatus.offer) BigButton(label: 'Review offer & contract', icon: Icons.description_rounded, color: LifeColors.green, onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => OfferScreen(life: life, app: app)))),
        if (type == 'applications') BigButton(label: 'Open my applications', icon: Icons.assignment_rounded, onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ApplicationsScreen(life: life)))),
      ]),
    );
  }
}

/// Upcoming interviews, shifts, payday, bills.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key, required this.life});
  final LifeSession life;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: life,
        builder: (BuildContext context, _) {
          final LifeGame g = life.game;
          final List<(int, String)> ev = <(int, String)>[];
          for (final ApplicationRecord a in g.applications) {
            if (a.status == ApplicationStatus.invited && a.interviewDay != null) {
              ev.add((a.interviewDay!, '🎤 Interview — ${a.listing?.title} at ${a.listing?.employer.name}, ${a.interviewHour}:00'));
            }
            if (a.status == ApplicationStatus.pending) ev.add((a.respondDay, '📬 Reply expected from ${a.listing?.employer.name}'));
            if (a.status == ApplicationStatus.waitlisted && a.waitlistResolveDay != null) ev.add((a.waitlistResolveDay!, '⏳ Waiting-list decision — ${a.listing?.employer.name}'));
          }
          final JobRecord? j = g.job;
          if (j != null) {
            if (j.contract.startDay > g.day) ev.add((j.contract.startDay, '🏢 First day at ${j.employer.name}, ${j.contract.startHour}:00'));
            ev.add((j.lastPaydayDay + JobEngine.paydayInterval, '💵 Payday from ${j.employer.name}'));
            if (j.noticeEndDay != null) ev.add((j.noticeEndDay!, '🚨 Your role ends'));
          }
          ev.add((g.economy.lastBillDay + ShopCatalog.billingPeriodDays, '🧾 Rent & bills due (${money(g.economy.monthlyFixedCosts)})'));
          ev.sort(((int, String) a, (int, String) b) => a.$1.compareTo(b.$1));
          return LifePage(
            title: '🗓️ Calendar',
            subtitle: 'Today is ${LifeClock.weekdayNames[g.clock.weekdayIndex]}, Day ${g.day}',
            child: ListView(padding: const EdgeInsets.all(14), children: <Widget>[
              if (j != null)
                Panel(child: Text('Work: Mon–Fri ${j.contract.startHour}:00–${j.contract.endHour}:00 at ${j.employer.name}', style: const TextStyle(fontWeight: FontWeight.w800))),
              const SizedBox(height: 8),
              for (final (int, String) e in ev)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Panel(
                    child: Row(children: <Widget>[
                      SizedBox(width: 70, child: Text(e.$1 <= g.day ? 'Today' : '${LifeClock.weekdayNames[(e.$1 - 1) % 7]} D${e.$1}', style: TextStyle(fontWeight: FontWeight.w900, color: e.$1 <= g.day ? LifeColors.amber : LifeColors.muted))),
                      Expanded(child: Text(e.$2)),
                    ]),
                  ),
                ),
            ]),
          );
        },
      );
}
