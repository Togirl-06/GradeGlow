/// Accounting workplace scenarios. Stations: `ledger_desk`, `audit_room`,
/// `reporting_desk`. Several are generated from a seed so the numbers differ.
library;

import '../../core/stable_random.dart';
import '../work_task.dart';

const String _ac = 'accountant';

String _m(num v) {
  final String s = v.round().toString();
  final StringBuffer b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '\$$b';
}

class _Txn {
  const _Txn(this.text, this.dr, this.cr);
  final String Function(int amount) text;
  final String dr;
  final String cr;
}

final List<_Txn> _txns = <_Txn>[
  _Txn((int a) => 'The owner invests ${_m(a)} cash into the business.', 'Cash', "Owner's capital"),
  _Txn((int a) => 'The company buys office equipment for ${_m(a)} on credit.', 'Equipment', 'Accounts payable'),
  _Txn((int a) => 'The firm completes a service for a customer, who will pay later: ${_m(a)}.', 'Accounts receivable', 'Service revenue'),
  _Txn((int a) => 'The company pays ${_m(a)} cash for this month\'s rent.', 'Rent expense', 'Cash'),
  _Txn((int a) => 'A customer pays an outstanding invoice of ${_m(a)}.', 'Cash', 'Accounts receivable'),
  _Txn((int a) => 'The company pays a supplier ${_m(a)} it owed.', 'Accounts payable', 'Cash'),
  _Txn((int a) => 'The bank lends the company ${_m(a)}, paid into the account.', 'Cash', 'Loan payable'),
  _Txn((int a) => 'Staff salaries of ${_m(a)} are paid in cash.', 'Salaries expense', 'Cash'),
  _Txn((int a) => 'A customer prepays ${_m(a)} for services to be delivered next month.', 'Cash', 'Unearned revenue'),
  _Txn((int a) => 'The company buys ${_m(a)} of office supplies, paying cash.', 'Supplies', 'Cash'),
];

const List<String> _accountPool = <String>[
  'Cash', 'Accounts receivable', 'Accounts payable', 'Equipment', 'Service revenue', 'Rent expense',
  "Owner's capital", 'Loan payable', 'Salaries expense', 'Unearned revenue', 'Supplies',
];

WorkScenario _journal(int seed) {
  final StableRandom r = StableRandom(seed);
  final List<_Txn> picks = r.sample<_Txn>(_txns, 3);
  final List<WorkStage> stages = <WorkStage>[];
  for (int i = 0; i < picks.length; i++) {
    final _Txn t = picks[i];
    final int amount = (r.nextInt(18) + 2) * 100;
    final String right = 'Debit ${t.dr}, credit ${t.cr}';
    final String swapped = 'Debit ${t.cr}, credit ${t.dr}';
    final List<String> others = _accountPool.where((String a) => a != t.dr && a != t.cr).toList();
    final String wrong1 = 'Debit ${t.dr}, credit ${r.pick(others)}';
    final String wrong2 = 'Debit ${r.pick(others)}, credit ${t.cr}';
    final List<String> opts = r.shuffled<String>(<String>{right, swapped, wrong1, wrong2}.toList());
    stages.add(WorkStage.choice(
      id: 'ac_journal-$seed-$i',
      prompt: t.text(amount),
      options: opts,
      correct: opts.indexOf(right),
      explanation: 'Debit the account that increases on the left side (assets/expenses) or decreases on the right (liabilities/equity/revenue). '
          'Here: $right.',
    ));
  }
  return WorkScenario(
    id: 'gen:ac_journal:$seed',
    careerId: _ac,
    title: 'Post the journal entries',
    brief: 'Three transactions arrived today. Record each as a double-entry journal entry.',
    assignedBy: 'Finance Manager',
    station: 'ledger_desk',
    minutes: 45,
    skillGain: const <String, double>{'accounting': 3.0},
    stages: stages,
  );
}

