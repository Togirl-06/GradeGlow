import 'package:flutter/material.dart';

import '../models/hospital_room.dart';

/// Hospital wings and rooms for virtual hospital simulations.
class VirtualHospitalData {
  VirtualHospitalData._();

  static List<HospitalRoom> roomsFor({required bool teachingHospital}) {
    if (teachingHospital) {
      return <HospitalRoom>[
        const HospitalRoom(id: 'er', name: 'Emergency Room', icon: Icons.emergency_rounded, description: 'Triage and stabilize acute presentations.', accent: Color(0xFFEF5350)),
        const HospitalRoom(id: 'icu', name: 'ICU', icon: Icons.monitor_heart_outlined, description: 'Manage critically ill patients on monitors.', accent: Color(0xFFAB47BC)),
        const HospitalRoom(id: 'trauma', name: 'Trauma Center', icon: Icons.healing_rounded, description: 'Multi-system trauma and hemorrhage control.', accent: Color(0xFFFF7043)),
        const HospitalRoom(id: 'surgery', name: 'Surgical Wing', icon: Icons.content_cut_outlined, description: 'Pre-op, sterile technique, and post-op care.', accent: Color(0xFF26A69A)),
        const HospitalRoom(id: 'peds', name: 'Pediatric Wing', icon: Icons.child_care_rounded, description: 'Age-specific assessment and family communication.', accent: Color(0xFF42A5F5)),
      ];
    }
    return <HospitalRoom>[
      const HospitalRoom(id: 'er', name: 'Emergency Department', icon: Icons.emergency_rounded, description: 'Rapid assessment and intervention.', accent: Color(0xFF22D3EE)),
      const HospitalRoom(id: 'med_surg', name: 'Patient Rooms', icon: Icons.hotel_rounded, description: 'Med-surg floors — vitals, meds, and education.', accent: Color(0xFF66BB6A)),
      const HospitalRoom(id: 'icu', name: 'ICU', icon: Icons.monitor_heart_outlined, description: 'Critical care and ventilator management.', accent: Color(0xFFAB47BC)),
      const HospitalRoom(id: 'or', name: 'Operating Room', icon: Icons.content_cut_outlined, description: 'Perioperative nursing and safety checks.', accent: Color(0xFF26A69A)),
    ];
  }
}
