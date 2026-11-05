/// Practical labs: a professional environment with working tools, a
/// briefing, interactive steps graded by published rules, an evaluation and
/// saved progress. Steps reuse the simulator's task types and add lab-only
/// interactions (programs, SQL, OS simulators, patient records, ledgers).
library;

import '../engine/text_rubric.dart';
import '../model/career_models.dart';
import '../model/tasks.dart';

enum LabEnvironment {
  computingLab,
  hospitalWard,
  clinicRoom,
  accountingFirm,
  mathsLab;

  String get label => switch (this) {
        LabEnvironment.computingLab => 'Computer Science and Computing Laboratory',
        LabEnvironment.hospitalWard => 'GradeGlow Teaching Hospital',
        LabEnvironment.clinicRoom => 'Medical Simulation and Clinical Skills Centre',
        LabEnvironment.accountingFirm => 'Professional Accounting Firm',
        LabEnvironment.mathsLab => 'Mathematics Problem-Solving Laboratory',
      };
}

enum LabDifficulty {
  foundation,
  intermediate,
  advanced;

  String get label => switch (this) {
        LabDifficulty.foundation => 'Beginner',
        LabDifficulty.intermediate => 'Intermediate',
        LabDifficulty.advanced => 'Advanced',
      };
}

/// Someone present in the environment, with a professional role.
class LabPerson {
  const LabPerson(this.name, this.role, this.says);
  final String name;
  final String role;
  final String says;
}

class Briefing {
  const Briefing({
    required this.what,
    required this.why,
    required this.information,
    required this.tools,
    required this.expected,
    this.requirements = const <String>[],
  });

  final String what;
  final String why;
  final List<String> information;
  final List<String> tools;
  final String expected;

  /// Safety or professional requirements.
  final List<String> requirements;
}

abstract class LabStep {
  const LabStep({required this.id, required this.title, required this.instructions, this.skills = const <String>[], this.passMark = 70});
  final String id;
  final String title;
  final String instructions;
  final List<String> skills;
  final int passMark;

  String get kind;
}

/// Any simulator task (code, decision, calculation, written work …).
class TaskStep extends LabStep {
  TaskStep(this.task, {String? instructions})
      : super(id: task.id, title: task.title, instructions: instructions ?? task.brief, skills: task.skills, passMark: task.passMark);
  final TaskSpec task;

  @override
  String get kind => task.kindLabel;
}

class ProgramCase {
  const ProgramCase(this.stdin, this.expected);
  final String stdin;
  final String expected;
}

/// Write a whole program; it is run on each input and its output compared.
class ProgramStep extends LabStep {
  const ProgramStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.cases,
    this.starter = const <String, String>{},
    super.skills,
  }) : super(passMark: 100);

  final List<ProgramCase> cases;
  final Map<String, String> starter;

  @override
  String get kind => 'Program';

  static String normalize(String s) =>
      s.replaceAll('\r\n', '\n').split('\n').map((String l) => l.trimRight()).join('\n').trim();
}

/// A query (or change) run against the lab's SQLite database.
class SqlStep extends LabStep {
  const SqlStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.expected,
    this.check,
    this.ordered = false,
    this.starter = '',
    super.skills,
  }) : super(passMark: 100);

  /// Expected rows of the student's result, or of [check] when set.
  final List<List<Object?>> expected;

  /// Query run after the student's statements (for INSERT/UPDATE/CREATE tasks).
  final String? check;
  final bool ordered;
  final String starter;

  @override
  String get kind => check == null ? 'SQL query' : 'SQL change';

  static String _cell(Object? v) {
    if (v is num) {
      final double d = v.toDouble();
      return d == d.roundToDouble() ? d.toInt().toString() : d.toStringAsFixed(4);
    }
    return v == null ? 'NULL' : '$v';
  }

  static List<String> rowKeys(List<List<Object?>> rows) => rows.map((List<Object?> r) => r.map(_cell).join('|')).toList();

  /// Compares rows by value (column names are not compared).
  bool matches(List<List<Object?>> got) {
    final List<String> a = rowKeys(got);
    final List<String> b = rowKeys(expected);
    if (a.length != b.length) return false;
    if (ordered) {
      for (int i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }
    final List<String> sa = List<String>.from(a)..sort();
    final List<String> sb = List<String>.from(b)..sort();
    for (int i = 0; i < sa.length; i++) {
      if (sa[i] != sb[i]) return false;
    }
    return true;
  }
}

class SchedProcess {
  const SchedProcess(this.name, this.arrival, this.burst);
  final String name;
  final int arrival;
  final int burst;
}

enum SchedAlgorithm { fcfs, sjf }

