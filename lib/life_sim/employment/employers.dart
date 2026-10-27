/// Companies that hire in GradeGlow Life. `buildingId` links to the city map.
library;

class InterviewerPersona {
  const InterviewerPersona({
    required this.name,
    required this.title,
    required this.style,
    required this.skinTone,
    required this.hairColor,
    required this.outfitColor,
    this.hairStyle = 'short',
  });

  final String name;
  final String title;

  /// `warm`, `direct` or `technical` — changes the interviewer's reactions.
  final String style;
  final int skinTone;
  final int hairColor;
  final int outfitColor;
  final String hairStyle;
}

class Employer {
  const Employer({
    required this.id,
    required this.name,
    required this.buildingId,
    required this.hires,
    required this.prestige,
    required this.hiringBar,
    required this.culture,
    required this.blurb,
    required this.values,
    required this.interviewer,
    this.startHour = 9,
    this.endHour = 17,
    this.accent = 0xFF3B82F6,
  });

  final String id;
  final String name;
  final String buildingId;

  /// Career ids this employer recruits for.
  final List<String> hires;

  /// Pay multiplier (0.9 .. 1.15).
  final double prestige;

  /// Extra score needed to be hired (0 easy … 12 very selective).
  final double hiringBar;
  final String culture;
  final String blurb;

  /// Words that describe what the company cares about (for "why us" answers).
  final List<String> values;
  final InterviewerPersona interviewer;
  final int startHour;
  final int endHour;
  final int accent;

  int get shiftHours => endHour - startHour;
}

class EmployerCatalog {
  const EmployerCatalog._();

