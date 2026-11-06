// Real resume files (made by Word-style DOCX, LibreOffice, Chromium, ReportLab
// and qpdf; see tool/resume_fixtures/make.py) are read, parsed and scored.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ai_study_buddy/career_sim/content/catalog.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/model/content_models.dart';
import 'package:ai_study_buddy/career_sim/resume/resume_analysis.dart';
import 'package:ai_study_buddy/career_sim/resume/resume_parser.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List fixture(String name) => File('test/fixtures/resumes/$name').readAsBytesSync();

final Map<String, dynamic> expected = jsonDecode(File('test/fixtures/resumes/expected.json').readAsStringSync()) as Map<String, dynamic>;

const Map<String, String> files = <String, String>{
  'jordan_rivera_cs.docx': 'cs',
  'jordan_rivera_cs_libreoffice.pdf': 'cs',
  'amara_okafor_nursing.docx': 'nursing',
  'amara_okafor_nursing_chrome.pdf': 'nursing',
  'amara_okafor_nursing_objstm.pdf': 'nursing',
  'daniel_chen_business.docx': 'business',
  'daniel_chen_business_reportlab.pdf': 'business',
  'sofia_martinez_law.docx': 'law',
  'sofia_martinez_law.pdf': 'law',
  'ethan_brooks_engineering.docx': 'engineering',
  'ethan_brooks_engineering.pdf': 'engineering',
  'priya_shah_medicine.docx': 'medicine',
  'grace_kim_biology.docx': 'science',
  'noah_williams_maths.docx': 'maths',
  'olivia_turner_english.docx': 'communication',
};

