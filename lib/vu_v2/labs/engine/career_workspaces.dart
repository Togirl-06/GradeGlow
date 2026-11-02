import 'package:flutter/material.dart';

import 'lab_session.dart';

/// Workplace desks for Career and Life Skills — not a lecture hall and not a quiz.
class CareerWorkspace extends StatelessWidget {
  const CareerWorkspace({super.key, required this.session});
  final LabSession session;

  static String deskFor(LabSession session) {
    final String blob =
        '${session.blueprint.title} ${session.blueprint.courseTitle} ${session.blueprint.unit} ${session.blueprint.role}'
            .toLowerCase();
    if (blob.contains('interview') || blob.contains('star')) return 'interview';
    if (blob.contains('speak') || blob.contains('audience') || blob.contains('stage')) {
      return 'speak';
    }
    if (blob.contains('budget') ||
        blob.contains('finance') ||
        blob.contains('money') ||
        blob.contains('credit') ||
        blob.contains('saving')) {
      return 'budget';
    }
    if (blob.contains('lead') || blob.contains('team') || blob.contains('conflict')) {
      return 'lead';
    }
    return 'resume';
  }

  @override
  Widget build(BuildContext context) {
    switch (deskFor(session)) {
      case 'interview':
        return _InterviewRoom(session: session);
      case 'speak':
        return _SpeakingStage(session: session);
      case 'budget':
        return _BudgetDesk(session: session);
      case 'lead':
        return _TeamFloor(session: session);
      default:
        return _ResumeDesk(session: session);
    }
  }
}

class _ResumeDesk extends StatelessWidget {
  const _ResumeDesk({required this.session});
  final LabSession session;