/// Build the Gantt chart for a non-preemptive CPU scheduler.
class SchedulingStep extends LabStep {
  const SchedulingStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.processes,
    required this.algorithm,
    super.skills,
  }) : super(passMark: 100);

  final List<SchedProcess> processes;
  final SchedAlgorithm algorithm;

  @override
  String get kind => 'Scheduler simulation';

  /// The correct dispatch order (ties: earlier arrival, then name).
  List<String> correctOrder() {
    final List<SchedProcess> left = List<SchedProcess>.from(processes);
    final List<String> order = <String>[];
    int t = 0;
    while (left.isNotEmpty) {
      final List<SchedProcess> ready = left.where((SchedProcess p) => p.arrival <= t).toList();
      if (ready.isEmpty) {
        t = left.map((SchedProcess p) => p.arrival).reduce((int a, int b) => a < b ? a : b);
        continue;
      }
      ready.sort((SchedProcess a, SchedProcess b) {
        if (algorithm == SchedAlgorithm.sjf && a.burst != b.burst) return a.burst.compareTo(b.burst);
        if (a.arrival != b.arrival) return a.arrival.compareTo(b.arrival);
        return a.name.compareTo(b.name);
      });
      final SchedProcess next = ready.first;
      order.add(next.name);
      t += next.burst;
      left.remove(next);
    }
    return order;
  }

  /// Waiting time of each process for a dispatch order.
  Map<String, int> waiting(List<String> order) {
    final Map<String, int> w = <String, int>{};
    int t = 0;
    for (final String n in order) {
      final SchedProcess p = processes.firstWhere((SchedProcess x) => x.name == n);
      if (t < p.arrival) t = p.arrival;
      w[n] = t - p.arrival;
      t += p.burst;
    }
    return w;
  }

  double averageWaiting(List<String> order) {
    final Map<String, int> w = waiting(order);
    return w.values.fold<int>(0, (int a, int b) => a + b) / w.length;
  }
}

enum PagingAlgorithm { fifo, lru }

/// Run page replacement by hand: hit or fault, and which frame to evict.
class PagingStep extends LabStep {
  const PagingStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.references,
    required this.frames,
    required this.algorithm,
    super.skills,
  }) : super(passMark: 80);

  final List<int> references;
  final int frames;
  final PagingAlgorithm algorithm;

  @override
  String get kind => 'Memory simulation';

  /// The page the algorithm evicts given the history so far.
  /// [loadedAt] = time each resident page was loaded; [usedAt] = last use.
  int victim(Map<int, int> loadedAt, Map<int, int> usedAt) {
    final Map<int, int> key = algorithm == PagingAlgorithm.fifo ? loadedAt : usedAt;
    int best = key.keys.first;
    for (final int p in key.keys) {
      if (key[p]! < key[best]!) best = p;
    }
    return best;
  }

  /// Faults with the correct algorithm.
  int correctFaults() {
    final Map<int, int> loaded = <int, int>{};
    final Map<int, int> used = <int, int>{};
    int faults = 0;
    for (int t = 0; t < references.length; t++) {
      final int r = references[t];
      if (loaded.containsKey(r)) {
        used[r] = t;
        continue;
      }
      faults++;
      if (loaded.length == frames) {
        final int v = victim(loaded, used);
        loaded.remove(v);
        used.remove(v);
      }
      loaded[r] = t;
      used[r] = t;
    }
    return faults;
  }
}

/// Binary search, one decision at a time.
class SearchTraceStep extends LabStep {
  const SearchTraceStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.values,
    required this.target,
    super.skills,
  }) : super(passMark: 100);

  final List<int> values;
  final int target;

  @override
  String get kind => 'Algorithm trace';
}

// ------------------------------------------------------------ patients

class Vitals {
  const Vitals({
    required this.time,
    required this.rr,
    required this.spo2,
    required this.sbp,
    required this.dbp,
    required this.hr,
    required this.temp,
    this.onOxygen = false,
    this.alert = true,
    this.pain = 0,
  });

  final String time;
  final int rr;
  final int spo2;
  final int sbp;
  final int dbp;
  final int hr;
  final double temp;
  final bool onOxygen;

  /// Alert on the ACVPU scale; false = new confusion / voice / pain / unresponsive.
  final bool alert;
  final int pain;
}

