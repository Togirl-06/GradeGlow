import '../lab_models.dart';
import 'gen_acc_core.dart';

// Accounting (Professional Accounting Firm). The ledger, trial balance and
// statements are computed live from the student's own entries.

const List<String> bakeryAccounts = <String>[
  'Cash',
  'Accounts receivable',
  'Equipment',
  'Vehicles',
  'Accounts payable',
  'Bank loan',
  'Owner\'s capital',
  'Sales revenue',
  'Purchases',
  'Wages expense',
  'Rent expense',
];

/// Normal balance side for each account (true = debit).
const Map<String, bool> bakeryNormalDebit = <String, bool>{
  'Cash': true,
  'Accounts receivable': true,
  'Equipment': true,
  'Vehicles': true,
  'Accounts payable': false,
  'Bank loan': false,
  'Owner\'s capital': false,
  'Sales revenue': false,
  'Purchases': true,
  'Wages expense': true,
  'Rent expense': true,
};

const List<LabPerson> _firm = <LabPerson>[
  LabPerson('Rachel Holt', 'Audit manager, Carver & Holt', 'Every entry needs a source document. If it does not balance, it does not go in.'),
  LabPerson('Sam Okoro', 'Owner, Riverside Bakery (client)', 'I keep every receipt in this folder — I hope that helps!'),
];

final LabSpec accountingBookkeepingLab = LabSpec(
  id: 'acc_lab_bookkeeping',
  deptId: 'business',
  majorId: 'accounting',
  number: 1,
  title: 'Bookkeeping, Journals and Ledgers',
  environment: LabEnvironment.accountingFirm,
  summary: 'Record a new client\'s first month from source documents. Postings, T-accounts and the trial balance update from your entries.',
  objectives: const <String>['Identify the accounts affected by a transaction', 'Record balanced journal entries, including compound entries', 'Read a trial balance'],
  skills: const <String>['bz_acct'],
  difficulty: LabDifficulty.foundation,
  minutes: 45,
  scenarios: <LabScenario>[
    LabScenario(
      id: 'riverside_month1',
      title: 'Riverside Bakery: month one',
      people: _firm,
      briefing: Briefing(
        what: 'Journalise every document in the client\'s folder.',
        why: 'The client needs accurate books for a bank loan review next week.',
        information: <String>['Riverside Bakery started trading on 1 March.', 'Use only the accounts in the chart of accounts.'],
        tools: <String>['Source document folder', 'General journal', 'Ledger (T-accounts)', 'Trial balance'],
        expected: 'Every entry correct and a trial balance that agrees.',
        requirements: <String>['Each entry must balance before it is posted.'],
      ),
      steps: <LabStep>[
        JournalStep(
          id: 'journal',
          title: 'General journal',
          instructions: 'Record one journal entry per document. Add as many lines as the transaction needs.',
          accounts: bakeryAccounts,
          skills: <String>['bz_acct'],
          documents: <SourceDocument>[
            SourceDocument('BS-01', '1 Mar', 'Bank statement: deposit of £15,000 by the owner, Sam Okoro, to start the business.'),
            SourceDocument('INV-4471', '2 Mar', 'Supplier invoice from OvenWorks Ltd: commercial oven £4,800, payable in 30 days.'),
            SourceDocument('RCPT-118', '3 Mar', 'Till receipt: flour, butter and sugar £620, paid in cash.'),
            SourceDocument('Z-0303', '5 Mar', 'Till Z-report: cash sales for the week £1,350.'),
            SourceDocument('SINV-001', '8 Mar', 'Sales invoice to Corner Café: 300 loaves £900, due in 14 days.'),
            SourceDocument('PAY-03', '15 Mar', 'Payroll summary: wages paid in cash £700.'),
            SourceDocument('CHQ-002', '20 Mar', 'Payment to OvenWorks Ltd: £2,000 towards invoice INV-4471.'),
            SourceDocument('BS-02', '22 Mar', 'Bank statement: £900 received from Corner Café for SINV-001.'),
            SourceDocument('VAN-01', '25 Mar', 'Purchase of a delivery van £12,000: £3,000 paid from the business account, the rest financed by a bank loan.'),
          ],
          expected: <List<EntryLine>>[
            <EntryLine>[EntryLine('Cash', true, 15000), EntryLine('Owner\'s capital', false, 15000)],
            <EntryLine>[EntryLine('Equipment', true, 4800), EntryLine('Accounts payable', false, 4800)],
            <EntryLine>[EntryLine('Purchases', true, 620), EntryLine('Cash', false, 620)],
            <EntryLine>[EntryLine('Cash', true, 1350), EntryLine('Sales revenue', false, 1350)],
            <EntryLine>[EntryLine('Accounts receivable', true, 900), EntryLine('Sales revenue', false, 900)],
            <EntryLine>[EntryLine('Wages expense', true, 700), EntryLine('Cash', false, 700)],
            <EntryLine>[EntryLine('Accounts payable', true, 2000), EntryLine('Cash', false, 2000)],
            <EntryLine>[EntryLine('Cash', true, 900), EntryLine('Accounts receivable', false, 900)],
            <EntryLine>[EntryLine('Vehicles', true, 12000), EntryLine('Cash', false, 3000), EntryLine('Bank loan', false, 9000)],
          ],
        ),
      ],
    ),
    ...accLabBookkeepingExtra,
  ],
);

