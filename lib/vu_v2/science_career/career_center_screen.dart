import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../utils/io_file_bytes.dart';
import 'hiring_pipeline_screen.dart';
import 'interview_center_screen.dart';
import 'job_catalog.dart';
import 'northwind_workplace_screen.dart';
import 'resume_file_extractor.dart';
import 'science_career_content.dart';
import 'science_career_progress.dart';
import 'science_career_theme.dart';

class CareerCenterScreen extends StatefulWidget {
  const CareerCenterScreen({super.key, required this.progress});

  final ScienceCareerProgress progress;

  @override
  State<CareerCenterScreen> createState() => _CareerCenterScreenState();
}

class _CareerCenterScreenState extends State<CareerCenterScreen> {
  JobListing _selected = CareerJobs.all.first;
  String _filter = 'All majors';
  String _query = '';

  List<JobListing> get _jobs {
    Iterable<JobListing> list = CareerJobs.all;
    if (_filter == 'Remote') {
      list = list.where((JobListing j) => j.mode == 'Remote');
    } else if (_filter != 'All majors') {
      list = list.where((JobListing j) => j.majorTag == _filter);
    }
    final String q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where(
        (JobListing j) =>
            j.title.toLowerCase().contains(q) ||
            j.company.toLowerCase().contains(q) ||
            j.skills.any((String s) => s.toLowerCase().contains(q)),
      );
    }
    return list.toList();
  }

  String get _status => widget.progress.statusFor(_selected.id);

  bool get _canApplyNow =>
      _status == 'none' || _status == 'rejected';

  bool get _inPipeline =>
      _status == 'recruiter' ||
      _status == 'oa' ||
      _status == 'technical';

  Future<void> _applyNow() async {
    if (!_canApplyNow) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _status == 'offered'
                ? 'You have an offer — accept or decline below.'
                : _status == 'hired'
                    ? 'You already work here — Start job below.'
                    : _inPipeline
                        ? 'Finish your interview loop: ${ScienceCareerProgress.pipelineLabel(_status)}.'
                        : 'Application already in progress.',
          ),
        ),
      );
      return;
    }
    final ApplyResult? result = await showModalBottomSheet<ApplyResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SciCosmic.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return _ApplyResumeSheet(
          job: _selected,
          progress: widget.progress,
        );
      },
    );
    if (!mounted) return;
    setState(() {});
    if (result == null) return;
    Map<String, dynamic>? mail;
    for (final Map<String, dynamic> e in widget.progress.emails) {
      if (e['id'] == result.emailId) {
        mail = e;
        break;
      }
    }
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return _EmailDialog(
          email: mail ??
              <String, dynamic>{
                'subject': result.advanced
                    ? 'Next step: Recruiter call'
                    : 'Application update',
                'from': '${_selected.company} Talent',
                'to': 'you@gradeglow.edu',
                'body': result.advanced
                    ? 'Your résumé passed the screen. Complete recruiter call → online assessment → technical interview, then you may receive an offer.'
                    : 'Not moving forward right now. Strengthen your résumé and reapply.',
                'kind': result.advanced ? 'pipeline' : 'reject',
              },
          onContinuePipeline: result.advanced
              ? () async {
                  Navigator.of(ctx).pop();
                  await _openPipeline();
                }
              : null,
        );
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _openPipeline() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => HiringPipelineScreen(
          progress: widget.progress,
          job: _selected,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openInbox() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SciCosmic.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return _InboxSheet(
          progress: widget.progress,
          onOpen: (Map<String, dynamic> mail) async {
            Navigator.of(ctx).pop();
            await widget.progress.markEmailRead('${mail['id']}');
            if (!mounted) return;
            await showDialog<void>(
              context: context,
              builder: (BuildContext dCtx) => _EmailDialog(
                email: mail,
                onContinuePipeline: mail['kind'] == 'pipeline'
                    ? () async {
                        Navigator.of(dCtx).pop();
                        final JobListing? j =
                            CareerJobs.byId('${mail['jobId']}');
                        if (j != null) {
                          setState(() => _selected = j);
                          await _openPipeline();
                        }
                      }
                    : null,
                onAcceptOffer: mail['kind'] == 'offer' &&
                        mail['jobId'] == _selected.id
                    ? () async {
                        Navigator.of(dCtx).pop();
                        await _accept();
                      }
                    : mail['kind'] == 'offer'
                        ? () async {
                            Navigator.of(dCtx).pop();
                            final bool ok =
                                await widget.progress.acceptOffer(
                              jobId: '${mail['jobId']}',
                              company: '${mail['company'] ?? ''}',
                            );
                            if (!mounted) return;
                            setState(() {});
                            if (ok) await _startOrContinueJob();
                          }
                        : null,
              ),
            );
            if (mounted) setState(() {});
          },
        );
      },
    );
  }

  Future<void> _accept() async {
    final bool ok = await widget.progress.acceptOffer(
      jobId: _selected.id,
      company: _selected.company,
    );
    if (!mounted) return;
    setState(() {});
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No open offer to accept for this role.'),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Offer accepted — Start job when ready.')),
    );
    await _startOrContinueJob();
  }

  Future<void> _decline() async {
    final bool ok = await widget.progress.declineOffer(
      jobId: _selected.id,
      company: _selected.company,
      roleTitle: _selected.title,
    );
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Offer declined.' : 'No open offer to decline.',
        ),
      ),
    );
  }

  Future<void> _startOrContinueJob() async {
    final bool northwind = _selected.company == 'Northwind Labs' ||
        CareerJobs.isNorthwindJob(_selected.id) ||
        widget.progress.isEmployedAtNorthwind;
    if (northwind) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => NorthwindWorkplaceScreen(progress: widget.progress),
        ),
      );
      if (mounted) setState(() {});
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_selected.company} workplace opens from Company District — simulation expands next.',
        ),
      ),
    );
  }

  Future<void> _openMobileJob(JobListing job) async {
    setState(() => _selected = job);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SciCosmic.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetCtx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModal) {
            void refresh() {
              setModal(() {});
              if (mounted) setState(() {});
            }

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.92,
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 10),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: SciCosmic.stroke,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    Expanded(
                      child: _JobDetail(
                        job: _selected,
                        progress: widget.progress,
                        canApplyNow: _canApplyNow,
                        status: _status,
                        onApplyNow: () async {
                          await _applyNow();
                          refresh();
                        },
                        onAccept: () async {
                          await _accept();
                          refresh();
                        },
                        onDecline: () async {
                          await _decline();
                          refresh();
                        },
                        onStartJob: () async {
                          await _startOrContinueJob();
                          refresh();
                        },
                        onContinuePipeline: () async {
                          await _openPipeline();
                          refresh();
                        },
                        onOpenInbox: () async {
                          await _openInbox();
                          refresh();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<JobListing> jobs = _jobs;
    return Scaffold(
      backgroundColor: SciCosmic.bg,
      appBar: SciCosmic.appBar(
        context: context,
        title: 'Career Center',
        icon: Icons.work_outline_rounded,
        trailing: <Widget>[
          TextButton.icon(
            onPressed: _openInbox,
            icon: Badge(
              isLabelVisible: widget.progress.unreadEmailCount > 0,
              label: Text('${widget.progress.unreadEmailCount}'),
              child: const Icon(Icons.mail_outline_rounded, size: 20),
            ),
            label: const Text('Inbox'),
            style: TextButton.styleFrom(foregroundColor: SciCosmic.electric),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SciStarfield(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) {
            final bool wide = c.maxWidth >= 1000;
            final Widget list = _JobList(
              jobs: jobs,
              selected: _selected,
              filter: _filter,
              totalCount: CareerJobs.all.length,
              onQuery: (String q) => setState(() {
                _query = q;
                final List<JobListing> next = _jobs;
                if (next.isNotEmpty &&
                    !next.any((JobListing j) => j.id == _selected.id)) {
                  _selected = next.first;
                }
              }),
              onFilter: (String f) => setState(() {
                _filter = f;
                final List<JobListing> next = _jobs;
                if (next.isNotEmpty) _selected = next.first;
              }),
              onSelect: wide
                  ? (JobListing j) => setState(() => _selected = j)
                  : _openMobileJob,
            );
            final Widget detail = _JobDetail(
              job: _selected,
              progress: widget.progress,
              canApplyNow: _canApplyNow,
              status: _status,
              onApplyNow: _applyNow,
              onAccept: _accept,
              onDecline: _decline,
              onStartJob: _startOrContinueJob,
              onContinuePipeline: _openPipeline,
              onOpenInbox: _openInbox,
            );
            final Widget resume = _ResumePanel(
              progress: widget.progress,
              onInterview: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        InterviewCenterScreen(progress: widget.progress),
                  ),
                );
              },
            );
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(width: 280, child: list),
                  Expanded(child: detail),
                  SizedBox(width: 280, child: resume),
                ],
              );
            }
            // Mobile: full-height job board; tap a role to open details.
            return list;
          },
        ),
      ),
    );
  }
}

