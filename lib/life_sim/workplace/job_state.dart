/// Having a job: shifts, performance, pay, promotion and losing it.
library;

import '../careers/career_catalog.dart';
import '../core/stable_random.dart';
import '../education/skills.dart';
import '../employment/contract.dart';
import '../employment/employers.dart';
import 'task_bank.dart';
import 'work_task.dart';

enum JobEventKind { info, praise, warning, promotion, pay, noticeGiven, employmentEnded }

class JobEvent {
  const JobEvent(this.kind, this.message, {this.amount = 0, this.endedReason});
  final JobEventKind kind;
  final String message;

  /// Gross pay for [JobEventKind.pay]; severance for [JobEventKind.employmentEnded].
  final double amount;

  /// `fired`, `laid_off` for [JobEventKind.employmentEnded].
  final String? endedReason;
}

class TaskOutcome {
  const TaskOutcome({required this.score, required this.performanceDelta, required this.skillGains, required this.rating});
  final double score;
  final double performanceDelta;

  /// Skill id → points to add (already scaled by quality of work).
  final Map<String, double> skillGains;
  final String rating;
}

class PromotionStatus {
  const PromotionStatus({required this.eligible, required this.unmet, this.nextRank, this.newSalary, this.nextTitle});
  final bool eligible;
  final List<String> unmet;
  final int? nextRank;
  final double? newSalary;
  final String? nextTitle;
}

class JobRecord {
  JobRecord({
    required this.contract,
    required this.lastPaydayDay,
    this.workdaysAtRank = 0,
    this.totalWorkdays = 0,
    this.performance = 62,
    List<int>? strikeDays,
    this.accruedGross = 0,
    this.todayDay = 0,
    List<String>? assignedIds,
    Map<String, double>? doneScores,
    this.checkedInMinute,
    this.excusedToday = false,
    List<String>? recentIds,
    this.sickDaysUsed = 0,
    this.sickWindowStart = 1,
    this.lastWarningDay = -99,
    this.noticeEndDay,
    this.promotions = 0,
  })  : strikeDays = strikeDays ?? <int>[],
        assignedIds = assignedIds ?? <String>[],
        doneScores = doneScores ?? <String, double>{},
        recentIds = recentIds ?? <String>[];

  EmploymentContract contract;

  /// Credited workdays at the current rank (half days count 0.5).
  double workdaysAtRank;
  double totalWorkdays;

  /// Rolling rating 0..100.
  double performance;
  final List<int> strikeDays;
  int lastPaydayDay;
  double accruedGross;

  // Today's state.
  int todayDay;
  final List<String> assignedIds;
  final Map<String, double> doneScores;
  int? checkedInMinute;
  bool excusedToday;

  final List<String> recentIds;
  int sickDaysUsed;
  int sickWindowStart;
  int lastWarningDay;
  int? noticeEndDay;
  int promotions;

  int get rank => contract.rank;
  Employer get employer => contract.employer;
  CareerDef get career => contract.career;
  bool get onNotice => noticeEndDay != null;
  bool get checkedIn => checkedInMinute != null;
  int get tasksDoneToday => doneScores.length;
  List<String> get remainingIds => assignedIds.where((String id) => !doneScores.containsKey(id)).toList();

  bool get inProbation => totalWorkdays < contract.probationDays * 5 / 7;

  Map<String, Object?> toJson() => <String, Object?>{
        'contract': contract.toJson(),
        'workdaysAtRank': workdaysAtRank,
        'totalWorkdays': totalWorkdays,
        'performance': performance,
        'strikeDays': strikeDays,
        'lastPaydayDay': lastPaydayDay,
        'accruedGross': accruedGross,
        'todayDay': todayDay,
        'assignedIds': assignedIds,
        'doneScores': doneScores,
        'checkedInMinute': checkedInMinute,
        'excusedToday': excusedToday,
        'recentIds': recentIds,
        'sickDaysUsed': sickDaysUsed,
        'sickWindowStart': sickWindowStart,
        'lastWarningDay': lastWarningDay,
        'noticeEndDay': noticeEndDay,
        'promotions': promotions,
      };

