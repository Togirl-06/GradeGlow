/// Client for the `careerServer` Cloud Function, which keeps the only
/// verified copy of a student's applications, jobs and simulated pay.
///
/// The app still runs every rule locally so the simulator works offline and
/// responds instantly. Each event that affects scores or money is also put in
/// an outbox and sent to the server, which re-computes the numbers from its
/// own catalogue (functions/career/catalog.json) and keeps the wallet in a
/// collection the app cannot write (`users/{uid}/career_server`).
library;

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../content/catalog.dart';
import '../engine/career_rules.dart';
import '../engine/interview_engine.dart';
import '../engine/market_rules.dart';
import '../engine/pay_rules.dart';
import '../labs/lab_catalog.dart';
import '../labs/lab_models.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../model/tasks.dart';
import '../resume/resume_analysis.dart';
import '../resume/resume_parser.dart';
import '../engine/text_rubric.dart';

/// The server could not be reached; the report stays in the outbox.
class CareerServerOffline implements Exception {
  const CareerServerOffline(this.message);
  final String message;
  @override
  String toString() => message;
}

class CareerServerReply {
  const CareerServerReply({required this.rejected, required this.message, required this.state, required this.reply});

  /// The server refused the report (for example, a score it could not verify).
  final bool rejected;
  final String message;
  final Map<String, dynamic> state;
  final Map<String, dynamic> reply;
}

abstract class CareerServer {
  /// Sends one report. Throws [CareerServerOffline] when it cannot be delivered.
  Future<CareerServerReply> send(String opId, String action, Map<String, dynamic> payload);
}

class HttpCareerServer implements CareerServer {
  HttpCareerServer({http.Client? client, Future<String?> Function()? idToken, Uri? endpoint})
      : _client = client ?? http.Client(),
        _idToken = idToken ?? _firebaseIdToken,
        _endpoint = endpoint ?? defaultEndpoint;

  static final Uri defaultEndpoint = Uri.parse('https://us-central1-ai-studybuddy-1fad1.cloudfunctions.net/careerServer');

  final http.Client _client;
  final Future<String?> Function() _idToken;
  final Uri _endpoint;

