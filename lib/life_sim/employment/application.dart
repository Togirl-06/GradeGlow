/// Job applications: screening, response timing and notifications.
library;

import '../careers/career_catalog.dart';
import '../core/stable_random.dart';
import '../education/skills.dart';
import 'employers.dart';
import 'job_listing.dart';
import 'phone_inbox.dart';
import 'qualifications.dart';

enum ApplicationStatus {
  pending,
  invited,
  rejected,
  interviewed,
  infoRequested,
  offer,
  waitlisted,
  hired,
  declined,
  expired,
}

class ApplicationRecord {
  ApplicationRecord({
    required this.id,
    required this.listingId,
    required this.submittedDay,
    required this.respondDay,
    required this.matchScore,
    required this.resumeScore,
    required this.willInvite,
    this.status = ApplicationStatus.pending,
    this.interviewDay,
    this.interviewHour,
    this.interviewScore,
    this.offerSalary,
    this.waitlistResolveDay,
    this.waitlistWillOffer = false,
    this.willAskInfo = false,
    this.round = 1,
    this.infoDeadlineDay,
    this.infoRequest,
    List<String>? feedback,
  }) : feedback = feedback ?? <String>[];

  final String id;
  final String listingId;
  final int submittedDay;
  int respondDay;
  final double matchScore;
  final double resumeScore;
  bool willInvite;
  ApplicationStatus status;
  int? interviewDay;
  int? interviewHour;
  double? interviewScore;
  double? offerSalary;
  int? waitlistResolveDay;
  bool waitlistWillOffer;
  bool willAskInfo;

  /// 1 = first interview, 2 = final interview.
  int round;
  int? infoDeadlineDay;
  String? infoRequest;
  final List<String> feedback;

  JobListing? get listing => JobBoard.byId(listingId);

  bool get isActive =>
      status == ApplicationStatus.pending ||
      status == ApplicationStatus.invited ||
      status == ApplicationStatus.infoRequested ||
      status == ApplicationStatus.offer ||
      status == ApplicationStatus.waitlisted;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'listingId': listingId,
        'submittedDay': submittedDay,
        'respondDay': respondDay,
        'matchScore': matchScore,
        'resumeScore': resumeScore,
        'willInvite': willInvite,
        'status': status.name,
        'interviewDay': interviewDay,
        'interviewHour': interviewHour,
        'interviewScore': interviewScore,
        'offerSalary': offerSalary,
        'waitlistResolveDay': waitlistResolveDay,
        'waitlistWillOffer': waitlistWillOffer,
        'willAskInfo': willAskInfo,
        'round': round,
        'infoDeadlineDay': infoDeadlineDay,
        'infoRequest': infoRequest,
        'feedback': feedback,
      };

  factory ApplicationRecord.fromJson(Map<String, Object?> j) => ApplicationRecord(
        id: j['id'] as String? ?? '',
        listingId: j['listingId'] as String? ?? '',
        submittedDay: (j['submittedDay'] as num?)?.toInt() ?? 1,
        respondDay: (j['respondDay'] as num?)?.toInt() ?? 1,
        matchScore: (j['matchScore'] as num?)?.toDouble() ?? 0,
        resumeScore: (j['resumeScore'] as num?)?.toDouble() ?? 0,
        willInvite: j['willInvite'] as bool? ?? false,
        status: ApplicationStatus.values.firstWhere(
          (ApplicationStatus s) => s.name == j['status'],
          orElse: () => ApplicationStatus.pending,
        ),
        interviewDay: (j['interviewDay'] as num?)?.toInt(),
        interviewHour: (j['interviewHour'] as num?)?.toInt(),
        interviewScore: (j['interviewScore'] as num?)?.toDouble(),
        offerSalary: (j['offerSalary'] as num?)?.toDouble(),
        waitlistResolveDay: (j['waitlistResolveDay'] as num?)?.toInt(),
        waitlistWillOffer: j['waitlistWillOffer'] as bool? ?? false,
        willAskInfo: j['willAskInfo'] as bool? ?? false,
        round: (j['round'] as num?)?.toInt() ?? 1,
        infoDeadlineDay: (j['infoDeadlineDay'] as num?)?.toInt(),
        infoRequest: j['infoRequest'] as String?,
        feedback: (j['feedback'] is List)
            ? (j['feedback'] as List).map((Object? e) => e.toString()).toList()
            : <String>[],
      );
}

