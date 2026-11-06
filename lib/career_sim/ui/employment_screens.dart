import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../content/catalog.dart';
import '../content/job_market.dart';
import '../engine/career_rules.dart';
import '../engine/market_rules.dart';
import '../engine/pay_rules.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../store/career_sim_store.dart';
import 'career_centre.dart';
import 'common.dart';
import 'interview_screen.dart';
import 'job_screens.dart';
import 'money_find_screens.dart';
import 'resume_screens.dart';
import 'workplace_screen.dart';
import 'gg_kit.dart';

/// The student's employment status, as the Career Centre shows it.
(String, String) employmentStatus(CareerSimStore store) {
  final CareerProfile p = store.profile;
  final Employment? job = p.currentJob;
  if (job != null) {
    final Department? d = CareerCatalog.department(job.deptId);
    if (store.onboardingLeft(job).isNotEmpty) return ('Hired', 'Finish onboarding at ${job.employer}.');
    if (d != null && CareerRules.promotion(p, d, job, p.day).approved) return ('Promotion available', 'Request a promotion review in your workplace.');
    return ('Currently working', job.open != null ? 'Complete your open assignment.' : 'Get your next assignment from ${CareerCatalog.workplace(job.workplaceId)?.supervisor ?? 'your manager'}.');
  }
  const List<(ApplicationStatus, String, String)> order = <(ApplicationStatus, String, String)>[
    (ApplicationStatus.offerReceived, 'Offer received', 'Review the offer and accept, negotiate or decline.'),
    (ApplicationStatus.furtherAssessment, 'Interview completed', 'Complete the employer\'s further assessment.'),
    (ApplicationStatus.interviewCompleted, 'Interview completed', 'Wait for the hiring decision (next working day).'),
    (ApplicationStatus.interviewScheduled, 'Interview scheduled', 'Attend your interview on the booked day.'),
    (ApplicationStatus.shortlisted, 'Shortlisted', 'Book an interview slot.'),
    (ApplicationStatus.underReview, 'Under review', 'The employer is screening your application.'),
    (ApplicationStatus.submitted, 'Application submitted', 'The employer will review it on the next working day.'),
  ];
  for (final (ApplicationStatus s, String label, String next) in order) {
    if (p.applications.any((JobApplication a) => a.status == s)) return (label, next);
  }
  if (p.resumeUploads.isEmpty && p.resume.fullName.isEmpty) return ('Not applied yet', 'Upload your resume to build your professional profile.');
  return ('Not applied yet', 'Browse job opportunities in your field and apply.');
}

class CareerStatusCard extends StatelessWidget {
  const CareerStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final (String status, String next) = employmentStatus(store);
    return SectionCard(
      key: const ValueKey<String>('employment_status'),
      title: 'Employment status: $status',
      subtitle: 'Next: $next',
      child: Text(PayRules.notice, style: TextStyle(color: GG.mute, fontSize: 12)),
    );
  }
}

/// Offer terms laid out like a real offer letter.
class OfferDetails extends StatelessWidget {
  const OfferDetails({super.key, required this.offer});
  final JobOffer offer;

  @override
  Widget build(BuildContext context) {
    final JobOffer o = offer;
    final int annual = PayRules.annual(o.salary, o.salaryPeriod, hoursPerWeek: o.hoursPerWeek);
    Widget row(String a, String b) => Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            SizedBox(width: 170, child: Text(a, style: TextStyle(color: GG.mute, fontSize: 13))),
            Expanded(child: Text(b, style: TextStyle(color: GG.ink, fontSize: 13.5, fontWeight: FontWeight.w600))),
          ]),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      row('Company', '${o.employer} $simulatedEmployer'),
      row('Position', o.title),
      if (o.department.isNotEmpty) row('Department', o.department),
      row('Employment type', o.employmentType.isEmpty ? 'Full-time' : o.employmentType),
      row(o.salaryPeriod == 'hour' ? 'Hourly rate' : 'Salary', money(o.salary, o.salaryPeriod)),
      row('Annual equivalent', usdWhole(annual)),
      row('Payment schedule', PayRules.frequencyLabel(o.payFrequency)),
      row('Working hours', '${o.hoursPerWeek} hours per week'),
      row('Virtual monthly gross', usd((annual * 100 / 12).round())),
      row('Gross per paycheck', usd(PayRules.periodGrossCents(o.salary, o.salaryPeriod, o.payFrequency, hoursPerWeek: o.hoursPerWeek))),
      row('Start date', 'Day ${o.startDay}'),
      row('Respond by', 'Day ${o.respondByDay}'),
    ]);
  }
}

/// The simulated employment contract. Signing it accepts the offer.
class ContractScreen extends StatefulWidget {
  const ContractScreen({super.key, required this.applicationId});
  final String applicationId;

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  final TextEditingController _sign = TextEditingController();
  bool _agree = false;

