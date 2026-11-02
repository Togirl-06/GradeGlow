import 'package:flutter/material.dart';

import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';

class VuV2CertificateScreen extends StatelessWidget {
  const VuV2CertificateScreen({
    super.key,
    required this.studentName,
    required this.courseTitle,
    required this.verificationId,
    this.completionDate,
  });

  final String studentName;
  final String courseTitle;
  final String verificationId;
  final DateTime? completionDate;

  @override
  Widget build(BuildContext context) {
    final DateTime date = completionDate ?? DateTime.now();
    final String dateLabel =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: Text('Certificate')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(VuV2Radii.xl),
              border: Border.all(color: VuV2Colors.orange, width: 2),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  VuV2Colors.navyElevated,
                  VuV2Colors.orange.withValues(alpha: 0.18),
                ],
              ),
            ),
            child: Column(
              children: <Widget>[
                Text('🎓', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(
                  'GradeGlow Virtual University',
                  style: TextStyle(
                    color: VuV2Colors.orange,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Certificate of Completion',
                  style: TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'This certifies that',
                  style: TextStyle(color: VuV2Colors.mute),
                ),
                const SizedBox(height: 8),
                Text(
                  studentName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'has successfully completed',
                  style: TextStyle(color: VuV2Colors.mute),
                ),
                const SizedBox(height: 8),
                Text(
                  courseTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: VuV2Colors.orange,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Completion date · $dateLabel',
                  style: TextStyle(color: VuV2Colors.mute, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  'Verification ID · $verificationId',
                  style: TextStyle(color: VuV2Colors.mute, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  'Learning achievement · beta (not an accredited credential)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: VuV2Colors.mute, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          VuV2PrimaryButton(
            label: 'Done',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
