import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../services/biology_progress_service.dart';
import '../../services/chemistry_progress_service.dart';
import '../../services/openai_service.dart';
import '../../services/physics_progress_service.dart';
import '../../theme/university_dashboard_colors.dart';
import '../biology/biology_degree_home_screen.dart';
import '../chemistry/chemistry_degree_home_screen.dart';
import '../physics/physics_degree_home_screen.dart';

class ScienceSchoolScreen extends StatelessWidget {
  const ScienceSchoolScreen({super.key});

  static const List<_ScienceProgram> _programs = <_ScienceProgram>[
    _ScienceProgram(
      id: 'biology',
      title: 'Biology',
      emoji: '🧬',
      color: Color(0xFF16A34A),
      asset: 'assets/biology/animal_cell.svg',
      description:
          'Explore living systems from cells and genes to organisms, health, and ecosystems.',
      topics: <String>[
        'Cell Biology',
        'Genetics',
        'Microbiology',
        'Anatomy & Physiology',
        'Ecology',
      ],
      courseCount: 26,
    ),
    _ScienceProgram(
      id: 'chemistry',
      title: 'Chemistry',
      emoji: '⚗️',
      color: Color(0xFF7C3AED),
      asset: 'assets/chemistry/atom.svg',
      description:
          'Understand matter, reactions, molecules, energy, and modern laboratory analysis.',
      topics: <String>[
        'General Chemistry',
        'Organic Chemistry',
        'Biochemistry',
        'Analytical Chemistry',
        'Physical Chemistry',
      ],
      courseCount: 26,
    ),
    _ScienceProgram(
      id: 'physics',
      title: 'Physics',
      emoji: '⚛️',
      color: Color(0xFF2563EB),
      asset: 'assets/physics/wave.svg',
      description:
          'Discover the laws of nature through mathematics, experiments, and simulations.',
      topics: <String>[
        'Mechanics',
        'Thermodynamics',
        'Electromagnetism',
        'Waves & Optics',
        'Modern Physics',
      ],
      courseCount: 24,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final UniversityDashboardColors dashboard = UniversityDashboardColors.of(
      context,
    );
    return Scaffold(
      backgroundColor: dashboard.page,
      appBar: AppBar(
        backgroundColor: dashboard.page,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 74,
        titleSpacing: 8,
        title: Row(
          children: <Widget>[
            const _ScienceHeaderIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'School of Sciences',
                    style: TextStyle(
                      color: dashboard.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 21,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Explore life, matter, and nature through AI-powered laboratories.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: dashboard.mutedText,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          if (MediaQuery.sizeOf(context).width >= 560)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('View All Progress'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: dashboard.text,
                  backgroundColor: dashboard.card,
                  side: BorderSide(color: dashboard.border),
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final int columns = constraints.maxWidth >= 850
              ? 3
              : constraints.maxWidth >= 560
              ? 2
              : 1;
          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth >= 900 ? 18 : 12,
              vertical: 2,
            ),
            children: <Widget>[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _programs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 340,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final _ScienceProgram program = _programs[index];
                  return _ProgramCard(
                    program: program,
                    onTap: () => _openProgram(context, program.id),
                  );
                },
              ),
              const SizedBox(height: 16),
              const _WhyScience(),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Text(
                    'Continue Learning',
                    style: TextStyle(
                      color: dashboard.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFF38D35A),
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 134,
                ),
                itemBuilder: (BuildContext context, int index) {
                  const List<String> titles = <String>[
                    'Cell Biology',
                    'Organic Chemistry',
                    'Mechanics',
                  ];
                  const List<String> subtitles = <String>[
                    'Organelles & Cell Function',
                    'Structure & Bonding',
                    'Newton\'s Laws',
                  ];
                  const List<double> progress = <double>[.72, .54, .38];
                  final _ScienceProgram program = _programs[index];
                  return _ContinueCard(
                    title: titles[index],
                    subtitle: subtitles[index],
                    emoji: program.emoji,
                    color: program.color,
                    progress: progress[index],
                    onTap: () => _openProgram(context, program.id),
                  );
                },
              ),
              const SizedBox(height: 28),
            ],
          );
        },
      ),
    );
  }

  static void _openProgram(BuildContext context, String id) {
    switch (id) {
      case 'biology':
        final BiologyProgressService progress = context
            .read<BiologyProgressService>();
        final OpenAiService openAi = context.read<OpenAiService>();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => MultiProvider(
              providers: [
                Provider<OpenAiService>.value(value: openAi),
                ChangeNotifierProvider<BiologyProgressService>.value(
                  value: progress,
                ),
              ],
              child: const BiologyDegreeHomeScreen(),
            ),
          ),
        );
        return;
      case 'chemistry':
        final ChemistryProgressService progress = context
            .read<ChemistryProgressService>();
        final OpenAiService openAi = context.read<OpenAiService>();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => MultiProvider(
              providers: [
                Provider<OpenAiService>.value(value: openAi),
                ChangeNotifierProvider<ChemistryProgressService>.value(
                  value: progress,
                ),
              ],
              child: const ChemistryDegreeHomeScreen(),
            ),
          ),
        );
        return;
      case 'physics':
        final PhysicsProgressService progress = context
            .read<PhysicsProgressService>();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                ChangeNotifierProvider<PhysicsProgressService>.value(
                  value: progress,
                  child: const PhysicsDegreeHomeScreen(),
                ),
          ),
        );
        return;
    }
  }
}