  static Future<String?> _firebaseIdToken() async {
    try {
      return await FirebaseAuth.instance.currentUser?.getIdToken();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<CareerServerReply> send(String opId, String action, Map<String, dynamic> payload) async {
    final String? token = await _idToken();
    if (token == null) throw const CareerServerOffline('Not signed in.');
    final http.Response res;
    try {
      res = await _client
          .post(
            _endpoint,
            headers: <String, String>{'content-type': 'application/json', 'authorization': 'Bearer $token'},
            body: jsonEncode(<String, Object?>{
              'data': <String, Object?>{'opId': opId, 'action': action, 'payload': payload},
            }),
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw CareerServerOffline('$e');
    }
    final Object? body = res.body.isEmpty ? null : jsonDecode(res.body);
    if (body is Map && body['result'] is Map) {
      final Map<String, dynamic> r = Map<String, dynamic>.from(body['result'] as Map<dynamic, dynamic>);
      return CareerServerReply(
        rejected: false,
        message: '',
        state: Map<String, dynamic>.from((r['state'] as Map<dynamic, dynamic>?) ?? const <String, dynamic>{}),
        reply: Map<String, dynamic>.from((r['reply'] as Map<dynamic, dynamic>?) ?? const <String, dynamic>{}),
      );
    }
    if (body is Map && body['error'] is Map) {
      final Map<dynamic, dynamic> err = body['error'] as Map<dynamic, dynamic>;
      final String status = '${err['status'] ?? ''}';
      if (status == 'FAILED_PRECONDITION' || status == 'INVALID_ARGUMENT') {
        return CareerServerReply(rejected: true, message: '${err['message'] ?? 'Rejected by the server.'}', state: const <String, dynamic>{}, reply: const <String, dynamic>{});
      }
      throw CareerServerOffline('${err['message'] ?? status}');
    }
    throw CareerServerOffline('HTTP ${res.statusCode}');
  }
}

/// What the app sends for each event. The same builders feed the parity test,
/// so the server is checked against exactly what the app reports.
abstract final class CareerServerPayloads {
  static Map<String, dynamic> resume(ParsedResume r) => <String, dynamic>{
        'name': r.name,
        'email': r.email,
        'phone': r.phone,
        'headline': r.headline,
        'summary': r.summary,
        'education': r.education,
        'experience': r.experience,
        'skills': r.skills,
        'projects': r.projects,
        'certifications': r.certifications,
        'achievements': r.achievements,
      };

  /// Labs passed and modules completed in the posting's field (the evidence
  /// part of screening, which the server cannot see).
  static (int, int) evidence(CareerProfile p, JobPosting job) {
    final Set<String> familyLabs = <String>{
      ...?CareerCatalog.workplace(job.workplaceId)?.assignments.map((AssignmentSpec s) => s.task).whereType<LabTaskSpec>().map((LabTaskSpec t) => t.labId),
    };
    final int labs = familyLabs.where(p.labPassed).length;
    final int modules = p.completedModules.where((String id) => CareerCatalog.departmentOfModule(id)?.id == job.deptId).length;
    return (labs, modules);
  }

  static Map<String, dynamic> screen(CareerProfile p, JobPosting job, JobApplication a, ScreeningReport local, int day) {
    if (job.keywords.isEmpty) {
      return <String, dynamic>{
        'applicationId': a.id,
        'postingId': job.id,
        'clientScore': local.score,
        'clientEligible': local.eligible,
      };
    }
    final (ParsedResume r, String text) = MarketRules.resumeOf(p, a);
    final (int labs, int modules) = evidence(p, job);
    return <String, dynamic>{
      'applicationId': a.id,
      'postingId': job.id,
      'submittedDay': a.submittedDay ?? day,
      'stage': p.stage.name,
      'labsPassed': labs,
      'modules': modules,
      'resume': resume(r),
      'resumeText': text,
      'coverLetter': a.coverLetter,
      'answers': a.answers,
    };
  }

  static Map<String, dynamic> interview(JobApplication a, InterviewRecord r, InterviewPlan? plan) => <String, dynamic>{
        'applicationId': a.id,
        'turns': <Map<String, dynamic>>[
          for (final InterviewTurn t in r.turns) _turn(t, plan?.question(t.questionId), r.practicalPassed),
        ],
        'candidateQuestions': r.candidateQuestions,
      };

  static Map<String, dynamic> _turn(InterviewTurn t, InterviewQuestion? q, bool practicalPassed) {
    if (q != null && q.practical != null) {
      return <String, dynamic>{'q': t.questionId, 'practicalScore': t.score, 'practicalPassed': practicalPassed};
    }
    if (q != null && q.isChoice) return <String, dynamic>{'q': t.questionId, 'choice': q.options.indexOf(t.answer)};
    return <String, dynamic>{'q': t.questionId, 'answer': t.answer};
  }
}

/// The catalogue the server scores against, exported from the app's own
/// content so both sides always use the same jobs, questions and pay.
abstract final class CareerServerCatalog {
  static List<Map<String, dynamic>> _concepts(List<Concept> cs) => <Map<String, dynamic>>[
        for (final Concept c in cs) <String, dynamic>{'id': c.id, 'anyOf': c.anyOf, 'weight': c.weight},
      ];

  static Map<String, dynamic> _question(InterviewQuestion q) => <String, dynamic>{
        'id': q.id,
        'competency': q.competency.name,
        'rubric': _concepts(q.rubric),
        'minWords': q.minWords,
        'options': q.options.length,
        'correctOption': q.correctOption,
        'practical': q.practical != null,
        'probeId': q.probeId,
        'stretchId': q.stretchId,
        'behavioural': q.behavioural,
      };

  static Map<String, dynamic> export() {
    // The resume question's rubric is fixed; build one plan to read it.
    final JobPosting sample = CareerCatalog.postings.firstWhere((JobPosting p) => p.keywords.isNotEmpty);
    final InterviewPlan samplePlan = MarketRules.interviewPlan(
        CareerProfile(), JobApplication(id: 'x', postingId: sample.id, status: ApplicationStatus.draft, createdDay: 1), sample, CareerCatalog.interviewPlan(sample.interviewPlanId)!);
    final List<Concept> letter = CareerRules.coverLetterRubric(null);
    return <String, dynamic>{
      'version': 1,
      'stages': <String>[for (final CareerStage s in CareerStage.values) s.name],
      'stipendCents': <String, int>{for (final MapEntry<LabDifficulty, int> e in PayRules.stipendCents.entries) e.key.name: e.value},
      'deductionRate': PayRules.deductionRate,
      'actionVerbs': actionVerbs,
      'aliases': resumeAliases,
      'deptKeywords': deptKeywords,
      'star': _concepts(InterviewSession.starRubric),
      'resumeQuestionRubric': _concepts(samplePlan.question('res_x')!.rubric),
      'negotiationRubric': _concepts(MarketRules.negotiationRubric),
      'coverLetterRubric': _concepts(letter),
      'postings': <String, dynamic>{
        for (final JobPosting p in CareerCatalog.postings)
          p.id: <String, dynamic>{
            'deptId': p.deptId,
            'title': p.title,
            'company': p.company.name,
            'level': p.level,
            'salaryMin': p.salaryMin,
            'salaryMax': p.salaryMax,
            'salaryPeriod': p.salaryPeriod,
            'payFrequency': p.payFrequency,
            'hoursPerWeek': p.hoursPerWeek,
            'shortlistMark': p.shortlistMark,
            'practicalRequired': p.practicalRequired,
            'openDay': p.openDay,
            'deadlineDay': p.deadlineDay,
            'minStage': p.requirements.minStage.name,
            'stageOnHire': p.stageOnHire.name,
            'keywords': p.keywords,
            'preferredKeywords': p.preferredKeywords,
            'educationFields': p.educationFields,
            'questions': <Map<String, dynamic>>[
              for (final ApplicationQuestion q in p.questions) <String, dynamic>{'id': q.id, 'minWords': q.minWords, 'rubric': _concepts(q.rubric)},
            ],
            'roleQuestions': <Map<String, dynamic>>[for (final InterviewQuestion q in p.roleQuestions) _question(q)],
            'interviewPlanId': p.interviewPlanId,
            'workplaceId': p.workplaceId,
          },
      },
      'plans': <String, dynamic>{
        for (final InterviewPlan pl in CareerCatalog.interviewPlans)
          pl.id: <String, dynamic>{
            'main': pl.main,
            'maxQuestions': pl.maxQuestions,
            'bank': <Map<String, dynamic>>[for (final InterviewQuestion q in pl.bank) _question(q)],
          },
      },
      'workplaces': <String, dynamic>{
        for (final WorkplaceDef w in CareerCatalog.workplaces)
          w.id: <String, dynamic>{'internshipLength': w.internshipLength, 'returnOfferPostingId': w.returnOfferPostingId},
      },
      'labs': <String, dynamic>{
        for (final LabSpec l in LabCatalog.all)
          l.id: <String, String>{for (final LabScenario s in l.scenarios) s.id: s.level.name},
      },
    };
  }
}
