/// Business-management workplace scenarios. Stations: `meeting_room`,
/// `manager_desk`, `complaints_desk`, `strategy_room`.
library;

import '../../core/stable_random.dart';
import '../work_task.dart';

const String _bm = 'business_manager';

String _m(num v) {
  final String s = v.round().toString();
  final StringBuffer b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '\$$b';
}

WorkScenario _kpi(int seed) {
  final StableRandom r = StableRandom(seed + 5);
  final int start = (r.nextInt(40) + 60) * 10;
  final int lostPct = 3 + r.nextInt(9);
  final int lost = (start * lostPct / 100).round();
  final int visitors = (r.nextInt(60) + 40) * 100;
  final int convPct10 = 15 + r.nextInt(40); // 1.5% .. 5.4%
  final int buyers = (visitors * convPct10 / 1000).round();
  final double churn = ((lost * 1000 / start).round()) / 10;
  final double conv = ((buyers * 1000 / visitors).round()) / 10;
  final bool churnIsProblem = churn >= 6;
  return WorkScenario(
    id: 'gen:bm_kpi:$seed',
    careerId: _bm,
    title: 'Monthly KPI review',
    brief: 'Operations sent this month\'s numbers. Work out the KPIs and decide what needs attention.',
    assignedBy: 'Operations Director',
    station: 'manager_desk',
    minutes: 50,
    difficulty: 2,
    skillGain: const <String, double>{'management': 3.0, 'finance': 1.0},
    stages: <WorkStage>[
      WorkStage.numeric(
        id: 'bm_kpi-$seed-1',
        prompt: 'You started the month with $start customers and lost $lost. What is the customer churn rate (% to one decimal)?',
        answer: churn,
        tolerance: 0.15,
        unit: '%',
        explanation: 'Churn = customers lost ÷ customers at start = $lost ÷ $start = $churn%.',
      ),
      WorkStage.numeric(
        id: 'bm_kpi-$seed-2',
        prompt: 'The website had ${_m(visitors).substring(1)} visitors and $buyers bought something. What is the conversion rate (% to one decimal)?',
        answer: conv,
        tolerance: 0.15,
        unit: '%',
        explanation: 'Conversion = buyers ÷ visitors = $buyers ÷ $visitors = $conv%.',
      ),
      WorkStage.choice(
        id: 'bm_kpi-$seed-3',
        prompt: churnIsProblem
            ? 'A monthly churn of $churn% is high for this business. What do you do first?'
            : 'Churn of $churn% is healthy, but conversion is only $conv%. What do you do first?',
        options: churnIsProblem
            ? <String>[
                'Interview or survey departing customers to find out why they left, then fix the top cause',
                'Double the advertising budget to win new customers',
                'Cut prices by 30% for everyone',
                'Ignore it; churn is normal',
              ]
            : <String>[
                'Study the checkout journey and test improvements (clearer pricing, fewer steps)',
                'Fire the website team',
                'Stop all marketing',
                'Raise prices 30%',
              ],
        correct: 0,
        explanation: churnIsProblem
            ? 'Fix the leak before pouring more water in: learn why customers leave. Advertising or discounts treat the symptom.'
            : 'Diagnose the funnel and run small experiments before big, risky changes.',
        weight: 1.5,
      ),
    ],
  );
}

WorkScenario _roi(int seed) {
  final StableRandom r = StableRandom(seed + 17);
  final int spend = (r.nextInt(8) + 3) * 1000;
  final int revenue = spend * (3 + r.nextInt(3)) + (r.nextInt(5)) * 500;
  final int marginPct = <int>[40, 50, 60][r.nextInt(3)];
  final int gross = (revenue * marginPct / 100).round();
  final int profit = gross - spend;
  final double roi = (profit * 1000 / spend).round() / 10;
  return WorkScenario(
    id: 'gen:bm_roi:$seed',
    careerId: _bm,
    title: 'Was the campaign worth it?',
    brief: 'Marketing wants more budget. Check the return on the last campaign.',
    assignedBy: 'Operations Director',
    station: 'manager_desk',
    minRank: 1,
    minutes: 40,
    difficulty: 2,
    skillGain: const <String, double>{'management': 2.5, 'finance': 2.0},
    stages: <WorkStage>[
      WorkStage.numeric(
        id: 'bm_roi-$seed-1',
        prompt: 'The campaign cost ${_m(spend)} and generated ${_m(revenue)} in sales. Products carry a $marginPct% gross margin. What was the gross profit from those sales?',
        answer: gross.toDouble(),
        tolerance: 1,
        unit: '\$',
        explanation: '${_m(revenue)} × $marginPct% = ${_m(gross)}.',
      ),
      WorkStage.numeric(
        id: 'bm_roi-$seed-2',
        prompt: 'What was the return on investment (ROI) as a percentage of spend, to one decimal?',
        answer: roi,
        tolerance: 0.2,
        unit: '%',
        explanation: 'ROI = (gross profit − spend) ÷ spend = (${_m(gross)} − ${_m(spend)}) ÷ ${_m(spend)} = $roi%.',
      ),
      WorkStage.choice(
        id: 'bm_roi-$seed-3',
        prompt: roi > 0 ? 'What is the sensible decision?' : 'The campaign lost money. What is the sensible decision?',
        options: roi > 0
            ? <String>[
                'Approve a modest increase and track ROI per channel so you can scale what works',
                'Triple the budget immediately without measurement',
                'Cancel marketing forever',
                'Hide the numbers from the team',
              ]
            : <String>[
                'Pause or redesign the campaign and test smaller variations before spending more',
                'Spend even more to "make it back"',
                'Blame the agency publicly',
                'Hide the numbers from the team',
              ],
        correct: 0,
        explanation: 'Decide from the data: scale what is proven in measured steps; stop or fix what loses money.',
      ),
    ],
  );
}

