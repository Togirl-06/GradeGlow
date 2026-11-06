import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../vu_v2/design/vu_v2_theme.dart';
import '../content/catalog.dart';
import '../engine/pay_rules.dart';
import '../labs/lab_catalog.dart';
import '../labs/lab_models.dart';
import '../labs/ui/lab_screens.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../store/career_sim_store.dart';
import 'career_centre.dart';
import 'common.dart';
import 'department_screens.dart';
import 'hub_screens.dart';
import 'job_screens.dart';
import 'workplace_screen.dart';

const String simulatedPayNote = PayRules.notice;

/// Virtual employee wallet: balance, paychecks (gross, deductions, net),
/// next payday and payment history. All figures are virtual USD.
class MoneyScreen extends StatelessWidget {
  const MoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final CareerProfile p = store.profile;
    final Employment? job = p.currentJob;
    final int total = p.ledger.where((MoneyEntry e) => e.cents > 0).fold<int>(0, (int a, MoneyEntry e) => a + e.cents);
    final int gross = p.paychecks.fold<int>(0, (int a, Paycheck c) => a + c.grossCents);
    final int deductions = p.paychecks.fold<int>(0, (int a, Paycheck c) => a + c.deductionCents);
    final int stipends = p.ledger.where((MoneyEntry e) => e.kind == 'lab').fold<int>(0, (int a, MoneyEntry e) => a + e.cents);
    final Paycheck? last = p.paychecks.isEmpty ? null : p.paychecks.last;
    return Scaffold(
      appBar: AppBar(title: const Text('My Earnings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Container(
            key: const ValueKey<String>('money_notice'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: VuV2Colors.mute.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
            child: Text(simulatedPayNote, style: TextStyle(color: VuV2Colors.ink, fontSize: 12.5, height: 1.35)),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Virtual balance',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(usd(p.balanceCents), key: const ValueKey<String>('money_balance'), style: TextStyle(color: VuV2Colors.ink, fontSize: 34, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text('Total earned ${usd(total)} · gross pay ${usd(gross)} · simulated deductions ${usd(deductions)} · training stipends ${usd(stipends)}',
                  style: TextStyle(color: VuV2Colors.mute)),
            ]),
          ),
          if (last != null)
            SectionCard(
              title: 'My virtual paycheck',
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                _Rate('Company', '${last.employer} (simulated employer)'),
                _Rate('Position', last.title),
                _Rate('Pay period', '${last.period} · ${PayRules.frequencyLabel(last.frequency).toLowerCase()} · ${last.hours} approved hours'),
                _Rate('Gross pay', usd(last.grossCents)),
                _Rate('Simulated deductions (${(PayRules.deductionRate * 100).round()}%)', '−${usd(last.deductionCents)}'),
                _Rate('Net virtual payment', usd(last.netCents)),
                const _Rate('Payment status', 'Paid (virtual)'),
              ]),
            ),
          SectionCard(
            title: job == null ? 'How to earn' : 'Next payday',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              if (job != null) ...<Widget>[
                _Rate('Salary', money(job.salary, job.salaryPeriod)),
                _Rate('Pay frequency', PayRules.frequencyLabel(job.payFrequency)),
                _Rate('Gross per paycheck', usd(PayRules.periodGrossCents(job.salary, job.salaryPeriod, job.payFrequency, hoursPerWeek: job.hoursPerWeek))),
                _Rate('Next paycheck', 'after ${store.weeksToPayday(job)} more approved work week(s)'),
                const SizedBox(height: 6),
                Text('Each evaluated assignment is one approved work week (${job.hoursPerWeek} h). Raises come from performance reviews every four assignments and from promotions.',
                    style: TextStyle(color: VuV2Colors.mute, fontSize: 12.5)),
              ] else ...<Widget>[
                Text('Get hired to earn a virtual salary. Until then, the first pass of each lab scenario pays a training stipend:', style: TextStyle(color: VuV2Colors.ink)),
                const SizedBox(height: 6),
                for (final LabDifficulty l in LabDifficulty.values) _Rate('${l.label} scenario', 'up to ${usd(PayRules.stipendCents[l]!)}'),
              ],
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
                FilledButton.tonalIcon(
                  key: const ValueKey<String>('money_jobs'),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => job == null ? const JobBoardScreen() : const WorkplaceScreen())),
                  icon: const Icon(Icons.work_rounded),
                  label: Text(job == null ? 'Find a job' : 'Go to work'),
                ),
                FilledButton.tonalIcon(
                  key: const ValueKey<String>('money_labs'),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PracticalLabsScreen())),
                  icon: const Icon(Icons.science_rounded),
                  label: const Text('Practise in labs'),
                ),
              ]),
            ]),
          ),
          SectionCard(
            title: 'Payment history',
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
              if (p.ledger.isEmpty) Text('No payments yet.', style: TextStyle(color: VuV2Colors.mute)),
              for (final MoneyEntry e in p.ledger.reversed.take(60))
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(e.kind == 'lab' ? Icons.school_rounded : Icons.payments_rounded),
                  title: Text(e.text),
                  subtitle: Text('Day ${e.day}${e.paycheckId.isEmpty ? '' : ' · net after simulated deductions'}'),
                  trailing: Text('+${usd(e.cents)}', style: TextStyle(color: VuV2Colors.success, fontWeight: FontWeight.w800)),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Rate extends StatelessWidget {
  const _Rate(this.what, this.pay);
  final String what;
  final String pay;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: <Widget>[
          Expanded(child: Text(what, style: TextStyle(color: VuV2Colors.ink))),
          Text(pay, style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800)),
        ]),
      );
}

