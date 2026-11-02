/// The player's resume and the career assistant that reviews it.
library;

import '../avatar/avatar_profile.dart';
import '../careers/career_catalog.dart';
import '../education/skills.dart';
import 'employers.dart';
import 'job_listing.dart';
import 'qualifications.dart';

class EducationEntry {
  const EducationEntry({required this.degree, required this.school, required this.level});
  final String degree;
  final String school;
  final String level;

  Map<String, Object?> toJson() =>
      <String, Object?>{'degree': degree, 'school': school, 'level': level};

  factory EducationEntry.fromJson(Map<String, Object?> j) => EducationEntry(
        degree: j['degree'] as String? ?? '',
        school: j['school'] as String? ?? '',
        level: j['level'] as String? ?? '',
      );
}

class ExperienceEntry {
  const ExperienceEntry({
    required this.role,
    required this.employer,
    required this.workdays,
    this.bullets = const <String>[],
  });
  final String role;
  final String employer;
  final int workdays;
  final List<String> bullets;

  Map<String, Object?> toJson() => <String, Object?>{
        'role': role,
        'employer': employer,
        'workdays': workdays,
        'bullets': bullets,
      };

  factory ExperienceEntry.fromJson(Map<String, Object?> j) => ExperienceEntry(
        role: j['role'] as String? ?? '',
        employer: j['employer'] as String? ?? '',
        workdays: (j['workdays'] as num?)?.toInt() ?? 0,
        bullets: (j['bullets'] is List)
            ? (j['bullets'] as List).map((Object? e) => e.toString()).toList()
            : <String>[],
      );
}

class ProjectEntry {
  const ProjectEntry({required this.title, required this.description});
  final String title;
  final String description;

  Map<String, Object?> toJson() => <String, Object?>{'title': title, 'description': description};

  factory ProjectEntry.fromJson(Map<String, Object?> j) => ProjectEntry(
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
      );
}

class Resume {
  Resume({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.city = 'Glow City',
    this.summary = '',
    List<EducationEntry>? education,
    List<String>? skills,
    List<ExperienceEntry>? experience,
    List<ProjectEntry>? projects,
    List<String>? certifications,
  })  : education = education ?? <EducationEntry>[],
        skills = skills ?? <String>[],
        experience = experience ?? <ExperienceEntry>[],
        projects = projects ?? <ProjectEntry>[],
        certifications = certifications ?? <String>[];

  String fullName;
  String email;
  String phone;
  String city;
  String summary;
  List<EducationEntry> education;
  List<String> skills;
  List<ExperienceEntry> experience;
  List<ProjectEntry> projects;
  List<String> certifications;

  /// Fills the factual sections from the player's real in-game record while
  /// preserving anything the player wrote themselves.
  void syncFacts({
    required AvatarProfile avatar,
    required PlayerQualifications q,
    required List<EducationEntry> degrees,
    required List<ExperienceEntry> jobs,
  }) {
    if (fullName.trim().isEmpty) fullName = avatar.name;
    if (email.trim().isEmpty) {
      final String slug = avatar.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '.');
      email = '${slug.isEmpty ? 'student' : slug}@glowmail.app';
    }
    final List<EducationEntry> edu = <EducationEntry>[
      EducationEntry(
        degree: 'High school diploma',
        school: 'Glow City High',
        level: 'high_school',
      ),
      ...degrees,
    ];
    education = edu;
    experience = jobs;
    certifications = q.certifications
        .map((String id) => CertificationCatalog.byId(id)?.name ?? id)
        .toList()
      ..sort();
    // Auto-list skills the player has actually trained (>= 10), keeping manual ones.
    for (final SkillDef s in Skills.all) {
      if (q.skills.level(s.id) >= 10 && !skills.contains(s.name)) skills.add(s.name);
    }
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'city': city,
        'summary': summary,
        'education': education.map((EducationEntry e) => e.toJson()).toList(),
        'skills': skills,
        'experience': experience.map((ExperienceEntry e) => e.toJson()).toList(),
        'projects': projects.map((ProjectEntry e) => e.toJson()).toList(),
        'certifications': certifications,
      };

  factory Resume.fromJson(Map<String, Object?> j) {
    List<T> list<T>(Object? v, T Function(Map<String, Object?>) f) => v is List
        ? v.whereType<Map>().map((Map m) => f(Map<String, Object?>.from(m))).toList()
        : <T>[];
    List<String> strings(Object? v) =>
        v is List ? v.map((Object? e) => e.toString()).toList() : <String>[];
    return Resume(
      fullName: j['fullName'] as String? ?? '',
      email: j['email'] as String? ?? '',
      phone: j['phone'] as String? ?? '',
      city: j['city'] as String? ?? 'Glow City',
      summary: j['summary'] as String? ?? '',
      education: list(j['education'], EducationEntry.fromJson),
      skills: strings(j['skills']),
      experience: list(j['experience'], ExperienceEntry.fromJson),
      projects: list(j['projects'], ProjectEntry.fromJson),
      certifications: strings(j['certifications']),
    );
  }
}