  @override
  void dispose() {
    _sign.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final JobApplication? a = store.profile.application(widget.applicationId);
    final JobOffer? o = a?.offer;
    if (a == null || o == null) return const Scaffold(body: Center(child: Text('Offer not found')));
    return Scaffold(
      appBar: AppBar(title: const Text('Employment contract')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Text('Simulated employment contract', style: TextStyle(color: GG.ink, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          SectionCard(title: 'Terms', child: BulletList(MarketRules.contractTerms(o, ''))),
          SectionCard(title: 'Your offer', child: OfferDetails(offer: o)),
          CheckboxListTile(
            key: const ValueKey<String>('contract_agree'),
            contentPadding: EdgeInsets.zero,
            value: _agree,
            onChanged: (bool? v) => setState(() => _agree = v ?? false),
            title: const Text('I have read the terms and understand this is an educational simulation, not real employment or real pay.'),
          ),
          TextField(
            key: const ValueKey<String>('contract_signature'),
            controller: _sign,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Type your full name to sign',
              helperText: store.profile.resume.fullName.isEmpty ? null : 'As on your profile: ${store.profile.resume.fullName}',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          BusyButton(
            key: const ValueKey<String>('sign_contract'),
            label: 'Sign and accept',
            icon: Icons.draw_rounded,
            onPressed: !_agree
                ? null
                : () async {
                    final Employment? e = await runCareerAction<Employment>(context, () => store.acceptOffer(a.id, signature: _sign.text), success: 'Welcome to ${o.employer}!');
                    if (e != null && context.mounted) {
                      await Navigator.of(context).pushReplacement(ggRoute<void>((_) => const WorkplaceScreen()));
                    }
                  },
          ),
        ],
      ),
    );
  }
}

/// The onboarding checklist shown in the workplace until it is complete.
class OnboardingCard extends StatelessWidget {
  const OnboardingCard({super.key, required this.employment});
  final Employment employment;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final List<(String, String, String)> items = MarketRules.onboarding(employment);
    return SectionCard(
      key: const ValueKey<String>('onboarding'),
      title: 'Onboarding checklist',
      subtitle: '${items.where(((String, String, String) i) => employment.onboarding.contains(i.$1)).length} of ${items.length} done — finish it to get your first assignment.',
      child: Column(children: <Widget>[
        for (final (String id, String title, String body) in items)
          ExpansionTile(
            key: ValueKey<String>('onb_$id'),
            tilePadding: EdgeInsets.zero,
            leading: Icon(employment.onboarding.contains(id) ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                color: employment.onboarding.contains(id) ? GG.green : GG.mute),
            title: Text(title),
            children: <Widget>[
              Align(alignment: Alignment.centerLeft, child: Text(body, style: TextStyle(color: GG.ink, height: 1.4))),
              const SizedBox(height: 6),
              if (!employment.onboarding.contains(id))
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonal(
                    key: ValueKey<String>('onb_done_$id'),
                    onPressed: () => runCareerAction<void>(context, () => store.completeOnboarding(id)),
                    child: const Text('Mark as done'),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
      ]),
    );
  }
}

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});
  final PerformanceReview review;

  @override
  Widget build(BuildContext context) => SectionCard(
        title: 'Review ${review.cycle}: ${review.outcome}',
        subtitle: 'Day ${review.day} · overall ${review.overall}/100${review.raisePercent > 0 ? ' · ${review.raisePercent}% raise' : ''}',
        trailing: const ValidatedBadge(label: 'From your work'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          for (final MapEntry<String, int> s in review.scores.entries) LabeledBar(label: s.key, value: s.value),
          if (review.raisePercent > 0)
            Text('Salary: ${usdWhole(review.oldSalary)} → ${usdWhole(review.newSalary)} (virtual USD)',
                style: TextStyle(color: GG.green, fontWeight: FontWeight.w700)),
          if (review.promotionEligible) const StatusChip('Promotion eligible'),
          BulletList(review.comments),
        ]),
      );
}

class PerformanceReviewsScreen extends StatelessWidget {
  const PerformanceReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final List<(Employment, PerformanceReview)> all = <(Employment, PerformanceReview)>[
      for (final Employment e in store.profile.employment.reversed)
        for (final PerformanceReview r in e.reviews.reversed) (e, r),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Performance Reviews')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Text('A review is written every ${CareerSimStore.reviewEvery} evaluated assignments. It scores quality, accuracy, problem-solving, communication, teamwork, reliability and deadlines from your actual work. '
              'Raises: 70+ overall = 2%, 85+ with 75+ on deadlines = 5%.', style: TextStyle(color: GG.mute)),
          const SizedBox(height: 12),
          if (all.isEmpty) Text('No reviews yet.', style: TextStyle(color: GG.mute)),
          for (final (Employment e, PerformanceReview r) in all) ...<Widget>[
            Text('${e.title} · ${e.employer}', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w800)),
            ReviewCard(review: r),
          ],
          for (final Employment e in store.profile.employment.reversed)
            for (final AssignmentRecord a in e.evaluated.reversed.take(8))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.assignment_turned_in_rounded),
                title: Text(store.specOf(e, a)?.title ?? a.assignmentId),
                subtitle: Text('${e.employer} · ${a.evaluation!.rating} (${a.evaluation!.overall}) · day ${a.submittedDay}'),
              ),
        ],
      ),
    );
  }
}