class ApplicationAssessment {
  const ApplicationAssessment({
    required this.score,
    required this.hardFail,
    required this.gaps,
    required this.strengths,
    required this.threshold,
  });

  /// 0..100 match.
  final double score;

  /// True if a hard requirement (education) is far from met.
  final bool hardFail;
  final List<String> gaps;
  final List<String> strengths;
  final double threshold;

  bool get passes => !hardFail && score >= threshold;
}

class ApplicationEngine {
  const ApplicationEngine._();

  static const int maxActive = 6;
  static const int cooldownAfterRejectionDays = 3;

  /// Deterministic screening of [q] against [listing].
  static ApplicationAssessment assess({
    required PlayerQualifications q,
    required JobListing listing,
    required double resumeScore,
    required String seedKey,
  }) {
    final Employer emp = listing.employer;
    final CareerDef career = listing.career;
    final List<String> gaps = <String>[];
    final List<String> strengths = <String>[];

    final int eduDiff = q.educationRank - listing.minEducationRank;
    double eduFit = 1;
    bool hardFail = false;
    if (eduDiff < 0) {
      if (eduDiff == -1) {
        eduFit = 0.35;
        gaps.add('Education: this role asks for ${_eduName(listing.minEducationRank)}.');
      } else {
        eduFit = 0;
        hardFail = true;
        gaps.add('Education: this role requires ${_eduName(listing.minEducationRank)} — '
            'enrol at the University first.');
      }
    } else {
      strengths.add('Your education meets the requirement.');
    }

    double skillFit = 1;
    if (listing.requiredSkills.isNotEmpty) {
      double sum = 0;
      listing.requiredSkills.forEach((String id, int need) {
        final double have = q.skills.level(id);
        final double fit = need <= 0 ? 1 : (have / need).clamp(0, 1).toDouble();
        sum += fit;
        if (fit < 1) {
          gaps.add('${Skills.nameOf(id)}: you have ${have.round()}, the role wants $need.');
        }
      });
      skillFit = sum / listing.requiredSkills.length;
      if (skillFit >= 1) strengths.add('You meet every required skill.');
    }

    double expFit = 1;
    final int days = q.daysIn(listing.careerId);
    if (listing.requiredExperienceDays > 0) {
      expFit = (days / listing.requiredExperienceDays).clamp(0, 1).toDouble();
      if (expFit < 1) {
        gaps.add('Experience: $days of ${listing.requiredExperienceDays} workdays in '
            '${career.title.toLowerCase()} roles.');
      } else {
        strengths.add('You have the experience they want.');
      }
    }

    if (resumeScore < 55) {
      gaps.add('Your resume scored ${resumeScore.round()}/100 — visit the career assistant to improve it.');
    } else if (resumeScore >= 75) {
      strengths.add('Your resume is strong.');
    }

    double bonus = 0;
    final List<String> relevantCerts =
        career.certifications.where(q.certifications.contains).toList();
    bonus += (relevantCerts.length * 4).clamp(0, 8).toDouble();
    if (relevantCerts.isNotEmpty) strengths.add('A relevant certification helps.');
    bonus += q.professionalism * 0.6;
    if (q.hasTrait('charismatic')) bonus += 2;
    if (q.hasTrait('disciplined')) bonus += 1;

    final double base = 28 * eduFit + 30 * skillFit + 17 * expFit + 25 * (resumeScore / 100);
    double score = base * (0.55 + 0.45 * expFit) * (0.6 + 0.4 * skillFit) + bonus;
    score -= emp.hiringBar * 0.5;
    final StableRandom rng = StableRandom.fromString(seedKey);
    score += (rng.nextDouble() - 0.5) * 6; // ±3

    final double threshold = 52.0 + listing.rank * 3;
    return ApplicationAssessment(
      score: score.clamp(0, 100).toDouble(),
      hardFail: hardFail,
      gaps: gaps,
      strengths: strengths,
      threshold: threshold,
    );
  }

  static String _eduName(int rank) {
    const List<String> n = <String>[
      'a high school diploma',
      'an associate degree',
      "a bachelor's degree",
      "a master's degree",
      'a doctorate',
    ];
    return n[rank.clamp(0, 4)];
  }