  static const List<(String id, String weak, String strong)> bullets = <(String, String, String)>[
    (
      'sales',
      'Responsible for helping with sales.',
      'Closed 14 enterprise renewals (\$1.1M) after rebuilding the Q3 pipeline from stalled accounts.',
    ),
    (
      'ops',
      'Duties included making spreadsheets.',
      'Cut weekly close from 11 hours to 4 by automating reconciliations the team still did by hand.',
    ),
    (
      'lead',
      'Team player who assisted the manager.',
      'Coached 3 junior analysts through their first client deck; two were promoted within a year.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Set<String> rewritten = (session.getv<List<dynamic>>('rewritten') ?? <dynamic>[])
        .map((dynamic e) => e.toString())
        .toSet();
    final int ats = 42 + rewritten.length * 18;
    return Container(
      color: const Color(0xFF14110D),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                const Text(
                  'HIRING DESK — draft is too duties-heavy. Rewrite for a hiring manager.',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                ...bullets.map((item) {
                  final bool done = rewritten.contains(item.$1);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: done ? const Color(0xFF1B3A32) : const Color(0xFF2A2218),
                      child: InkWell(
                        onTap: () {
                          if (done) return;
                          final List<dynamic> next = List<dynamic>.from(
                            session.getv<List<dynamic>>('rewritten') ?? <dynamic>[],
                          )..add(item.$1);
                          session.setVar('rewritten', next);
                          session.act(
                            next.length >= 3 ? 'decide' : 'inspect',
                            inspect: done
                                ? item.$3
                                : 'Was: ${item.$2}\nNow: ${item.$3}',
                            say: next.length >= 3
                                ? 'The draft now leads with outcomes. That is what a hiring desk can use.'
                                : 'Keep going. Duties are not achievements.',
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            done ? item.$3 : item.$2,
                            style: TextStyle(
                              color: done ? const Color(0xFF3DDBAD) : Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            width: 140,
            color: Colors.black,
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'ATS $ats',
                  style: const TextStyle(
                    color: Color(0xFF3DDBAD),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  rewritten.length == 3
                      ? 'Ready to send'
                      : 'Tap each weak line',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InterviewRoom extends StatelessWidget {
  const _InterviewRoom({required this.session});
  final LabSession session;

  static const List<String> cards = <String>[
    'S — Last quarter our biggest account froze after a price change.',
    'T — I owned the save-plan in ten days with a \$400k book at risk.',
    'A — I mapped stakeholders, ran three working sessions, and cut a 90-day usage path.',
    'R — They renewed. Churn in that segment dropped from 18% to 6%.',
    'I am a hard worker and a people person.',
    'We just kind of figured it out as a team.',
  ];

  @override
  Widget build(BuildContext context) {
    final List<int> picked = (session.getv<List<dynamic>>('star') ?? <dynamic>[])
        .whereType<int>()
        .toList();
    return Container(
      color: const Color(0xFF10141C),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'INTERVIEWER — “Tell me about a time you rescued a failing account.” Build STAR in order. Skip fluff.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, height: 1.35),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List<Widget>.generate(cards.length, (int i) {
              final bool used = picked.contains(i);
              return ChoiceChip(
                selected: used,
                label: Text(cards[i], style: const TextStyle(fontSize: 12)),
                onSelected: (_) {
                  if (used) return;
                  final List<int> next = <int>[...picked, i];
                  session.setVar('star', next);
                  final bool fluff = i >= 4;
                  final bool orderOk =
                      next.length <= 4 && List<int>.generate(next.length, (int k) => k).every((int k) => next[k] == k);
                  if (fluff) {
                    session.act(
                      'trace_miss',
                      say: 'That is a slogan, not a story. The interviewer still does not know what you did.',
                    );
                  } else if (!orderOk) {
                    session.act(
                      'trace_miss',
                      say: 'STAR is a sequence. Situation before Task before Action before Result.',
                    );
                  } else if (next.length == 4 && orderOk) {
                    session.act(
                      'decide',
                      inspect: next.map((int k) => cards[k]).join('\n'),
                      say: 'That answer can be scored. You named a situation, a task, an action, and a result.',
                    );
                  } else {
                    session.act('inspect', inspect: cards[i]);
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SpeakingStage extends StatelessWidget {
  const _SpeakingStage({required this.session});
  final LabSession session;

  static const List<String> points = <String>[
    'Name the problem the room already feels',
    'One story with a number',
    'The ask — what you want them to do Monday',
    'A joke that is about you, not them',
    'Read every slide word for word',
  ];

  @override
  Widget build(BuildContext context) {
    final List<int> order = (session.getv<List<dynamic>>('talk') ?? <dynamic>[])
        .whereType<int>()
        .toList();
    return Container(
      color: const Color(0xFF1A1010),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          const Text(
            'STAGE — 90-second brief. Pick three beats in a sequence an audience can follow. Bad beats will flatten the room.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: points.length,
              itemBuilder: (BuildContext context, int i) {
                final int slot = order.indexOf(i);
                return ListTile(
                  tileColor: slot >= 0 ? const Color(0xFF3D1F1F) : const Color(0xFF2A1818),
                  leading: Text(slot >= 0 ? '${slot + 1}' : '·', style: const TextStyle(color: Colors.white)),
                  title: Text(points[i], style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    if (order.contains(i)) return;
                    final List<int> next = <int>[...order, i];
                    session.setVar('talk', next);
                    if (i >= 3) {
                      session.act(
                        'trace_miss',
                        pause: true,
                        say: 'The room checked out. That beat is filler. Cut it and rebuild.',
                      );
                    } else if (next.length == 3 && next[0] == 0 && next[1] == 1 && next[2] == 2) {
                      session.act(
                        'decide',
                        say: 'Problem → proof → ask. That is a speech, not a recitation.',
                      );
                    } else {
                      session.act('inspect', inspect: 'Beat ${next.length}: ${points[i]}');
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetDesk extends StatelessWidget {
  const _BudgetDesk({required this.session});
  final LabSession session;

  @override
  Widget build(BuildContext context) {
    const double income = 4200;
    final double rent = session.getv<double>('rent') ?? 1600;
    final double food = session.getv<double>('food') ?? 700;
    final double debt = session.getv<double>('debt') ?? 450;
    final double save = session.getv<double>('save') ?? 200;
    final bool shock = session.getv<bool>('shock') ?? false;
    final double repair = shock ? 800 : 0;
    final double left = income - rent - food - debt - save - repair;
    return Container(
      color: const Color(0xFF0E1612),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            shock
                ? 'SHOCK — the car needs \$800 this week. Reallocate without emptying the emergency line.'
                : 'MONEY DESK — take-home \$4,200. Build a month that can survive a shock.',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          _line('Rent', rent, (double v) => session.setVar('rent', v, inspectorText: 'Rent \$${v.round()}')),
          _line('Food', food, (double v) => session.setVar('food', v, inspectorText: 'Food \$${v.round()}')),
          _line('Debt', debt, (double v) => session.setVar('debt', v, inspectorText: 'Debt \$${v.round()}')),
          _line('Save', save, (double v) {
            session.setVar('save', v, inspectorText: 'Emergency \$${v.round()}');
            if (shock && v >= 150 && left >= 0) {
              session.act('rebalance', say: 'You paid the shock and still have a floor. That is a money system.');
            }
          }),
          SwitchListTile(
            title: const Text('Apply car-repair shock', style: TextStyle(color: Colors.white)),
            value: shock,
            onChanged: (bool v) {
              session.setVar('shocked', v);
              session.setVar('shock', v);
              session.act(v ? 'shock' : 'inspect', say: v ? 'The account just took a hit. Do not freeze — rebalance.' : null);
            },
          ),
          Text(
            'Left this month: \$${left.round()}',
            style: TextStyle(
              color: left < 0 ? const Color(0xFFEF4444) : const Color(0xFF3DDBAD),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('$label  \$${value.round()}', style: const TextStyle(color: Colors.white70)),
        Slider(value: value, min: 0, max: 2500, onChanged: onChanged),
      ],
    );
  }
}

class _TeamFloor extends StatelessWidget {
  const _TeamFloor({required this.session});
  final LabSession session;

  @override
  Widget build(BuildContext context) {
    final String pick = session.getv<String>('call') ?? '';
    return Container(
      color: const Color(0xFF121820),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'FLOOR — two analysts are blocked. One missed a deadline; the other is covering quietly. What do you do first?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, height: 1.4),
          ),
          const SizedBox(height: 16),
          for (final (String id, String label, bool good) in const <(String, String, bool)>[
            ('cc', 'Copy the whole team on a blame email', false),
            ('1:1', 'Private 1:1s, then a shared plan with dates', true),
            ('do', 'Do their tickets yourself so the dashboard looks green', false),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                selected: pick == id,
                tileColor: pick == id ? const Color(0xFF1E3A32) : const Color(0xFF1C2430),
                title: Text(label, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  session.setVar('call', id);
                  if (good) {
                    session.act(
                      'decide',
                      say: 'You protected dignity and still named the miss. The floor can work again.',
                    );
                  } else {
                    session.act(
                      'trace_miss',
                      pause: true,
                      say: 'That move either humiliates or hides the problem. The dashboard will look fine until it is not.',
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