  factory JobRecord.fromJson(Map<String, Object?> j) {
    List<String> strs(Object? v) => v is List ? v.map((Object? e) => e.toString()).toList() : <String>[];
    final Object? ds = j['doneScores'];
    return JobRecord(
      contract: EmploymentContract.fromJson(Map<String, Object?>.from(j['contract'] as Map)),
      lastPaydayDay: (j['lastPaydayDay'] as num?)?.toInt() ?? 1,
      workdaysAtRank: (j['workdaysAtRank'] as num?)?.toDouble() ?? 0,
      totalWorkdays: (j['totalWorkdays'] as num?)?.toDouble() ?? 0,
      performance: (j['performance'] as num?)?.toDouble() ?? 62,
      strikeDays: j['strikeDays'] is List ? (j['strikeDays'] as List).map((Object? e) => (e as num).toInt()).toList() : <int>[],
      accruedGross: (j['accruedGross'] as num?)?.toDouble() ?? 0,
      todayDay: (j['todayDay'] as num?)?.toInt() ?? 0,
      assignedIds: strs(j['assignedIds']),
      doneScores: ds is Map ? ds.map((Object? k, Object? v) => MapEntry<String, double>(k.toString(), (v as num).toDouble())) : <String, double>{},
      checkedInMinute: (j['checkedInMinute'] as num?)?.toInt(),
      excusedToday: j['excusedToday'] as bool? ?? false,
      recentIds: strs(j['recentIds']),
      sickDaysUsed: (j['sickDaysUsed'] as num?)?.toInt() ?? 0,
      sickWindowStart: (j['sickWindowStart'] as num?)?.toInt() ?? 1,
      lastWarningDay: (j['lastWarningDay'] as num?)?.toInt() ?? -99,
      noticeEndDay: (j['noticeEndDay'] as num?)?.toInt(),
      promotions: (j['promotions'] as num?)?.toInt() ?? 0,
    );
  }
}

class JobEngine {
  const JobEngine._();

  static const int paydayInterval = 14;
  static const int lateGraceMinutes = 15;
  static const int maxSickDaysPerMonth = 2;
  static const int strikeWindowDays = 14;
  static const int strikesToFire = 3;
  static const int noticeDays = 7;
  static const double workdaysPerYear = 260;

  static bool isWorkday(int day) => ((day - 1) % 7) < 5;

  /// The first pay period covers exactly [paydayInterval] days from the start date.
  static JobRecord start(EmploymentContract c) => JobRecord(contract: c, lastPaydayDay: c.startDay - 1);

  static double dailyRate(JobRecord j) => j.contract.monthlySalary * 12 / workdaysPerYear;

  /// Can the player work today (job started, a weekday, not on notice-end)?
  static bool isShiftDay(JobRecord j, int day) => isWorkday(day) && day >= j.contract.startDay;

  static void _rollDay(JobRecord j, int day) {
    if (j.todayDay == day) return;
    j.todayDay = day;
    j.assignedIds.clear();
    j.doneScores.clear();
    j.checkedInMinute = null;
    j.excusedToday = false;
  }

  /// Reports for work: records arrival and hands out today's assignments.
  static ({List<WorkScenario> tasks, bool late, String message}) checkIn(JobRecord j, int day, int minuteOfDay) {
    _rollDay(j, day);
    if (!isShiftDay(j, day)) {
      return (tasks: <WorkScenario>[], late: false, message: 'There is no shift today.');
    }
    final int start = j.contract.startHour * 60;
    final int end = j.contract.endHour * 60;
    if (minuteOfDay >= end) {
      return (tasks: <WorkScenario>[], late: true, message: 'The working day is over — you missed your shift.');
    }
    if (j.excusedToday) {
      return (tasks: <WorkScenario>[], late: false, message: 'You called in sick today.');
    }
    if (j.checkedIn) {
      return (tasks: _scenarios(j.assignedIds), late: false, message: 'You are already checked in.');
    }
    final bool late = minuteOfDay > start + lateGraceMinutes;
    j.checkedInMinute = minuteOfDay;
    final List<WorkScenario> tasks = WorkTaskBank.assignDay(
      careerId: j.contract.careerId,
      rank: j.rank,
      day: day,
      recentIds: j.recentIds,
    );
    j.assignedIds
      ..clear()
      ..addAll(tasks.map((WorkScenario s) => s.id));
    final String boss = j.employer.interviewer.name;
    return (
      tasks: tasks,
      late: late,
      message: late
          ? '$boss: "You are late. Please be on time — here is what we have for today."'
          : '$boss: "Good morning! Here is what we have for today."',
    );
  }