  /// Why [listing] cannot be applied for right now, or null if allowed.
  static String? blockReason(
    List<ApplicationRecord> all,
    JobListing listing,
    int today,
  ) {
    if (!JobBoard.isOpen(listing, today)) return 'This position has been filled.';
    if (all.where((ApplicationRecord a) => a.isActive).length >= maxActive) {
      return 'You already have $maxActive active applications.';
    }
    for (final ApplicationRecord a in all) {
      if (a.listingId != listing.id) continue;
      if (a.isActive) return 'You already applied for this job.';
      if (a.status == ApplicationStatus.rejected &&
          today - a.respondDay < cooldownAfterRejectionDays) {
        return 'You can reapply in ${cooldownAfterRejectionDays - (today - a.respondDay)} day(s) — '
            'use the time to improve.';
      }
    }
    return null;
  }

  /// Submits an application; the outcome is decided now but revealed later.
  static ApplicationRecord submit({
    required String id,
    required PlayerQualifications q,
    required JobListing listing,
    required double resumeScore,
    required int today,
  }) {
    final ApplicationAssessment a = assess(
      q: q,
      listing: listing,
      resumeScore: resumeScore,
      seedKey: '$id|${listing.id}|$today|${q.name}',
    );
    final StableRandom rng = StableRandom.fromString('delay|$id|${listing.id}');
    final int delay = 1 + rng.nextInt(3);
    return ApplicationRecord(
      id: id,
      listingId: listing.id,
      submittedDay: today,
      respondDay: today + delay,
      matchScore: a.score,
      resumeScore: resumeScore,
      willInvite: a.passes,
      willAskInfo: !a.passes && !a.hardFail && a.score >= a.threshold - 9 && a.gaps.isNotEmpty,
      feedback: <String>[
        ...a.gaps,
        if (!a.passes && a.gaps.isEmpty) 'Other candidates were a closer fit this round.',
      ],
    );
  }

  /// Next free interview slot: a weekday, 1-3 days after [respondDay], inside
  /// the employer's hours.
  static ({int day, int hour}) scheduleInterview(ApplicationRecord a, Employer e) {
    final StableRandom rng = StableRandom.fromString('slot|${a.id}');
    int day = a.respondDay + 1 + rng.nextInt(2);
    while (((day - 1) % 7) >= 5) {
      day++;
    }
    final int span = (e.endHour - e.startHour - 2).clamp(1, 8);
    final int hour = e.startHour + 1 + rng.nextInt(span);
    return (day: day, hour: hour);
  }