/// Career ladder for the current (or target) role family.
class CareerProgressionScreen extends StatelessWidget {
  const CareerProgressionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final CareerProfile p = store.profile;
    final Employment? e = p.currentJob;
    final WorkplaceDef? w = e == null ? null : CareerCatalog.workplace(e.workplaceId);
    final Department? d = e == null ? store.department : CareerCatalog.department(e.deptId);
    final PromotionReview? next = e == null || d == null ? null : CareerRules.promotion(p, d, e, p.day);
    final CareerStage cur = e?.stage ?? p.stage;
    final List<JobPosting> higher = CareerCatalog.postings
        .where((JobPosting j) => (d == null || j.deptId == d.id) && j.stageOnHire.index > p.stage.index)
        .toList()
      ..sort((JobPosting a, JobPosting b) => a.stageOnHire.index.compareTo(b.stageOnHire.index));
    return Scaffold(
      appBar: AppBar(title: const Text('Career Progression')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          SectionCard(
            title: 'Your stage: ${p.stage.label}',
            subtitle: e == null ? 'Get hired to start climbing a career ladder.' : '${e.title} at ${e.employer} · ${money(e.salary, e.salaryPeriod)}',
            child: w == null
                ? const SizedBox.shrink()
                : Column(children: <Widget>[
                    for (final MapEntry<CareerStage, String> t in w.titles.entries)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          t.key == cur ? Icons.radio_button_checked : (t.key.index < cur.index ? Icons.check_circle_rounded : Icons.radio_button_unchecked),
                          color: t.key.index <= cur.index ? GG.green : GG.mute,
                        ),
                        title: Text(t.value),
                        subtitle: Text(t.key.label),
                      ),
                  ]),
          ),
          if (next != null && next.to != null)
            SectionCard(
              title: 'Next promotion: ${next.to!.label}',
              subtitle: 'Promotions bring new responsibilities and a 12% raise.',
              child: Column(children: <Widget>[
                for (final Criterion c in next.criteria)
                  Row(children: <Widget>[
                    Icon(c.met ? Icons.check_circle_rounded : Icons.radio_button_unchecked, size: 18, color: c.met ? GG.green : GG.mute),
                    const SizedBox(width: 6),
                    Expanded(child: Text('${c.label}${c.detail.isEmpty ? '' : ' (${c.detail})'}')),
                  ]),
              ]),
            ),
          SectionCard(
            title: 'Better positions to aim for',
            child: Column(children: <Widget>[
              if (higher.isEmpty) Text('You are at the top of this ladder.', style: TextStyle(color: GG.mute)),
              for (final JobPosting j in higher.take(8))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(j.title),
                  subtitle: Text('${j.company.name} · ${j.levelLabel} · ${money(j.salaryMin, j.salaryPeriod)}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(ggRoute<void>((_) => JobDetailScreen(postingId: j.id))),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}

class InterviewCenterScreen extends StatelessWidget {
  const InterviewCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final CareerProfile p = store.profile;
    final List<JobApplication> upcoming = p.applications.where((JobApplication a) => a.status == ApplicationStatus.interviewScheduled || a.status == ApplicationStatus.shortlisted).toList();
    final List<JobApplication> done = p.applications.where((JobApplication a) => a.interview != null).toList();
    final Department? d = store.department;
    return Scaffold(
      appBar: AppBar(title: const Text('Interview Center')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Row(children: <Widget>[Expanded(child: Text('Today is day ${store.day}', style: TextStyle(color: GG.mute))), const NextDayButton()]),
          SectionCard(
            title: 'Upcoming interviews',
            child: Column(children: <Widget>[
              if (upcoming.isEmpty) Text('None. Shortlisted applications appear here.', style: TextStyle(color: GG.mute)),
              for (final JobApplication a in upcoming)
                ListTile(
                  key: ValueKey<String>('iv_${a.id}'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_rounded),
                  title: Text(CareerCatalog.posting(a.postingId)?.title ?? a.postingId),
                  subtitle: Text(a.status == ApplicationStatus.shortlisted ? 'Book a slot' : 'Day ${a.interviewDay}${store.interviewAvailable(a) ? ' — today' : ''}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(ggRoute<void>((_) => ApplicationScreen(applicationId: a.id))),
                ),
            ]),
          ),
          if (d != null)
            SectionCard(
              title: 'Practice interview',
              subtitle: 'Same questions and rubric as the ${d.title} panel; does not affect applications.',
              child: Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  key: const ValueKey<String>('ic_practice'),
                  onPressed: () {
                    final List<JobPosting> js = CareerCatalog.postingsFor(d.id);
                    final InterviewPlan? plan = js.isEmpty ? null : CareerCatalog.interviewPlan(js.first.interviewPlanId);
                    if (plan == null) return;
                    Navigator.of(context).push(ggRoute<void>((_) => InterviewScreen(plan: plan, company: js.first.company, applicationId: 'mock', day: store.day, practice: true, onFinished: store.recordPracticeInterview),
                    ));
                  },
                  icon: const Icon(Icons.record_voice_over_rounded),
                  label: const Text('Start practice interview'),
                ),
              ),
            ),
          for (final JobApplication a in done) InterviewReportCard(record: a.interview!),
        ],
      ),
    );
  }
}

class JobOffersScreen extends StatelessWidget {
  const JobOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final List<JobApplication> offers = store.profile.applications.where((JobApplication a) => a.offer != null).toList().reversed.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Job Offers')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          if (offers.isEmpty) Text('No offers yet. Offers follow a successful interview.', style: TextStyle(color: GG.mute)),
          for (final JobApplication a in offers)
            Card(
              child: ListTile(
                key: ValueKey<String>('offer_${a.id}'),
                title: Text(a.offer!.title),
                subtitle: Text('${a.offer!.employer} · ${money(a.offer!.salary, a.offer!.salaryPeriod)} · ${a.status.label}'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(ggRoute<void>((_) => ApplicationScreen(applicationId: a.id))),
              ),
            ),
        ],
      ),
    );
  }
}