  static List<WorkScenario> _scenarios(List<String> ids) =>
      ids.map(WorkTaskBank.byId).whereType<WorkScenario>().toList();

  static List<WorkScenario> assigned(JobRecord j) => _scenarios(j.assignedIds);

  /// Scores a completed task and updates performance.
  static TaskOutcome completeTask(JobRecord j, WorkScenario s, double score, int day, {double readiness = 1}) {
    _rollDay(j, day);
    final double s100 = (score * 100).clamp(0, 100).toDouble();
    // Tired, hungry workers do slightly worse than their answers deserve.
    final double adjusted = (s100 * (0.9 + 0.1 * readiness)).clamp(0, 100).toDouble();
    final double before = j.performance;
    j.performance = (j.performance + (adjusted - j.performance) * 0.12).clamp(0, 100).toDouble();
    j.doneScores[s.id] = score;
    j.recentIds.add(s.id);
    while (j.recentIds.length > 14) {
      j.recentIds.removeAt(0);
    }
    final Map<String, double> gains = <String, double>{
      for (final MapEntry<String, double> e in s.skillGain.entries) e.key: e.value * (0.4 + 0.9 * score),
    };
    final String rating = score >= 0.9
        ? 'Outstanding'
        : score >= 0.75
            ? 'Good work'
            : score >= 0.55
                ? 'Acceptable'
                : score >= 0.35
                    ? 'Needs improvement'
                    : 'Poor';
    return TaskOutcome(score: score, performanceDelta: j.performance - before, skillGains: gains, rating: rating);
  }

  static bool canCallInSick(JobRecord j, int day) {
    if (day - j.sickWindowStart >= 30) return true;
    return j.sickDaysUsed < maxSickDaysPerMonth;
  }

  /// Excuses today's absence (limited per month). Returns an error or null.
  static String? callInSick(JobRecord j, int day) {
    _rollDay(j, day);
    if (!isShiftDay(j, day)) return 'There is no shift today.';
    if (j.tasksDoneToday > 0) return 'You already started work today.';
    if (day - j.sickWindowStart >= 30) {
      j.sickWindowStart = day;
      j.sickDaysUsed = 0;
    }
    if (j.sickDaysUsed >= maxSickDaysPerMonth) {
      return 'You have used your $maxSickDaysPerMonth sick days this month.';
    }
    j.sickDaysUsed++;
    j.excusedToday = true;
    return null;
  }

