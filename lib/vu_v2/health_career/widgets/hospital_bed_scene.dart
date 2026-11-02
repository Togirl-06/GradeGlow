import 'package:flutter/material.dart';

import '../health_career_theme.dart';
import '../models/hospital_case.dart';
import '../models/patient_profile.dart';

/// Realistic hospital room backdrop with patient in bed + bedside monitor.
class HospitalBedScene extends StatelessWidget {
  const HospitalBedScene({
    super.key,
    required this.patient,
    required this.vitals,
    this.vitalsRevealed = true,
    this.caption,
  });

  final PatientProfile patient;
  final LiveVitals vitals;
  final bool vitalsRevealed;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CustomPaint(
              painter: _WardRoomPainter(
                skin: patient.skinTone,
                hobElevated: vitals.hobElevated,
                onOxygen: vitals.onOxygen,
                ivStarted: vitals.ivStarted,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: _MonitorPanel(vitals: vitals, revealed: vitalsRevealed),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              right: 12,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        caption ??
                            '${patient.displayName} · ${patient.appearanceNotes}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: MedCosmic.ink,
                          fontSize: 12,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

class _MonitorPanel extends StatelessWidget {
  const _MonitorPanel({required this.vitals, required this.revealed});

  final LiveVitals vitals;
  final bool revealed;

  Color _spo2Color() {
    if (vitals.spo2 < 90) return MedCosmic.danger;
    if (vitals.spo2 < 94) return MedCosmic.warning;
    return MedCosmic.success;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F14).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1F3A2E)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'BEDSIDE MONITOR',
            style: TextStyle(
              color: Color(0xFF6EE7B7),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          if (!revealed)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Not connected\nTake vitals to sync',
                style: TextStyle(
                  color: MedCosmic.mute,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            )
          else ...<Widget>[
            _MonRow('HR', '${vitals.hr}', const Color(0xFFF87171)),
            _MonRow('SpO₂', '${vitals.spo2}%', _spo2Color()),
            _MonRow('BP', vitals.bpLabel, const Color(0xFF93C5FD)),
            _MonRow('RR', '${vitals.rr}', const Color(0xFFFDE68A)),
            _MonRow('Temp', vitals.tempLabel, const Color(0xFFFBBF24)),
            if (vitals.onOxygen)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'O₂ ON',
                  style: TextStyle(
                    color: MedCosmic.clinical,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _MonRow extends StatelessWidget {
  const _MonRow(this.k, this.v, this.c);
  final String k;
  final String v;
  final Color c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 36,
            child: Text(
              k,
              style: TextStyle(
                color: c.withValues(alpha: 0.85),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: TextStyle(
                color: c,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WardRoomPainter extends CustomPainter {
  _WardRoomPainter({
    required this.skin,
    required this.hobElevated,
    required this.onOxygen,
    required this.ivStarted,
  });

  final Color skin;
  final bool hobElevated;
  final bool onOxygen;
  final bool ivStarted;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;

    // Room wash — cool clinical lighting
    final Paint wall = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFF1A2336),
          Color(0xFF121A28),
          Color(0xFF0E1522),
        ],
      ).createShader(bounds);
    canvas.drawRect(bounds, wall);

    // Window light
    final RRect window = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.62, size.height * 0.08, size.width * 0.28,
          size.height * 0.32),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      window,
      Paint()..color = const Color(0xFF2A3F5C).withValues(alpha: 0.55),
    );
    canvas.drawRRect(
      window,
      Paint()
        ..color = const Color(0xFF7DD3FC).withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Floor
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.72, size.width, size.height * 0.28),
      Paint()..color = const Color(0xFF1C2434),
    );

    // Bed frame
    final double bedLeft = size.width * 0.12;
    final double bedTop = size.height * (hobElevated ? 0.38 : 0.42);
    final double bedW = size.width * 0.55;
    final double bedH = size.height * 0.28;

    final RRect mattress = RRect.fromRectAndRadius(
      Rect.fromLTWH(bedLeft, bedTop, bedW, bedH),
      const Radius.circular(10),
    );
    canvas.drawRRect(mattress, Paint()..color = const Color(0xFFE8EEF6));
    canvas.drawRRect(
      mattress,
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Pillow / elevated head
    final double headLift = hobElevated ? -size.height * 0.06 : 0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          bedLeft + 8,
          bedTop - 18 + headLift,
          bedW * 0.28,
          28,
        ),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFFF1F5F9),
    );

    // Blanket
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          bedLeft + bedW * 0.22,
          bedTop + bedH * 0.35,
          bedW * 0.72,
          bedH * 0.55,
        ),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF3B82F6).withValues(alpha: 0.55),
    );

    // Patient body (realistic proportions, not cartoon face)
    final double torsoY = bedTop + 6 + headLift * 0.4;
    final Paint skinPaint = Paint()..color = skin;
    // Head
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bedLeft + bedW * 0.18, torsoY + 10),
        width: 36,
        height: 42,
      ),
      skinPaint,
    );
    // Hair
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(bedLeft + bedW * 0.18, torsoY + 4),
        width: 38,
        height: 28,
      ),
      3.4,
      2.5,
      false,
      Paint()
        ..color = const Color(0xFF1C1917)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
    // Torso / gown
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          bedLeft + bedW * 0.22,
          torsoY + 18,
          bedW * 0.42,
          bedH * 0.45,
        ),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFFCBD5E1),
    );
    // Arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          bedLeft + bedW * 0.55,
          torsoY + 28,
          bedW * 0.22,
          14,
        ),
        const Radius.circular(7),
      ),
      skinPaint,
    );

    // IV pole
    if (ivStarted || true) {
      final double poleX = bedLeft + bedW + 18;
      canvas.drawLine(
        Offset(poleX, size.height * 0.18),
        Offset(poleX, size.height * 0.78),
        Paint()
          ..color = const Color(0xFF94A3B8)
          ..strokeWidth = 3,
      );
      if (ivStarted) {
        canvas.drawCircle(
          Offset(poleX, size.height * 0.22),
          10,
          Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.85),
        );
        canvas.drawLine(
          Offset(poleX, size.height * 0.28),
          Offset(bedLeft + bedW * 0.72, torsoY + 34),
          Paint()
            ..color = const Color(0xFF7DD3FC)
            ..strokeWidth = 1.5,
        );
      }
    }

    // O2 tubing hint
    if (onOxygen) {
      canvas.drawLine(
        Offset(bedLeft + bedW * 0.18, torsoY + 22),
        Offset(bedLeft + bedW * 0.05, torsoY + 40),
        Paint()
          ..color = const Color(0xFF67E8F9)
          ..strokeWidth = 2,
      );
      canvas.drawCircle(
        Offset(bedLeft + bedW * 0.04, torsoY + 48),
        8,
        Paint()..color = const Color(0xFF22D3EE).withValues(alpha: 0.7),
      );
    }

    // Side rail
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bedLeft - 6, bedTop + 8, 8, bedH * 0.7),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF64748B),
    );
  }

  @override
  bool shouldRepaint(covariant _WardRoomPainter oldDelegate) =>
      oldDelegate.hobElevated != hobElevated ||
      oldDelegate.onOxygen != onOxygen ||
      oldDelegate.ivStarted != ivStarted ||
      oldDelegate.skin != skin;
}
