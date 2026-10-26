/// Career Labs registry — playable profession workplaces.
library;

class CareerLabDef {
  const CareerLabDef({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.role,
    required this.available,
  });

  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final String role;
  final bool available;
}

abstract final class CareerLabRegistry {
  static const List<CareerLabDef> all = <CareerLabDef>[
    CareerLabDef(
      id: 'law_firm',
      title: 'Law — Firm & Courtroom',
      subtitle: 'Enter the firm · interview clients · work the case file',
      emoji: '⚖️',
      role: 'Junior Law Associate',
      available: true,
    ),
    CareerLabDef(
      id: 'nursing_ed',
      title: 'Nursing — Emergency Department',
      subtitle: 'Start your shift · prioritize patients · assess & escalate',
      emoji: '🏥',
      role: 'Student Nurse',
      available: true,
    ),
    CareerLabDef(
      id: 'medicine',
      title: 'Medicine — Diagnostic Ward',
      subtitle: 'Interview patients · order tests · form a diagnosis',
      emoji: '🩺',
      role: 'Medical Student',
      available: true,
    ),
    CareerLabDef(
      id: 'business',
      title: 'Business — Company HQ',
      subtitle: 'Enter the company · find why sales dropped · set strategy',
      emoji: '💼',
      role: 'Junior Business Analyst',
      available: true,
    ),
    CareerLabDef(
      id: 'finance',
      title: 'Finance — Markets Desk',
      subtitle: 'Analyze statements · allocate a portfolio · face a shock',
      emoji: '💰',
      role: 'Junior Financial Analyst',
      available: true,
    ),
    CareerLabDef(
      id: 'accounting',
      title: 'Accounting — Firm Floor',
      subtitle: 'Classify transactions · hunt the discrepancy',
      emoji: '📊',
      role: 'Junior Accountant',
      available: true,
    ),
    CareerLabDef(
      id: 'marketing',
      title: 'Marketing — Agency',
      subtitle: 'Interview the client · build & tune a campaign',
      emoji: '📣',
      role: 'Junior Marketing Strategist',
      available: true,
    ),
    CareerLabDef(
      id: 'economics',
      title: 'Economics — Policy Unit',
      subtitle: 'Run a country dashboard · manage inflation tradeoffs',
      emoji: '📈',
      role: 'Economic Policy Analyst',
      available: true,
    ),
    CareerLabDef(
      id: 'cs_career',
      title: 'CS Career — Engineering Floor',
      subtitle: 'Debug production · ship a feature · survive review',
      emoji: '💻',
      role: 'Junior Software Engineer',
      available: true,
    ),
    CareerLabDef(
      id: 'psychology',
      title: 'Psychology — Behavioral Lab',
      subtitle: 'Interview a participant · design & run an experiment',
      emoji: '🧠',
      role: 'Research Assistant',
      available: true,
    ),
    CareerLabDef(
      id: 'biology',
      title: 'Biology — Science Lab',
      subtitle: 'Microscope · cell diagrams · genetics · ecology · mystery specimen',
      emoji: '🧬',
      role: 'Biology Lab Student',
      available: true,
    ),
    CareerLabDef(
      id: 'chemistry',
      title: 'Chemistry — Science Lab',
      subtitle: 'Bench · titration · molecules · reactions · identify unknown',
      emoji: '⚗️',
      role: 'Chemistry Lab Student',
      available: true,
    ),
    CareerLabDef(
      id: 'physics',
      title: 'Physics — Science Lab',
      subtitle: 'Motion · forces · circuits · waves · optics · launch challenges',
      emoji: '⚛️',
      role: 'Physics Lab Student',
      available: true,
    ),
    CareerLabDef(
      id: 'engineering',
      title: 'Engineering — Design Studio',
      subtitle: 'Design → test → fail → redesign a bridge',
      emoji: '⚙️',
      role: 'Junior Engineer',
      available: true,
    ),
    CareerLabDef(
      id: 'mathematics',
      title: 'Mathematics — Analytics Desk',
      subtitle: 'Model shipping costs · defend your model',
      emoji: '➗',
      role: 'Math Analyst',
      available: true,
    ),
    CareerLabDef(
      id: 'civil_engineering',
      title: 'Civil Engineering — Jobsite',
      subtitle: 'Run the project · respond to a weather delay',
      emoji: '🏗️',
      role: 'Junior Civil Engineer',
      available: true,
    ),
    CareerLabDef(
      id: 'electrical_engineering',
      title: 'Electrical Engineering — EE Lab',
      subtitle: 'Build a circuit · find and fix the fault',
      emoji: '⚡',
      role: 'EE Student',
      available: true,
    ),
    CareerLabDef(
      id: 'medical_lab_science',
      title: 'Medical Lab Science — Core Lab',
      subtitle: 'Receive → prepare → test → report · flag criticals',
      emoji: '🧪',
      role: 'MLS Student',
      available: true,
    ),
    CareerLabDef(
      id: 'pharmacy',
      title: 'Pharmacy — Dispensary',
      subtitle: 'Catch Rx safety issues · counsel the patient',
      emoji: '💊',
      role: 'Pharmacy Student',
      available: true,
    ),
    CareerLabDef(
      id: 'personal_finance',
      title: 'Personal Finance — Budget Boss',
      subtitle: 'Sort needs · spot fees · survive paychecks, cards & a crisis',
      emoji: '💸',
      role: 'Money Rookie',
      available: true,
    ),
    CareerLabDef(
      id: 'cybersecurity',
      title: 'Cybersecurity — SOC',
      subtitle: 'Investigate the alert · classify · contain',
      emoji: '🧑‍💻',
      role: 'Security Analyst',
      available: true,
    ),
  ];

  static CareerLabDef? byId(String id) {
    for (final CareerLabDef d in all) {
      if (d.id == id) return d;
    }
    return null;
  }

  /// Subject laboratories (Learn → Practice).
  static const Set<String> scienceLabIds = <String>{
    'biology',
    'chemistry',
    'physics',
  };

  static List<CareerLabDef> get scienceLabs =>
      all.where((CareerLabDef d) => scienceLabIds.contains(d.id)).toList();

  /// Professional workplaces (Experience).
  static List<CareerLabDef> get simulations =>
      all.where((CareerLabDef d) => !scienceLabIds.contains(d.id)).toList();
}
