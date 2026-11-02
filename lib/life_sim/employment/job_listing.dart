/// Job postings generated from employers × careers × ranks.
library;

import '../careers/career_catalog.dart';
import '../core/stable_random.dart';
import 'employers.dart';

class JobListing {
  const JobListing({
    required this.id,
    required this.employerId,
    required this.careerId,
    required this.rank,
    required this.title,
    required this.monthlySalary,
    required this.minEducationRank,
    required this.requiredSkills,
    required this.requiredExperienceDays,
    required this.startHour,
    required this.endHour,
    required this.responsibilities,
  });

  final String id;
  final String employerId;
  final String careerId;
  final int rank;
  final String title;
  final double monthlySalary;
  final int minEducationRank;
  final Map<String, int> requiredSkills;

  /// Workdays already worked in this career (any employer).
  final int requiredExperienceDays;
  final int startHour;
  final int endHour;
  final List<String> responsibilities;

  Employer get employer => EmployerCatalog.require(employerId);
  CareerDef get career => CareerCatalog.require(careerId);

  String get hoursLabel {
    String h(int v) {
      final int h12 = v % 12 == 0 ? 12 : v % 12;
      return '$h12${v < 12 ? 'am' : 'pm'}';
    }

    return 'Mon–Fri · ${h(startHour)}–${h(endHour)}';
  }
}

class JobBoard {
  const JobBoard._();

  /// Highest rank posted externally (promotion handles the rest).
  static const int maxExternalRank = 4;

  static final List<JobListing> _all = _build();

  static List<JobListing> _build() {
    final List<JobListing> out = <JobListing>[];
    for (final Employer e in EmployerCatalog.all) {
      for (final String careerId in e.hires) {
        final CareerDef c = CareerCatalog.require(careerId);
        for (int rank = 0; rank <= maxExternalRank; rank++) {
          out.add(_make(e, c, rank));
        }
      }
    }
    return out;
  }

  static JobListing _make(Employer e, CareerDef c, int rank) {
    final Map<String, int> skills = <String, int>{};
    if (rank >= 1) {
      final PromotionRequirement req = CareerCatalog.promotionRequirement(c, rank);
      skills[c.coreSkill] = (req.skills[c.coreSkill]! * 0.7).round();
      skills['communication'] = 10 + rank * 4;
    } else {
      skills[c.coreSkill] = 5;
    }
    const List<int> exp = <int>[0, 0, 15, 40, 80];
    return JobListing(
      id: '${e.id}:${c.id}:$rank',
      employerId: e.id,
      careerId: c.id,
      rank: rank,
      title: c.titleForRank(rank),
      monthlySalary: CareerCatalog.monthlySalary(c, rank, employerFactor: e.prestige),
      minEducationRank: c.educationRankFor(rank),
      requiredSkills: skills,
      requiredExperienceDays: exp[rank],
      startHour: e.startHour,
      endHour: e.endHour,
      responsibilities: _responsibilities(c, rank),
    );
  }

  static List<String> _responsibilities(CareerDef c, int rank) {
    final List<String> base = List<String>.of(c.dayInLife);
    if (rank == 0) {
      return <String>[...base.take(3), 'Learn from mentors and ask questions'];
    }
    if (rank >= 3) {
      return <String>[...base, 'Mentor junior colleagues'];
    }
    return base;
  }

  static JobListing? byId(String id) {
    for (final JobListing l in _all) {
      if (l.id == id) return l;
    }
    return null;
  }

  static List<JobListing> get everything => List<JobListing>.unmodifiable(_all);

  /// Is this posting open on [day]? Junior roles are always open; senior roles
  /// open in most weeks so the board changes as time passes.
  static bool isOpen(JobListing l, int day) {
    if (l.rank <= 1) return true;
    final int week = (day - 1) ~/ 7;
    return (stableHash(l.id) + week) % 4 != 0;
  }

  static List<JobListing> openListings(int day, {String? careerId}) {
    return _all
        .where((JobListing l) => (careerId == null || l.careerId == careerId) && isOpen(l, day))
        .toList();
  }
}
