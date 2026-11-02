import 'package:flutter/material.dart';

import 'job_catalog.dart';
import 'northwind_workplace_screen.dart';
import 'science_career_content.dart' show JobListing;
import 'science_career_progress.dart';
import 'science_career_theme.dart';

/// Company District — only workplaces for jobs you were hired into.
class CompanyDistrictScreen extends StatelessWidget {
  const CompanyDistrictScreen({super.key, required this.progress});

  final ScienceCareerProgress progress;

  @override
  Widget build(BuildContext context) {
    final List<JobListing> hiredJobs = CareerJobs.all
        .where(
          (JobListing j) =>
              progress.employedJobIds.contains(j.id) ||
              progress.statusFor(j.id) == 'hired' ||
              (j.id == 'northwind_junior' && progress.isEmployedAtNorthwind),
        )
        .toList();

    // Deduplicate by company for the district map.
    final Map<String, JobListing> byCompany = <String, JobListing>{};
    for (final JobListing j in hiredJobs) {
      byCompany.putIfAbsent(j.company, () => j);
    }

    return Scaffold(
      backgroundColor: SciCosmic.bg,
      appBar: SciCosmic.appBar(
        context: context,
        title: 'Company District',
        icon: Icons.apartment_rounded,
        subtitle: 'Made ${progress.lifetimeEarnedLabel}',
      ),
      body: SciStarfield(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: SciCosmic.panelBox(radius: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Your workplaces',
                    style: TextStyle(
                      color: SciCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    byCompany.isEmpty
                        ? 'No offices unlocked yet. Apply with your résumé in Career Center, pass the interview, then accept an offer.'
                        : 'Clock in to start a paid shift. Complete tickets while on the clock, then clock out to deposit dollars.',
                    style: const TextStyle(color: SciCosmic.mute, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bank ${progress.balanceLabel} · lifetime earned \$${(progress.lifetimeEarnedCents / 100).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: SciCosmic.gold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (byCompany.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: SciCosmic.panelBox(radius: 16),
                child: const Text(
                  'District locked for unhired roles. Get hired to unlock your company floor.',
                  style: TextStyle(color: SciCosmic.mute),
                ),
              )
            else
              ...byCompany.entries.map((MapEntry<String, JobListing> e) {
                final JobListing job = e.value;
                final bool isNorthwind = e.key == 'Northwind Labs';
                final String action =
                    progress.jobActionLabel(jobId: job.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: SciCosmic.panelBox(radius: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: SciCosmic.blue,
                              child: Text(
                                job.companyLetter,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    e.key,
                                    style: const TextStyle(
                                      color: SciCosmic.ink,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    '${job.title} · \$${(progress.hourlyWageCents / 100).toStringAsFixed(2)}/hr',
                                    style: const TextStyle(
                                      color: SciCosmic.mute,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SciCosmic.pill(
                              progress.clockedIn &&
                                      progress.activeEmployerJobId == job.id
                                  ? 'On shift'
                                  : progress.hasStartedWork
                                      ? 'In progress'
                                      : 'Ready',
                              bg: SciCosmic.success.withValues(alpha: 0.2),
                              fg: SciCosmic.success,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () {
                            if (isNorthwind) {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (_) => NorthwindWorkplaceScreen(
                                    progress: progress,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${e.key} floor simulation expands next — you are hired as ${job.title}.',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            progress.clockedIn
                                ? Icons.play_circle_outline
                                : progress.hasStartedWork
                                    ? Icons.work_history_outlined
                                    : Icons.play_arrow_rounded,
                          ),
                          label: Text(action),
                          style: FilledButton.styleFrom(
                            backgroundColor: SciCosmic.teal,
                            minimumSize: const Size.fromHeight(44),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