WorkScenario _bankRec(int seed) {
  final StableRandom r = StableRandom(seed + 7);
  final int deposit = (r.nextInt(8) + 2) * 100;
  final int outstanding = (r.nextInt(8) + 2) * 100 + 50;
  final int fee = (r.nextInt(4) + 1) * 10;
  final int interest = r.nextInt(5) + 2;
  final int bank = (r.nextInt(30) + 40) * 100;
  final int adjustedBank = bank + deposit - outstanding;
  final int ledger = adjustedBank + fee - interest;
  return WorkScenario(
    id: 'gen:ac_bankrec:$seed',
    careerId: _ac,
    title: 'Bank reconciliation',
    brief: 'Month-end: the bank statement and the cash ledger differ. Reconcile them.',
    assignedBy: 'Finance Manager',
    station: 'ledger_desk',
    minRank: 0,
    minutes: 60,
    difficulty: 2,
    skillGain: const <String, double>{'accounting': 3.5, 'problem_solving': 1.0},
    stages: <WorkStage>[
      WorkStage.numeric(
        id: 'ac_bankrec-$seed-1',
        prompt: 'Adjust the BANK side: add deposits in transit, subtract outstanding cheques. What is the adjusted bank balance?',
        table: <List<String>>[
          <String>['Bank statement', 'Amount'],
          <String>['Balance per bank statement', _m(bank)],
          <String>['Deposit in transit (not yet credited)', _m(deposit)],
          <String>['Outstanding cheques (not yet cleared)', _m(outstanding + 0)],
        ],
        answer: adjustedBank.toDouble(),
        tolerance: 0.5,
        unit: '\$',
        explanation: '${_m(bank)} + ${_m(deposit)} − ${_m(outstanding)} = ${_m(adjustedBank)}.',
      ),
      WorkStage.numeric(
        id: 'ac_bankrec-$seed-2',
        prompt: 'Now adjust the LEDGER: subtract bank fees, add interest earned. What should the adjusted ledger balance be?',
        table: <List<String>>[
          <String>['Cash ledger', 'Amount'],
          <String>['Balance per ledger', _m(ledger)],
          <String>['Bank fees not yet recorded', _m(fee)],
          <String>['Interest earned not yet recorded', _m(interest)],
        ],
        answer: adjustedBank.toDouble(),
        tolerance: 0.5,
        unit: '\$',
        explanation: '${_m(ledger)} − ${_m(fee)} + ${_m(interest)} = ${_m(adjustedBank)}, matching the adjusted bank balance — the accounts reconcile.',
      ),
      WorkStage.choice(
        id: 'ac_bankrec-$seed-3',
        prompt: 'Which items need a journal entry in YOUR books (not just a note)?',
        options: <String>[
          'Bank fees and interest earned',
          'Deposits in transit and outstanding cheques',
          'Both groups',
          'Neither',
        ],
        correct: 0,
        explanation: 'Fees and interest are events your ledger has not recorded yet. Deposits in transit and outstanding cheques are already in your books; the bank will catch up.',
      ),
    ],
  );
}

