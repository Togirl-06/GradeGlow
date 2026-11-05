/// Every practical lab is run as a shift at a (fictional) employer: a role,
/// a supervisor, an inbox, a work queue and a supervisor's review. Completed
/// shifts form a work-experience log the student can put on a CV.
library;

import '../model/career_models.dart';
import 'lab_models.dart';

class Workplace {
  const Workplace({required this.employer, required this.kind, required this.role, required this.supervisor, required this.location});

  /// Fictional organisation name.
  final String employer;
  final String kind;

  /// The student's job title on the shift.
  final String role;
  final LabPerson supervisor;
  final String location;
}

const Map<String, Workplace> _byMajor = <String, Workplace>{
  'computer_science': Workplace(employer: 'Northgate Software Ltd', kind: 'Software company', role: 'Graduate Software Developer', supervisor: LabPerson('Hannah Kowalski', 'Engineering Lead', ''), location: 'Platform team, 3rd floor'),
  'software_engineering': Workplace(employer: 'Bridgeline Digital', kind: 'Software consultancy', role: 'Junior Software Engineer', supervisor: LabPerson('Marcus Bell', 'Delivery Manager', ''), location: 'Client delivery squad'),
  'artificial_intelligence': Workplace(employer: 'Lumen AI Research', kind: 'Applied AI lab', role: 'Machine Learning Intern', supervisor: LabPerson('Dr Mei Lin', 'Research Scientist', ''), location: 'Model evaluation group'),
  'data_science': Workplace(employer: 'Clearview Analytics', kind: 'Data consultancy', role: 'Junior Data Scientist', supervisor: LabPerson('Oluwaseun Adeyemi', 'Analytics Manager', ''), location: 'Insights team'),
  'cybersecurity': Workplace(employer: 'Sentinel SecOps', kind: 'Managed security provider', role: 'SOC Analyst (Tier 1)', supervisor: LabPerson('Rachel Moreno', 'SOC Shift Lead', ''), location: 'Security Operations Centre'),
  'information_technology': Workplace(employer: 'Harbour City Council IT', kind: 'Public-sector IT department', role: 'IT Support Technician', supervisor: LabPerson('Gareth Hughes', 'Service Desk Manager', ''), location: 'Service desk'),
  'web_development': Workplace(employer: 'Pixel & Pine Studio', kind: 'Web agency', role: 'Junior Web Developer', supervisor: LabPerson('Sofia Rossi', 'Lead Developer', ''), location: 'Studio floor'),
  'mobile_app_development': Workplace(employer: 'AppForge Mobile', kind: 'App development company', role: 'Junior Flutter Developer', supervisor: LabPerson('Daniel Okafor', 'Mobile Lead', ''), location: 'Mobile squad'),
  'medicine': Workplace(employer: 'St Aldric’s University Hospital', kind: 'Teaching hospital', role: 'Medical Student on placement', supervisor: LabPerson('Dr Farah Siddiqui', 'Consultant Physician', ''), location: 'Acute Medical Unit'),
  'nursing': Workplace(employer: 'St Aldric’s University Hospital', kind: 'Teaching hospital', role: 'Student Nurse', supervisor: LabPerson('Sister Joy Mensah', 'Ward Manager', ''), location: 'Ward 7, Medical'),
  'introduction_to_law': Workplace(employer: 'Ashford & Lane Solicitors', kind: 'Law firm', role: 'Trainee Solicitor', supervisor: LabPerson('Eleanor Ashford', 'Supervising Partner', ''), location: 'Litigation department'),
  'mechanical_engineering': Workplace(employer: 'Kestrel Engineering', kind: 'Engineering consultancy', role: 'Graduate Mechanical Engineer', supervisor: LabPerson('Ian Fraser CEng', 'Principal Engineer', ''), location: 'Design office'),
  'civil_engineering': Workplace(employer: 'Meridian Civil & Structural', kind: 'Civil engineering firm', role: 'Graduate Civil Engineer', supervisor: LabPerson('Amina Yusuf CEng', 'Project Engineer', ''), location: 'Site office'),
  'electrical_engineering': Workplace(employer: 'Voltaris Systems', kind: 'Electrical engineering company', role: 'Graduate Electrical Engineer', supervisor: LabPerson('Peter Lindqvist', 'Senior Electrical Engineer', ''), location: 'Test laboratory'),
  'chemical_engineering': Workplace(employer: 'Aurora Process Industries', kind: 'Chemical plant', role: 'Graduate Process Engineer', supervisor: LabPerson('Dr Kavita Rao', 'Process Engineering Manager', ''), location: 'Control room'),
  'aerospace_engineering': Workplace(employer: 'Skyward Aerostructures', kind: 'Aerospace manufacturer', role: 'Graduate Aerospace Engineer', supervisor: LabPerson('Colin Marsh', 'Chief of Aerodynamics', ''), location: 'Design and test hangar'),
  'industrial_engineering': Workplace(employer: 'Brightworks Manufacturing', kind: 'Manufacturing plant', role: 'Graduate Industrial Engineer', supervisor: LabPerson('Lucia Fernández', 'Operations Manager', ''), location: 'Production floor'),
  'business_administration': Workplace(employer: 'Greenleaf Retail Group', kind: 'Retail company', role: 'Management Trainee', supervisor: LabPerson('Jonathan Reid', 'Regional Operations Director', ''), location: 'Head office'),
  'accounting': Workplace(employer: 'Carter Whitfield LLP', kind: 'Accountancy firm', role: 'Trainee Accountant', supervisor: LabPerson('Helen Carter ACA', 'Audit Manager', ''), location: 'Accounts and audit team'),
  'finance': Workplace(employer: 'Halcyon Capital Partners', kind: 'Investment firm', role: 'Financial Analyst (Graduate)', supervisor: LabPerson('Victor Mensah CFA', 'Portfolio Manager', ''), location: 'Investment desk'),
  'economics': Workplace(employer: 'Office for Regional Economic Policy', kind: 'Government economics unit', role: 'Assistant Economist', supervisor: LabPerson('Dr Ruth Adler', 'Senior Economist', ''), location: 'Policy analysis unit'),
  'entrepreneurship': Workplace(employer: 'LaunchPad Incubator', kind: 'Startup incubator', role: 'Founder in Residence', supervisor: LabPerson('Nadia Haddad', 'Incubator Director', ''), location: 'Co-working floor'),
  'marketing': Workplace(employer: 'Brightside Marketing Agency', kind: 'Marketing agency', role: 'Marketing Executive', supervisor: LabPerson('Chloe Bennett', 'Account Director', ''), location: 'Campaigns team'),
  'human_resource_management': Workplace(employer: 'Westbrook Logistics', kind: 'Logistics company', role: 'HR Assistant', supervisor: LabPerson('Samuel Osei CIPD', 'HR Business Partner', ''), location: 'People team'),
  'international_business': Workplace(employer: 'Atlas Global Trading', kind: 'Import–export company', role: 'International Business Analyst', supervisor: LabPerson('Yuki Tanaka', 'Head of International Markets', ''), location: 'Global markets office'),
  'mathematics': Workplace(employer: 'Quantis Mathematical Consulting', kind: 'Mathematical consultancy', role: 'Junior Mathematical Analyst', supervisor: LabPerson('Dr Amara Osei', 'Principal Analyst', ''), location: 'Modelling team'),
  'biology': Workplace(employer: 'Verdant Life Sciences', kind: 'Biological research institute', role: 'Research Assistant', supervisor: LabPerson('Dr Isaac Mwangi', 'Group Leader', ''), location: 'Cell and molecular laboratory'),
  'chemistry': Workplace(employer: 'Corvex Analytical Laboratories', kind: 'Analytical chemistry lab', role: 'Laboratory Analyst', supervisor: LabPerson('Dr Elena Petrova', 'Laboratory Manager', ''), location: 'Wet laboratory'),
  'physics': Workplace(employer: 'Helix Instruments', kind: 'Instrumentation R&D company', role: 'Junior Physicist', supervisor: LabPerson('Dr Tom Okonkwo', 'Lead Physicist', ''), location: 'Measurement laboratory'),
  'english': Workplace(employer: 'Inkwell Communications', kind: 'Publishing and communications firm', role: 'Communications Assistant', supervisor: LabPerson('Grace Whitmore', 'Managing Editor', ''), location: 'Editorial office'),
};