final LabSpec accountingReconciliationLab = LabSpec(
  id: 'acc_lab_reconciliation',
  deptId: 'business',
  majorId: 'accounting',
  number: 2,
  title: 'Bank Reconciliation',
  environment: LabEnvironment.accountingFirm,
  summary: 'Compare the cash book with the bank statement, classify every difference and agree the balances.',
  objectives: const <String>['Match items in both records', 'Identify timing differences and bank-only items', 'Calculate the adjusted cash book balance'],
  skills: const <String>['bz_acct'],
  difficulty: LabDifficulty.intermediate,
  minutes: 30,
  prerequisites: const <String>['acc_lab_bookkeeping'],
  scenarios: <LabScenario>[
    LabScenario(
      id: 'sept_recon',
      title: 'Riverside Bakery: 30 September',
      people: _firm,
      briefing: Briefing(
        what: 'Reconcile the September cash book (balance £3,240) with the bank statement (balance £3,040).',
        why: 'Unreconciled differences hide errors and fraud; the auditor will ask for this reconciliation.',
        information: <String>['Money in is positive, money out is negative.'],
        tools: <String>['Cash book', 'Bank statement', 'Reconciliation worksheet'],
        expected: 'Every line classified and the adjusted cash book balance agreed.',
      ),
      steps: <LabStep>[
        ReconciliationStep(
          id: 'recon',
          title: 'Reconciliation worksheet',
          instructions: 'Classify each line, then enter the adjusted cash book balance.',
          cashBookBalance: 3240,
          bankBalance: 3040,
          skills: <String>['bz_acct'],
          lines: <ReconLine>[
            ReconLine('Cash book', 'Cheque 101 to Mill Flour Co', -300, ReconItem.matched),
            ReconLine('Cash book', 'Receipt from Corner Café', 1000, ReconItem.matched),
            ReconLine('Cash book', 'Cheque 104 to OvenWorks Ltd', -420, ReconItem.unpresentedCheque),
            ReconLine('Cash book', 'Takings banked 30 Sep', 600, ReconItem.outstandingDeposit),
            ReconLine('Bank statement', 'Monthly account fee', -25, ReconItem.bankCharge),
            ReconLine('Bank statement', 'Interest credited', 5, ReconItem.interestReceived),
          ],
        ),
      ],
    ),
    ...accLabReconciliationExtra,
  ],
);

final LabSpec accountingStatementsLab = LabSpec(
  id: 'acc_lab_statements',
  deptId: 'business',
  majorId: 'accounting',
  number: 3,
  title: 'Financial Statements',
  environment: LabEnvironment.accountingFirm,
  summary: 'Prepare the income statement and balance sheet from a year-end trial balance; totals compute from your classification.',
  objectives: const <String>['Classify accounts into the statements', 'Calculate net income', 'Check that the balance sheet balances'],
  skills: const <String>['bz_acct'],
  difficulty: LabDifficulty.intermediate,
  minutes: 30,
  prerequisites: const <String>['acc_lab_bookkeeping'],
  scenarios: <LabScenario>[
    LabScenario(
      id: 'year_end',
      title: 'Riverside Bakery: year-end accounts',
      people: _firm,
      briefing: Briefing(
        what: 'Prepare the year-end income statement and balance sheet.',
        why: 'The bank will lend only on the basis of reliable year-end statements.',
        information: <String>['The trial balance has been checked and balances.'],
        tools: <String>['Trial balance', 'Statement builder'],
        expected: 'Every account in the right statement, net income and total assets correct, and a balancing balance sheet.',
      ),
      steps: <LabStep>[
        StatementsStep(
          id: 'statements',
          title: 'Statement builder',
          instructions: 'Place each account, then enter net income and total assets.',
          skills: <String>['bz_acct'],
          trialBalance: <TbAccount>[
            TbAccount('Sales revenue', 48000, false, StatementLine.revenue),
            TbAccount('Cost of goods sold', 21000, true, StatementLine.expense),
            TbAccount('Wages expense', 12000, true, StatementLine.expense),
            TbAccount('Rent expense', 6000, true, StatementLine.expense),
            TbAccount('Utilities expense', 1800, true, StatementLine.expense),
            TbAccount('Cash', 5200, true, StatementLine.asset),
            TbAccount('Accounts receivable', 3400, true, StatementLine.asset),
            TbAccount('Inventory', 2600, true, StatementLine.asset),
            TbAccount('Equipment', 15000, true, StatementLine.asset),
            TbAccount('Accounts payable', 2900, false, StatementLine.liability),
            TbAccount('Bank loan', 8000, false, StatementLine.liability),
            TbAccount('Owner\'s capital', 8100, false, StatementLine.equity),
          ],
        ),
      ],
    ),
    ...accLabStatementsExtra,
  ],
);

final List<LabSpec> accountingLabs = <LabSpec>[accountingBookkeepingLab, accountingReconciliationLab, accountingStatementsLab];