  static const List<Employer> all = <Employer>[
    Employer(
      id: 'pixelforge',
      name: 'Pixelforge Studios',
      buildingId: 'pixelforge',
      hires: <String>['software_engineer'],
      prestige: 0.95,
      hiringBar: 0,
      culture: 'Casual start-up. Ship fast, learn faster.',
      blurb: 'A scrappy game and app studio with a friendly team of 40.',
      values: <String>['creativity', 'learning', 'ownership', 'players', 'speed', 'curious'],
      interviewer: InterviewerPersona(
        name: 'Dev Patel',
        title: 'Engineering Lead',
        style: 'technical',
        skinTone: 0xFFC68642,
        hairColor: 0xFF1B1B1B,
        outfitColor: 0xFF3B82F6,
      ),
      startHour: 10,
      endHour: 18,
      accent: 0xFF8B5CF6,
    ),
    Employer(
      id: 'nimbus',
      name: 'Nimbus Cloud Systems',
      buildingId: 'nimbus_cloud',
      hires: <String>['software_engineer'],
      prestige: 1.1,
      hiringBar: 8,
      culture: 'Large cloud company. High standards, strong process.',
      blurb: 'Runs infrastructure for thousands of businesses. Reliability is religion.',
      values: <String>['reliability', 'scale', 'customers', 'quality', 'security', 'process'],
      interviewer: InterviewerPersona(
        name: 'Claire Okonkwo',
        title: 'Senior Engineering Manager',
        style: 'direct',
        skinTone: 0xFF8D5524,
        hairColor: 0xFF1B1B1B,
        outfitColor: 0xFF111827,
        hairStyle: 'braids',
      ),
      accent: 0xFF0EA5E9,
    ),
    Employer(
      id: 'st_gabriel',
      name: "St. Gabriel General Hospital",
      buildingId: 'st_gabriel',
      hires: <String>['nurse', 'doctor'],
      prestige: 1.05,
      hiringBar: 6,
      culture: 'Busy teaching hospital. Patients first, always.',
      blurb: 'The city\'s main hospital: emergency, wards, theatres and labs.',
      values: <String>['patients', 'safety', 'compassion', 'teamwork', 'excellence', 'learning'],
      interviewer: InterviewerPersona(
        name: 'Matron Adaeze Bello',
        title: 'Director of Clinical Services',
        style: 'warm',
        skinTone: 0xFF5A3825,
        hairColor: 0xFF1B1B1B,
        outfitColor: 0xFF10B981,
        hairStyle: 'bun',
      ),
      startHour: 7,
      endHour: 15,
      accent: 0xFFEF4444,
    ),
    Employer(
      id: 'riverside',
      name: 'Riverside Community Clinic',
      buildingId: 'riverside_clinic',
      hires: <String>['nurse', 'doctor'],
      prestige: 0.95,
      hiringBar: 1,
      culture: 'Small neighbourhood clinic. Know every patient by name.',
      blurb: 'Primary care for families on the east side of the river.',
      values: <String>['community', 'families', 'prevention', 'listening', 'care', 'trust'],
      interviewer: InterviewerPersona(
        name: 'Dr. Tom Whitfield',
        title: 'Clinic Director',
        style: 'warm',
        skinTone: 0xFFF1C27D,
        hairColor: 0xFF9E9E9E,
        outfitColor: 0xFF3B82F6,
      ),
      startHour: 8,
      endHour: 16,
      accent: 0xFF14B8A6,
    ),
    Employer(
      id: 'whitmore',
      name: 'Whitmore & Lane LLP',
      buildingId: 'whitmore_lane',
      hires: <String>['lawyer'],
      prestige: 1.15,
      hiringBar: 9,
      culture: 'Prestigious commercial firm. Long hours, big cases.',
      blurb: 'Corporate litigation and contracts for the city\'s largest companies.',
      values: <String>['precision', 'excellence', 'clients', 'advocacy', 'integrity', 'results'],
      interviewer: InterviewerPersona(
        name: 'Margaret Lane',
        title: 'Senior Partner',
        style: 'direct',
        skinTone: 0xFFFFDFC4,
        hairColor: 0xFF9E9E9E,
        outfitColor: 0xFF111827,
        hairStyle: 'bun',
      ),
      accent: 0xFF6366F1,
    ),
    Employer(
      id: 'civic_legal',
      name: 'Civic Legal Aid Office',
      buildingId: 'civic_legal',
      hires: <String>['lawyer'],
      prestige: 0.9,
      hiringBar: 1,
      culture: 'Public-interest practice. Heavy caseload, real impact.',
      blurb: 'Free legal help for tenants, workers and families.',
      values: <String>['justice', 'access', 'clients', 'community', 'advocacy', 'fairness'],
      interviewer: InterviewerPersona(
        name: 'Samuel Adeyemi',
        title: 'Supervising Attorney',
        style: 'warm',
        skinTone: 0xFF8D5524,
        hairColor: 0xFF1B1B1B,
        outfitColor: 0xFF8B5CF6,
      ),
      accent: 0xFFF59E0B,
    ),
    Employer(
      id: 'ledger_co',
      name: 'Ledger & Co',
      buildingId: 'ledger_co',
      hires: <String>['accountant'],
      prestige: 1.0,
      hiringBar: 2,
      culture: 'Friendly mid-size firm serving local businesses.',
      blurb: 'Bookkeeping, tax and payroll for shops, restaurants and start-ups.',
      values: <String>['accuracy', 'clients', 'deadlines', 'trust', 'clarity', 'detail'],
      interviewer: InterviewerPersona(
        name: 'Priya Raman',
        title: 'Finance Manager',
        style: 'warm',
        skinTone: 0xFFC68642,
        hairColor: 0xFF1B1B1B,
        outfitColor: 0xFFEC4899,
        hairStyle: 'long',
      ),
      accent: 0xFF22C55E,
    ),
    Employer(
      id: 'ironclad',
      name: 'Ironclad Audit Partners',
      buildingId: 'ironclad_audit',
      hires: <String>['accountant'],
      prestige: 1.1,
      hiringBar: 7,
      culture: 'Audit specialists. Process-driven and exacting.',
      blurb: 'Independent audits for banks and listed companies.',
      values: <String>['integrity', 'compliance', 'rigour', 'controls', 'independence', 'accuracy'],
      interviewer: InterviewerPersona(
        name: 'Henrik Olsen',
        title: 'Audit Partner',
        style: 'direct',
        skinTone: 0xFFFFDFC4,
        hairColor: 0xFFB7872F,
        outfitColor: 0xFF263238,
      ),
      accent: 0xFF64748B,
    ),
    Employer(
      id: 'meridian',
      name: 'Meridian Group',
      buildingId: 'meridian_group',
      hires: <String>['business_manager'],
      prestige: 1.1,
      hiringBar: 6,
      culture: 'Corporate headquarters. Ambitious, data-driven, fast promotion.',
      blurb: 'A diversified company with logistics, retail and energy divisions.',
      values: <String>['growth', 'leadership', 'results', 'data', 'strategy', 'ownership'],
      interviewer: InterviewerPersona(
        name: 'Victor Hale',
        title: 'VP of Operations',
        style: 'direct',
        skinTone: 0xFFE0AC69,
        hairColor: 0xFF2C1810,
        outfitColor: 0xFF111827,
      ),
      accent: 0xFFF97316,
    ),
    Employer(
      id: 'harbor_retail',
      name: 'Harbor Retail Group',
      buildingId: 'harbor_retail',
      hires: <String>['business_manager'],
      prestige: 0.95,
      hiringBar: 1,
      culture: 'Customer-obsessed retail chain. Hands-on managers.',
      blurb: 'Forty shops across the coast; managers run real stores.',
      values: <String>['customers', 'service', 'teamwork', 'sales', 'people', 'community'],
      interviewer: InterviewerPersona(
        name: 'Lola Mensah',
        title: 'Regional Manager',
        style: 'warm',
        skinTone: 0xFF5A3825,
        hairColor: 0xFF1B1B1B,
        outfitColor: 0xFFF97316,
        hairStyle: 'afro',
      ),
      startHour: 9,
      endHour: 17,
      accent: 0xFF06B6D4,
    ),
  ];

  static Employer? byId(String id) {
    for (final Employer e in all) {
      if (e.id == id) return e;
    }
    return null;
  }

  static Employer require(String id) {
    final Employer? e = byId(id);
    if (e == null) throw ArgumentError('Unknown employer: $id');
    return e;
  }

  static Employer? byBuilding(String buildingId) {
    for (final Employer e in all) {
      if (e.buildingId == buildingId) return e;
    }
    return null;
  }

  static List<Employer> hiringFor(String careerId) =>
      all.where((Employer e) => e.hires.contains(careerId)).toList();
}
