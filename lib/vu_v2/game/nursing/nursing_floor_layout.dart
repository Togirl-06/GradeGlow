import '../models/vu_game_models.dart';

/// GradeGlow Nursing Virtual Clinical — single-floor hospital MVP.
abstract final class NursingFloorLayout {
  static const double worldW = 920;
  static const double worldH = 620;

  static VuGameWorldLayout build() {
    return VuGameWorldLayout(
      id: 'nursing_clinical_floor',
      title: 'Riverside Med · Clinical Wing',
      worldSize: const VuGameVec2(worldW, worldH),
      playerSpawn: const VuGameVec2(120, 520),
      zones: const <VuGameZone>[
        VuGameZone(
          id: 'entrance',
          name: 'Hospital Entrance',
          bounds: VuGameRect(40, 460, 200, 140),
          floorColor: 0xFFB8D4E8,
        ),
        VuGameZone(
          id: 'reception',
          name: 'Reception',
          bounds: VuGameRect(260, 460, 180, 140),
          floorColor: 0xFFE8DCC8,
        ),
        VuGameZone(
          id: 'hallway',
          name: 'Main Hallway',
          bounds: VuGameRect(460, 300, 440, 300),
          floorColor: 0xFFF0E6D4,
        ),
        VuGameZone(
          id: 'nurses_station',
          name: "Nurses' Station",
          bounds: VuGameRect(40, 240, 380, 200),
          floorColor: 0xFFC8E6D0,
        ),
        VuGameZone(
          id: 'patient_room',
          name: 'Patient Room 103',
          bounds: VuGameRect(520, 40, 360, 240),
          floorColor: 0xFFE0F0F8,
        ),
      ],
      walls: const <VuGameRect>[
        // Outer shell
        VuGameRect(20, 20, 880, 16),
        VuGameRect(20, 20, 16, 580),
        VuGameRect(884, 20, 16, 580),
        VuGameRect(20, 584, 880, 16),
        // Reception desk
        VuGameRect(300, 480, 100, 36),
        // Nurse station counter
        VuGameRect(180, 300, 200, 28),
        // Patient room divider
        VuGameRect(500, 40, 16, 260),
        VuGameRect(500, 280, 420, 16),
        // Med cabinet alcove
        VuGameRect(60, 260, 80, 60),
        // Bed footprint
        VuGameRect(620, 120, 140, 70),
      ],
      npcs: const <VuGameNpc>[
        VuGameNpc(
          id: 'diaz',
          name: 'Charge Nurse Diaz',
          role: 'Supervisor',
          position: VuGameVec2(280, 340),
          dialogueRootId: 'diaz_root',
          glyph: '👩‍⚕️',
        ),
        VuGameNpc(
          id: 'cole',
          name: 'Mr. Cole',
          role: 'Patient 103',
          position: VuGameVec2(680, 160),
          dialogueRootId: 'patient_root',
          glyph: '🧑',
        ),
        VuGameNpc(
          id: 'dr_park',
          name: 'Dr. Park',
          role: 'Physician',
          position: VuGameVec2(720, 380),
          dialogueRootId: 'doctor_root',
          glyph: '👨‍⚕️',
        ),
      ],
      interactables: const <VuGameInteractable>[
        VuGameInteractable(
          id: 'assignment_board',
          label: 'Assignment board',
          position: VuGameVec2(320, 280),
          actionId: 'view_assignments',
          glyph: '📋',
          zoneId: 'nurses_station',
        ),
        VuGameInteractable(
          id: 'patient_chart',
          label: 'Patient chart',
          position: VuGameVec2(560, 100),
          actionId: 'review_chart',
          glyph: '📁',
          zoneId: 'patient_room',
        ),
        VuGameInteractable(
          id: 'bed',
          label: 'Hospital bed',
          position: VuGameVec2(690, 155),
          actionId: 'bedside',
          glyph: '🛏️',
          zoneId: 'patient_room',
        ),
        VuGameInteractable(
          id: 'monitor',
          label: 'Patient monitor',
          position: VuGameVec2(780, 130),
          actionId: 'check_monitor',
          glyph: '📈',
          zoneId: 'patient_room',
        ),
        VuGameInteractable(
          id: 'bp_cuff',
          label: 'Blood pressure cuff',
          position: VuGameVec2(600, 200),
          actionId: 'check_bp',
          glyph: '🩺',
          zoneId: 'patient_room',
        ),
        VuGameInteractable(
          id: 'stethoscope',
          label: 'Stethoscope',
          position: VuGameVec2(640, 210),
          actionId: 'auscultate',
          glyph: '🫁',
          zoneId: 'patient_room',
        ),
        VuGameInteractable(
          id: 'med_cabinet',
          label: 'Medication cabinet',
          position: VuGameVec2(100, 290),
          actionId: 'med_cabinet',
          glyph: '💊',
          zoneId: 'nurses_station',
        ),
        VuGameInteractable(
          id: 'nurse_phone',
          label: 'Nurse phone',
          position: VuGameVec2(360, 320),
          actionId: 'call_team',
          glyph: '☎️',
          zoneId: 'nurses_station',
        ),
        VuGameInteractable(
          id: 'workstation',
          label: 'Workstation',
          position: VuGameVec2(240, 320),
          actionId: 'document',
          glyph: '🖥️',
          zoneId: 'nurses_station',
        ),
      ],
    );
  }
}