  /// Processes the day that just finished. Call once per midnight rollover.
  static List<JobEvent> endOfDay(JobRecord j, int day) {
    final List<JobEvent> events = <JobEvent>[];
    final bool working = isShiftDay(j, day);
    if (working) {
      final bool wasToday = j.todayDay == day;
      final int done = wasToday ? j.tasksDoneToday : 0;
      final bool excused = wasToday && j.excusedToday;
      double credit;
      if (excused) {
        credit = 1;
      } else if (done >= WorkTaskBank.tasksPerDay) {
        credit = 1;
      } else if (done >= 1) {
        credit = 0.5;
      } else {
        credit = 0;
      }
      if (credit > 0) {
        j.workdaysAtRank += credit;
        j.totalWorkdays += credit;
        j.accruedGross += dailyRate(j) * credit;
      }
      if (!excused) {
        if (credit == 0) {
          j.performance = (j.performance - 5).clamp(0, 100).toDouble();
          j.strikeDays.add(day);
          events.add(JobEvent(JobEventKind.warning,
              'You did not turn up for work on day $day. ${j.employer.interviewer.name} recorded an absence.'));
        } else if (credit == 0.5) {
          events.add(const JobEvent(JobEventKind.info, 'You only finished part of your shift — half a day credited.'));
        } else {
          final double avg = j.doneScores.isEmpty ? 0 : j.doneScores.values.reduce((double a, double b) => a + b) / j.doneScores.length;
          if (avg >= 0.8) {
            j.performance = (j.performance + 0.6).clamp(0, 100).toDouble();
            events.add(JobEvent(JobEventKind.praise, '${j.employer.interviewer.name} praised your work today.'));
          }
        }
        if (wasToday && j.checkedIn && j.checkedInMinute! > j.contract.startHour * 60 + lateGraceMinutes && credit > 0) {
          j.performance = (j.performance - 1).clamp(0, 100).toDouble();
        }
      }
    }

    j.strikeDays.removeWhere((int d) => day - d > strikeWindowDays);
    if (j.strikeDays.length >= strikesToFire) {
      events.add(JobEvent(JobEventKind.employmentEnded,
          'You were dismissed from ${j.employer.name} after repeated unexplained absences.',
          endedReason: 'fired'));
      return events;
    }
    if (working && j.performance < 28 && j.totalWorkdays >= 10) {
      events.add(JobEvent(JobEventKind.employmentEnded,
          'You were dismissed from ${j.employer.name} for sustained poor performance.',
          endedReason: 'fired'));
      return events;
    }
    if (working && j.performance < 40 && j.totalWorkdays >= 5 && day - j.lastWarningDay >= 7) {
      j.lastWarningDay = day;
      events.add(JobEvent(JobEventKind.warning,
          '${j.employer.interviewer.name}: "Your performance is below expectations. I need to see improvement or we will have to talk about your future here."'));
    }

    // Payday.
    if (day - j.lastPaydayDay >= paydayInterval) {
      final double gross = double.parse(j.accruedGross.toStringAsFixed(2));
      j.lastPaydayDay = day;
      j.accruedGross = 0;
      if (gross > 0) {
        events.add(JobEvent(JobEventKind.pay, 'Payday from ${j.employer.name}.', amount: gross));
      }
    }

    // Monthly restructuring risk.
    if (day % 30 == 0 && j.totalWorkdays >= 15 && !j.onNotice) {
      final StableRandom rng = StableRandom.fromString('layoff|${j.contract.employerId}|${j.contract.signedDay}|$day');
      double p = 0.03;
      if (j.performance < 50) p += 0.08;
      if (j.rank <= 1) p += 0.02;
      if (j.performance >= 80) p -= 0.02;
      if (rng.chance(p.clamp(0.0, 0.2))) {
        j.noticeEndDay = day + noticeDays;
        events.add(JobEvent(JobEventKind.noticeGiven,
            '${j.employer.name} is restructuring. Your role is at risk — you have $noticeDays days\' notice. Start applying elsewhere!'));
      }
    }
    if (j.onNotice && day >= j.noticeEndDay!) {
      events.add(JobEvent(JobEventKind.employmentEnded,
          'Your role at ${j.employer.name} has ended. You receive severance of half a month\'s salary.',
          amount: j.contract.monthlySalary * 0.5,
          endedReason: 'laid_off'));
    }
    return events;
  }

  // ---- Promotion -----------------------------------------------------

  static PromotionStatus promotionStatus(JobRecord j, SkillSet skills) {
    if (j.rank >= kTopRank) {
      return const PromotionStatus(eligible: false, unmet: <String>['You are already at the top of this ladder.']);
    }
    final int next = j.rank + 1;
    final PromotionRequirement req = CareerCatalog.promotionRequirement(j.career, next);
    final List<String> unmet = <String>[];
    if (j.workdaysAtRank < req.workdays) {
      unmet.add('Time in role: ${j.workdaysAtRank.floor()}/${req.workdays} workdays.');
    }
    if (j.performance < req.performance) {
      unmet.add('Performance rating: ${j.performance.round()}/${req.performance.round()}.');
    }
    unmet.addAll(skills.gaps(req.skills).map((String g) => 'Skill — $g'));
    final double table = CareerCatalog.monthlySalary(j.career, next, employerFactor: j.employer.prestige);
    final double salary = table > j.contract.monthlySalary * 1.06 ? table : (j.contract.monthlySalary * 1.06 / 10).round() * 10.0;
    return PromotionStatus(
      eligible: unmet.isEmpty,
      unmet: unmet,
      nextRank: next,
      newSalary: salary,
      nextTitle: j.career.titleForRank(next),
    );
  }