WorkScenario _trialBalance(int seed) {
  final StableRandom r = StableRandom(seed + 31);
  final bool transposition = r.chance(0.5);
  int diff;
  if (transposition) {
    // Multiples of 9 that do not look like round amounts (27, 36, 54, 63 …).
    do {
      diff = 9 * (r.nextInt(30) + 3);
    } while (diff % 10 == 0);
  } else {
    // Round amounts that are NOT divisible by 9 (so only one explanation fits).
    do {
      diff = (r.nextInt(18) + 2) * 50;
    } while (diff % 9 == 0);
  }
  final int debits = (r.nextInt(80) + 120) * 100;
  final int credits = debits - diff;
  final List<String> options = transposition
      ? <String>[
          'A transposition error (two digits swapped when posting), since the difference divides evenly by 9',
          'A single entry was posted only to one side (an amount equal to the difference was omitted)',
          'Revenue was recorded as expense',
          'The trial balance is correct',
        ]
      : <String>[
          'A transposition error (digits swapped), since the difference is divisible by 9',
          'One side of a ${_m(diff)} entry was not posted (a one-sided entry)',
          'Two equal and opposite errors cancelled out',
          'The trial balance is correct',
        ];
  final int correct = transposition ? 0 : 1;
  return WorkScenario(
    id: 'gen:ac_tb:$seed',
    careerId: _ac,
    title: 'The trial balance does not balance',
    brief: 'Total debits are ${_m(debits)} but total credits are ${_m(credits)}. Find the type of error before you hunt for it.',
    assignedBy: 'Finance Manager',
    station: 'ledger_desk',
    minRank: 1,
    minutes: 50,
    difficulty: 2,
    skillGain: const <String, double>{'accounting': 3.5, 'problem_solving': 1.5},
    stages: <WorkStage>[
      WorkStage.choice(
        id: 'ac_tb-$seed-1',
        prompt: 'The difference is ${_m(diff)}. What is the most likely cause?',
        options: options,
        correct: correct,
        explanation: transposition
            ? 'A difference divisible by 9 is a classic sign of transposed digits (e.g. 540 recorded as 450).'
            : 'A difference equal to a round transaction amount suggests half an entry was never posted.',
        weight: 2,
      ),
      WorkStage.choice(
        id: 'ac_tb-$seed-2',
        prompt: 'What is the best first step to find it?',
        options: <String>[
          'Plug the difference into a "suspense" account and move on',
          'Re-add the columns, then trace postings from the journal to the ledger for entries matching the difference',
          'Delete the largest entry',
          'Ask the owner to guess',
        ],
        correct: 1,
        explanation: 'Re-check the arithmetic, then trace journal-to-ledger postings. A suspense account is a last resort and must be cleared.',
      ),
    ],
  );
}

WorkScenario _depreciation(int seed) {
  final StableRandom r = StableRandom(seed + 3);
  final int cost = (r.nextInt(20) + 10) * 1000;
  final int life = <int>[4, 5, 8, 10][r.nextInt(4)];
  final int salvage = cost ~/ 10;
  final int yearly = ((cost - salvage) / life).round();
  final int years = 2 + r.nextInt(life - 2);
  final int bookValue = cost - yearly * years;
  return WorkScenario(
    id: 'gen:ac_dep:$seed',
    careerId: _ac,
    title: 'Depreciation schedule',
    brief: 'A new delivery van must be depreciated using the straight-line method.',
    assignedBy: 'Finance Manager',
    station: 'reporting_desk',
    minutes: 40,
    difficulty: 2,
    skillGain: const <String, double>{'accounting': 3.0},
    stages: <WorkStage>[
      WorkStage.numeric(
        id: 'ac_dep-$seed-1',
        prompt: 'Cost ${_m(cost)}, residual (salvage) value ${_m(salvage)}, useful life $life years. What is the annual depreciation expense?',
        answer: yearly.toDouble(),
        tolerance: 1,
        unit: '\$',
        explanation: '(${_m(cost)} − ${_m(salvage)}) ÷ $life = ${_m(yearly)} per year.',
      ),
      WorkStage.numeric(
        id: 'ac_dep-$seed-2',
        prompt: 'What is the van\'s net book value after $years years?',
        answer: bookValue.toDouble(),
        tolerance: 2,
        unit: '\$',
        explanation: '${_m(cost)} − ($years × ${_m(yearly)}) = ${_m(bookValue)}.',
      ),
    ],
  );
}