class ResumeReview {
  const ResumeReview({
    required this.score,
    required this.sections,
    required this.strengths,
    required this.improvements,
    required this.expectations,
  });

  /// 0..100
  final double score;

  /// Section name → 0..1 completeness.
  final Map<String, double> sections;
  final List<String> strengths;
  final List<String> improvements;

  /// What employers in this field expect (explained by the career assistant).
  final List<String> expectations;

  String get grade {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Strong';
    if (score >= 50) return 'Fair';
    return 'Needs work';
  }
}

/// Offline "AI career assistant": deterministic resume review with advice.
class ResumeCoach {
  const ResumeCoach._();

  static int wordCount(String s) =>
      s.trim().isEmpty ? 0 : s.trim().split(RegExp(r'\s+')).length;

  static bool _hasNumber(String s) => RegExp(r'\d').hasMatch(s);

  static ResumeReview review(Resume r, {JobListing? target, String? careerId}) {
    final String cid = target?.careerId ?? careerId ?? '';
    final CareerDef? career = cid.isEmpty ? null : CareerCatalog.byId(cid);
    final Employer? employer = target?.employer;
    final List<String> strengths = <String>[];
    final List<String> fixes = <String>[];
    final Map<String, double> sec = <String, double>{};

    // Contact (10)
    int contact = 0;
    if (r.fullName.trim().isNotEmpty) contact++;
    if (RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(r.email.trim())) contact++;
    if (r.phone.replaceAll(RegExp(r'\D'), '').length >= 7) contact++;
    if (r.city.trim().isNotEmpty) contact++;
    sec['Contact'] = contact / 4;
    if (contact < 4) fixes.add('Complete your contact details (name, email, phone, city).');

    // Summary (15): length, domain words, tailoring.
    final String summaryLower = r.summary.toLowerCase();
    final int sw = wordCount(r.summary);
    double summary = 0;
    if (sw == 0) {
      fixes.add('Write a professional summary (30–70 words) about who you are and what you offer.');
    } else {
      if (sw >= 25 && sw <= 80) {
        summary += 0.45;
        strengths.add('Your summary is a good length.');
      } else if (sw < 25) {
        summary += 0.2;
        fixes.add('Your summary is too short — aim for 30–70 words.');
      } else {
        summary += 0.25;
        fixes.add('Your summary is too long — recruiters skim. Trim it to under 80 words.');
      }
      if (career != null) {
        final int hits = career.interviewKeywords.where(summaryLower.contains).length;
        if (hits >= 2) {
          summary += 0.3;
        } else {
          summary += hits * 0.12;
          fixes.add('Use more ${career.title.toLowerCase()} language in your summary '
              '(for example: ${career.interviewKeywords.take(3).join(', ')}).');
        }
      } else {
        summary += 0.2;
      }
      if (employer != null) {
        final int vh = employer.values.where(summaryLower.contains).length;
        if (vh >= 1) {
          summary += 0.25;
          strengths.add('You tailored your summary to ${employer.name}.');
        } else {
          fixes.add('Tailor it to ${employer.name}: they value ${employer.values.take(3).join(', ')}.');
        }
      } else {
        summary += 0.15;
      }
    }
    sec['Summary'] = summary.clamp(0, 1).toDouble();

    // Education (15)
    double edu = 0;
    if (r.education.isNotEmpty) edu += 0.5;
    if (career != null &&
        r.education.any((EducationEntry e) => e.degree.toLowerCase().contains(
              career.title.split(' ').first.toLowerCase(),
            ) ||
            e.level == _levelFor(career))) {
      edu += 0.5;
    } else if (r.education.length >= 2) {
      edu += 0.3;
    }
    sec['Education'] = edu.clamp(0, 1).toDouble();
    if (r.education.length < 2 && career != null) {
      fixes.add('Earn the ${career.title} degree at the University to strengthen your education section.');
    }

    // Skills (15)
    double skills = 0;
    if (r.skills.length >= 4) {
      skills += 0.5;
    } else if (r.skills.isNotEmpty) {
      skills += 0.25;
      fixes.add('List at least four relevant skills.');
    } else {
      fixes.add('Add a skills section — train skills at work or in the library to unlock them.');
    }
    if (career != null) {
      final String core = Skills.nameOf(career.coreSkill).toLowerCase();
      if (r.skills.any((String s) => s.toLowerCase() == core)) {
        skills += 0.3;
        strengths.add('You list your core skill (${Skills.nameOf(career.coreSkill)}).');
      } else {
        fixes.add('List ${Skills.nameOf(career.coreSkill)} — it is the first thing recruiters scan for.');
      }
      if (r.skills.any((String s) => s.toLowerCase() == 'communication')) skills += 0.2;
    } else {
      skills += 0.3;
    }
    sec['Skills'] = skills.clamp(0, 1).toDouble();

    // Experience (20)
    double exp = 0;
    if (r.experience.isNotEmpty) {
      exp += 0.5;
      if (career != null && r.experience.any((ExperienceEntry e) => e.role.isNotEmpty)) exp += 0.2;
      if (r.experience.any((ExperienceEntry e) => e.bullets.any(_hasNumber))) {
        exp += 0.3;
        strengths.add('You quantify your results — recruiters love numbers.');
      } else {
        fixes.add('Add measurable results to your experience (e.g. "closed 12 tickets in a week").');
      }
    } else {
      fixes.add('No work experience yet — start with an internship or add a project.');
    }
    sec['Experience'] = exp.clamp(0, 1).toDouble();

    // Projects (15)
    double proj = 0;
    final List<ProjectEntry> good =
        r.projects.where((ProjectEntry p) => wordCount(p.description) >= 12).toList();
    if (good.isNotEmpty) proj += 0.55;
    if (good.length >= 2) proj += 0.25;
    if (good.any((ProjectEntry p) => _hasNumber(p.description))) proj += 0.2;
    sec['Projects'] = proj.clamp(0, 1).toDouble();
    if (good.isEmpty) {
      fixes.add('Add a project with a 1–2 sentence description (what you built, how, and the outcome).');
    } else if (good.length == 1) {
      fixes.add('A second project would show range.');
    } else {
      strengths.add('Your projects show range.');
    }

    // Certifications (10)
    double cert = 0;
    if (r.certifications.isNotEmpty) cert += 0.5;
    if (career != null) {
      final List<String> wanted = career.certifications
          .map((String id) => CertificationCatalog.byId(id)?.name ?? id)
          .toList();
      if (r.certifications.any(wanted.contains)) {
        cert += 0.5;
        strengths.add('Your certification is relevant to this field.');
      } else if (wanted.isNotEmpty) {
        fixes.add('Consider earning: ${wanted.join(', ')}.');
      }
    }
    sec['Certifications'] = cert.clamp(0, 1).toDouble();

    // Professionalism: no shouting.
    double penalty = 0;
    final String all = '${r.summary} ${r.projects.map((ProjectEntry p) => p.description).join(' ')}';
    if (all.contains('!!') || RegExp(r'[A-Z]{12,}').hasMatch(all)) {
      penalty = 5;
      fixes.add('Avoid ALL CAPS and multiple exclamation marks — keep the tone professional.');
    }

    final double total = sec['Contact']! * 10 +
        sec['Summary']! * 15 +
        sec['Education']! * 15 +
        sec['Skills']! * 15 +
        sec['Experience']! * 20 +
        sec['Projects']! * 15 +
        sec['Certifications']! * 10 -
        penalty;

    return ResumeReview(
      score: total.clamp(0, 100).toDouble(),
      sections: sec,
      strengths: strengths,
      improvements: fixes,
      expectations: career?.employerExpectations ?? const <String>[],
    );
  }

  static String _levelFor(CareerDef c) {
    switch (c.minEducationRank) {
      case 4:
        return 'doctorate';
      case 3:
        return 'master';
      case 2:
        return 'bachelor';
      default:
        return 'associate';
    }
  }
}