Workplace workplaceFor(LabSpec lab) =>
    _byMajor[lab.majorId] ??
    const Workplace(employer: 'GradeGlow Partner Organisation', kind: 'Partner employer', role: 'Graduate Trainee', supervisor: LabPerson('Alex Morgan', 'Supervisor', ''), location: 'Main office');

/// Supervisor's rating for a scenario score.
String performanceRating(int score, bool passed) {
  if (passed && score >= 90) return 'Exceeds expectations';
  if (passed) return 'Meets expectations';
  if (score >= 50) return 'Approaching expectations';
  return 'Below expectations';
}

/// A short written review from the supervisor, built from the actual results.
String supervisorReview(LabSpec lab, LabScenario sc, Map<String, TaskResult> results, int score, bool passed) {
  final Workplace w = workplaceFor(lab);
  final List<LabStep> good = sc.steps.where((LabStep s) => results[s.id]?.passed ?? false).toList();
  final List<LabStep> bad = sc.steps.where((LabStep s) => !(results[s.id]?.passed ?? false)).toList();
  final StringBuffer b = StringBuffer();
  if (passed) {
    b.write('You completed "${sc.title}" to the standard we expect of a ${w.role.toLowerCase()}. ');
    b.write(score >= 90 ? 'This is work I would send to a client without changes. ' : 'Good work — review the notes below before your next shift. ');
  } else {
    b.write('This assignment is not ready to sign off. ');
    if (bad.isNotEmpty) b.write('Rework ${bad.map((LabStep s) => '"${s.title}"').join(', ')} before it can go out. ');
  }
  if (good.isNotEmpty && !passed) b.write('${good.length} of ${sc.steps.length} tasks met the standard. ');
  final bool safety = results.values.any((TaskResult r) => r.feedback.any((String f) => f.toLowerCase().contains('unsafe') || f.toLowerCase().contains('critical')));
  if (safety) b.write('Note: a critical or safety issue was recorded — in practice this would be escalated. ');
  b.write('— ${w.supervisor.name}, ${w.supervisor.role}');
  return b.toString();
}

/// Hours of work experience credited for a completed shift.
double shiftHours(LabSpec lab) => ((lab.minutes / 60) * 2).ceil() / 2;