/// One search result.
class FindResult {
  const FindResult(this.id, this.kind, this.title, this.detail, this.icon, this.open, [this.keywords = '']);
  final String id;
  final String kind;
  final String title;
  final String detail;
  final IconData icon;
  final Widget Function() open;

  /// Extra searchable text (not shown).
  final String keywords;
}

/// Everything the student can open, for search.
List<FindResult> findIndex(CareerSimStore store) {
  final CareerProfile p = store.profile;
  return <FindResult>[
    FindResult('labs', 'Screen', 'Practical Labs', 'All hands-on lab work by major', Icons.science_rounded, () => const PracticalLabsScreen()),
    FindResult('money', 'Screen', 'My Earnings', 'Pay, balance and how to earn more', Icons.account_balance_wallet_rounded, () => const MoneyScreen()),
    FindResult('jobs', 'Screen', 'Job Board', 'Opportunities: open jobs and internships', Icons.work_outline_rounded, () => const JobBoardScreen()),
    FindResult('career', 'Screen', 'Career Centre', 'Resume, cover letter, trainee status', Icons.business_center_rounded, () => const CareerCentreScreen()),
    FindResult('applications', 'Screen', 'My Applications', 'Applications, interviews and offers', Icons.track_changes_rounded, () => const ApplicationsTrackerScreen()),
    FindResult('workplace', 'Screen', 'My Workplace', 'Assignments from your supervisor', Icons.apartment_rounded, () => const WorkplaceScreen()),
    FindResult('assessments', 'Screen', 'Assessments', 'Graded tests and certifications', Icons.fact_check_rounded, () => const AssessmentsScreen()),
    FindResult('portfolio', 'Screen', 'My Portfolio', 'Projects and passed labs', Icons.folder_special_rounded, () => const PortfolioScreen()),
    FindResult('progress', 'Screen', 'Progress', 'Skills and career readiness', Icons.insights_rounded, () => const ProgressScreen()),
    FindResult('schools', 'Screen', 'Schools and departments', 'Choose or change department', Icons.account_balance_rounded, () => const DepartmentPickerScreen()),
    for (final LabSpec l in LabCatalog.all)
      FindResult(l.id, 'Lab', l.title, '${LabCatalog.majorLabels[l.majorId] ?? l.majorId} · ${l.environment.label} · ${labStatus(p, l)}', environmentIcon(l.environment),
          () => LabIntroScreen(labId: l.id), '${l.summary} ${l.objectives.join(' ')}'),
    for (final Department d in CareerCatalog.departments)
      for (final TrainingModule m in d.modules)
        FindResult(m.id, 'Module', m.title, 'Training module · ${d.title}', Icons.menu_book_rounded, () => ModuleScreen(deptId: d.id, moduleId: m.id)),
    for (final JobPosting j in CareerCatalog.postings)
      if (PostingSchedule.isOpen(j, p.day))
        FindResult(j.id, 'Job', j.title, '${j.company.name} · ${j.type.label}', Icons.work_rounded, () => JobDetailScreen(postingId: j.id)),
  ];
}