/// NEWS2 (Royal College of Physicians, 2017), SpO₂ scale 1.
abstract final class News2 {
  static int rr(int v) => v <= 8 ? 3 : v <= 11 ? 1 : v <= 20 ? 0 : v <= 24 ? 2 : 3;
  static int spo2(int v) => v <= 91 ? 3 : v <= 93 ? 2 : v <= 95 ? 1 : 0;
  static int oxygen(bool on) => on ? 2 : 0;
  static int sbp(int v) => v <= 90 ? 3 : v <= 100 ? 2 : v <= 110 ? 1 : v <= 219 ? 0 : 3;
  static int hr(int v) => v <= 40 ? 3 : v <= 50 ? 1 : v <= 90 ? 0 : v <= 110 ? 1 : v <= 130 ? 2 : 3;
  static int consciousness(bool alert) => alert ? 0 : 3;
  static int temp(double v) => v <= 35.0 ? 3 : v <= 36.0 ? 1 : v <= 38.0 ? 0 : v <= 39.0 ? 1 : 2;

  static int total(Vitals v) =>
      rr(v.rr) + spo2(v.spo2) + oxygen(v.onOxygen) + sbp(v.sbp) + hr(v.hr) + consciousness(v.alert) + temp(v.temp);

  static bool redScore(Vitals v) =>
      <int>[rr(v.rr), spo2(v.spo2), sbp(v.sbp), hr(v.hr), consciousness(v.alert), temp(v.temp)].contains(3);

  static const List<String> responses = <String>[
    'Continue routine 12-hourly observations',
    'Increase to 4–6-hourly; inform the nurse in charge',
    'Urgent review by the ward doctor; hourly observations',
    'Emergency response: call the critical care outreach team now',
  ];

  /// Index into [responses].
  static int response(Vitals v) {
    final int t = total(v);
    if (t >= 7) return 3;
    if (t >= 5 || redScore(v)) return 2;
    if (t >= 1) return 1;
    return 0;
  }
}

class MedOrder {
  const MedOrder(this.drug, this.dose, this.route, this.frequency, this.due, {this.lastGiven = '', this.notes = ''});
  final String drug;
  final String dose;
  final String route;
  final String frequency;
  final String due;
  final String lastGiven;
  final String notes;
}

class Patient {
  const Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.sex,
    required this.mrn,
    required this.dob,
    required this.bed,
    required this.presenting,
    required this.history,
    required this.allergies,
    required this.medications,
    this.labs = const <Fact>[],
    this.vitals = const <Vitals>[],
    this.notes = const <String>[],
    this.weightKg = 70,
  });

  final String id;
  final String name;
  final int age;
  final String sex;
  final String mrn;
  final String dob;
  final String bed;
  final String presenting;
  final List<String> history;
  final List<String> allergies;
  final List<MedOrder> medications;
  final List<Fact> labs;
  final List<Vitals> vitals;
  final List<String> notes;
  final double weightKg;
}

/// Positive patient identification against the record.
class IdentityCheckStep extends LabStep {
  const IdentityCheckStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.patientId,
    required this.wristband,
    required this.stated,
    super.skills,
  }) : super(passMark: 100);

  final String patientId;

  /// Field → value printed on the wristband.
  final Map<String, String> wristband;

  /// Field → value the patient states when asked.
  final Map<String, String> stated;

  @override
  String get kind => 'Identity check';

  static const List<String> fields = <String>['Name', 'Date of birth', 'MRN'];

  static String recordValue(Patient p, String field) => switch (field) {
        'Name' => p.name,
        'Date of birth' => p.dob,
        _ => p.mrn,
      };
}

class HistoryQuestion {
  const HistoryQuestion(this.question, this.answer, {this.essential = false, this.relevant = true});
  final String question;
  final String answer;
  final bool essential;
  final bool relevant;
}

/// Ask the patient questions, then document what you found.
class HistoryStep extends LabStep {
  const HistoryStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.patientId,
    required this.questions,
    required this.maxQuestions,
    required this.noteRubric,
    super.skills,
    super.passMark = 70,
  });

  final String patientId;
  final List<HistoryQuestion> questions;
  final int maxQuestions;
  final List<Concept> noteRubric;

  @override
  String get kind => 'Patient interview';
}

/// Observation rounds: score NEWS2 and choose the response each time.
class VitalsStep extends LabStep {
  const VitalsStep({required super.id, required super.title, required super.instructions, required this.patientId, super.skills})
      : super(passMark: 75);
  final String patientId;

  @override
  String get kind => 'Observations';
}

enum MedDecision {
  give,
  hold,
  query;

  String get label => switch (this) {
        MedDecision.give => 'Give as prescribed',
        MedDecision.hold => 'Hold and inform the prescriber',
        MedDecision.query => 'Do not give — query the order',
      };
}

