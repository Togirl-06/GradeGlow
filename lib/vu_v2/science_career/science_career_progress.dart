import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'job_catalog.dart';

/// Persistent School of Science career-sim progress.
class ScienceCareerProgress extends ChangeNotifier {
  ScienceCareerProgress();

  static const String _key = 'science_career_progress_v2';
  static ScienceCareerProgress? _instance;
  static ScienceCareerProgress get instance =>
      _instance ??= ScienceCareerProgress();

  bool loaded = false;
  String majorId = 'software_engineering';
  int xp = 0;
  int level = 1;
  int careerStage = 1;
  /// Bank balance in USD cents.
  int balanceCents = 0;
  /// Deprecated legacy field — kept for save compatibility only. Use [balanceCents].
  int credits = 0;
  int streakDays = 1;
  final Set<String> completedChallenges = <String>{};
  final Set<String> badges = <String>{};
  final Set<String> skills = <String>{'Python', 'Arrays', 'Hash maps'};
  final Map<String, int> skillLevels = <String, int>{
    'Debugging': 1,
    'Arrays': 1,
    'Hash maps': 1,
  };
  final Set<String> completedProjects = <String>{};
  final Map<String, Map<String, dynamic>> projectDrafts =
      <String, Map<String, dynamic>>{};
  /// Custom portfolio projects (title, links, tech) — VMock-style résumé builder.
  final List<PortfolioProject> portfolioProjects = <PortfolioProject>[];
  /// Editable résumé profile used by Project Lab résumé builder.
  ResumeProfile resumeProfile = ResumeProfile();
  final List<Map<String, dynamic>> interviewHistory = <Map<String, dynamic>>[];
  bool interviewPassed = false;

  /// jobId → recruiter | oa | technical | offered | hired | rejected
  /// (legacy: applied | interviewed still load)
  final Map<String, String> applicationStatus = <String, String>{};
  final Set<String> appliedJobIds = <String>{};
  final Set<String> employedJobIds = <String>{};
  final Set<String> ticketsCleared = <String>{};

  bool appliedNorthwind = false;
  bool offerReceived = false;
  bool employedAtNorthwind = false;
  String? offerCompanyId;

  /// Time clock
  bool clockedIn = false;
  String? clockInAtIso;
  String? activeEmployerJobId;
  int hourlyWageCents = 2800; // $28/hr junior SE
  int lifetimeEarnedCents = 0;
  final List<Map<String, dynamic>> payStubs = <Map<String, dynamic>>[];
  /// In-game hiring inbox (newest first).
  final List<Map<String, dynamic>> emails = <Map<String, dynamic>>[];

  /// NPC applicants waiting on your hiring desk (status: pending).
  final List<Map<String, dynamic>> pendingApplicants = <Map<String, dynamic>>[];
  /// Teammates you hired from the desk.
  final List<Map<String, dynamic>> hiredTeam = <Map<String, dynamic>>[];
  /// Applicants you rejected (kept for history, capped).
  final List<Map<String, dynamic>> rejectedApplicants =
      <Map<String, dynamic>>[];

  String? dailyMissionDate;
  bool dailyMissionDone = false;

  bool get appliedNovaTech => appliedNorthwind;
  bool get employedAtNovaTech => employedAtNorthwind;
  /// Back-compat alias — earnings are dollars in [balanceCents], not coins.
  int get salaryCoins => balanceCents;

  String get balanceLabel {
    final double d = balanceCents / 100.0;
    return '\$${d.toStringAsFixed(2)}';
  }

  String get lifetimeEarnedLabel {
    final double d = lifetimeEarnedCents / 100.0;
    return '\$${d.toStringAsFixed(2)}';
  }

  String get stageLabel => switch (careerStage) {
        1 => 'Student',
        2 => 'Intern',
        3 => 'Junior employee',
        4 => 'Mid-level',
        5 => 'Senior',
        6 => 'Team lead',
        _ => 'Specialist',
      };

  int get xpIntoLevel => xp % 2000;
  int get xpToNextLevel => 2000;
  double get levelProgress => xpIntoLevel / xpToNextLevel;

  int get arraysCleared => completedChallenges
      .where((String id) => id.contains('two_sum') || id.contains('array'))
      .length
      .clamp(0, 5);

  bool get hasAnyJob => employedJobIds.isNotEmpty || employedAtNorthwind;

  /// True after the first shift / ticket / paycheck — used for Continue vs Start.
  bool get hasStartedWork =>
      clockedIn ||
      lifetimeEarnedCents > 0 ||
      payStubs.isNotEmpty ||
      ticketsCleared.isNotEmpty;

  String jobActionLabel({String? jobId}) {
    if (jobId != null) {
      final String st = statusFor(jobId);
      if (st != 'hired' &&
          !(CareerJobs.isNorthwindJob(jobId) && isEmployedAtNorthwind)) {
        return 'Start job';
      }
    } else if (!hasAnyJob) {
      return 'Start job';
    }
    if (clockedIn) return 'Continue shift';
    if (hasStartedWork) return 'Continue job';
    return 'Start job';
  }

  /// True if hired into any Northwind Labs role (not only northwind_junior).
  bool get isEmployedAtNorthwind {
    if (employedAtNorthwind) return true;
    if (employedJobIds.contains('northwind_junior')) return true;
    if (statusFor('northwind_junior') == 'hired') return true;
    for (final String id in employedJobIds) {
      if (CareerJobs.isNorthwindJob(id)) return true;
    }
    for (final MapEntry<String, String> e in applicationStatus.entries) {
      if (e.value == 'hired' && CareerJobs.isNorthwindJob(e.key)) return true;
    }
    return false;
  }

  void _syncNorthwindEmployment() {
    if (isEmployedAtNorthwind) {
      employedAtNorthwind = true;
      employedJobIds.add('northwind_junior');
      applicationStatus['northwind_junior'] = 'hired';
    }
  }