final List<ScenarioGenerator> businessGenerators = <ScenarioGenerator>[
  ScenarioGenerator(id: 'bm_kpi', careerId: _bm, build: _kpi),
  ScenarioGenerator(id: 'bm_roi', careerId: _bm, build: _roi, minRank: 1),
];

final List<WorkScenario> businessScenarios = <WorkScenario>[
  WorkScenario(
    id: 'bm_meeting',
    careerId: _bm,
    title: 'Run the weekly team meeting',
    brief: 'Your Monday meetings drag on for 90 minutes with no decisions. Fix them.',
    assignedBy: 'Operations Director',
    station: 'meeting_room',
    minutes: 40,
    skillGain: const <String, double>{'management': 2.5, 'communication': 1.5, 'teamwork': 1.5},
    stages: <WorkStage>[
      WorkStage.multi(
        id: 'bm_meeting-1',
        prompt: 'Which practices make a meeting effective?',
        options: <String>[
          'Send an agenda in advance with the decisions needed',
          'Timebox topics and keep the meeting to 30 minutes',
          'End with written action items: who, what, by when',
          'Invite everyone in the company "just in case"',
          'Let the loudest person decide every topic',
        ],
        correct: <int>[0, 1, 2],
        explanation: 'Agenda, time limits and clear owners turn meetings into decisions.',
      ),
    ],
  ),
  WorkScenario(
    id: 'bm_delegate',
    careerId: _bm,
    title: 'Delegate the right work to the right people',
    brief: 'Three new jobs arrived. Assign each to the best person, considering strengths and workload.',
    assignedBy: 'Operations Director',
    station: 'manager_desk',
    minutes: 40,
    difficulty: 2,
    skillGain: const <String, double>{'management': 3.0, 'teamwork': 1.0},
    stages: <WorkStage>[
      WorkStage.choice(
        id: 'bm_delegate-1',
        prompt: 'Job 1: analyse last quarter\'s sales by region and recommend where to invest. Who gets it?',
        table: <List<String>>[
          <String>['Team member', 'Strength', 'Current workload'],
          <String>['Ana', 'Data analysis', '35%'],
          <String>['Ben', 'Customer service', '125% (overloaded)'],
          <String>['Chi', 'Junior, eager to learn', '40%'],
          <String>['Dara', 'Design', '85%'],
        ],
        options: <String>['Ana', 'Ben', 'Chi', 'Dara'],
        correct: 0,
        explanation: 'Match the task to strength when capacity allows: Ana is the analyst and has room.',
      ),
      WorkStage.choice(
        id: 'bm_delegate-2',
        prompt: 'Job 2: write a new-starter guide (low risk, great learning opportunity). Who gets it?',
        options: <String>['Ana', 'Ben', 'Chi', 'Dara'],
        correct: 2,
        explanation: 'Developmental, low-risk work with spare capacity suits Chi. Ben is already overloaded.',
      ),
      WorkStage.choice(
        id: 'bm_delegate-3',
        prompt: 'Ben is at 125% workload and a VIP customer needs urgent help. What is the best move?',
        options: <String>[
          'Give Ben the VIP case on top of everything else',
          'Reprioritise: move some of Ben\'s lower-value tasks to others, then give Ben the VIP case',
          'Ignore the VIP; they will wait',
          'Handle everything yourself, every time',
        ],
        correct: 1,
        explanation: 'Rebalance workload instead of stacking more on one person; protect the important customer.',
      ),
    ],
  ),
  WorkScenario(
    id: 'bm_complaint',
    careerId: _bm,
    title: 'The furious customer',
    brief: 'Mrs. Adaobi storms in: "My order arrived two weeks late AND it\'s the wrong item! This is the third time! I want to speak to the manager!"',
    assignedBy: 'Operations Director',
    station: 'complaints_desk',
    minutes: 30,
    skillGain: const <String, double>{'communication': 3.0, 'management': 1.5},
    stages: <WorkStage>[
      WorkStage.text(
        id: 'bm_complaint-1',
        prompt: 'Write what you would say to Mrs. Adaobi.',
        rubric: const <RubricItem>[
          RubricItem('Genuine apology and ownership (no blame)', <String>['sorry', 'apolog', 'my responsibility', 'i take ownership', 'our mistake']),
          RubricItem('Empathy for the impact', <String>['frustrat', 'understand', 'i can see', 'must have been', 'upsetting', 'disappoint']),
          RubricItem('A concrete solution (refund, replacement, expedited)', <String>['refund', 'replace', 'send the correct', 'deliver', 'compensat', 'credit', 'voucher']),
          RubricItem('A timeline or commitment', <String>['today', 'tomorrow', 'within', 'by ', 'hours', 'days']),
          RubricItem('Prevent a repeat and follow up', <String>['investigat', 'prevent', 'follow up', 'call you', 'make sure', 'check why', 'process']),
        ],
        modelAnswer: 'I am so sorry — this is our mistake and I understand how frustrating a third failure must be. I will send the correct item by express delivery today at no charge and refund this order. '
            'I will also investigate why this keeps happening so it does not happen again, and I will personally call you tomorrow to check it arrived.',
        minWords: 30,
      ),
    ],
  ),
  WorkScenario(
    id: 'bm_prioritise',
    careerId: _bm,
    title: 'Everything is urgent',
    brief: 'Four projects want your team this week and you can only fully staff two. Rank them.',
    assignedBy: 'Operations Director',
    station: 'manager_desk',
    minRank: 1,
    minutes: 30,
    difficulty: 2,
    skillGain: const <String, double>{'management': 2.5, 'problem_solving': 1.0},
    stages: <WorkStage>[
      WorkStage.order(
        id: 'bm_prioritise-1',
        prompt: 'Order the projects from highest to lowest priority.',
        options: <String>[
          'Fix the billing bug that is overcharging 2,000 customers',
          'Prepare the contract renewal for the biggest client (due Friday)',
          'Redesign the office kitchen',
          'Experiment with a new social-media logo',
        ],
        correct: <int>[0, 1, 2, 3],
        explanation: 'Customer harm and legal risk first, then revenue at risk with a deadline, then internal comfort and cosmetic experiments.',
      ),
    ],
  ),
  WorkScenario(
    id: 'bm_underperf',
    careerId: _bm,
    title: 'The struggling team member',
    brief: 'Sam has missed targets for three months in a row and the rest of the team is getting frustrated.',
    assignedBy: 'Operations Director',
    station: 'manager_desk',
    minRank: 2,
    minutes: 40,
    difficulty: 3,
    skillGain: const <String, double>{'management': 3.0, 'communication': 2.0},
    stages: <WorkStage>[
      WorkStage.order(
        id: 'bm_underperf-1',
        prompt: 'Put your steps in a fair and effective order.',
        options: <String>[
          'Hold a private one-to-one: listen to find the causes',
          'Set clear, measurable expectations and a support plan with dates',
          'Provide training or resources and check in weekly',
          'Review progress; if there is still no improvement, follow the formal HR process',
        ],
        correct: <int>[0, 1, 2, 3],
        explanation: 'Listen first, set clear goals, support, then escalate formally only if needed — and document each step.',
      ),
    ],
  ),
  WorkScenario(
    id: 'bm_strategy',
    careerId: _bm,
    title: 'A cheap competitor arrives',
    brief: 'A rival opens next door selling similar products 20% cheaper. Customers are asking questions.',
    assignedBy: 'Director of Operations',
    station: 'strategy_room',
    minRank: 3,
    minutes: 60,
    difficulty: 3,
    skillGain: const <String, double>{'management': 3.0, 'finance': 1.5},
    stages: <WorkStage>[
      WorkStage.multi(
        id: 'bm_strategy-1',
        prompt: 'Which actions are sound strategy?',
        options: <String>[
          'Analyse who is leaving and why (price, quality, service)',
          'Differentiate on service, quality and loyalty rewards instead of competing only on price',
          'Cut prices 30% immediately across the board',
          'Protect margins by checking which products can absorb a price match',
          'Reduce quality secretly to keep margins',
        ],
        correct: <int>[0, 1, 3],
        explanation: 'Understand the threat with data, defend with value, and make targeted price moves. A blanket price war or secret quality cuts damage the business.',
        notes: <int, String>{2: 'A price war can destroy margins.', 4: 'Hidden quality cuts break trust.'},
      ),
      WorkStage.choice(
        id: 'bm_strategy-2',
        prompt: 'Which metric would best tell you if your response is working after 3 months?',
        options: <String>[
          'Number of social-media likes',
          'Customer retention and repeat-purchase rate, alongside profit margin',
          'How many employees attended the party',
          'The size of the shop sign',
        ],
        correct: 1,
        explanation: 'Retention and margin directly measure whether you kept customers profitably.',
      ),
    ],
  ),
  WorkScenario(
    id: 'bm_hire',
    careerId: _bm,
    title: 'Hire the right person',
    brief: 'You have an opening on your team and three finalists. Design a fair hiring process.',
    assignedBy: 'Director of Operations',
    station: 'manager_desk',
    minRank: 3,
    minutes: 45,
    difficulty: 3,
    skillGain: const <String, double>{'management': 3.0, 'communication': 1.5},
    stages: <WorkStage>[
      WorkStage.multi(
        id: 'bm_hire-1',
        prompt: 'Which hiring practices are sound?',
        options: <String>[
          'Use the same structured questions and scoring for every candidate',
          'Include a job-relevant work sample',
          'Check references',
          'Hire the candidate you would most like to have a drink with',
          'Decide based on gut feeling in the first 5 minutes',
        ],
        correct: <int>[0, 1, 2],
        explanation: 'Structured interviews, work samples and references predict performance. Likeability and gut feeling introduce bias.',
      ),
    ],
  ),
  WorkScenario(
    id: 'bm_present',
    careerId: _bm,
    title: 'Present results to the board',
    brief: 'Sales are up 8% but profit is down 3%. Brief the management team in a short report.',
    assignedBy: 'Director of Operations',
    station: 'meeting_room',
    minRank: 1,
    minutes: 45,
    difficulty: 2,
    skillGain: const <String, double>{'communication': 3.0, 'management': 2.0},
    stages: <WorkStage>[
      WorkStage.text(
        id: 'bm_present-1',
        prompt: 'Write your briefing: headline, evidence, cause, action and what you need from them.',
        rubric: const <RubricItem>[
          RubricItem('Leads with a clear headline', <String>['headline', 'in short', 'summary', 'sales are up', 'profit is down', 'the key point']),
          RubricItem('Uses the data (8%, 3%)', <String>['8%', '3%', 'margin', 'revenue', 'profit']),
          RubricItem('Explains a cause', <String>['because', 'driven by', 'due to', 'cost', 'discount', 'shipping', 'supplier']),
          RubricItem('Proposes actions', <String>['propose', 'recommend', 'we will', 'plan', 'action', 'review pricing', 'negotiate']),
          RubricItem('States a clear ask or decision needed', <String>['i need', 'approval', 'decision', 'we ask', 'please approve', 'request']),
        ],
        modelAnswer: 'Headline: sales are up 8% but profit is down 3%. The cause is higher shipping costs and heavier discounting, which cut our margin. '
            'I recommend renegotiating our carrier contract and capping discounts at 10%, and I need your approval to start this month.',
        minWords: 30,
      ),
    ],
  ),
  WorkScenario(
    id: 'bm_restructure',
    careerId: _bm,
    title: 'Announce a restructuring',
    brief: 'The company must cut 10% of roles. You lead the announcement for your division.',
    assignedBy: 'CEO',
    station: 'strategy_room',
    minRank: 5,
    minutes: 60,
    difficulty: 3,
    skillGain: const <String, double>{'management': 3.5, 'communication': 2.5},
    stages: <WorkStage>[
      WorkStage.multi(
        id: 'bm_restructure-1',
        prompt: 'Which actions reflect responsible leadership?',
        options: <String>[
          'Tell affected employees personally and privately first, with HR present',
          'Explain the reasons honestly and the criteria used',
          'Offer support: severance, references and outplacement help',
          'Announce it by email at 5:55 pm on Friday and disappear',
          'Promise there will be no more cuts, whatever happens',
        ],
        correct: <int>[0, 1, 2],
        explanation: 'Treat people with dignity: private, honest, supported. Avoid cowardly timing and promises you cannot keep.',
      ),
    ],
  ),
];