class _ScienceHeaderIcon extends StatelessWidget {
  const _ScienceHeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: const Color(0xFF16C784).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Icon(
        Icons.science_rounded,
        color: Color(0xFF38DFA3),
        size: 23,
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program, required this.onTap});

  final _ScienceProgram program;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final UniversityDashboardColors dashboard = UniversityDashboardColors.of(
      context,
    );
    return Material(
      color: dashboard.card,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: dashboard.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 34,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        program.color.withValues(alpha: 0.48),
                        dashboard.elevatedCard,
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: SvgPicture.asset(
                          program.asset,
                          height: 125,
                          fit: BoxFit.contain,
                          placeholderBuilder: (_) => Icon(
                            Icons.science,
                            size: 80,
                            color: program.color,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: dashboard.card.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: program.color),
                          ),
                          child: Text(
                            'MAJOR',
                            style: TextStyle(
                              color: dashboard.text,
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 66,
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(program.emoji),
                          const SizedBox(width: 7),
                          Text(
                            program.title,
                            style: TextStyle(
                              color: dashboard.text,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        program.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: dashboard.mutedText,
                          fontSize: 9,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 9),
                      ...program.topics
                          .take(5)
                          .map(
                            (String topic) => Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.check_circle,
                                    size: 13,
                                    color: program.color,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      topic,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: dashboard.text,
                                        fontSize: 8.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      const Spacer(),
                      Row(
                        children: <Widget>[
                          Text(
                            '${program.courseCount} courses',
                            style: TextStyle(
                              color: dashboard.mutedText,
                              fontSize: 8.5,
                            ),
                          ),
                          const Spacer(),
                          OutlinedButton(
                            onPressed: onTap,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: program.color,
                              side: BorderSide(color: program.color),
                              visualDensity: VisualDensity.compact,
                            ),
                            child: const Text('Explore'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhyScience extends StatelessWidget {
  const _WhyScience();

  @override
  Widget build(BuildContext context) {
    final UniversityDashboardColors dashboard = UniversityDashboardColors.of(
      context,
    );
    const List<(IconData, String, String)> benefits =
        <(IconData, String, String)>[
          (
            Icons.co_present,
            'AI Professors',
            'University lectures with diagrams, formulas, and questions.',
          ),
          (
            Icons.view_in_ar,
            'Interactive Models',
            'Manipulate cells, molecules, forces, and systems.',
          ),
          (
            Icons.science,
            'Virtual Laboratories',
            'Run experiments and analyze changing variables.',
          ),
          (
            Icons.biotech,
            'Research Skills',
            'Interpret evidence, write reports, and defend conclusions.',
          ),
          (
            Icons.workspace_premium,
            'Career Ready',
            'Build practical scientific and laboratory experience.',
          ),
        ];
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 13),
      decoration: BoxDecoration(
        color: dashboard.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: dashboard.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Why study science with us?',
            style: TextStyle(
              color: dashboard.text,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double width = constraints.maxWidth >= 850
                  ? (constraints.maxWidth - 48) / 5
                  : constraints.maxWidth >= 500
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 14,
                children: benefits
                    .map(
                      ((IconData, String, String) benefit) => SizedBox(
                        width: width,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 31,
                              height: 31,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF0EA5E9,
                                ).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                benefit.$1,
                                color: const Color(0xFF0EA5E9),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    benefit.$2,
                                    style: TextStyle(
                                      color: dashboard.text,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                  Text(
                                    benefit.$3,
                                    style: TextStyle(
                                      color: dashboard.mutedText,
                                      fontSize: 8,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.progress,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final UniversityDashboardColors dashboard = UniversityDashboardColors.of(
      context,
    );
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: dashboard.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: dashboard.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(emoji),
              const SizedBox(width: 7),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 8.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            style: TextStyle(
              color: dashboard.text,
              fontWeight: FontWeight.w900,
              fontSize: 10.5,
            ),
          ),
          const Spacer(),
          LinearProgressIndicator(
            value: progress,
            color: color,
            minHeight: 4,
            backgroundColor: dashboard.track,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: double.infinity,
            height: 24,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: color.withValues(alpha: 0.24),
                foregroundColor: color,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                textStyle: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScienceProgram {
  const _ScienceProgram({
    required this.id,
    required this.title,
    required this.emoji,
    required this.color,
    required this.asset,
    required this.description,
    required this.topics,
    required this.courseCount,
  });

  final String id;
  final String title;
  final String emoji;
  final Color color;
  final String asset;
  final String description;
  final List<String> topics;
  final int courseCount;
}