WorkScenario _incomeStatement(int seed) {
  final StableRandom r = StableRandom(seed + 11);
  final int revenue = (r.nextInt(60) + 80) * 1000;
  final int cogs = (revenue * (0.35 + r.nextInt(20) / 100)).round() ~/ 100 * 100;
  final int opex = (revenue * (0.18 + r.nextInt(10) / 100)).round() ~/ 100 * 100;
  final int tax = ((revenue - cogs - opex) * 0.2).round() ~/ 10 * 10;
  final int gross = revenue - cogs;
  final int net = gross - opex - tax;
  final double marginPct = (gross * 1000 / revenue).round() / 10;
  return WorkScenario(
    id: 'gen:ac_is:$seed',
    careerId: _ac,
    title: 'Prepare the monthly income statement',
    brief: 'The owner wants the profit figures for this quarter.',
    assignedBy: 'Finance Manager',
    station: 'reporting_desk',
    minRank: 1,
    minutes: 55,
    difficulty: 2,
    skillGain: const <String, double>{'accounting': 3.5, 'finance': 1.0},
    stages: <WorkStage>[
      WorkStage.numeric(
        id: 'ac_is-$seed-1',
        prompt: 'What is gross profit?',
        table: <List<String>>[
          <String>['Item', 'Amount'],
          <String>['Revenue', _m(revenue)],
          <String>['Cost of goods sold', _m(cogs)],
          <String>['Operating expenses', _m(opex)],
          <String>['Tax', _m(tax)],
        ],
        answer: gross.toDouble(),
        tolerance: 1,
        unit: '\$',
        explanation: 'Revenue − cost of goods sold = ${_m(revenue)} − ${_m(cogs)} = ${_m(gross)}.',
      ),
      WorkStage.numeric(
        id: 'ac_is-$seed-2',
        prompt: 'What is net profit after operating expenses and tax?',
        answer: net.toDouble(),
        tolerance: 1,
        unit: '\$',
        explanation: '${_m(gross)} − ${_m(opex)} − ${_m(tax)} = ${_m(net)}.',
      ),
      WorkStage.numeric(
        id: 'ac_is-$seed-3',
        prompt: 'What is the gross margin as a percentage (to one decimal place)?',
        answer: marginPct,
        tolerance: 0.15,
        unit: '%',
        explanation: 'Gross profit ÷ revenue × 100 = ${_m(gross)} ÷ ${_m(revenue)} = $marginPct%.',
      ),
    ],
  );
}

final List<ScenarioGenerator> accountingGenerators = <ScenarioGenerator>[
  ScenarioGenerator(id: 'ac_journal', careerId: _ac, build: _journal, maxRank: 3),
  ScenarioGenerator(id: 'ac_bankrec', careerId: _ac, build: _bankRec, maxRank: 4),
  ScenarioGenerator(id: 'ac_tb', careerId: _ac, build: _trialBalance, minRank: 1),
  ScenarioGenerator(id: 'ac_dep', careerId: _ac, build: _depreciation, minRank: 1),
  ScenarioGenerator(id: 'ac_is', careerId: _ac, build: _incomeStatement, minRank: 1),
];