/// Medication round from the MAR, checking the chart for each dose.
class MarStep extends LabStep {
  const MarStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.patientId,
    required this.correct,
    required this.why,
    super.skills,
  }) : super(passMark: 100);

  final String patientId;

  /// Correct decision for each medication on the patient's MAR.
  final List<MedDecision> correct;
  final List<String> why;

  @override
  String get kind => 'Medication round';
}

// ------------------------------------------------------------ accounting

class SourceDocument {
  const SourceDocument(this.ref, this.date, this.text);
  final String ref;
  final String date;
  final String text;
}

class EntryLine {
  const EntryLine(this.account, this.debit, this.amount);
  final String account;
  final bool debit;
  final double amount;

  Map<String, Object?> toJson() => <String, Object?>{'a': account, 'd': debit, 'm': amount};
  static EntryLine fromJson(Map<String, dynamic> j) =>
      EntryLine('${j['a']}', j['d'] == true, (j['m'] as num).toDouble());
}

/// Record the journal from source documents; the ledger and trial balance
/// update from the student's own entries.
class JournalStep extends LabStep {
  const JournalStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.accounts,
    required this.documents,
    required this.expected,
    super.skills,
  }) : super(passMark: 80);

  final List<String> accounts;
  final List<SourceDocument> documents;

  /// Expected lines per document.
  final List<List<EntryLine>> expected;

  @override
  String get kind => 'Journal and ledger';
}

enum ReconItem {
  matched,
  unpresentedCheque,
  outstandingDeposit,
  bankCharge,
  interestReceived;

  String get label => switch (this) {
        ReconItem.matched => 'In both — matched',
        ReconItem.unpresentedCheque => 'Unpresented cheque',
        ReconItem.outstandingDeposit => 'Outstanding deposit',
        ReconItem.bankCharge => 'Bank charge not in cash book',
        ReconItem.interestReceived => 'Interest not in cash book',
      };
}

class ReconLine {
  const ReconLine(this.source, this.description, this.amount, this.answer);

  /// 'Cash book' or 'Bank statement'.
  final String source;
  final String description;

  /// Positive = money in, negative = money out.
  final double amount;
  final ReconItem answer;
}

class ReconciliationStep extends LabStep {
  const ReconciliationStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.cashBookBalance,
    required this.bankBalance,
    required this.lines,
    super.skills,
  }) : super(passMark: 80);

  final double cashBookBalance;
  final double bankBalance;
  final List<ReconLine> lines;

  @override
  String get kind => 'Bank reconciliation';

  /// Cash book after bank-only items.
  double get adjustedCashBook => cashBookBalance +
      lines
          .where((ReconLine l) => l.answer == ReconItem.bankCharge || l.answer == ReconItem.interestReceived)
          .fold<double>(0, (double s, ReconLine l) => s + l.amount);
}

enum StatementLine {
  revenue,
  expense,
  asset,
  liability,
  equity;

  String get label => switch (this) {
        StatementLine.revenue => 'Income statement — revenue',
        StatementLine.expense => 'Income statement — expense',
        StatementLine.asset => 'Balance sheet — asset',
        StatementLine.liability => 'Balance sheet — liability',
        StatementLine.equity => 'Balance sheet — equity',
      };
}

class TbAccount {
  const TbAccount(this.name, this.balance, this.debit, this.line);
  final String name;
  final double balance;
  final bool debit;
  final StatementLine line;
}

/// Prepare the income statement and balance sheet from a trial balance.
class StatementsStep extends LabStep {
  const StatementsStep({required super.id, required super.title, required super.instructions, required this.trialBalance, super.skills})
      : super(passMark: 80);

  final List<TbAccount> trialBalance;

  @override
  String get kind => 'Financial statements';

  double sum(StatementLine l, Map<String, StatementLine?> mapping) => trialBalance
      .where((TbAccount a) => mapping[a.name] == l)
      .fold<double>(0, (double s, TbAccount a) => s + a.balance);

  double netIncome(Map<String, StatementLine?> m) => sum(StatementLine.revenue, m) - sum(StatementLine.expense, m);
}

// ------------------------------------------------------------ labs

class LabScenario {
  const LabScenario({
    required this.id,
    required this.title,
    required this.briefing,
    required this.steps,
    this.people = const <LabPerson>[],
    this.level = LabDifficulty.foundation,
  });
  final String id;
  final String title;
  final Briefing briefing;
  final List<LabStep> steps;
  final List<LabPerson> people;

  /// Beginner, intermediate or advanced. Harder levels unlock as easier
  /// scenarios are passed (see [LabGrader.scenarioUnlocked]).
  final LabDifficulty level;
}