class _JobList extends StatelessWidget {
  const _JobList({
    required this.jobs,
    required this.selected,
    required this.filter,
    required this.totalCount,
    required this.onQuery,
    required this.onFilter,
    required this.onSelect,
  });

  final List<JobListing> jobs;
  final JobListing selected;
  final String filter;
  final int totalCount;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onFilter;
  final ValueChanged<JobListing> onSelect;

  @override
  Widget build(BuildContext context) {
    const List<String> filters = <String>[
      'All majors',
      'Software Engineering',
      'Computer Science',
      'Web Development',
      'Mobile App Development',
      'Cybersecurity',
      'Data Science',
      'AI & Machine Learning',
      'Information Technology',
      'Remote',
    ];
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: SciCosmic.panelBox(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${jobs.length} of $totalCount roles',
            style: const TextStyle(color: SciCosmic.mute, fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: onQuery,
            style: const TextStyle(color: SciCosmic.ink, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search jobs or companies',
              hintStyle: const TextStyle(color: SciCosmic.mute),
              isDense: true,
              filled: true,
              fillColor: SciCosmic.panelAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: SciCosmic.mute, size: 18),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: filters
                  .map(
                    (String f) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () => onFilter(f),
                        child: SciCosmic.pill(
                          f,
                          bg: filter == f
                              ? SciCosmic.blue.withValues(alpha: 0.35)
                              : SciCosmic.panelAlt,
                          fg: SciCosmic.ink,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: jobs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, int i) {
                final JobListing j = jobs[i];
                final bool on = j.id == selected.id;
                return InkWell(
                  onTap: () => onSelect(j),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: on
                          ? SciCosmic.blue.withValues(alpha: 0.18)
                          : SciCosmic.panelAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: on ? SciCosmic.electric : SciCosmic.stroke,
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: SciCosmic.purple,
                          child: Text(
                            j.companyLetter,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                j.title,
                                style: const TextStyle(
                                  color: SciCosmic.ink,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                j.company,
                                style: const TextStyle(
                                  color: SciCosmic.mute,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 4,
                                children: <Widget>[
                                  SciCosmic.pill(j.mode),
                                  SciCosmic.pill(j.level),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _JobDetail extends StatelessWidget {
  const _JobDetail({
    required this.job,
    required this.progress,
    required this.canApplyNow,
    required this.status,
    required this.onApplyNow,
    required this.onAccept,
    required this.onDecline,
    required this.onStartJob,
    required this.onContinuePipeline,
    required this.onOpenInbox,
  });

  final JobListing job;
  final ScienceCareerProgress progress;
  final bool canApplyNow;
  final String status;
  final VoidCallback onApplyNow;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onStartJob;
  final VoidCallback onContinuePipeline;
  final VoidCallback onOpenInbox;

  @override
  Widget build(BuildContext context) {
    final bool projectOk = progress.hasPortfolioProject;
    final bool scoreOk = progress.resumeBuilderScore >= 40;
    final bool fileOk = progress.uploadedResumeBytes >= 800;
    final int projectCount = progress.portfolioProjects.length;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      padding: const EdgeInsets.all(18),
      decoration: SciCosmic.panelBox(radius: 18),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
          Text(
            job.title,
            style: const TextStyle(
              color: SciCosmic.ink,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${job.company} · ${job.mode} · ${job.level}',
            style: const TextStyle(color: SciCosmic.mute),
          ),
          const SizedBox(height: 12),
          Text(
            job.blurb,
            style: const TextStyle(color: SciCosmic.ink, height: 1.4),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: job.skills.map((String s) => SciCosmic.pill(s)).toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SciCosmic.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              job.id == 'northwind_junior'
                  ? '\$28.00 / hour after hire · paid when you clock out'
                  : '${job.payLabel} · paid when you clock out',
              style: const TextStyle(
                color: SciCosmic.gold,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your résumé',
            style: TextStyle(
              color: SciCosmic.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          _Req(
            ok: projectOk,
            label: 'Projects you added in Project Lab',
            detail: '$projectCount',
          ),
          _Req(
            ok: scoreOk,
            label: 'Résumé builder score',
            detail: '${progress.resumeBuilderScore}/100',
          ),
          _Req(
            ok: fileOk,
            label: 'Uploaded PDF/DOCX (optional)',
            detail: fileOk ? 'attached' : 'none',
          ),
          const SizedBox(height: 8),
          const Text(
            'Build your résumé in Project Lab with your own projects — no Coding Arena required. Apply Now emails a decision immediately.',
            style: TextStyle(color: SciCosmic.mute, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 12),
          SciCosmic.pill(
            'Status: ${status == 'none' ? 'not applied' : status}',
            bg: SciCosmic.panelAlt,
          ),
          const SizedBox(height: 18),
          if (status == 'hired') ...<Widget>[
            SciCosmic.pill(
              progress.clockedIn ? 'On shift now' : 'Employed',
              bg: SciCosmic.success.withValues(alpha: 0.2),
              fg: SciCosmic.success,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onStartJob,
              icon: Icon(
                progress.clockedIn
                    ? Icons.play_circle_outline
                    : progress.hasStartedWork
                        ? Icons.work_history_outlined
                        : Icons.play_arrow_rounded,
              ),
              label: Text(progress.jobActionLabel(jobId: job.id)),
              style: FilledButton.styleFrom(
                backgroundColor: SciCosmic.teal,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Opens your workplace — clock in to earn, then clock out to deposit pay.',
              style: TextStyle(color: SciCosmic.mute, fontSize: 12, height: 1.35),
            ),
          ] else if (status == 'offered') ...<Widget>[
            const Text(
              'Offer ready — review compensation, then accept or decline. '
              'After you accept, Start job unlocks.',
              style: TextStyle(color: SciCosmic.mute, fontSize: 12, height: 1.35),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onAccept,
              style: FilledButton.styleFrom(
                backgroundColor: SciCosmic.success,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text('Accept ${job.company} offer'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onDecline,
              style: OutlinedButton.styleFrom(
                foregroundColor: SciCosmic.danger,
                side: const BorderSide(color: SciCosmic.stroke),
                minimumSize: const Size.fromHeight(44),
              ),
              child: const Text('Decline offer'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onOpenInbox,
              style: OutlinedButton.styleFrom(
                foregroundColor: SciCosmic.ink,
                side: const BorderSide(color: SciCosmic.stroke),
                minimumSize: const Size.fromHeight(44),
              ),
              child: const Text('Read offer email'),
            ),
          ] else if (status == 'recruiter' ||
              status == 'oa' ||
              status == 'technical') ...<Widget>[
            _PipelineProgress(status: status),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onContinuePipeline,
              icon: const Icon(Icons.route_rounded),
              label: Text(
                status == 'recruiter'
                    ? 'Start recruiter call'
                    : status == 'oa'
                        ? 'Start online assessment'
                        : 'Start technical interview',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: SciCosmic.teal,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Loop: Recruiter (15–30) → Online assessment (45–90) → '
              'Technical (45–60) → Offer → Start job.',
              style: TextStyle(color: SciCosmic.mute, fontSize: 12, height: 1.35),
            ),
          ] else ...<Widget>[
            FilledButton(
              onPressed: canApplyNow ? onApplyNow : null,
              style: FilledButton.styleFrom(
                backgroundColor: SciCosmic.purple,
                disabledBackgroundColor: SciCosmic.stroke,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(
                status == 'rejected' ? 'Apply Now again' : 'Apply Now',
              ),
            ),
            if (status == 'rejected') ...<Widget>[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: onOpenInbox,
                style: OutlinedButton.styleFrom(
                  foregroundColor: SciCosmic.ink,
                  side: const BorderSide(color: SciCosmic.stroke),
                  minimumSize: const Size.fromHeight(44),
                ),
                child: const Text('Read rejection email'),
              ),
            ],
          ],
          ],
        ),
      ),
    );
  }
}

class _PipelineProgress extends StatelessWidget {
  const _PipelineProgress({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    const List<String> steps = <String>[
      'recruiter',
      'oa',
      'technical',
      'offered',
    ];
    final int cur = steps.indexOf(status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Interview loop',
          style: TextStyle(
            color: SciCosmic.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        ...List<Widget>.generate(steps.length, (int i) {
          final bool done = cur > i;
          final bool active = cur == i;
          final String label = ScienceCareerProgress.pipelineLabel(steps[i]);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: <Widget>[
                Icon(
                  done
                      ? Icons.check_circle
                      : active
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                  size: 16,
                  color: done
                      ? SciCosmic.success
                      : active
                          ? SciCosmic.electric
                          : SciCosmic.mute,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: active || done ? SciCosmic.ink : SciCosmic.mute,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _Req extends StatelessWidget {
  const _Req({
    required this.ok,
    required this.label,
    required this.detail,
  });

  final bool ok;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Icon(
            ok ? Icons.check_circle : Icons.radio_button_unchecked,
            color: ok ? SciCosmic.blue : SciCosmic.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: SciCosmic.ink, fontSize: 13),
            ),
          ),
          Text(
            detail,
            style: TextStyle(
              color: ok ? SciCosmic.mute : SciCosmic.orange,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumePanel extends StatelessWidget {
  const _ResumePanel({required this.progress, required this.onInterview});

  final ScienceCareerProgress progress;
  final VoidCallback onInterview;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: SciCosmic.panelBox(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Your résumé',
            style: TextStyle(
              color: SciCosmic.ink,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: progress.skills
                .map((String s) => SciCosmic.pill(s))
                .toList(),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.4,
              children: <Widget>[
                _Stat('${progress.portfolioProjects.length}', 'Résumé projects'),
                _Stat('${progress.resumeBuilderScore}', 'Résumé score'),
                _Stat('${progress.strongBulletCount}', 'Strong bullets'),
                _Stat(
                  '${progress.interviewHistory.length}',
                  'Interviews',
                ),
              ],
            ),
          ),
          const Text(
            'Your résumé fills automatically as challenges and projects are completed.',
            style: TextStyle(color: SciCosmic.mute, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: onInterview,
            style: FilledButton.styleFrom(
              backgroundColor: SciCosmic.purple,
              minimumSize: const Size.fromHeight(44),
            ),
            child: const Text('Practice an interview'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: SciCosmic.panelAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              color: SciCosmic.ink,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: SciCosmic.mute, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ApplyResumeSheet extends StatefulWidget {
  const _ApplyResumeSheet({required this.job, required this.progress});

  final JobListing job;
  final ScienceCareerProgress progress;

  @override
  State<_ApplyResumeSheet> createState() => _ApplyResumeSheetState();
}

class _ApplyResumeSheetState extends State<_ApplyResumeSheet> {
  final TextEditingController _note = TextEditingController();
  bool _sending = false;
  bool _picking = false;
  UploadedResumeFile? _uploaded;

  @override
  void initState() {
    super.initState();
    final ScienceCareerProgress p = widget.progress;
    if (p.uploadedResumeName != null && p.uploadedResumeName!.isNotEmpty) {
      _uploaded = UploadedResumeFile(
        fileName: p.uploadedResumeName!,
        extension: p.uploadedResumeExt ?? '',
        sizeBytes: p.uploadedResumeBytes,
        extractedText: p.uploadedResumeText,
      );
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickResume() async {
    if (_picking || _sending) return;
    setState(() => _picking = true);
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const <String>['pdf', 'docx'],
        withData: true,
        dialogTitle: 'Upload résumé (PDF or DOCX)',
      );
      if (result == null || result.files.isEmpty) return;
      final PlatformFile file = result.files.first;
      Uint8List? bytes = file.bytes;
      if ((bytes == null || bytes.isEmpty) &&
          !kIsWeb &&
          file.path != null &&
          file.path!.isNotEmpty) {
        bytes = await readFileBytes(file.path!);
      }
      if (bytes == null || bytes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read that file. Try again.')),
        );
        return;
      }
      final Uint8List fileBytes = bytes;
      final String name = file.name;
      final String ext = (file.extension ??
              (name.contains('.') ? name.split('.').last : ''))
          .toLowerCase();
      if (ext != 'pdf' && ext != 'docx') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a PDF or DOCX résumé.')),
        );
        return;
      }
      final String text = await ResumeFileExtractor.extract(
        bytes: fileBytes,
        extension: ext,
        fileName: name,
      );
      if (!mounted) return;
      setState(() {
        _uploaded = UploadedResumeFile(
          fileName: name,
          extension: ext,
          sizeBytes: fileBytes.length,
          extractedText: text,
        );
      });
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _send() async {
    if (_sending) return;
    if (_uploaded == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload a PDF or DOCX résumé before applying.'),
        ),
      );
      return;
    }
    setState(() => _sending = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final ApplyResult? result = await widget.progress.submitResumeApplication(
      jobId: widget.job.id,
      company: widget.job.company,
      roleTitle: widget.job.title,
      preferredSkills: widget.job.skills,
      coverNote: _note.text.trim(),
      fromName: 'Maya Okafor',
      uploaded: _uploaded,
    );
    if (!mounted) return;
    if (result == null) {
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Already applied to this role, or upload a résumé first.'),
        ),
      );
      return;
    }
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final ScienceCareerProgress p = widget.progress;
    final double bottom = MediaQuery.of(context).viewInsets.bottom;
    final UploadedResumeFile? file = _uploaded;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: SciCosmic.stroke,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Apply Now',
              style: TextStyle(
                color: SciCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            Text(
              'Upload your résumé (PDF or DOCX) to ${widget.job.company} for ${widget.job.title}.',
              style: const TextStyle(color: SciCosmic.mute, height: 1.35),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: (_picking || _sending) ? null : _pickResume,
              icon: _picking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file_outlined),
              label: Text(
                _picking
                    ? 'Opening file picker…'
                    : (file == null
                        ? 'Upload résumé (PDF or DOCX)'
                        : 'Replace file'),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: SciCosmic.ink,
                side: const BorderSide(color: SciCosmic.stroke),
                minimumSize: const Size.fromHeight(46),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SciCosmic.panelAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: file != null ? SciCosmic.electric : SciCosmic.stroke,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        file != null
                            ? Icons.check_circle_outline
                            : Icons.description_outlined,
                        color: file != null
                            ? SciCosmic.electric
                            : SciCosmic.mute,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          file != null
                              ? '${file.fileName}  ·  ${_formatBytes(file.sizeBytes)}'
                              : 'No file attached yet',
                          style: const TextStyle(
                            color: SciCosmic.ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'GradeGlow profile · Skills: ${p.skills.isEmpty ? '—' : p.skills.join(', ')}',
                    style: const TextStyle(color: SciCosmic.mute, fontSize: 12),
                  ),
                  Text(
                    'Projects: ${p.portfolioProjects.length}  ·  Résumé ${p.resumeBuilderScore}/100  ·  Level ${p.level}',
                    style: const TextStyle(color: SciCosmic.mute, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLines: 3,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: InputDecoration(
                labelText: 'Short note to recruiter (optional)',
                labelStyle: const TextStyle(color: SciCosmic.mute),
                filled: true,
                fillColor: SciCosmic.panelAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _sending ? null : _send,
              style: FilledButton.styleFrom(
                backgroundColor: SciCosmic.purple,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(
                _sending ? 'Sending résumé…' : 'Send résumé · Apply Now',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'PDF or DOCX required. You get an email reply immediately with their decision.',
              textAlign: TextAlign.center,
              style: TextStyle(color: SciCosmic.mute, fontSize: 11),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static String _formatBytes(int n) {
    if (n < 1024) return '$n B';
    if (n < 1024 * 1024) return '${(n / 1024).toStringAsFixed(1)} KB';
    return '${(n / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _InboxSheet extends StatelessWidget {
  const _InboxSheet({required this.progress, required this.onOpen});

  final ScienceCareerProgress progress;
  final ValueChanged<Map<String, dynamic>> onOpen;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> mails = progress.emails;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Inbox',
              style: TextStyle(
                color: SciCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ),
          Expanded(
            child: mails.isEmpty
                ? const Center(
                    child: Text(
                      'No emails yet. Apply Now to a job to hear back.',
                      style: TextStyle(color: SciCosmic.mute),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: mails.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, int i) {
                      final Map<String, dynamic> m = mails[i];
                      final bool unread = m['read'] != true;
                      return InkWell(
                        onTap: () => onOpen(m),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: unread
                                ? SciCosmic.blue.withValues(alpha: 0.12)
                                : SciCosmic.panelAlt,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: SciCosmic.stroke),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      '${m['from']}',
                                      style: TextStyle(
                                        color: SciCosmic.ink,
                                        fontWeight: unread
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  if (unread)
                                    SciCosmic.pill(
                                      'New',
                                      bg: SciCosmic.purple.withValues(alpha: 0.3),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${m['subject']}',
                                style: const TextStyle(
                                  color: SciCosmic.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${m['company']}',
                                style: const TextStyle(
                                  color: SciCosmic.mute,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmailDialog extends StatelessWidget {
  const _EmailDialog({
    required this.email,
    this.onAcceptOffer,
    this.onContinuePipeline,
  });

  final Map<String, dynamic> email;
  final VoidCallback? onAcceptOffer;
  final VoidCallback? onContinuePipeline;

  @override
  Widget build(BuildContext context) {
    final bool offer = email['kind'] == 'offer';
    final bool pipeline = email['kind'] == 'pipeline';
    return AlertDialog(
      backgroundColor: SciCosmic.panel,
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      title: Row(
        children: <Widget>[
          Icon(
            offer
                ? Icons.mark_email_read_rounded
                : pipeline
                    ? Icons.route_rounded
                    : Icons.mail_outline_rounded,
            color: offer
                ? SciCosmic.success
                : pipeline
                    ? SciCosmic.electric
                    : SciCosmic.orange,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Mail',
              style: TextStyle(
                color: SciCosmic.ink,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'From: ${email['from']}',
                style: const TextStyle(color: SciCosmic.mute, fontSize: 12),
              ),
              Text(
                'To: ${email['to'] ?? 'you@gradeglow.edu'}',
                style: const TextStyle(color: SciCosmic.mute, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                '${email['subject']}',
                style: const TextStyle(
                  color: SciCosmic.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SciCosmic.panelAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${email['body']}',
                  style: const TextStyle(
                    color: SciCosmic.ink,
                    height: 1.45,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (onContinuePipeline != null)
          FilledButton(
            onPressed: onContinuePipeline,
            style: FilledButton.styleFrom(backgroundColor: SciCosmic.teal),
            child: const Text('Continue interview loop'),
          ),
        if (onAcceptOffer != null)
          FilledButton(
            onPressed: onAcceptOffer,
            style: FilledButton.styleFrom(backgroundColor: SciCosmic.success),
            child: const Text('Accept offer'),
          ),
      ],
    );
  }
}
