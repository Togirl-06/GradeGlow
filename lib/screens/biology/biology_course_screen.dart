import 'package:flutter/material.dart';

import '../../data/vu_premium_course_adapters.dart';
import '../../models/biology_degree.dart';
import '../virtual_university/course/vu_premium_course_screen.dart';

/// Biology course opens the premium digital classroom experience.
class BiologyCourseScreen extends StatelessWidget {
  const BiologyCourseScreen({
    super.key,
    required this.year,
    required this.course,
  });

  final BiologyDegreeYear year;
  final BiologyDegreeCourse course;

  @override
  Widget build(BuildContext context) {
    final courseData = VuPremiumCourseAdapters.fromBiology(
      year: year,
      course: course,
      context: context,
    );
    return VuPremiumCourseScreen(course: courseData);
  }
}
