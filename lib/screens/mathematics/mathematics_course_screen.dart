import 'package:flutter/material.dart';

import '../../data/vu_premium_course_adapters.dart';
import '../../models/mathematics_degree.dart';
import '../virtual_university/course/vu_premium_course_screen.dart';

class MathematicsCourseScreen extends StatelessWidget {
  const MathematicsCourseScreen({
    super.key,
    required this.year,
    required this.course,
  });

  final MathematicsDegreeYear year;
  final MathematicsDegreeCourse course;

  @override
  Widget build(BuildContext context) {
    return VuPremiumCourseScreen(
      course: VuPremiumCourseAdapters.fromMathematics(
        year: year,
        course: course,
        context: context,
      ),
    );
  }
}
