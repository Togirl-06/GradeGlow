import 'package:flutter/material.dart';

import '../../design/vu_v2_theme.dart';
import '../vu_v2_lab_models.dart';

/// Per-school identity for Virtual Lab Centers.
class VuV2SchoolLabIdentity {
  const VuV2SchoolLabIdentity({
    required this.school,
    required this.facilityName,
    required this.roleTitle,
    required this.dayOneBrief,
    required this.accent,
    required this.heroLine,
  });

  final VuV2LabSchool school;
  final String facilityName;
  final String roleTitle;
  final String dayOneBrief;
  final Color accent;
  final String heroLine;

  static VuV2SchoolLabIdentity forSchool(VuV2LabSchool school) {
    switch (school) {
      case VuV2LabSchool.physics:
        return const VuV2SchoolLabIdentity(
          school: VuV2LabSchool.physics,
          facilityName: 'Physics Research Bay',
          roleTitle: 'Lab Technician · Physics',
          heroLine: 'Measure. Model. Predict. Defend your numbers.',
          dayOneBrief:
              'You are on the floor of a university physics bay. '
              'Stations are live equipment — not worksheets. Log every observation '
              'before you leave a bench. Mentors will ask what changed and why.',
          accent: Color(0xFF38BDF8),
        );
      case VuV2LabSchool.chemistry:
        return const VuV2SchoolLabIdentity(
          school: VuV2LabSchool.chemistry,
          facilityName: 'Chemistry Synthesis Lab',
          roleTitle: 'Junior Chemist',
          heroLine: 'Safety first. Stoichiometry second. Insight always.',
          dayOneBrief:
              'Goggles on. You run reactions, titrations, and molecular models. '
              'Record yields, color changes, and hazards. Guessing without a notebook '
              'fails this lab — just like a real internship.',
          accent: Color(0xFFA78BFA),
        );
      case VuV2LabSchool.biology:
        return const VuV2SchoolLabIdentity(
          school: VuV2LabSchool.biology,
          facilityName: 'Biology Discovery Suite',
          roleTitle: 'Research Assistant · Biology',
          heroLine: 'Cells, DNA, and systems — observe before you conclude.',
          dayOneBrief:
              'You assist a PI in a wet/dry biology suite. Anatomy, cell structure, '
              'and DNA pairing are live benches. Write what you see. Hypotheses without '
              'evidence get rejected in lab meeting.',
          accent: Color(0xFF34D399),
        );
      case VuV2LabSchool.nursing:
        return const VuV2SchoolLabIdentity(
          school: VuV2LabSchool.nursing,
          facilityName: 'Clinical Skills Center',
          roleTitle: 'Student Nurse · Clinical Placement',
          heroLine: 'Patients first. Protocols always. Calm under pressure.',
          dayOneBrief:
              'This is a clinical skills floor. Vital signs, scenarios, and equipment '
              'checks mirror a hospital skills lab. Document assessments. Escalate safely. '
              'Your mentor grades judgment — not memorized flashcards.',
          accent: Color(0xFFFB7185),
        );
      case VuV2LabSchool.psychology:
        return const VuV2SchoolLabIdentity(
          school: VuV2LabSchool.psychology,
          facilityName: 'Cognitive Science Lab',
          roleTitle: 'Research Assistant · Psychology',
          heroLine: 'Design the trial. Collect the data. Question the bias.',
          dayOneBrief:
              'You run cognitive experiments. Memory, attention, and bias are the instruments. '
              'Log methods and results like a RA preparing a lab report for publication.',
          accent: Color(0xFFFBBF24),
        );
      case VuV2LabSchool.mathematics:
        return const VuV2SchoolLabIdentity(
          school: VuV2LabSchool.mathematics,
          facilityName: 'Mathematics Modeling Studio',
          roleTitle: 'Modeling Intern',
          heroLine: 'Graph it. Prove it. Stress-test the assumptions.',
          dayOneBrief:
              'This studio treats math as a lab — parameters, graphs, and written reasoning. '
              'Change a coefficient, watch the model move, then explain the geometry in words '
              'a teammate can reuse.',
          accent: Color(0xFF818CF8),
        );
      case VuV2LabSchool.computerScience:
        return const VuV2SchoolLabIdentity(
          school: VuV2LabSchool.computerScience,
          facilityName: 'Algorithm Arena',
          roleTitle: 'Software Engineer Intern',
          heroLine: 'Ship correct code under constraints.',
          dayOneBrief: 'Open Algorithm Arena and solve unique problems.',
          accent: Color(0xFF22D3EE),
        );
      case VuV2LabSchool.business:
        return const VuV2SchoolLabIdentity(
          school: VuV2LabSchool.business,
          facilityName: 'Business Simulation Center',
          roleTitle: 'CEO Fellow',
          heroLine: 'One company. Compounding decisions.',
          dayOneBrief: 'Open the Simulation Center HQ.',
          accent: Color(0xFF10B981),
        );
    }
  }
}

class VuV2LabGlass extends StatelessWidget {
  const VuV2LabGlass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.accent,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final Color border = accent ?? VuV2Colors.stroke;
    final Widget body = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border.withValues(alpha: 0.75)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            VuV2Colors.navyElevated.withValues(alpha: 0.95),
            VuV2Colors.navy.withValues(alpha: 0.9),
          ],
        ),
        boxShadow: accent == null
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: accent!.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: child,
    );
    if (onTap == null) {
      return body;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: body,
      ),
    );
  }
}