/// Ranks results: every word must match; title matches and the student's own field come first.
List<FindResult> search(CareerSimStore store, String query) {
  final List<String> words = query.toLowerCase().split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).toList();
  if (words.isEmpty) return const <FindResult>[];
  final String major = (LabCatalog.majorLabels[store.profile.majorId] ?? '').toLowerCase();
  final String dept = store.department?.title.toLowerCase() ?? '';
  final List<(int, FindResult)> hits = <(int, FindResult)>[];
  for (final FindResult r in findIndex(store)) {
    final String title = r.title.toLowerCase();
    final String all = '$title ${r.detail.toLowerCase()} ${r.kind.toLowerCase()} ${r.keywords.toLowerCase()}';
    if (!words.every(all.contains)) continue;
    int score = words.where(title.contains).length * 10;
    if (title.startsWith(words.first)) score += 5;
    if (r.kind == 'Screen') score += 4;
    final String d = r.detail.toLowerCase();
    if ((major.isNotEmpty && d.contains(major)) || (dept.isNotEmpty && d.contains(dept))) score += 3;
    hits.add((score, r));
  }
  hits.sort(((int, FindResult) a, (int, FindResult) b) => b.$1.compareTo(a.$1));
  return <FindResult>[for (final (int, FindResult) h in hits.take(60)) h.$2];
}

/// "Find anything": labs, modules, jobs and screens in one search box.
class FindScreen extends StatefulWidget {
  const FindScreen({super.key, this.initial = ''});
  final String initial;

  @override
  State<FindScreen> createState() => _FindScreenState();
}

class _FindScreenState extends State<FindScreen> {
  late final TextEditingController _q = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final List<FindResult> results = search(store, _q.text);
    const List<String> ideas = <String>['labs', 'earnings', 'jobs', 'resume', 'interview', 'SQL', 'anatomy', 'CAD'];
    return Scaffold(
      appBar: AppBar(title: const Text('Find')),
      body: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            key: const ValueKey<String>('find_query'),
            controller: _q,
            autofocus: widget.initial.isEmpty,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Search labs, lessons, jobs, screens…', border: OutlineInputBorder()),
          ),
        ),
        if (_q.text.trim().isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
              for (final String s in ideas)
                ActionChip(label: Text(s), onPressed: () => setState(() => _q.text = s)),
            ]),
          )
        else if (results.isEmpty)
          Padding(padding: const EdgeInsets.all(24), child: Text('Nothing matches "${_q.text.trim()}".', style: TextStyle(color: VuV2Colors.mute)))
        else
          Expanded(
            child: ListView(children: <Widget>[
              for (final FindResult r in results)
                ListTile(
                  key: ValueKey<String>('find_${r.kind.toLowerCase()}_${r.id}'),
                  leading: Icon(r.icon),
                  title: Text(r.title),
                  subtitle: Text('${r.kind} · ${r.detail}', maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => r.open())),
                ),
            ]),
          ),
      ]),
    );
  }
}