  Future<void> ensureLoaded() async {
    if (loaded) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? raw = prefs.getString(_key);
    raw ??= prefs.getString('science_career_progress_v1');
    if (raw != null && raw.isNotEmpty) {
      try {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(jsonDecode(raw) as Map);
        majorId = data['majorId'] as String? ?? majorId;
        xp = data['xp'] as int? ?? 0;
        level = data['level'] as int? ?? ((xp ~/ 2000) + 1);
        careerStage = data['careerStage'] as int? ?? 1;
        balanceCents = data['balanceCents'] as int? ?? 0;
        lifetimeEarnedCents = data['lifetimeEarnedCents'] as int? ?? 0;
        final int legacyCredits =
            data['credits'] as int? ?? data['salaryCoins'] as int? ?? 0;
        // Migrate leftover fake credits into the dollar bank once.
        if (balanceCents == 0 && legacyCredits > 0) {
          balanceCents = legacyCredits;
          if (lifetimeEarnedCents < legacyCredits) {
            lifetimeEarnedCents = legacyCredits;
          }
        }
        credits = 0;
        hourlyWageCents = data['hourlyWageCents'] as int? ?? 2800;
        streakDays = data['streakDays'] as int? ?? 1;
        interviewPassed = data['interviewPassed'] as bool? ?? false;
        appliedNorthwind = data['appliedNorthwind'] as bool? ??
            data['appliedNovaTech'] as bool? ??
            false;
        offerReceived = data['offerReceived'] as bool? ?? false;
        employedAtNorthwind = data['employedAtNorthwind'] as bool? ??
            data['employedAtNovaTech'] as bool? ??
            false;
        offerCompanyId = data['offerCompanyId'] as String?;
        clockedIn = data['clockedIn'] as bool? ?? false;
        clockInAtIso = data['clockInAtIso'] as String?;
        activeEmployerJobId = data['activeEmployerJobId'] as String?;
        dailyMissionDate = data['dailyMissionDate'] as String?;
        dailyMissionDone = data['dailyMissionDone'] as bool? ?? false;
        appliedJobIds
          ..clear()
          ..addAll(_stringSet(data['appliedJobIds']));
        if (appliedNorthwind) appliedJobIds.add('northwind_junior');
        employedJobIds
          ..clear()
          ..addAll(_stringSet(data['employedJobIds']));
        if (employedAtNorthwind) employedJobIds.add('northwind_junior');
        applicationStatus
          ..clear()
          ..addAll(_stringMap(data['applicationStatus']));
        for (final String id in appliedJobIds) {
          applicationStatus.putIfAbsent(id, () => 'applied');
        }
        if (offerReceived && !employedAtNorthwind) {
          applicationStatus.putIfAbsent('northwind_junior', () => 'offered');
        }
        if (employedAtNorthwind) {
          applicationStatus['northwind_junior'] = 'hired';
        }
        // Heal: any hired Northwind Labs role counts as employed at Northwind.
        _syncNorthwindEmployment();
        completedChallenges
          ..clear()
          ..addAll(_stringSet(data['completedChallenges']));
        badges
          ..clear()
          ..addAll(_stringSet(data['badges']));
        skills
          ..clear()
          ..addAll(_stringSet(data['skills']));
        if (skills.isEmpty) {
          skills.addAll(<String>['Python', 'Arrays', 'Hash maps']);
        }
        completedProjects
          ..clear()
          ..addAll(_stringSet(data['completedProjects']));
        if (completedProjects.contains('se_auth_notes')) {
          completedProjects.add('se_login_api');
        }
        projectDrafts
          ..clear()
          ..addAll(_draftMap(data['projectDrafts']));
        ticketsCleared
          ..clear()
          ..addAll(_stringSet(data['ticketsCleared']));
        final Object? levels = data['skillLevels'];
        if (levels is Map) {
          skillLevels
            ..clear()
            ..addAll(
              levels.map(
                (Object? k, Object? v) =>
                    MapEntry<String, int>('$k', int.tryParse('$v') ?? 1),
              ),
            );
        }
        interviewHistory
          ..clear()
          ..addAll(
            ((data['interviewHistory'] as List?) ?? <dynamic>[])
                .whereType<Map>()
                .map((Map e) => Map<String, dynamic>.from(e)),
          );
        payStubs
          ..clear()
          ..addAll(
            ((data['payStubs'] as List?) ?? <dynamic>[])
                .whereType<Map>()
                .map((Map e) => Map<String, dynamic>.from(e)),
          );
        emails
          ..clear()
          ..addAll(
            ((data['emails'] as List?) ?? <dynamic>[])
                .whereType<Map>()
                .map((Map e) => Map<String, dynamic>.from(e)),
          );
        pendingApplicants
          ..clear()
          ..addAll(
            ((data['pendingApplicants'] as List?) ?? <dynamic>[])
                .whereType<Map>()
                .map((Map e) => Map<String, dynamic>.from(e)),
          );
        hiredTeam
          ..clear()
          ..addAll(
            ((data['hiredTeam'] as List?) ?? <dynamic>[])
                .whereType<Map>()
                .map((Map e) => Map<String, dynamic>.from(e)),
          );
        rejectedApplicants
          ..clear()
          ..addAll(
            ((data['rejectedApplicants'] as List?) ?? <dynamic>[])
                .whereType<Map>()
                .map((Map e) => Map<String, dynamic>.from(e)),
          );
        uploadedResumeName = data['uploadedResumeName'] as String?;
        uploadedResumeExt = data['uploadedResumeExt'] as String?;
        uploadedResumeBytes = data['uploadedResumeBytes'] as int? ?? 0;
        uploadedResumeText = data['uploadedResumeText'] as String? ?? '';
        resumeProfile = ResumeProfile.fromJson(
          data['resumeProfile'] is Map
              ? Map<String, dynamic>.from(data['resumeProfile'] as Map)
              : null,
        );
        portfolioProjects
          ..clear()
          ..addAll(
            ((data['portfolioProjects'] as List?) ?? <dynamic>[])
                .whereType<Map>()
                .map(
                  (Map e) => PortfolioProject.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                ),
          );
      } catch (e) {
        debugPrint('ScienceCareerProgress load failed: $e');
      }
    }
    _rollDailyIfNeeded();
    loaded = true;
    notifyListeners();
  }

  Set<String> _stringSet(Object? raw) {
    if (raw is! List) return <String>{};
    return raw.map((Object? e) => '$e').toSet();
  }

  Map<String, String> _stringMap(Object? raw) {
    if (raw is! Map) return <String, String>{};
    return raw.map(
      (Object? k, Object? v) => MapEntry<String, String>('$k', '$v'),
    );
  }