class LabSpec {
  const LabSpec({
    required this.id,
    required this.deptId,
    required this.majorId,
    required this.number,
    required this.title,
    required this.environment,
    required this.summary,
    required this.objectives,
    required this.skills,
    required this.difficulty,
    required this.minutes,
    required this.scenarios,
    this.prerequisites = const <String>[],
    this.patients = const <Patient>[],
    this.database = '',
    this.databaseTables = const <String>[],
    this.addsToPortfolio = false,
  });

  final String id;
  final String deptId;
  final String majorId;
  final int number;
  final String title;
  final LabEnvironment environment;
  final String summary;
  final List<String> objectives;
  final List<String> skills;
  final LabDifficulty difficulty;
  final int minutes;
  final List<LabScenario> scenarios;

  /// Lab ids that should be completed first (advisory; shown on the intro).
  final List<String> prerequisites;

  /// Patients whose records are open in this lab.
  final List<Patient> patients;

  /// SQL that builds the lab database (SQL labs).
  final String database;
  final List<String> databaseTables;
  final bool addsToPortfolio;

  Patient? patient(String id) {
    for (final Patient p in patients) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<LabScenario> atLevel(LabDifficulty level) => scenarios.where((LabScenario s) => s.level == level).toList();

  LabScenario? scenario(String id) {
    for (final LabScenario s in scenarios) {
      if (s.id == id) return s;
    }
    return null;
  }
}

// ------------------------------------------------------------ saved runs

enum LabPhase { environment, briefing, work, evaluation, complete }

class LabRun {
  LabRun({
    required this.labId,
    required this.scenarioId,
    required this.startedDay,
    this.phase = LabPhase.environment,
    this.stepIndex = 0,
    Map<String, TaskResult>? results,
    Map<String, String>? drafts,
    this.score,
    this.completedDay,
  })  : results = results ?? <String, TaskResult>{},
        drafts = drafts ?? <String, String>{};

  factory LabRun.fromJson(Map<String, dynamic> j) => LabRun(
        labId: '${j['labId']}',
        scenarioId: '${j['scenarioId']}',
        startedDay: (j['startedDay'] as num?)?.toInt() ?? 0,
        phase: LabPhase.values.firstWhere((LabPhase p) => p.name == j['phase'], orElse: () => LabPhase.environment),
        stepIndex: (j['stepIndex'] as num?)?.toInt() ?? 0,
        results: (j['results'] as Map<dynamic, dynamic>? ?? <dynamic, dynamic>{}).map((dynamic k, dynamic v) =>
            MapEntry<String, TaskResult>('$k', TaskResult.fromJson(Map<String, dynamic>.from(v as Map<dynamic, dynamic>)))),
        drafts: (j['drafts'] as Map<dynamic, dynamic>? ?? <dynamic, dynamic>{})
            .map((dynamic k, dynamic v) => MapEntry<String, String>('$k', '$v')),
        score: (j['score'] as num?)?.toInt(),
        completedDay: (j['completedDay'] as num?)?.toInt(),
      );

  final String labId;
  final String scenarioId;
  final int startedDay;
  LabPhase phase;
  int stepIndex;
  final Map<String, TaskResult> results;
  final Map<String, String> drafts;
  int? score;
  int? completedDay;

  bool get done => completedDay != null;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'labId': labId,
        'scenarioId': scenarioId,
        'startedDay': startedDay,
        'phase': phase.name,
        'stepIndex': stepIndex,
        'results': results.map((String k, TaskResult v) => MapEntry<String, dynamic>(k, v.toJson())),
        'drafts': drafts,
        if (score != null) 'score': score,
        if (completedDay != null) 'completedDay': completedDay,
      };
}

/// Identify structures on a real anatomy diagram, one highlighted at a time.
class AnatomyIdStep extends LabStep {
  const AnatomyIdStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.diagramId,
    required this.regionIds,
    super.skills,
  }) : super(passMark: 80);

  final String diagramId;
  final List<String> regionIds;

  @override
  String get kind => 'Anatomy identification';
}

class LabCompletion {
  const LabCompletion({required this.labId, required this.scenarioId, required this.score, required this.passed, required this.day});

  factory LabCompletion.fromJson(Map<String, dynamic> j) => LabCompletion(
        labId: '${j['labId']}',
        scenarioId: '${j['scenarioId']}',
        score: (j['score'] as num?)?.toInt() ?? 0,
        passed: j['passed'] == true,
        day: (j['day'] as num?)?.toInt() ?? 0,
      );

  final String labId;
  final String scenarioId;
  final int score;
  final bool passed;
  final int day;

  Map<String, dynamic> toJson() => <String, dynamic>{'labId': labId, 'scenarioId': scenarioId, 'score': score, 'passed': passed, 'day': day};
}
