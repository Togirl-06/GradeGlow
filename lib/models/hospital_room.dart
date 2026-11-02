import 'package:flutter/material.dart';

class HospitalRoom {
  const HospitalRoom({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.accent,
  });

  final String id;
  final String name;
  final IconData icon;
  final String description;
  final Color accent;
}
