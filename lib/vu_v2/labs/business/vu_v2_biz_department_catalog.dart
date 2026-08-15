import 'package:flutter/material.dart';

enum VuV2BizRoomId {
  dashboard,
  marketing,
  finance,
  hr,
  operations,
  strategy,
  negotiation,
  board,
  startup,
  crisis,
  analytics,
  expansion,
  achievements,
  lessons,
  multiplayer,
}

class VuV2BizDepartment {
  const VuV2BizDepartment({
    required this.id,
    required this.title,
    required this.blurb,
    required this.icon,
    required this.accent,
    this.navLabel,
  });

  final VuV2BizRoomId id;
  final String title;
  final String blurb;
  final IconData icon;
  final Color accent;
  final String? navLabel;

  String get label => navLabel ?? title;
}

abstract final class VuV2BizDepartmentCatalog {
  static const List<VuV2BizDepartment> all = <VuV2BizDepartment>[
    VuV2BizDepartment(
      id: VuV2BizRoomId.dashboard,
      title: 'Dashboard',
      blurb: 'Executive command center and live company KPIs.',
      icon: Icons.dashboard_customize_outlined,
      accent: Color(0xFF3B82F6),
    ),
    VuV2BizDepartment(
      id: VuV2BizRoomId.marketing,
      title: 'Marketing',
      blurb: 'Design campaigns, pick channels, and launch.',
      icon: Icons.campaign_outlined,
      accent: Color(0xFF8B5CF6),
    ),
    VuV2BizDepartment(
      id: VuV2BizRoomId.finance,
      title: 'Finance',
      blurb: 'Cash, payroll, loans, and unexpected costs.',
      icon: Icons.account_balance_outlined,
      accent: Color(0xFF10B981),
    ),
    VuV2BizDepartment(
      id: VuV2BizRoomId.hr,
      title: 'Human Resources',
      blurb: 'Hire, mediate conflicts, and lift morale.',
      icon: Icons.groups_outlined,
      accent: Color(0xFFEC4899),
      navLabel: 'HR',
    ),
    VuV2BizDepartment(
      id: VuV2BizRoomId.operations,
      title: 'Operations',
      blurb: 'Inventory, suppliers, and production shocks.',
      icon: Icons.precision_manufacturing_outlined,
      accent: Color(0xFF0EA5E9),
    ),
    VuV2BizDepartment(
      id: VuV2BizRoomId.strategy,
      title: 'Strategy Room',
      blurb: 'SWOT, PESTLE, and market-entry decisions.',
      icon: Icons.hub_outlined,
      accent: Color(0xFF6366F1),
      navLabel: 'Strategy',
    ),
    VuV2BizDepartment(
      id: VuV2BizRoomId.negotiation,
      title: 'Negotiation',
      blurb: 'Face investors, suppliers, and partners.',
      icon: Icons.handshake_outlined,
      accent: Color(0xFFF59E0B),
    ),
    VuV2BizDepartment(
      id: VuV2BizRoomId.board,
      title: 'Board Room',
      blurb: 'Present quarterly results to the board.',
      icon: Icons.meeting_room_outlined,
      accent: Color(0xFF14B8A6),
      navLabel: 'Board',
    ),
    VuV2BizDepartment(
      id: VuV2BizRoomId.startup,
      title: 'Startup Builder',
      blurb: 'Build a company from idea to launch.',
      icon: Icons.rocket_launch_outlined,
      accent: Color(0xFFF97316),
      navLabel: 'Startup',
    ),
    VuV2BizDepartment(
      id: VuV2BizRoomId.crisis,
      title: 'Crisis Center',
      blurb: 'Respond under time pressure.',
      icon: Icons.warning_amber_rounded,
      accent: Color(0xFFEF4444),
      navLabel: 'Crisis',
    ),
    VuV2BizDepartment(
      id: VuV2BizRoomId.analytics,
      title: 'Analytics',
      blurb: 'Investigate revenue dips and trends.',
      icon: Icons.analytics_outlined,
      accent: Color(0xFF22D3EE),
    ),
    VuV2BizDepartment(
      id: VuV2BizRoomId.expansion,
      title: 'Global Expansion',
      blurb: 'Open markets and track competitors.',
      icon: Icons.public,
      accent: Color(0xFF34D399),
      navLabel: 'Expansion',
    ),
    VuV2BizDepartment(
      id: VuV2BizRoomId.achievements,
      title: 'Achievements',
      blurb: 'CEO level, awards, and reputation.',
      icon: Icons.emoji_events_outlined,
      accent: Color(0xFFFBBF24),
    ),
    VuV2BizDepartment(
      id: VuV2BizRoomId.lessons,
      title: 'Lessons',
      blurb: 'Executive briefings linked to Business School.',
      icon: Icons.school_outlined,
      accent: Color(0xFFA78BFA),
    ),
    VuV2BizDepartment(
      id: VuV2BizRoomId.multiplayer,
      title: 'Multiplayer',
      blurb: 'Compete and partner with classmates (Premium).',
      icon: Icons.sports_esports_outlined,
      accent: Color(0xFFFB7185),
    ),
  ];

  static VuV2BizDepartment byId(VuV2BizRoomId id) {
    for (int i = 0; i < all.length; i++) {
      if (all[i].id == id) {
        return all[i];
      }
    }
    return all.first;
  }

  static VuV2BizRoomId? roomFromExperimentId(String experimentId) {
    if (experimentId == 'biz_marketing') {
      return VuV2BizRoomId.marketing;
    }
    if (experimentId == 'biz_finance') {
      return VuV2BizRoomId.finance;
    }
    if (experimentId == 'biz_company' || experimentId == 'biz_sim_center') {
      return VuV2BizRoomId.dashboard;
    }
    if (experimentId.contains('hr')) {
      return VuV2BizRoomId.hr;
    }
    if (experimentId.contains('ops') || experimentId.contains('operation')) {
      return VuV2BizRoomId.operations;
    }
    return VuV2BizRoomId.dashboard;
  }
}