  Map<String, Map<String, dynamic>> _draftMap(Object? raw) {
    if (raw is! Map) return <String, Map<String, dynamic>>{};
    return raw.map(
      (Object? k, Object? v) => MapEntry<String, Map<String, dynamic>>(
        '$k',
        v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> projectDraft(String projectId) {
    return Map<String, dynamic>.from(
      projectDrafts[projectId] ??
          <String, dynamic>{
            'stepIndex': 0,
            'answers': <String, dynamic>{},
          },
    );
  }

  Future<void> saveProjectDraft(
    String projectId, {
    required int stepIndex,
    required Map<String, String> answers,
  }) async {
    projectDrafts[projectId] = <String, dynamic>{
      'stepIndex': stepIndex,
      'answers': answers,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await _save();
  }

  bool isProjectComplete(String projectId) {
    if (completedProjects.contains(projectId)) return true;
    if (projectId == 'se_login_api' &&
        completedProjects.contains('se_auth_notes')) {
      return true;
    }
    return false;
  }

  void _rollDailyIfNeeded() {
    final String today = DateTime.now().toIso8601String().substring(0, 10);
    if (dailyMissionDate != today) {
      dailyMissionDate = today;
      dailyMissionDone = false;
    }
  }

  Future<void> _save() async {
    level = (xp ~/ 2000) + 1;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(<String, dynamic>{
        'majorId': majorId,
        'xp': xp,
        'level': level,
        'careerStage': careerStage,
        'credits': credits,
        'balanceCents': balanceCents,
        'lifetimeEarnedCents': lifetimeEarnedCents,
        'hourlyWageCents': hourlyWageCents,
        'streakDays': streakDays,
        'completedChallenges': completedChallenges.toList(),
        'badges': badges.toList(),
        'skills': skills.toList(),
        'skillLevels': skillLevels,
        'completedProjects': completedProjects.toList(),
        'projectDrafts': projectDrafts,
        'interviewHistory': interviewHistory,
        'interviewPassed': interviewPassed,
        'appliedNorthwind': appliedNorthwind,
        'offerReceived': offerReceived,
        'employedAtNorthwind': employedAtNorthwind,
        'offerCompanyId': offerCompanyId,
        'appliedJobIds': appliedJobIds.toList(),
        'employedJobIds': employedJobIds.toList(),
        'applicationStatus': applicationStatus,
        'ticketsCleared': ticketsCleared.toList(),
        'clockedIn': clockedIn,
        'clockInAtIso': clockInAtIso,
        'activeEmployerJobId': activeEmployerJobId,
        'payStubs': payStubs,
        'emails': emails,
        'pendingApplicants': pendingApplicants,
        'hiredTeam': hiredTeam,
        'rejectedApplicants': rejectedApplicants,
        'uploadedResumeName': uploadedResumeName,
        'uploadedResumeExt': uploadedResumeExt,
        'uploadedResumeBytes': uploadedResumeBytes,
        'uploadedResumeText': uploadedResumeText,
        'resumeProfile': resumeProfile.toJson(),
        'portfolioProjects':
            portfolioProjects.map((PortfolioProject p) => p.toJson()).toList(),
        'dailyMissionDate': dailyMissionDate,
        'dailyMissionDone': dailyMissionDone,
      }),
    );
    notifyListeners();
  }

  /// Projects the student added themselves (no in-app grind required).
  bool get hasPortfolioProject => portfolioProjects.isNotEmpty;

  List<String> get _allResumeBullets {
    final List<String> out = <String>[];
    for (final PortfolioProject p in portfolioProjects) {
      out.addAll(p.effectiveBullets);
    }
    if (resumeProfile.experience.trim().isNotEmpty) {
      out.addAll(
        resumeProfile.experience
            .split(RegExp(r'[\n•]+'))
            .map((String s) => s.trim())
            .where((String s) => s.isNotEmpty),
      );
    }
    return out;
  }

  static final RegExp _numberRe = RegExp(r'\d');
  static final RegExp _actionVerbRe = RegExp(
    r'^(built|designed|developed|created|implemented|led|improved|reduced|increased|automated|shipped|wrote|fixed|deployed|optimized|tested|launched|engineered|refactored|migrated|integrated)\b',
    caseSensitive: false,
  );

  int get resumeImpactScore {
    final List<String> bullets = _allResumeBullets;
    if (bullets.isEmpty) return portfolioProjects.isEmpty ? 0 : 30;
    int withMetric = 0;
    for (final String b in bullets) {
      if (_numberRe.hasMatch(b)) withMetric++;
    }
    return ((withMetric / bullets.length) * 100).round().clamp(0, 100);
  }

  int get resumeClarityScore {
    final List<String> bullets = _allResumeBullets;
    if (bullets.isEmpty) return resumeProfile.summary.trim().length >= 40 ? 40 : 15;
    int good = 0;
    for (final String b in bullets) {
      final bool verb = _actionVerbRe.hasMatch(b.trim());
      final int len = b.trim().length;
      if (verb && len >= 28 && len <= 160) {
        good++;
      } else if (verb || (len >= 40 && len <= 140)) {
        good++;
      }
    }
    return ((good / bullets.length) * 100).round().clamp(0, 100);
  }

  int get resumeSkillsMatchScore {
    final ResumeProfile r = resumeProfile;
    final Set<String> mine = <String>{
      ...skills.map((String s) => s.toLowerCase()),
      ...r.extraSkills.map((String s) => s.toLowerCase()),
      for (final PortfolioProject p in portfolioProjects)
        ...p.tech.map((String s) => s.toLowerCase()),
    };
    final List<String> target = r.targetSkills.isNotEmpty
        ? r.targetSkills
        : <String>['Python', 'Debugging', 'Git', 'APIs', 'Testing'];
    if (target.isEmpty) return mine.length >= 4 ? 70 : 35;
    int hits = 0;
    for (final String t in target) {
      final String tl = t.toLowerCase();
      if (mine.any(
        (String m) => m.contains(tl) || tl.contains(m),
      )) {
        hits++;
      }
    }
    return ((hits / target.length) * 100).round().clamp(0, 100);
  }

  /// VMock-style overall 0–100 (weighted Impact / Clarity / Skills + completeness).
  int get resumeBuilderScore {
    final ResumeProfile r = resumeProfile;
    int completeness = 0;
    if (r.fullName.trim().isNotEmpty) completeness += 10;
    if (r.email.trim().isNotEmpty || r.phone.trim().isNotEmpty) completeness += 8;
    if (r.education.trim().isNotEmpty || r.university.trim().isNotEmpty) {
      completeness += 10;
    }
    if (portfolioProjects.isNotEmpty) completeness += 14;
    if (portfolioProjects.length >= 2) completeness += 6;
    if (_allResumeBullets.length >= 3) completeness += 10;
    if (r.targetRole.trim().isNotEmpty) completeness += 6;
    completeness = completeness.clamp(0, 40);

    final int weighted = ((resumeImpactScore * 0.35) +
            (resumeClarityScore * 0.30) +
            (resumeSkillsMatchScore * 0.35))
        .round();
    return ((completeness * 0.45) + (weighted * 0.55)).round().clamp(0, 100);
  }

  List<String> get resumeBuilderTips {
    final List<String> tips = <String>[];
    final ResumeProfile r = resumeProfile;
    if (r.fullName.trim().isEmpty) tips.add('Add your full name');
    if (portfolioProjects.isEmpty) {
      tips.add('Add a project you built (title, bullets, optional link)');
    }
    if (resumeImpactScore < 60) {
      tips.add('Add numbers to bullets (users, tests, %, time saved)');
    }
    if (resumeClarityScore < 60) {
      tips.add('Start bullets with strong action verbs');
    }
    if (r.targetRole.trim().isEmpty) tips.add('Set a target role for scoring');
    if (tips.isEmpty) {
      tips.add('Strong résumé — keep bullets specific and measurable');
    }
    return tips;
  }

  /// VMock-style rewrite suggestions for weak bullets.
  List<ResumeBulletSuggestion> get resumeSuggestions {
    final List<ResumeBulletSuggestion> out = <ResumeBulletSuggestion>[];
    int badge = 1;
    for (final PortfolioProject p in portfolioProjects) {
      final List<String> bullets = p.effectiveBullets;
      for (int i = 0; i < bullets.length; i++) {
        final String now = bullets[i];
        final bool hasVerb = _actionVerbRe.hasMatch(now.trim());
        final bool hasNum = _numberRe.hasMatch(now);
        if (hasVerb && hasNum && now.trim().length >= 28) continue;
        String tryText = now.trim();
        if (!hasVerb) {
          tryText =
              'Built $tryText${hasNum ? '' : ' with measurable results'}';
        } else if (!hasNum) {
          tryText =
              '$tryText, improving reliability across 12 automated checks';
        }
        if (tryText == now.trim()) continue;
        out.add(
          ResumeBulletSuggestion(
            id: '${p.id}_$i',
            badge: badge++,
            projectId: p.id,
            bulletIndex: i,
            reason: !hasVerb
                ? 'Start with a strong action verb'
                : 'Add a number or result',
            nowText: now,
            tryText: tryText,
          ),
        );
        if (out.length >= 4) return out;
      }
    }
    return out;
  }

  int get strongBulletCount {
    int n = 0;
    for (final String b in _allResumeBullets) {
      if (_actionVerbRe.hasMatch(b.trim()) && _numberRe.hasMatch(b)) n++;
    }
    return n;
  }

  Future<void> applyBulletSuggestion(ResumeBulletSuggestion s) async {
    final int pi =
        portfolioProjects.indexWhere((PortfolioProject p) => p.id == s.projectId);
    if (pi < 0) return;
    final PortfolioProject p = portfolioProjects[pi];
    final List<String> bullets = List<String>.from(p.effectiveBullets);
    if (s.bulletIndex < 0 || s.bulletIndex >= bullets.length) return;
    bullets[s.bulletIndex] = s.tryText;
    portfolioProjects[pi] = p.copyWith(
      bullets: bullets,
      description: bullets.join('\n'),
    );
    await _save();
  }

  Future<void> saveResumeProfile(ResumeProfile profile) async {
    resumeProfile = profile;
    for (final String s in profile.extraSkills) {
      final String t = s.trim();
      if (t.isNotEmpty) skills.add(t);
    }
    await _save();
  }

  Future<void> upsertPortfolioProject(PortfolioProject project) async {
    final int i =
        portfolioProjects.indexWhere((PortfolioProject p) => p.id == project.id);
    if (i >= 0) {
      portfolioProjects[i] = project;
    } else {
      portfolioProjects.insert(0, project);
    }
    for (final String s in project.tech) {
      final String t = s.trim();
      if (t.isNotEmpty) skills.add(t);
    }
    await awardXp(i >= 0 ? 15 : 40, badge: 'portfolio_${project.id}');
  }

  Future<void> removePortfolioProject(String id) async {
    portfolioProjects.removeWhere((PortfolioProject p) => p.id == id);
    await _save();
  }

  int get unreadEmailCount =>
      emails.where((Map<String, dynamic> e) => e['read'] != true).length;

  Future<void> markEmailRead(String emailId) async {
    for (final Map<String, dynamic> e in emails) {
      if (e['id'] == emailId) {
        e['read'] = true;
        break;
      }
    }
    await _save();
  }

  /// Last uploaded résumé file (pdf/docx) metadata — not raw bytes (too large).
  String? uploadedResumeName;
  String? uploadedResumeExt;
  int uploadedResumeBytes = 0;
  String uploadedResumeText = '';

  Map<String, dynamic> buildResumeSnapshot({
    String? coverNote,
    UploadedResumeFile? uploaded,
  }) {
    return <String, dynamic>{
      'skills': skills.toList(),
      'challenges': completedChallenges.length,
      'projects': completedProjects.toList(),
      'portfolioProjects':
          portfolioProjects.map((PortfolioProject p) => p.toJson()).toList(),
      'resumeProfile': resumeProfile.toJson(),
      'resumeScore': resumeBuilderScore,
      'interviews': interviewHistory.length,
      'level': level,
      'stage': stageLabel,
      'coverNote': coverNote ?? '',
      'generatedAt': DateTime.now().toIso8601String(),
      if (uploaded != null) ...<String, dynamic>{
        'uploadedFileName': uploaded.fileName,
        'uploadedExt': uploaded.extension,
        'uploadedBytes': uploaded.sizeBytes,
        'uploadedTextChars': uploaded.extractedText.length,
      } else if (uploadedResumeName != null) ...<String, dynamic>{
        'uploadedFileName': uploadedResumeName,
        'uploadedExt': uploadedResumeExt,
        'uploadedBytes': uploadedResumeBytes,
      },
    };
  }

  Future<void> saveUploadedResume(UploadedResumeFile file) async {
    uploadedResumeName = file.fileName;
    uploadedResumeExt = file.extension;
    uploadedResumeBytes = file.sizeBytes;
    uploadedResumeText = file.extractedText.length > 4000
        ? file.extractedText.substring(0, 4000)
        : file.extractedText;
    await _save();
  }

  /// Hire from the résumé they built/uploaded — not from in-app grind.
  bool evaluateResumeHire({
    required List<String> preferredSkills,
    UploadedResumeFile? uploaded,
  }) {
    // Sync target skills from the role they are applying to.
    if (preferredSkills.isNotEmpty && resumeProfile.targetSkills.isEmpty) {
      resumeProfile.targetSkills = List<String>.from(preferredSkills);
    }

    final String profileHay =
        '${resumeProfile.headline} ${resumeProfile.summary} '
        '${resumeProfile.experience} ${resumeProfile.targetRole} '
        '${portfolioProjects.map((PortfolioProject p) => '${p.title} ${p.description} ${p.effectiveBullets.join(' ')} ${p.tech.join(' ')}').join(' ')}';

    final String hay =
        '${uploaded?.extractedText ?? uploadedResumeText} ${skills.join(' ')} $profileHay'
            .toLowerCase();

    int skillHits = 0;
    for (final String s in preferredSkills) {
      if (hay.contains(s.toLowerCase())) skillHits++;
    }
    final bool hasFile = (uploaded?.sizeBytes ?? uploadedResumeBytes) >= 800;
    final bool builtResume =
        hasPortfolioProject && resumeBuilderScore >= 55;
    if (builtResume && (skillHits >= 1 || preferredSkills.isEmpty)) return true;
    if (builtResume && resumeBuilderScore >= 70) return true;
    if (hasFile && skillHits >= 2) return true;
    if (hasFile && hasPortfolioProject && skillHits >= 1) return true;
    if (resumeBuilderScore >= 75 && hasPortfolioProject) return true;
    return false;
  }

  Future<void> setMajor(String id) async {
    majorId = id;
    await _save();
  }

  Future<void> awardXp(
    int amount, {
    String? badge,
    int payCents = 0,
    @Deprecated('Use payCents') int creditsGain = 0,
  }) async {
    xp = (xp + amount).clamp(0, 1000000);
    final int dollars = payCents > 0 ? payCents : creditsGain;
    if (dollars > 0) {
      balanceCents += dollars;
      lifetimeEarnedCents += dollars;
    }
    if (badge != null) badges.add(badge);
    await _save();
  }

  Future<void> completeChallenge(String id, {int xpGain = 40}) async {
    if (!completedChallenges.add(id)) return;
    skills.addAll(<String>['Python', 'Arrays', 'Hash maps']);
    skillLevels['Arrays'] = (skillLevels['Arrays'] ?? 1) + 1;
    skillLevels['Hash maps'] = (skillLevels['Hash maps'] ?? 1) + 1;
    if (!dailyMissionDone) {
      dailyMissionDone = true;
      xpGain += 60;
    }
    if (careerStage < 2) careerStage = 2;
    await awardXp(xpGain, badge: 'coder_$id', payCents: 250); // $2.50
  }

  Future<void> completeProject(
    String id, {
    int xpGain = 100,
    String? resumeSkill,
  }) async {
    if (!completedProjects.add(id)) return;
    projectDrafts.remove(id);
    if (resumeSkill != null) skills.add(resumeSkill);
    await awardXp(xpGain, badge: 'project_$id', payCents: 800); // $8.00
  }

  Future<void> bumpSkill(String skill, {int by = 1}) async {
    skillLevels[skill] = (skillLevels[skill] ?? 1) + by;
    skills.add(skill);
    await _save();
  }

  /// Ready when they built a résumé with projects (no Coding Arena required).
  bool get resumeReadyToApply =>
      hasPortfolioProject && resumeBuilderScore >= 40;

  bool get meetsSoftApplyGate => resumeReadyToApply;
  bool canApplyNorthwind() => resumeReadyToApply;

  int get resumeRequirementsRemaining {
    int n = 0;
    if (!hasPortfolioProject) n++;
    if (resumeBuilderScore < 40) n++;
    return n;
  }

  String statusFor(String jobId) {
    final String raw = applicationStatus[jobId] ??
        (appliedJobIds.contains(jobId) ? 'applied' : 'none');
    // Normalize legacy statuses into the interview pipeline.
    if (raw == 'applied' || raw == 'interviewed') return 'recruiter';
    return raw;
  }

  bool get isInHiringPipeline {
    for (final String id in appliedJobIds) {
      final String s = statusFor(id);
      if (s == 'recruiter' || s == 'oa' || s == 'technical' || s == 'offered') {
        return true;
      }
    }
    return false;
  }

  static const List<String> pipelineOrder = <String>[
    'recruiter',
    'oa',
    'technical',
    'offered',
    'hired',
  ];

  static String pipelineLabel(String status) => switch (status) {
        'recruiter' => 'Recruiter call',
        'oa' => 'Online assessment',
        'technical' => 'Technical interview',
        'offered' => 'Offer',
        'hired' => 'Hired',
        'rejected' => 'Rejected',
        _ => status,
      };

  Future<void> applyNorthwind() async {
    await applyToJobId('northwind_junior', company: 'Northwind Labs');
  }

  Future<bool> applyToJobId(String jobId, {required String company}) async {
    final ApplyResult? r = await submitResumeApplication(
      jobId: jobId,
      company: company,
      roleTitle: 'Role',
      preferredSkills: const <String>[],
    );
    return r != null;
  }

  /// Apply Now: résumé screen → recruiter call (not an instant offer).
  Future<ApplyResult?> submitResumeApplication({
    required String jobId,
    required String company,
    required String roleTitle,
    required List<String> preferredSkills,
    String? coverNote,
    String? fromName,
    UploadedResumeFile? uploaded,
  }) async {
    final String status = statusFor(jobId);
    if (status == 'hired' ||
        status == 'offered' ||
        status == 'recruiter' ||
        status == 'oa' ||
        status == 'technical') {
      return null;
    }
    // rejected → allowed to reapply
    if (uploaded == null &&
        (uploadedResumeName == null || uploadedResumeName!.isEmpty)) {
      return null;
    }

    if (uploaded != null) {
      await saveUploadedResume(uploaded);
    }

    appliedJobIds.add(jobId);
    if (company == 'Northwind Labs' || jobId == 'northwind_junior') {
      appliedNorthwind = true;
    }

    final Map<String, dynamic> resume = buildResumeSnapshot(
      coverNote: coverNote,
      uploaded: uploaded,
    );
    final bool screenPass = evaluateResumeHire(
      preferredSkills: preferredSkills,
      uploaded: uploaded,
    );
    final String emailId =
        'mail_${DateTime.now().millisecondsSinceEpoch}_$jobId';
    final String recruiter = fromName ?? 'Maya Okafor';
    final String fromEmail =
        '${recruiter.toLowerCase().replaceAll(' ', '.')}@${_emailDomain(company)}';

    if (screenPass) {
      applicationStatus[jobId] = 'recruiter';
      emails.insert(0, <String, dynamic>{
        'id': emailId,
        'jobId': jobId,
        'company': company,
        'from': '$recruiter <$fromEmail>',
        'to': 'you@gradeglow.edu',
        'subject': 'Next step: Recruiter call — $roleTitle',
        'body': _pipelineInviteEmailBody(
          company: company,
          role: roleTitle,
          recruiter: recruiter,
        ),
        'kind': 'pipeline',
        'stage': 'recruiter',
        'read': false,
        'at': DateTime.now().toIso8601String(),
        'resume': resume,
      });
      await awardXp(25, badge: 'screen_$jobId');
      return ApplyResult(
        advanced: true,
        emailId: emailId,
        stage: 'recruiter',
      );
    }

    applicationStatus[jobId] = 'rejected';
    emails.insert(0, <String, dynamic>{
      'id': emailId,
      'jobId': jobId,
      'company': company,
      'from': '$recruiter <$fromEmail>',
      'to': 'you@gradeglow.edu',
      'subject': 'Update on your $roleTitle application',
      'body': _rejectEmailBody(
        company: company,
        role: roleTitle,
        recruiter: recruiter,
      ),
      'kind': 'reject',
      'read': false,
      'at': DateTime.now().toIso8601String(),
      'resume': resume,
    });
    await awardXp(5, badge: 'applied_$jobId');
    return ApplyResult(advanced: false, emailId: emailId, stage: 'rejected');
  }

  /// Finish a pipeline stage. Pass → next stage (or offer after technical).
  Future<bool> completePipelineStage({
    required String jobId,
    required String company,
    required String roleTitle,
    required String stage,
    required bool passed,
    String recruiterName = 'Maya Okafor',
    int? payCentsHour,
  }) async {
    if (statusFor(jobId) != stage) return false;
    if (!passed) {
      applicationStatus[jobId] = 'rejected';
      emails.insert(0, <String, dynamic>{
        'id': 'mail_${DateTime.now().millisecondsSinceEpoch}_$jobId',
        'jobId': jobId,
        'company': company,
        'from': '$recruiterName <talent@${_emailDomain(company)}>',
        'to': 'you@gradeglow.edu',
        'subject': 'Update after ${pipelineLabel(stage)}',
        'body':
            'Thank you for completing the ${pipelineLabel(stage).toLowerCase()} '
            'for $roleTitle. We are not moving forward at this time.\n\n'
            'You may strengthen your résumé and Apply Now again later.\n\n'
            'Regards,\n$recruiterName\nTalent · $company',
        'kind': 'reject',
        'read': false,
        'at': DateTime.now().toIso8601String(),
      });
      await awardXp(10, badge: 'fail_${stage}_$jobId');
      return false;
    }

    final String next = switch (stage) {
      'recruiter' => 'oa',
      'oa' => 'technical',
      'technical' => 'offered',
      _ => stage,
    };
    applicationStatus[jobId] = next;

    if (next == 'offered') {
      if (CareerJobs.isNorthwindJob(jobId) || company == 'Northwind Labs') {
        offerReceived = true;
        offerCompanyId = 'northwind';
      }
      final int wage = payCentsHour ??
          _wageFromPayLabel(CareerJobs.byId(jobId)?.payLabel) ??
          (CareerJobs.isNorthwindJob(jobId) || company == 'Northwind Labs'
              ? 2800
              : 2400);
      emails.insert(0, <String, dynamic>{
        'id': 'mail_${DateTime.now().millisecondsSinceEpoch}_$jobId',
        'jobId': jobId,
        'company': company,
        'from': '$recruiterName <talent@${_emailDomain(company)}>',
        'to': 'you@gradeglow.edu',
        'subject': 'Offer: $roleTitle at $company',
        'body': _offerEmailBody(
          company: company,
          role: roleTitle,
          recruiter: recruiterName,
          wageLabel: '\$${(wage / 100).toStringAsFixed(2)} / hour',
        ),
        'kind': 'offer',
        'read': false,
        'at': DateTime.now().toIso8601String(),
        'wageCents': wage,
      });
      await awardXp(100, badge: 'offer_$jobId');
      return true;
    }

    emails.insert(0, <String, dynamic>{
      'id': 'mail_${DateTime.now().millisecondsSinceEpoch}_$jobId',
      'jobId': jobId,
      'company': company,
      'from': '$recruiterName <talent@${_emailDomain(company)}>',
      'to': 'you@gradeglow.edu',
      'subject': 'Next step: ${pipelineLabel(next)} — $roleTitle',
      'body': _nextStageEmailBody(
        company: company,
        role: roleTitle,
        recruiter: recruiterName,
        nextStage: next,
      ),
      'kind': 'pipeline',
      'stage': next,
      'read': false,
      'at': DateTime.now().toIso8601String(),
    });
    await awardXp(
      stage == 'recruiter' ? 30 : 50,
      badge: 'pass_${stage}_$jobId',
    );
    return true;
  }

  Future<bool> declineOffer({
    required String jobId,
    required String company,
    required String roleTitle,
  }) async {
    if (statusFor(jobId) != 'offered') return false;
    applicationStatus[jobId] = 'rejected';
    if (offerCompanyId == 'northwind' && CareerJobs.isNorthwindJob(jobId)) {
      offerReceived = false;
    }
    emails.insert(0, <String, dynamic>{
      'id': 'mail_${DateTime.now().millisecondsSinceEpoch}_$jobId',
      'jobId': jobId,
      'company': company,
      'from': 'you@gradeglow.edu',
      'to': 'talent@${_emailDomain(company)}',
      'subject': 'Declined offer — $roleTitle',
      'body':
          'You declined the $roleTitle offer at $company. '
          'You can Apply Now to other roles anytime.',
      'kind': 'decline',
      'read': true,
      'at': DateTime.now().toIso8601String(),
    });
    await _save();
    return true;
  }

  String _emailDomain(String company) {
    final String slug = company
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '')
        .replaceAll(' ', '');
    return '$slug.com';
  }

  String _pipelineInviteEmailBody({
    required String company,
    required String role,
    required String recruiter,
  }) {
    return '''Hi,

Thanks for applying to $role at $company. Your résumé passed our screen.

Interview loop (complete these in Career Center):
1. Recruiter call (15–30 min) — background, why this role, logistics
2. Online assessment (45–90 min) — timed algorithm problems
3. Technical interview (45–60 min) — live coding with an engineer

After all three, we may send a written offer with compensation details.

Open Career Center → Start recruiter call when you are ready.

Best,
$recruiter
Talent · $company
''';
  }

  String _nextStageEmailBody({
    required String company,
    required String role,
    required String recruiter,
    required String nextStage,
  }) {
    final String detail = switch (nextStage) {
      'oa' =>
        'Online assessment (45–90 min): timed algorithm problems (arrays, strings, hash maps), usually 1–3 questions.',
      'technical' =>
        'Technical interview (45–60 min): live coding with an engineer. Juniors may also get a debugging task.',
      _ => pipelineLabel(nextStage),
    };
    return '''Hi,

You passed the previous step for $role at $company.

Next: $detail

Continue from Career Center when ready.

Best,
$recruiter
Talent · $company
''';
  }

  String _offerEmailBody({
    required String company,
    required String role,
    required String recruiter,
    String wageLabel = '\$28.00 / hour',
  }) {
    return '''Hi,

Congratulations — you completed the interview loop for $role at $company.

Offer details:
• Role: $role
• Compensation: $wageLabel (paid when you clock out of a shift)
• Start: accept in Career Center, then Start job

You may Accept or Decline this offer in Career Center.

We're excited to have you on the team.

Best,
$recruiter
Talent · $company
''';
  }

  String _rejectEmailBody({
    required String company,
    required String role,
    required String recruiter,
  }) {
    return '''Hi,

Thank you for submitting your résumé for $role at $company.

After reviewing your application, we are not moving forward at this time.

Regards,
$recruiter
Talent · $company
''';
  }

  /// Practice interviews in Interview Center (does not skip the hiring loop).
  Future<void> recordInterview({
    required bool passed,
    required Map<String, int> scores,
    required String feedback,
    String? scenarioId,
    String? forJobId,
  }) async {
    interviewPassed = passed || interviewPassed;
    interviewHistory.insert(0, <String, dynamic>{
      'at': DateTime.now().toIso8601String(),
      'passed': passed,
      'scores': scores,
      'feedback': feedback,
      if (scenarioId != null) 'scenarioId': scenarioId,
      if (forJobId != null) 'forJobId': forJobId,
    });
    if (passed) {
      skillLevels['Debugging'] = (skillLevels['Debugging'] ?? 1) + 1;
      skills.add('Debugging');
      if (careerStage < 2) careerStage = 2;
      await awardXp(
        40,
        badge: scenarioId == null ? 'interview_pass' : 'interview_$scenarioId',
      );
    } else {
      await _save();
    }
  }

  /// Accept an offer. Returns false if there was nothing to accept.
  Future<bool> acceptOffer({
    String jobId = 'northwind_junior',
    String? company,
  }) async {
    String resolvedId = jobId;
    String status = statusFor(resolvedId);

    // Already hired — treat as success and heal Northwind flags.
    if (status == 'hired' ||
        employedJobIds.contains(resolvedId) ||
        (CareerJobs.isNorthwindJob(resolvedId) && employedAtNorthwind)) {
      _markHired(resolvedId, company: company);
      await _save();
      return true;
    }

    // Resolve offered Northwind role if caller used a stale/wrong id.
    if (status != 'offered') {
      final bool northwindContext = offerReceived ||
          (company ?? CareerJobs.byId(resolvedId)?.company) ==
              'Northwind Labs';
      if (northwindContext) {
        String? offeredNorthwind;
        for (final MapEntry<String, String> e in applicationStatus.entries) {
          if (e.value == 'offered' && CareerJobs.isNorthwindJob(e.key)) {
            offeredNorthwind = e.key;
            break;
          }
        }
        if (offeredNorthwind != null) {
          resolvedId = offeredNorthwind;
          status = 'offered';
        } else if (offerReceived) {
          resolvedId = 'northwind_junior';
          status = statusFor(resolvedId);
          if (status != 'offered' && status != 'hired') {
            applicationStatus[resolvedId] = 'offered';
            status = 'offered';
          }
        }
      }
    }

    if (status != 'offered' && !offerReceived) return false;

    _markHired(resolvedId, company: company);
    careerStage = 3;
    await awardXp(120, badge: 'hired_$resolvedId');
    await ensureHiringDeskSeeded(count: 3);
    return true;
  }

  void _markHired(String jobId, {String? company}) {
    applicationStatus[jobId] = 'hired';
    employedJobIds.add(jobId);
    final String co =
        company ?? CareerJobs.byId(jobId)?.company ?? '';
    if (CareerJobs.isNorthwindJob(jobId) || co == 'Northwind Labs') {
      employedAtNorthwind = true;
      offerCompanyId = 'northwind';
      offerReceived = true;
      employedJobIds.add('northwind_junior');
      applicationStatus['northwind_junior'] = 'hired';
      if (hourlyWageCents < 2800) hourlyWageCents = 2800;
    } else {
      final int? fromOffer = _wageFromOfferEmail(jobId);
      final int? fromListing = _wageFromPayLabel(CareerJobs.byId(jobId)?.payLabel);
      final int wage = fromOffer ?? fromListing ?? 2400;
      if (wage > hourlyWageCents) hourlyWageCents = wage;
    }
  }

  int? _wageFromOfferEmail(String jobId) {
    for (final Map<String, dynamic> e in emails) {
      if (e['jobId'] == jobId && e['kind'] == 'offer') {
        final Object? w = e['wageCents'];
        if (w is int && w > 0) return w;
        if (w is num && w > 0) return w.round();
      }
    }
    return null;
  }

  /// Parse mid-range hourly cents from labels like "$22.00 – $28.00 / hour".
  static int? _wageFromPayLabel(String? label) {
    if (label == null || label.isEmpty) return null;
    final RegExp money = RegExp(r'\$(\d+(?:\.\d+)?)');
    final List<double> vals = money
        .allMatches(label)
        .map((RegExpMatch m) => double.tryParse(m.group(1) ?? '') ?? 0)
        .where((double v) => v > 0)
        .toList();
    if (vals.isEmpty) return null;
    final double mid =
        vals.length == 1 ? vals.first : (vals.first + vals.last) / 2;
    return (mid * 100).round();
  }

  Future<bool> clockIn({String jobId = 'northwind_junior'}) async {
    if (!isEmployedAtNorthwind &&
        !employedJobIds.contains(jobId) &&
        !employedAtNorthwind) {
      return false;
    }
    if (clockedIn) return false;
    clockedIn = true;
    clockInAtIso = DateTime.now().toIso8601String();
    activeEmployerJobId = jobId;
    await _save();
    return true;
  }

  /// Clock out and pay for elapsed time (min 15 minutes credited for playability).
  Future<int> clockOut() async {
    if (!clockedIn || clockInAtIso == null) return 0;
    final DateTime start = DateTime.tryParse(clockInAtIso!) ?? DateTime.now();
    final Duration raw = DateTime.now().difference(start);
    // Credit at least 0.25h so a short session still pays; cap at 8h per shift.
    double hours = raw.inSeconds / 3600.0;
    if (hours < 0.25) hours = 0.25;
    if (hours > 8) hours = 8;
    final int earned = (hours * hourlyWageCents).round();
    balanceCents += earned;
    lifetimeEarnedCents += earned;
    payStubs.insert(0, <String, dynamic>{
      'at': DateTime.now().toIso8601String(),
      'hours': double.parse(hours.toStringAsFixed(2)),
      'rateCents': hourlyWageCents,
      'earnedCents': earned,
      'jobId': activeEmployerJobId ?? 'northwind_junior',
    });
    if (payStubs.length > 40) {
      payStubs.removeRange(40, payStubs.length);
    }
    clockedIn = false;
    clockInAtIso = null;
    activeEmployerJobId = null;
    await _save();
    return earned;
  }

  Duration? get currentShiftElapsed {
    if (!clockedIn || clockInAtIso == null) return null;
    final DateTime start = DateTime.tryParse(clockInAtIso!) ?? DateTime.now();
    return DateTime.now().difference(start);
  }

  Future<void> clearTicket(String id, {int xpGain = 120, int pay = 0}) async {
    if (!clockedIn) return;
    if (!ticketsCleared.add(id)) return;
    skillLevels['Debugging'] = (skillLevels['Debugging'] ?? 1) + 1;
    // Task bonus in dollars (cents), not fake credits-as-salary.
    if (pay > 0) {
      balanceCents += pay;
      lifetimeEarnedCents += pay;
    }
    await awardXp(xpGain, badge: 'ticket_$id');
  }

  // ── Hiring desk (hire / reject NPC applicants) ───────────────────────────

  static const List<Map<String, String>> _applicantPool =
      <Map<String, String>>[
    <String, String>{
      'name': 'Aisha Rahman',
      'role': 'Junior Software Engineer',
      'blurb':
          'CS junior · strong Python and APIs · shipped a campus portal club project.',
      'skills': 'Python, Flask, Git',
    },
    <String, String>{
      'name': 'Marcus Chen',
      'role': 'Frontend Intern',
      'blurb':
          'Self-taught React · three freelance landing pages · hungry to learn.',
      'skills': 'React, CSS, TypeScript',
    },
    <String, String>{
      'name': 'Priya Nair',
      'role': 'Junior Data Analyst',
      'blurb':
          'Stats major · SQL + pandas · cleaned messy survey data for a nonprofit.',
      'skills': 'SQL, Pandas, Excel',
    },
    <String, String>{
      'name': 'Diego Alvarez',
      'role': 'QA Intern',
      'blurb':
          'Detail-obsessed · wrote bug reports for an open-source mobile app.',
      'skills': 'Testing, Selenium, Jira',
    },
    <String, String>{
      'name': 'Hannah Kim',
      'role': 'Junior Mobile Engineer',
      'blurb':
          'Flutter hobbyist · published a habit tracker on the Play Store.',
      'skills': 'Flutter, Dart, Firebase',
    },
    <String, String>{
      'name': 'Omar Hassan',
      'role': 'DevOps Intern',
      'blurb':
          'Homelab tinkerer · Docker Compose for campus hackathon backends.',
      'skills': 'Docker, Linux, CI/CD',
    },
    <String, String>{
      'name': 'Sofia Petrova',
      'role': 'Junior Backend Engineer',
      'blurb':
          'Java + Spring coursework · built a bookstore REST API with JWT auth.',
      'skills': 'Java, Spring, SQL',
    },
    <String, String>{
      'name': 'Jayden Brooks',
      'role': 'Security Analyst Intern',
      'blurb':
          'CompTIA Security+ studying · ran phishing drills for a student org.',
      'skills': 'Networking, OWASP, Python',
    },
    <String, String>{
      'name': 'Elena Vargas',
      'role': 'Junior UX Engineer',
      'blurb':
          'Design + code · Figma prototypes wired into React for a clinic app.',
      'skills': 'Figma, React, Accessibility',
    },
    <String, String>{
      'name': 'Noah Patel',
      'role': 'ML Intern',
      'blurb':
          'Kaggle bronze · fine-tuned a small classifier for campus event tags.',
      'skills': 'Python, sklearn, PyTorch',
    },
  ];

  /// Seed a few random applicants if the desk is empty (once employed).
  Future<void> ensureHiringDeskSeeded({int count = 3}) async {
    if (!hasAnyJob) return;
    if (pendingApplicants.isNotEmpty) return;
    await spawnRandomApplicants(count: count);
  }

  Future<List<Map<String, dynamic>>> spawnRandomApplicants({
    int count = 1,
  }) async {
    if (!hasAnyJob) return <Map<String, dynamic>>[];
    final Set<String> taken = <String>{
      ...pendingApplicants.map((Map<String, dynamic> a) => '${a['name']}'),
      ...hiredTeam.map((Map<String, dynamic> a) => '${a['name']}'),
    };
    final List<Map<String, String>> pool = List<Map<String, String>>.from(
      _applicantPool,
    )..shuffle();
    final List<Map<String, dynamic>> added = <Map<String, dynamic>>[];
    for (final Map<String, String> seed in pool) {
      if (added.length >= count) break;
      if (taken.contains(seed['name'])) continue;
      final Map<String, dynamic> row = <String, dynamic>{
        'id': 'app_${DateTime.now().millisecondsSinceEpoch}_${seed['name']}'
            .replaceAll(' ', '_')
            .toLowerCase(),
        'name': seed['name'],
        'role': seed['role'],
        'blurb': seed['blurb'],
        'skills': seed['skills'],
        'status': 'pending',
        'appliedAt': DateTime.now().toIso8601String(),
      };
      pendingApplicants.insert(0, row);
      added.add(row);
      taken.add(seed['name']!);
    }
    if (added.isNotEmpty) await _save();
    return added;
  }

  Future<bool> hireApplicant(String id) async {
    final int i = pendingApplicants.indexWhere(
      (Map<String, dynamic> a) => a['id'] == id,
    );
    if (i < 0) return false;
    final Map<String, dynamic> person =
        Map<String, dynamic>.from(pendingApplicants.removeAt(i));
    person['status'] = 'hired';
    person['hiredAt'] = DateTime.now().toIso8601String();
    hiredTeam.insert(0, person);
    if (hiredTeam.length >= 2 && careerStage < 4) careerStage = 4;
    if (hiredTeam.length >= 4 && careerStage < 5) careerStage = 5;
    if (hiredTeam.length >= 6 && careerStage < 6) careerStage = 6;
    await awardXp(40, badge: 'hired_teammate_$id');
    return true;
  }

  /// Hire one random pending applicant. Returns their name, or null.
  Future<String?> hireRandomApplicant() async {
    if (pendingApplicants.isEmpty) {
      await spawnRandomApplicants(count: 2);
    }
    if (pendingApplicants.isEmpty) return null;
    final List<Map<String, dynamic>> copy =
        List<Map<String, dynamic>>.from(pendingApplicants)..shuffle();
    final String id = '${copy.first['id']}';
    final String name = '${copy.first['name']}';
    final bool ok = await hireApplicant(id);
    return ok ? name : null;
  }

  Future<bool> rejectApplicant(String id) async {
    final int i = pendingApplicants.indexWhere(
      (Map<String, dynamic> a) => a['id'] == id,
    );
    if (i < 0) return false;
    final Map<String, dynamic> person =
        Map<String, dynamic>.from(pendingApplicants.removeAt(i));
    person['status'] = 'rejected';
    person['rejectedAt'] = DateTime.now().toIso8601String();
    rejectedApplicants.insert(0, person);
    if (rejectedApplicants.length > 30) {
      rejectedApplicants.removeRange(30, rejectedApplicants.length);
    }
    await awardXp(10, badge: 'reject_teammate_$id');
    return true;
  }
}

class ApplyResult {
  const ApplyResult({
    required this.advanced,
    required this.emailId,
    this.stage = '',
  });

  /// True if résumé screen passed and pipeline started (not an offer yet).
  final bool advanced;
  final String emailId;
  final String stage;

  /// Back-compat for older call sites.
  bool get hired => advanced && stage == 'offered';
}

class UploadedResumeFile {
  const UploadedResumeFile({
    required this.fileName,
    required this.extension,
    required this.sizeBytes,
    this.extractedText = '',
  });

  final String fileName;
  final String extension;
  final int sizeBytes;
  final String extractedText;
}

class ResumeProfile {
  ResumeProfile({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.githubUrl = '',
    this.headline = '',
    this.summary = '',
    this.education = '',
    this.university = '',
    this.degree = '',
    this.gradYear = '',
    this.coursework = '',
    this.experience = '',
    this.targetRole = '',
    this.targetCompany = '',
    List<String>? extraSkills,
    List<String>? targetSkills,
  })  : extraSkills = extraSkills ?? <String>[],
        targetSkills = targetSkills ?? <String>[];

  String fullName;
  String email;
  String phone;
  String location;
  String githubUrl;
  String headline;
  String summary;
  String education;
  String university;
  String degree;
  String gradYear;
  String coursework;
  String experience;
  String targetRole;
  String targetCompany;
  List<String> extraSkills;
  List<String> targetSkills;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'location': location,
        'githubUrl': githubUrl,
        'headline': headline,
        'summary': summary,
        'education': education,
        'university': university,
        'degree': degree,
        'gradYear': gradYear,
        'coursework': coursework,
        'experience': experience,
        'targetRole': targetRole,
        'targetCompany': targetCompany,
        'extraSkills': extraSkills,
        'targetSkills': targetSkills,
      };

  static ResumeProfile fromJson(Map<String, dynamic>? json) {
    if (json == null) return ResumeProfile();
    return ResumeProfile(
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      location: json['location'] as String? ?? '',
      githubUrl: json['githubUrl'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      education: json['education'] as String? ?? '',
      university: json['university'] as String? ?? '',
      degree: json['degree'] as String? ?? '',
      gradYear: json['gradYear'] as String? ?? '',
      coursework: json['coursework'] as String? ?? '',
      experience: json['experience'] as String? ?? '',
      targetRole: json['targetRole'] as String? ?? '',
      targetCompany: json['targetCompany'] as String? ?? '',
      extraSkills: ((json['extraSkills'] as List?) ?? <dynamic>[])
          .map((Object? e) => '$e')
          .toList(),
      targetSkills: ((json['targetSkills'] as List?) ?? <dynamic>[])
          .map((Object? e) => '$e')
          .toList(),
    );
  }

  ResumeProfile copy() => ResumeProfile(
        fullName: fullName,
        email: email,
        phone: phone,
        location: location,
        githubUrl: githubUrl,
        headline: headline,
        summary: summary,
        education: education,
        university: university,
        degree: degree,
        gradYear: gradYear,
        coursework: coursework,
        experience: experience,
        targetRole: targetRole,
        targetCompany: targetCompany,
        extraSkills: List<String>.from(extraSkills),
        targetSkills: List<String>.from(targetSkills),
      );
}

class PortfolioProject {
  const PortfolioProject({
    required this.id,
    required this.title,
    required this.description,
    this.bullets = const <String>[],
    this.tech = const <String>[],
    this.githubUrl = '',
    this.liveUrl = '',
    this.createdAt = '',
  });

  final String id;
  final String title;
  final String description;
  final List<String> bullets;
  final List<String> tech;
  final String githubUrl;
  final String liveUrl;
  final String createdAt;

  List<String> get effectiveBullets {
    if (bullets.isNotEmpty) {
      return bullets
          .map((String s) => s.trim())
          .where((String s) => s.isNotEmpty)
          .toList();
    }
    if (description.trim().isEmpty) return const <String>[];
    return description
        .split(RegExp(r'[\n•]+'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();
  }

  PortfolioProject copyWith({
    String? title,
    String? description,
    List<String>? bullets,
    List<String>? tech,
    String? githubUrl,
    String? liveUrl,
  }) {
    return PortfolioProject(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      bullets: bullets ?? this.bullets,
      tech: tech ?? this.tech,
      githubUrl: githubUrl ?? this.githubUrl,
      liveUrl: liveUrl ?? this.liveUrl,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'description': description,
        'bullets': bullets,
        'tech': tech,
        'githubUrl': githubUrl,
        'liveUrl': liveUrl,
        'createdAt': createdAt,
      };

  static PortfolioProject fromJson(Map<String, dynamic> json) {
    return PortfolioProject(
      id: json['id'] as String? ??
          'p_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      bullets: ((json['bullets'] as List?) ?? <dynamic>[])
          .map((Object? e) => '$e')
          .toList(),
      tech: ((json['tech'] as List?) ?? <dynamic>[])
          .map((Object? e) => '$e')
          .toList(),
      githubUrl: json['githubUrl'] as String? ?? '',
      liveUrl: json['liveUrl'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

class ResumeBulletSuggestion {
  const ResumeBulletSuggestion({
    required this.id,
    required this.badge,
    required this.projectId,
    required this.bulletIndex,
    required this.reason,
    required this.nowText,
    required this.tryText,
  });

  final String id;
  final int badge;
  final String projectId;
  final int bulletIndex;
  final String reason;
  final String nowText;
  final String tryText;
}
