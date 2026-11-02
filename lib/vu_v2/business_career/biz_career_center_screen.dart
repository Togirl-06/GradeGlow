import 'package:flutter/material.dart';

import 'biz_job_catalog.dart';
import 'biz_project_lab_screen.dart';
import 'biz_workplace_screen.dart';
import 'business_career_content.dart';
import 'business_career_progress.dart';
import 'business_career_theme.dart';

/// Career Center — search/filter jobs, apply when résumé is ready.
class BizCareerCenterScreen extends StatefulWidget {
  const BizCareerCenterScreen({super.key, required this.progress});

  final BusinessCareerProgress progress;

  @override
  State<BizCareerCenterScreen> createState() => _BizCareerCenterScreenState();
}

class _BizCareerCenterScreenState extends State<BizCareerCenterScreen> {
  late BizJobListing _selected;
  String _filter = 'All majors';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = BizCareerJobs.all.first;
    widget.progress.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.progress.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  List<BizJobListing> get _jobs {
    Iterable<BizJobListing> list = BizCareerJobs.all;
    if (_filter != 'All majors') {
      list = list.where((BizJobListing j) => j.majorTag == _filter);
    }
    final String q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where(
        (BizJobListing j) =>
            j.title.toLowerCase().contains(q) ||
            j.company.toLowerCase().contains(q) ||
            j.skills.any((String s) => s.toLowerCase().contains(q)),
      );
    }
    return list.toList();
  }

  String _statusFor(String jobId) {
    final dynamic raw = widget.progress.applicationStatus[jobId];
    if (raw == null) return 'none';
    return '$raw';
  }

  String get _status => _statusFor(_selected.id);

  Future<void> _apply() async {
    if (!widget.progress.resumeReadyToApply) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Build your résumé in Project Lab first (score ≥40 or add a project).',
          ),
        ),
      );
      return;
    }
    if (_status != 'none' && _status != 'rejected') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status already: $_status')),
      );
      return;
    }
    await widget.progress.applyToJob(_selected.id);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Applied to ${_selected.title} at ${_selected.company}. '
          'Head to Interview Center next.',
        ),
      ),
    );
  }

  Future<void> _accept() async {
    await widget.progress.acceptOffer(_selected.id);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Offer accepted — Start job when ready.')),
    );
  }

  Future<void> _decline() async {
    await widget.progress.declineOffer(_selected.id);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Offer declined.')),
    );
  }

  Future<void> _startJob() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BizWorkplaceScreen(progress: widget.progress),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openMobileJob(BizJobListing job) async {
    setState(() => _selected = job);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BizCosmic.bg,
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
                        color: BizCosmic.stroke,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    Expanded(
                      child: _JobDetail(
                        job: _selected,
                        progress: widget.progress,
                        status: _statusFor(_selected.id),
                        onApply: () async {
                          await _apply();
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
                          await _startJob();
                          refresh();
                        },
                        onOpenLab: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => BizProjectLabScreen(
                                progress: widget.progress,
                              ),
                            ),
                          );
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
    final List<BizJobListing> jobs = _jobs;
    return Scaffold(
      backgroundColor: BizCosmic.bg,
      appBar: BizCosmic.appBar(
        context: context,
        title: 'Career Center',
        icon: Icons.work_outline_rounded,
      ),
      body: BizStarfield(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) {
            final bool wide = c.maxWidth >= 1000;
            final Widget list = _JobList(
              jobs: jobs,
              selected: _selected,
              filter: _filter,
              totalCount: BizCareerJobs.all.length,
              onQuery: (String q) => setState(() {
                _query = q;
                final List<BizJobListing> next = _jobs;
                if (next.isNotEmpty &&
                    !next.any((BizJobListing j) => j.id == _selected.id)) {
                  _selected = next.first;
                }
              }),
              onFilter: (String f) => setState(() {
                _filter = f;
                final List<BizJobListing> next = _jobs;
                if (next.isNotEmpty) _selected = next.first;
              }),
              onSelect: wide
                  ? (BizJobListing j) => setState(() => _selected = j)
                  : _openMobileJob,
            );
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(width: 320, child: list),
                  Expanded(
                    child: _JobDetail(
                      job: _selected,
                      progress: widget.progress,
                      status: _status,
                      onApply: _apply,
                      onAccept: _accept,
                      onDecline: _decline,
                      onStartJob: _startJob,
                      onOpenLab: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => BizProjectLabScreen(
                              progress: widget.progress,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
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

  final List<BizJobListing> jobs;
  final BizJobListing selected;
  final String filter;
  final int totalCount;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onFilter;
  final ValueChanged<BizJobListing> onSelect;

  @override
  Widget build(BuildContext context) {
    final List<String> filters = <String>[
      'All majors',
      ...BusinessMajors.all.map((BusinessMajor m) => m.title),
    ];
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BizCosmic.panelBox(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${jobs.length} of $totalCount roles',
            style: const TextStyle(color: BizCosmic.mute, fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: onQuery,
            style: const TextStyle(color: BizCosmic.ink, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search jobs or companies',
              hintStyle: const TextStyle(color: BizCosmic.mute),
              isDense: true,
              filled: true,
              fillColor: BizCosmic.panelAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: BizCosmic.mute,
                size: 18,
              ),
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
                        child: BizCosmic.pill(
                          f,
                          bg: filter == f
                              ? BizCosmic.royal.withValues(alpha: 0.35)
                              : BizCosmic.panelAlt,
                          fg: BizCosmic.ink,
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
                final BizJobListing j = jobs[i];
                final bool on = j.id == selected.id;
                return InkWell(
                  onTap: () => onSelect(j),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: on
                          ? BizCosmic.royal.withValues(alpha: 0.18)
                          : BizCosmic.panelAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: on ? BizCosmic.electric : BizCosmic.stroke,
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: BizCosmic.emerald,
                          child: Text(
                            j.companyLetter,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
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
                                  color: BizCosmic.ink,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                j.company,
                                style: const TextStyle(
                                  color: BizCosmic.mute,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 4,
                                children: <Widget>[
                                  BizCosmic.pill(j.mode),
                                  BizCosmic.pill(j.level),
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
    required this.status,
    required this.onApply,
    required this.onAccept,
    required this.onDecline,
    required this.onStartJob,
    required this.onOpenLab,
  });

  final BizJobListing job;
  final BusinessCareerProgress progress;
  final String status;
  final VoidCallback onApply;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onStartJob;
  final VoidCallback onOpenLab;

  @override
  Widget build(BuildContext context) {
    final bool ready = progress.resumeReadyToApply;
    final int projectCount = progress.portfolioProjects.length;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      padding: const EdgeInsets.all(18),
      decoration: BizCosmic.panelBox(radius: 18),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              job.title,
              style: const TextStyle(
                color: BizCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${job.company} · ${job.mode} · ${job.level}',
              style: const TextStyle(color: BizCosmic.mute),
            ),
            const SizedBox(height: 12),
            Text(
              job.blurb,
              style: const TextStyle(color: BizCosmic.ink, height: 1.4),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: job.skills.map((String s) => BizCosmic.pill(s)).toList(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BizCosmic.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${job.payLabel} · paid when you complete work tasks',
                style: const TextStyle(
                  color: BizCosmic.gold,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your résumé',
              style: TextStyle(
                color: BizCosmic.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            _Req(
              ok: projectCount >= 1,
              label: 'Projects in Project Lab',
              detail: '$projectCount',
            ),
            _Req(
              ok: progress.resumeScore >= 40,
              label: 'Résumé score',
              detail: '${progress.resumeScore}/100',
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onOpenLab,
              child: const Text('Open Project Lab →'),
            ),
            BizCosmic.pill(
              'Status: ${status == 'none' ? 'not applied' : status}',
              bg: BizCosmic.panelAlt,
            ),
            const SizedBox(height: 18),
            if (status == 'hired') ...<Widget>[
              BizCosmic.pill(
                progress.clockedIn ? 'On shift now' : 'Employed',
                bg: BizCosmic.success.withValues(alpha: 0.2),
                fg: BizCosmic.success,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onStartJob,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(progress.jobActionLabel()),
                style: FilledButton.styleFrom(
                  backgroundColor: BizCosmic.emerald,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ] else if (status == 'offered') ...<Widget>[
              const Text(
                'Offer ready — accept to unlock Company District / workplace.',
                style: TextStyle(
                  color: BizCosmic.mute,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onAccept,
                style: FilledButton.styleFrom(
                  backgroundColor: BizCosmic.success,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text('Accept ${job.company} offer'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: onDecline,
                style: OutlinedButton.styleFrom(
                  foregroundColor: BizCosmic.danger,
                  side: const BorderSide(color: BizCosmic.stroke),
                  minimumSize: const Size.fromHeight(44),
                ),
                child: const Text('Decline offer'),
              ),
            ] else ...<Widget>[
              FilledButton(
                onPressed: (status == 'none' || status == 'rejected')
                    ? onApply
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: BizCosmic.royal,
                  disabledBackgroundColor: BizCosmic.stroke,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(
                  status == 'rejected' ? 'Apply again' : 'Apply Now',
                ),
              ),
              if (!ready) ...<Widget>[
                const SizedBox(height: 8),
                const Text(
                  'Résumé not ready yet — add a project or raise score to 40+.',
                  style: TextStyle(
                    color: BizCosmic.warning,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
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
            color: ok ? BizCosmic.emerald : BizCosmic.warning,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: BizCosmic.ink, fontSize: 13),
            ),
          ),
          Text(
            detail,
            style: TextStyle(
              color: ok ? BizCosmic.mute : BizCosmic.warning,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