  /// Reveals responses that are due. Returns the newly created messages.
  static List<PhoneMessage> processResponses({
    required List<ApplicationRecord> applications,
    required PhoneInbox inbox,
    required int today,
    required int minuteOfDay,
  }) {
    final List<PhoneMessage> out = <PhoneMessage>[];
    for (final ApplicationRecord a in applications) {
      final JobListing? l = a.listing;
      if (l == null) continue;
      final Employer e = l.employer;

      if (a.status == ApplicationStatus.pending && today >= a.respondDay) {
        if (a.willInvite) {
          final ({int day, int hour}) slot = scheduleInterview(a, e);
          a.status = ApplicationStatus.invited;
          a.interviewDay = slot.day;
          a.interviewHour = slot.hour;
          out.add(inbox.add(
            kind: MessageKind.email,
            from: '${e.interviewer.name} · ${e.name}',
            subject: 'Interview invitation: ${l.title}',
            body: 'Hello,\n\nThank you for applying for the ${l.title} position at ${e.name}. '
                'We were impressed by your application and would like to invite you to interview.\n\n'
                'When: Day ${slot.day}, ${_hourLabel(slot.hour)}\n'
                'Where: ${e.name} (reception)\n\n'
                'Tip: arrive a little early, dress professionally, and prepare examples. '
                'You can practise at the Employment Center.\n\n'
                '${e.interviewer.name}\n${e.interviewer.title}',
            day: today,
            minuteOfDay: minuteOfDay,
            action: <String, String>{'type': 'interview', 'applicationId': a.id},
          ));
        } else if (a.willAskInfo) {
          a.status = ApplicationStatus.infoRequested;
          a.infoDeadlineDay = today + 4;
          a.infoRequest = a.feedback.take(2).join(' ');
          out.add(inbox.add(
            kind: MessageKind.email,
            from: 'Recruitment · ${e.name}',
            subject: 'More information needed: ${l.title}',
            body: 'Hello,\n\nThank you for applying for ${l.title} at ${e.name}. You are close to what we are looking for, '
                'but before we decide we need a little more from you:\n\n- ${a.feedback.take(2).join('\n- ')}\n\n'
                'Improve your profile (resume, skills, certifications) and use "Send update" on your application by Day ${a.infoDeadlineDay}.',
            day: today,
            minuteOfDay: minuteOfDay,
            action: <String, String>{'type': 'applications'},
          ));
        } else {
          a.status = ApplicationStatus.rejected;
          out.add(inbox.add(
            kind: MessageKind.email,
            from: 'Recruitment · ${e.name}',
            subject: 'Your application: ${l.title}',
            body: 'Hello,\n\nThank you for your interest in the ${l.title} position at ${e.name}. '
                'After careful review we will not be moving forward with your application this time.\n\n'
                '${a.feedback.isEmpty ? '' : 'What would strengthen a future application:\n- ${a.feedback.join('\n- ')}\n\n'}'
                'You are welcome to apply again once you have built your profile.',
            day: today,
            minuteOfDay: minuteOfDay,
            action: <String, String>{'type': 'applications'},
          ));
        }
      }

      // Info request not answered in time.
      if (a.status == ApplicationStatus.infoRequested && a.infoDeadlineDay != null && today > a.infoDeadlineDay!) {
        a.status = ApplicationStatus.expired;
        out.add(inbox.add(
          kind: MessageKind.email,
          from: 'Recruitment · ${e.name}',
          subject: 'Application closed: ${l.title}',
          body: 'We did not receive the additional information we asked for, so we have closed your application. You are welcome to apply again.',
          day: today,
          minuteOfDay: minuteOfDay,
        ));
      }

      // Missed interview window.
      if (a.status == ApplicationStatus.invited && a.interviewDay != null) {
        final int endMinute = (a.interviewHour ?? 12) * 60 + 90;
        final bool passed = today > a.interviewDay! || (today == a.interviewDay! && minuteOfDay > endMinute);
        if (passed) {
          a.status = ApplicationStatus.expired;
          out.add(inbox.add(
            kind: MessageKind.email,
            from: 'Recruitment · ${e.name}',
            subject: 'Missed interview: ${l.title}',
            body: 'We were expecting you at ${_hourLabel(a.interviewHour ?? 9)} on Day ${a.interviewDay} '
                'but you did not arrive, so we have closed your application. '
                'Punctuality matters — please apply again if you are still interested.',
            day: today,
            minuteOfDay: minuteOfDay,
          ));
        }
      }

      // Waiting-list resolution.
      if (a.status == ApplicationStatus.waitlisted &&
          a.waitlistResolveDay != null &&
          today >= a.waitlistResolveDay!) {
        if (a.waitlistWillOffer) {
          a.status = ApplicationStatus.offer;
          a.offerSalary ??= l.monthlySalary;
          out.add(inbox.add(
            kind: MessageKind.email,
            from: '${e.interviewer.name} · ${e.name}',
            subject: 'Good news — job offer: ${l.title}',
            body: 'A place has opened up and we would like to offer you the ${l.title} role at '
                '${e.name} at \$${a.offerSalary!.round()}/month. Visit reception to review and sign your contract.',
            day: today,
            minuteOfDay: minuteOfDay,
            action: <String, String>{'type': 'offer', 'applicationId': a.id},
          ));
        } else {
          a.status = ApplicationStatus.rejected;
          out.add(inbox.add(
            kind: MessageKind.email,
            from: 'Recruitment · ${e.name}',
            subject: 'Update on your application: ${l.title}',
            body: 'Thank you for your patience. Unfortunately the position has now been filled by another '
                'candidate. We encourage you to apply for future openings.',
            day: today,
            minuteOfDay: minuteOfDay,
          ));
        }
      }
    }
    return out;
  }

  static String _hourLabel(int hour) {
    final int h12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$h12:00 ${hour < 12 ? 'AM' : 'PM'}';
  }
}