final List<WorkScenario> accountingScenarios = <WorkScenario>[
  WorkScenario(
    id: 'ac_audit_flags',
    careerId: _ac,
    title: 'Audit sample: spot the red flags',
    brief: 'Auditors sampled these payments. Flag the ones that deserve a closer look.',
    assignedBy: 'Audit Partner',
    station: 'audit_room',
    minRank: 1,
    minutes: 60,
    difficulty: 2,
    skillGain: const <String, double>{'accounting': 3.0, 'problem_solving': 1.5},
    stages: <WorkStage>[
      WorkStage.multi(
        id: 'ac_audit_flags-1',
        prompt: 'Select every payment with a genuine red flag.',
        table: <List<String>>[
          <String>['#', 'Payment', 'Detail'],
          <String>['1', 'Invoice 4471 — Acme Cleaning', 'Paid on 3 Mar; the same invoice number is paid again on 17 Mar'],
          <String>['2', 'Consulting — J. Park', '\$9,900 paid; approval limit is \$10,000; vendor shares an address with an employee'],
          <String>['3', 'Office rent — Landlord Ltd', '\$2,400 paid on the 1st, matches contract'],
          <String>['4', 'Stationery — PaperWorld', '\$180 paid within 30-day terms with a purchase order'],
          <String>['5', 'Cash withdrawal', '\$4,950 on Saturday night, no supporting document'],
        ],
        options: <String>[
          '1 — possible duplicate payment',
          '2 — just under the approval limit and a related party',
          '3 — recurring rent, matches contract',
          '4 — small, authorised purchase',
          '5 — unsupported weekend cash withdrawal',
        ],
        correct: <int>[0, 1, 4],
        explanation: 'Duplicates, amounts just below approval thresholds with related parties, and undocumented cash movements are classic fraud/error indicators.',
      ),
    ],
  ),
  WorkScenario(
    id: 'ac_ethics',
    careerId: _ac,
    title: 'Pressure to backdate',
    brief: 'The sales director asks you to date a January invoice in December "so we hit the annual target".',
    assignedBy: 'Finance Manager',
    station: 'audit_room',
    minRank: 1,
    minutes: 30,
    difficulty: 2,
    skillGain: const <String, double>{'accounting': 1.5, 'communication': 2.0},
    stages: <WorkStage>[
      WorkStage.choice(
        id: 'ac_ethics-1',
        prompt: 'What do you do?',
        options: <String>[
          'Do it quietly — it is only a few days',
          'Politely decline, explain the revenue-recognition rule, document the request, and escalate to your manager/compliance if pressed',
          'Do it, but delete the email so there is no trace',
          'Ignore the request and say nothing to anyone',
        ],
        correct: 1,
        explanation: 'Accountants must record transactions in the right period. Decline, document, and escalate — integrity protects you and the firm.',
        notes: <int, String>{0: 'Misstating the period is fraud, however small.', 2: 'Concealment makes it worse.'},
      ),
    ],
  ),
  WorkScenario(
    id: 'ac_accrual',
    careerId: _ac,
    title: 'Accrual accounting',
    brief: 'In December you finished a \$3,000 job; the invoice is sent and paid in January.',
    assignedBy: 'Finance Manager',
    station: 'reporting_desk',
    minutes: 25,
    skillGain: const <String, double>{'accounting': 2.5},
    stages: <WorkStage>[
      WorkStage.choice(
        id: 'ac_accrual-1',
        prompt: 'Under accrual accounting, when is the revenue recorded?',
        options: <String>['In December, when the work was done', 'In January, when the cash arrives', 'Half in each month', 'Whenever the owner prefers'],
        correct: 0,
        explanation: 'Accrual accounting records revenue when it is earned, not when cash is received. December gets the revenue (and a receivable).',
      ),
    ],
  ),
  WorkScenario(
    id: 'ac_payroll',
    careerId: _ac,
    title: 'Run payroll',
    brief: 'Calculate this month\'s pay for an employee.',
    assignedBy: 'Finance Manager',
    station: 'ledger_desk',
    minutes: 30,
    skillGain: const <String, double>{'accounting': 2.5},
    stages: <WorkStage>[
      WorkStage.numeric(
        id: 'ac_payroll-1',
        prompt: 'Gross pay is \$3,200 and income tax withheld is 15%. What is the net pay?',
        answer: 2720,
        tolerance: 0.5,
        unit: '\$',
        explanation: '15% of \$3,200 = \$480, so net pay = \$3,200 − \$480 = \$2,720. (The \$480 is paid to the tax authority.)',
      ),
      WorkStage.numeric(
        id: 'ac_payroll-2',
        prompt: 'The employer also pays 8% payroll contributions on gross pay. What is the total cost to the employer?',
        answer: 3456,
        tolerance: 0.5,
        unit: '\$',
        explanation: '8% of \$3,200 = \$256; gross + contributions = \$3,456.',
      ),
    ],
  ),
  WorkScenario(
    id: 'ac_ratios',
    careerId: _ac,
    title: 'Can the client pay its bills?',
    brief: 'A client\'s bank asks whether the company is liquid. Calculate the current ratio and interpret it.',
    assignedBy: 'Accounting Team Lead',
    station: 'reporting_desk',
    minRank: 2,
    minutes: 45,
    difficulty: 3,
    skillGain: const <String, double>{'accounting': 2.5, 'finance': 2.0},
    stages: <WorkStage>[
      WorkStage.numeric(
        id: 'ac_ratios-1',
        prompt: 'Current assets are \$84,000 and current liabilities are \$60,000. What is the current ratio (to 2 decimals)?',
        answer: 1.4,
        tolerance: 0.01,
        explanation: 'Current assets ÷ current liabilities = 84,000 ÷ 60,000 = 1.40.',
      ),
      WorkStage.choice(
        id: 'ac_ratios-2',
        prompt: 'What does a current ratio of 1.40 suggest?',
        options: <String>[
          'The company has \$1.40 of short-term assets for every \$1 of short-term debts — adequate liquidity',
          'The company is bankrupt',
          'The company earns 140% profit',
          'It means nothing',
        ],
        correct: 0,
        explanation: 'Above 1 means short-term assets cover short-term liabilities; around 1.2–2 is usually considered healthy, depending on the industry.',
      ),
    ],
  ),
  WorkScenario(
    id: 'ac_explain',
    careerId: _ac,
    title: 'Explain the numbers to the owner',
    brief: 'The bakery owner says: "I made sales of \$90,000 but there is hardly any cash in the bank. Where did the money go?"',
    assignedBy: 'Accounting Team Lead',
    station: 'reporting_desk',
    minRank: 2,
    minutes: 40,
    difficulty: 2,
    skillGain: const <String, double>{'accounting': 1.5, 'communication': 3.0},
    stages: <WorkStage>[
      WorkStage.text(
        id: 'ac_explain-1',
        prompt: 'Write a clear explanation in plain language.',
        rubric: const <RubricItem>[
          RubricItem('Profit is not the same as cash', <String>['profit is not', 'not the same as cash', 'cash flow', 'cash and profit', 'profit and cash', 'profit isn']),
          RubricItem('Mentions customers who have not paid yet (receivables)', <String>['receivable', 'unpaid', 'customers owe', 'owed to you', 'invoices']),
          RubricItem('Mentions inventory/equipment or loan repayments tying up cash', <String>['stock', 'inventory', 'equipment', 'loan', 'repay', 'bought']),
          RubricItem('Suggests actions (chase invoices, budget, forecast)', <String>['chase', 'forecast', 'budget', 'follow up', 'terms', 'faster']),
          RubricItem('Uses simple, non-technical language and offers help', <String>['happy to', 'walk you through', 'let me', 'simple', 'i can']),
        ],
        modelAnswer: 'Profit and cash are different. Many of your \$90,000 of sales are invoices customers have not paid yet, and you also spent cash on stock, a new oven and a loan repayment. '
            'I suggest we chase overdue invoices, shorten payment terms and build a monthly cash forecast. I am happy to walk you through the numbers.',
        minWords: 30,
      ),
    ],
  ),
  WorkScenario(
    id: 'ac_controls',
    careerId: _ac,
    title: 'Design internal controls',
    brief: 'You lead the accounting team. The company had a payment fraud last year. Strengthen the controls.',
    assignedBy: 'Finance Director',
    station: 'audit_room',
    minRank: 4,
    minutes: 45,
    difficulty: 3,
    skillGain: const <String, double>{'accounting': 2.0, 'management': 2.5},
    stages: <WorkStage>[
      WorkStage.multi(
        id: 'ac_controls-1',
        prompt: 'Which controls reduce the risk of payment fraud?',
        options: <String>[
          'Segregation of duties: the person who approves payments is not the one who sets up suppliers',
          'Dual approval above a threshold',
          'Monthly bank reconciliations reviewed by someone independent',
          'One person controls vendors, approvals and payments to keep things efficient',
          'Never review old payments',
        ],
        correct: <int>[0, 1, 2],
        explanation: 'Segregation of duties, dual approval and independent reconciliation are core controls. Concentrating power in one person and skipping reviews invites fraud.',
      ),
    ],
  ),
];
