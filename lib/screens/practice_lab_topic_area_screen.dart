import 'package:flutter/material.dart';



import '../data/practice_lab_topics_catalog.dart';

import '../models/ai_practice_mode.dart';

import '../models/practice_lab.dart';

import '../models/practice_lab_topic.dart';

import '../theme/study_theme.dart';

import '../widgets/practice_lab/practice_labs_hub_widgets.dart';

import 'practice_lab_session_screen.dart';



/// Topics within one practice-lab area (e.g. Fundamentals → Vital Signs).

class PracticeLabTopicAreaScreen extends StatefulWidget {

  const PracticeLabTopicAreaScreen({

    super.key,

    required this.major,

    required this.area,

  });



  final PracticeLabCategory major;

  final PracticeLabTopicArea area;



  @override

  State<PracticeLabTopicAreaScreen> createState() => _PracticeLabTopicAreaScreenState();

}



class _PracticeLabTopicAreaScreenState extends State<PracticeLabTopicAreaScreen> {

  final TextEditingController _searchController = TextEditingController();

  String _query = '';



  PracticeLabCategory get major => widget.major;

  PracticeLabTopicArea get area => widget.area;



  PracticeLabGroupStyle get _style => PracticeLabGroupStyle.forGroup(major.groupId ?? '');



  @override

  void initState() {

    super.initState();

    _searchController.addListener(() => setState(() => _query = _searchController.text));

  }



  @override

  void dispose() {

    _searchController.dispose();

    super.dispose();

  }



  List<PracticeLabTopic> get _filteredTopics {

    final String trimmed = _query.trim().toLowerCase();

    if (trimmed.isEmpty) return area.topics;

    return area.topics

        .where(

          (PracticeLabTopic topic) =>

              topic.name.toLowerCase().contains(trimmed) ||

              topic.description.toLowerCase().contains(trimmed),

        )

        .toList();

  }



  void _startLab(PracticeLabTopic topic, PracticeDifficulty difficulty) {

    final PracticeLabType lab = PracticeLabTopicsCatalog.labFor(

      major: major,

      area: area,

      topic: topic,

      difficulty: difficulty,

    );

    Navigator.of(context).push(

      MaterialPageRoute<void>(

        builder: (_) => PracticeLabSessionScreen(

          category: major,

          lab: lab,

          topicAreaName: area.name,

          topicName: topic.name,

        ),

      ),

    );

  }



  @override

  Widget build(BuildContext context) {

    final Brightness brightness = Theme.of(context).brightness;

    final Color textSecondary = StudyColors.textSecondary(brightness);

    final List<PracticeLabTopic> topics = _filteredTopics;



    return Scaffold(

      backgroundColor: StudyColors.background(brightness),

      appBar: AppBar(

        title: Text('${area.emoji} ${area.name}'.trim()),

        backgroundColor: Colors.transparent,

        elevation: 0,

        scrolledUnderElevation: 0,

      ),

      body: ListView(

        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),

        children: <Widget>[

          PracticeLabAreaHeader(majorName: major.name, area: area, style: _style),

          const SizedBox(height: 16),

          const PracticeLabsFeatureCarousel(),

          const SizedBox(height: 14),

          Text(

            'Pick a topic and difficulty — every session is a unique AI scenario with voice, hints, and live scoring.',

            style: TextStyle(color: textSecondary, height: 1.45, fontWeight: FontWeight.w500),

          ),

          const SizedBox(height: 14),

          PracticeLabStyledSearch(

            controller: _searchController,

            hintText: 'Search topics…',

            onClear: _query.trim().isNotEmpty ? _searchController.clear : null,

          ),

          const SizedBox(height: 12),

          const PracticeLabDifficultyLegend(),

          const SizedBox(height: 16),

          if (topics.isEmpty)

            Container(

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(

                color: StudyColors.surface(brightness),

                borderRadius: BorderRadius.circular(16),

                border: Border.all(color: StudyColors.border(brightness)),

              ),

              child: Text('No topics match "$_query".', style: TextStyle(color: textSecondary)),

            )

          else

            ...topics.map(

              (PracticeLabTopic topic) => Padding(

                padding: const EdgeInsets.only(bottom: 12),

                child: PracticeLabTopicTile(

                  topic: topic,

                  style: _style,

                  onBeginner: topic.beginner ? () => _startLab(topic, PracticeDifficulty.beginner) : null,

                  onIntermediate: topic.intermediate ? () => _startLab(topic, PracticeDifficulty.intermediate) : null,

                  onAdvanced: topic.advanced ? () => _startLab(topic, PracticeDifficulty.advanced) : null,

                ),

              ),

            ),

        ],

      ),

    );

  }

}


