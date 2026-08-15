import 'package:flutter/material.dart';

import '../../data/vu_premium_course_adapters.dart';
import '../../models/chemistry_degree.dart';
import '../virtual_university/course/vu_premium_course_screen.dart';

class ChemistryCourseScreen extends StatelessWidget {
  const ChemistryCourseScreen({
    super.key,
    required this.year,
    required this.course,
  });

  final ChemistryDegreeYear year;
  final ChemistryDegreeCourse course;

  @override
  Widget build(BuildContext context) {
    return VuPremiumCourseScreen(
      course: VuPremiumCourseAdapters.fromChemistry(
        year: year,
        course: course,
        context: context,
      ),
    );
  }
}
