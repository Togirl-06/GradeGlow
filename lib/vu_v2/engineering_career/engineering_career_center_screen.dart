import 'package:flutter/material.dart';

import 'engineering_career_content.dart';
import 'engineering_career_progress.dart';
import 'engineering_career_theme.dart';
import 'engineering_interview_screen.dart';
import 'job_offer_screen.dart';
import 'mechworks_workplace_screen.dart';
import 'work_task_board_screen.dart';

class EngineeringCareerCenterScreen extends StatefulWidget {
  const EngineeringCareerCenterScreen({super.key, required this.progress});

  final EngineeringCareerProgress progress;

  @override
  State<EngineeringCareerCenterScreen> createState() =>
      _EngineeringCareerCenterScreenState();
}

class _EngineeringCareerCenterScreenState
    extends State<EngineeringCareerCenterScreen>
    with SingleTickerProviderStateMixin {
  bool _busy = false;
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    widget.progress.addListener(_tick);
  }

  @override
  void dispose() {
    _tabs.dispose();
    widget.progress.removeListener(_tick);
    super.dispose();
  }

  void _tick() {
    if (mounted) setState(() {});
  }

  Future<void> _apply(EngJob job) async {
    if (_busy) return;
    setState(() => _busy = true);
    final String? err = await widget.progress.applyToJob(job.id);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          err ?? 'Applied to ${job.title}. Complete the interview next.',
        ),
      ),
    );
  }

  Future<void> _interview(EngJob job) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => EngineeringInterviewScreen(
          progress: widget.progress,
          forJobId: job.id,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openOffer(EngJob job) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => JobOfferScreen(
          progress: widget.progress,
          jobId: job.id,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<EngJob> available = EngJobs.forMajor(widget.progress.majorId);
    final List<EngJob> board =
        available.isEmpty ? EngJobs.all : available;
    final List<EngJob> mine = EngJobs.all
        .where(
          (EngJob j) => widget.progress.statusFor(j.id) != 'none',
        )
        .toList();

    return Scaffold(
      backgroundColor: EngCosmic.bg,
      appBar: EngCosmic.appBar(
        context: context,
        title: 'Career Center',
        icon: Icons.work_rounded,
        subtitle: 'Bank ${widget.progress.balanceLabel}',
      ),
      body: EngStarfield(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: EngCosmic.panelBox(radius: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Engineering employers (fictional)',
                      style: TextStyle(
                        color: EngCosmic.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Browse → Apply → Interview → Offer → Accept. '
                      'Jobs are never automatic. Stage: ${widget.progress.stageLabel}.',
                      style: const TextStyle(
                        color: EngCosmic.mute,
                        height: 1.35,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TabBar(
              controller: _tabs,
              labelColor: EngCosmic.electric,
              unselectedLabelColor: EngCosmic.mute,
              indicatorColor: EngCosmic.electric,
              tabs: const <Widget>[
                Tab(text: 'Available Jobs'),
                Tab(text: 'My Applications'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: <Widget>[
                  _JobList(
                    jobs: board,
                    progress: widget.progress,
                    busy: _busy,
                    onApply: _apply,
                    onInterview: _interview,
                    onOffer: _openOffer,
                    onWorkplace: (EngJob job) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => WorkTaskBoardScreen(
                            progress: widget.progress,
                          ),
                        ),
                      );
                    },
                  ),
                  mine.isEmpty
                      ? const Center(
                          child: Text(
                            'No applications yet.',
                            style: TextStyle(color: EngCosmic.mute),
                          ),
                        )
                      : _JobList(
                          jobs: mine,
                          progress: widget.progress,
                          busy: _busy,
                          onApply: _apply,
                          onInterview: _interview,
                          onOffer: _openOffer,
                          onWorkplace: (EngJob job) {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => MechWorksWorkplaceScreen(
                                  progress: widget.progress,
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobList extends StatelessWidget {
  const _JobList({
    required this.jobs,
    required this.progress,
    required this.busy,
    required this.onApply,
    required this.onInterview,
    required this.onOffer,
    required this.onWorkplace,
  });

  final List<EngJob> jobs;
  final EngineeringCareerProgress progress;
  final bool busy;
  final Future<void> Function(EngJob) onApply;
  final Future<void> Function(EngJob) onInterview;
  final Future<void> Function(EngJob) onOffer;
  final void Function(EngJob) onWorkplace;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
      itemCount: jobs.length,
      itemBuilder: (BuildContext context, int i) {
        final EngJob job = jobs[i];
        final String st = progress.statusFor(job.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: EngCosmic.panelBox(radius: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: EngCosmic.blue,
                      child: Text(
                        job.company[0],
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            job.title,
                            style: const TextStyle(
                              color: EngCosmic.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${job.company} · ${job.payLabel}',
                            style: const TextStyle(
                              color: EngCosmic.mute,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    EngCosmic.pill(st == 'none' ? 'Open' : st),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  job.blurb,
                  style: const TextStyle(
                    color: EngCosmic.ink,
                    height: 1.35,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children:
                      job.skills.map((String s) => EngCosmic.pill(s)).toList(),
                ),
                const SizedBox(height: 12),
                if (st == 'none' || st == 'rejected')
                  FilledButton(
                    onPressed: busy ? null : () => onApply(job),
                    child: Text(st == 'rejected' ? 'Apply again' : 'Apply'),
                  )
                else if (st == 'applied' || st == 'interviewed')
                  FilledButton(
                    onPressed: () => onInterview(job),
                    style: FilledButton.styleFrom(
                      backgroundColor: EngCosmic.purple,
                    ),
                    child: const Text('Start interview'),
                  )
                else if (st == 'offered')
                  FilledButton(
                    onPressed: () => onOffer(job),
                    style: FilledButton.styleFrom(
                      backgroundColor: EngCosmic.success,
                    ),
                    child: const Text('View offer'),
                  )
                else if (st == 'hired')
                  FilledButton(
                    onPressed: () => onWorkplace(job),
                    style: FilledButton.styleFrom(
                      backgroundColor: EngCosmic.teal,
                    ),
                    child: const Text('Open workplace tasks'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