  /// Promotes the player if eligible. Returns the status used.
  static PromotionStatus promote(JobRecord j, SkillSet skills, {double? negotiatedSalary}) {
    final PromotionStatus s = promotionStatus(j, skills);
    if (!s.eligible) return s;
    j.contract = j.contract.copyWith(
      rank: s.nextRank,
      title: s.nextTitle,
      monthlySalary: negotiatedSalary ?? s.newSalary,
    );
    j.workdaysAtRank = 0;
    j.promotions++;
    j.performance = j.performance < 62 ? 62 : j.performance - 4;
    j.recentIds.clear();
    return s;
  }
}

/// Negotiating an offer or a raise.
class NegotiationOutcome {
  const NegotiationOutcome({
    required this.accepted,
    required this.finalSalary,
    required this.message,
    this.counter,
    this.withdrawn = false,
  });

  /// True if your ask was accepted as asked.
  final bool accepted;
  final double finalSalary;

  /// A middle-ground the employer proposes (you may accept or keep the original).
  final double? counter;
  final bool withdrawn;
  final String message;
}

class SalaryNegotiation {
  const SalaryNegotiation._();

  /// Rubric for the player's written pitch.
  static final WorkStage pitchStage = WorkStage.text(
    id: 'negotiation-pitch',
    prompt: 'Explain why you deserve this salary.',
    rubric: const <RubricItem>[
      RubricItem('Cite concrete achievements or results', <String>['achiev', 'result', 'delivered', 'improved', 'completed', 'led', '%', 'rating']),
      RubricItem('Reference market rates or the role\'s value', <String>['market', 'industry', 'typical', 'comparable', 'range', 'benchmark', 'value']),
      RubricItem('Show flexibility and enthusiasm', <String>['flexible', 'open to', 'excited', 'happy to', 'committed', 'glad', 'looking forward']),
      RubricItem('Polite, professional tone', <String>['thank', 'appreciate', 'would like', 'i hope', 'please']),
    ],
    modelAnswer: 'Thank you for the offer. Based on my results — I completed my probation with a strong performance rating — and typical market ranges for this role, I would like to ask for a slightly higher salary. I am excited about the team and open to discussing the details.',
    minWords: 15,
  );

  /// 0..1 — how much negotiating power the player has.
  ///
  /// [rating] is interview score or job performance (0..100); [skillSurplus]
  /// is 0..1 (how far above requirements); [communication] is the 0..100 skill.
  static double leverage({
    required double rating,
    required double skillSurplus,
    required double communication,
    bool competingOffer = false,
  }) {
    double v = (rating - 50) / 60 * 0.5 + skillSurplus * 0.25 + communication / 100 * 0.15 + (competingOffer ? 0.15 : 0);
    return v.clamp(0, 1).toDouble();
  }

  /// [askPercent] is the raise requested over [offer] (0..30).
  static NegotiationOutcome respond({
    required double offer,
    required double askPercent,
    required double leverage,
    required double pitchScore,
    required bool isNewOffer,
  }) {
    final double maxPct = 2 + leverage * 10 + pitchScore * 4;
    double round10(double v) => (v / 10).round() * 10.0;
    if (askPercent <= 0) {
      return NegotiationOutcome(accepted: true, finalSalary: offer, message: 'No problem — we will proceed on the original terms.');
    }
    if (askPercent <= maxPct) {
      final double s = round10(offer * (1 + askPercent / 100));
      return NegotiationOutcome(
        accepted: true,
        finalSalary: s,
        message: 'That is reasonable given your record. We can agree \$${s.round()} per month.',
      );
    }
    if (askPercent <= maxPct + 5) {
      final double mid = round10(offer * (1 + (askPercent + maxPct) / 2 / 100));
      return NegotiationOutcome(
        accepted: false,
        finalSalary: offer,
        counter: mid,
        message: 'We cannot quite reach that, but we can offer \$${mid.round()} per month. Would that work?',
      );
    }
    if (isNewOffer && askPercent > maxPct + 14) {
      return const NegotiationOutcome(
        accepted: false,
        finalSalary: 0,
        withdrawn: true,
        message: 'That is far beyond our range. We are sorry — we are withdrawing the offer.',
      );
    }
    return NegotiationOutcome(
      accepted: false,
      finalSalary: offer,
      message: 'That is beyond what we can do. The original offer of \$${offer.round()} stands.',
    );
  }
}