void main() {
  for (final MapEntry<String, String> f in files.entries) {
    test('reads ${f.key}', () {
      final Map<String, dynamic> e = expected[f.value] as Map<String, dynamic>;
      final String text = extractResumeText(f.key, fixture(f.key));
      expect(text, contains(e['name']), reason: text);
      expect(text, contains(e['email']));
      final ParsedResume r = parseResume(text);
      expect(r.name, e['name'], reason: text);
      expect(r.email, e['email']);
      expect(r.phone.replaceAll(RegExp(r'\D'), ''), (e['phone'] as String).replaceAll(RegExp(r'\D'), ''));
      expect(r.education, isNotEmpty, reason: 'education from:\n$text');
      expect(r.skills.length, greaterThanOrEqualTo(5), reason: 'skills: ${r.skills}');
      expect(r.experience.isNotEmpty || r.projects.isNotEmpty, isTrue, reason: text);
      // Nothing is invented: every skill appears in the file's text.
      for (final String s in r.skills) {
        expect(text.toLowerCase(), contains(s.toLowerCase()), reason: s);
      }
      final ResumeQuality q = resumeQuality(r);
      expect(q.score, inInclusiveRange(55, 100), reason: q.weaknesses.join(', '));
    });
  }

  test('experience bullets stay with their role', () {
    final ParsedResume r = parseResume(extractResumeText('x.docx', fixture('jordan_rivera_cs.docx')));
    expect(r.experience.length, 2, reason: r.experience.join('\n'));
    expect(r.experience.first, startsWith('Software Developer Intern'));
    expect(r.experience.first, contains('reduced crash rate by 30%'));
    expect(r.certifications.single, contains('Google Associate Android Developer'));
    expect(r.achievements.length, 2);
    expect(r.projects.length, 2);
  });

  test('bad files are refused with a clear message', () {
    expect(() => extractResumeText('cv.pdf', Uint8List.fromList(utf8.encode('hello'))), throwsA(isA<FormatException>()));
    expect(() => extractResumeText('cv.doc', Uint8List.fromList(<int>[0xd0, 0xcf, 0x11, 0xe0, 1, 2, 3])), throwsA(isA<FormatException>()));
    expect(() => extractResumeText('scan.pdf', Uint8List.fromList(utf8.encode('%PDF-1.4\n1 0 obj << /Type /Catalog >> endobj'))), throwsA(isA<FormatException>()));
  });

  test('a weak resume gets specific suggestions', () {
    const ParsedResume weak = ParsedResume(name: 'Sam Lee', skills: <String>['Excel']);
    final ResumeQuality q = resumeQuality(weak);
    expect(q.score, lessThan(40));
    expect(q.suggestions.join(' '), contains('Education'));
    expect(q.suggestions.join(' '), contains('numbers'));
  });

  test('job compatibility explains matches and gaps', () {
    final ParsedResume cs = parseResume(extractResumeText('x.docx', fixture('jordan_rivera_cs.docx')));
    final JobPosting flutter = CareerCatalog.posting('mk_flutter_dev')!;
    final JobPosting acct = CareerCatalog.posting('mk_jr_accountant')!;
    final JobMatch good = jobMatch(cs, flutter, thisYear: 2026);
    final JobMatch bad = jobMatch(cs, acct, thisYear: 2026);
    expect(good.score, greaterThanOrEqualTo(75), reason: good.reasons.join('\n'));
    expect(good.matched, containsAll(<String>['Flutter', 'Dart', 'Firebase', 'Git']));
    expect(good.educationOk, isTrue);
    expect(bad.score, lessThan(good.score - 25));
    expect(bad.missing, contains('Reconciliation'));
    expect(bad.reasons.first, contains('Required skills'));
    // Interns and entry roles never penalise a student for having no paid experience.
    const ParsedResume student = ParsedResume(name: 'Al Ng', education: <String>['B.S. Computer Science, 2024 – 2028'], projects: <String>['Chess engine in Python']);
    final JobMatch intern = jobMatch(student, CareerCatalog.posting('mk_swe_intern')!);
    expect(intern.experienceNote, contains('projects count'));
  });

  test('every marketplace role is complete and paid in USD', () {
    final List<JobPosting> market = CareerCatalog.postings.where((JobPosting j) => j.id.startsWith('mk_')).toList();
    expect(market.length, greaterThanOrEqualTo(60));
    final Set<String> levels = <String>{for (final JobPosting j in market) j.levelLabel};
    expect(levels, containsAll(<String>['Internship', 'Entry-level', 'Junior', 'Mid-level', 'Senior', 'Management']));
    for (final JobPosting j in market) {
      expect(j.keywords, isNotEmpty, reason: j.id);
      expect(j.responsibilities.length, greaterThanOrEqualTo(2), reason: j.id);
      expect(j.salaryMin, greaterThan(0), reason: j.id);
      expect(j.hoursPerWeek, greaterThan(0));
      expect(j.positions, greaterThan(0));
      expect(j.requiredEducation, isNotEmpty, reason: j.id);
      final WorkplaceDef? w = CareerCatalog.workplace(j.workplaceId);
      expect(w, isNotNull, reason: j.id);
      expect(w!.assignments.length, greaterThanOrEqualTo(8), reason: '${j.id}: real workstation tasks');
      expect(CareerCatalog.interviewPlan(j.interviewPlanId), isNotNull);
      expect(j.roleQuestions, isNotEmpty, reason: j.id);
      if (j.deptId == 'nursing' || j.deptId == 'medicine') {
        if (j.title.contains('Nurs') || j.title.contains('Medical Graduate')) expect(j.simulationNote, contains('does not grant'), reason: j.id);
      }
    }
    for (final String title in <String>[
      'Junior Software Developer', 'Frontend Developer', 'Backend Developer', 'Junior Flutter Developer', 'AI/ML Intern', 'Data Analyst',
      'Cybersecurity Analyst', 'IT Support Specialist', 'Junior Data Scientist', 'Software Engineering Intern',
      'Nursing Assistant Trainee', 'Clinical Research Assistant', 'Medical Laboratory Assistant', 'Healthcare Administration Assistant',
      'Public Health Research Assistant', 'Nursing Graduate Trainee', 'Legal Research Assistant', 'Paralegal Trainee', 'Junior Legal Associate',
      'Corporate Legal Assistant', 'Compliance Analyst', 'Legal Intern', 'Junior Mechanical Engineer', 'Civil Engineering Intern',
      'Electrical Engineering Technician', 'Chemical Engineering Trainee', 'Aerospace Engineering Intern', 'Industrial Engineering Analyst',
      'Business Analyst', 'Junior Accountant', 'Financial Analyst', 'Marketing Associate', 'Human Resources Assistant', 'Investment Research Analyst',
      'Operations Associate', 'Business Development Associate', 'Economics Research Assistant', 'Mathematics Research Assistant',
      'Laboratory Research Assistant', 'Junior Data Analyst', 'Physics Research Intern', 'Chemistry Laboratory Assistant', 'Biology Research Assistant',
      'Content Writer', 'Technical Writer', 'Communications Assistant', 'Copywriter', 'Editorial Assistant', 'Public Relations Associate',
    ]) {
      expect(market.any((JobPosting j) => j.title == title), isTrue, reason: title);
    }
  });
}