/// The ten Career Center sections as large tiles.
class CareerSections extends StatelessWidget {
  const CareerSections({super.key});

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final CareerProfile p = store.profile;
    void go(Widget w) => Navigator.of(context).push(ggRoute<void>((_) => w));
    final List<(String, IconData, String, String, Widget)> tiles = <(String, IconData, String, String, Widget)>[
      ('open_resume', Icons.badge_rounded, 'My Professional Profile', '${(CareerRules.resumeCompleteness(p.resume) * 100).round()}% complete', const ResumeScreen()),
      ('open_resume_hub', Icons.upload_file_rounded, 'My Resume', p.resumeUploads.isEmpty ? 'Upload PDF or DOCX' : '${p.resumeUploads.length} uploaded', const ResumeHubScreen()),
      ('open_jobs', Icons.work_rounded, 'Job Opportunities', 'Internship to management', const JobBoardScreen()),
      ('open_tracker', Icons.track_changes_rounded, 'My Applications', '${p.applications.where((JobApplication a) => a.status.isActive).length} active', const ApplicationsTrackerScreen()),
      ('open_interviews', Icons.record_voice_over_rounded, 'Interview Center', '${p.applications.where((JobApplication a) => a.status == ApplicationStatus.interviewScheduled).length} scheduled', const InterviewCenterScreen()),
      ('open_offers', Icons.mark_email_read_rounded, 'Job Offers', '${p.applications.where((JobApplication a) => a.status == ApplicationStatus.offerReceived).length} open', const JobOffersScreen()),
      ('open_workplace', Icons.apartment_rounded, 'My Workplace', p.currentJob?.employer ?? 'Not employed', const WorkplaceScreen()),
      ('open_earnings', Icons.account_balance_wallet_rounded, 'My Earnings', usd(p.balanceCents), const MoneyScreen()),
      ('open_reviews', Icons.grading_rounded, 'Performance Reviews', '${p.employment.fold<int>(0, (int a, Employment e) => a + e.reviews.length)} reviews', const PerformanceReviewsScreen()),
      ('open_progression', Icons.trending_up_rounded, 'Career Progression', p.stage.label, const CareerProgressionScreen()),
    ];
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints c) {
      final int cols = c.maxWidth >= 720 ? 5 : 2;
      final double w = (c.maxWidth - 8 * (cols - 1)) / cols;
      return Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
        for (final (String key, IconData icon, String label, String caption, Widget screen) in tiles)
          SizedBox(
            width: w,
            child: Material(
              color: GG.mute.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                key: ValueKey<String>(key),
                borderRadius: BorderRadius.circular(12),
                onTap: () => go(screen),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Icon(icon, color: GG.accent),
                    const SizedBox(height: 4),
                    Text(label, maxLines: 2, style: TextStyle(color: GG.ink, fontWeight: FontWeight.w800, fontSize: 13)),
                    Text(caption, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: GG.mute, fontSize: 11.5)),
                  ]),
                ),
              ),
            ),
          ),
      ]);
    });
  }
}
