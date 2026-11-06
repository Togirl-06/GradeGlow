import '../../data/leetcode_problem_bank.dart';
import '../../models/leetcode_problem.dart';
import '../../services/code_judge_service.dart';
import '../model/content_models.dart';
import '../model/tasks.dart';
import 'business_content.dart';
import 'comm_content.dart';
import 'cs_content.dart';
import 'engineering_content.dart';
import 'job_market.dart';
import 'law_content.dart';
import 'medicine_content.dart';
import 'nursing_content.dart';
import 'science_content.dart';

/// Lookup over all simulator content.
abstract final class CareerCatalog {
  static final List<Department> departments = <Department>[
    computerScience,
    nursing,
    medicine,
    law,
    engineering,
    business,
    mathematics,
    communication,
    sciences,
  ];

  static final List<JobPosting> postings = <JobPosting>[
    ...csPostings,
    ...nursingPostings,
    ...medicinePostings,
    ...lawPostings,
    ...engineeringPostings,
    ...businessPostings,
    ...mathPostings,
    ...commPostings,
    ...sciencePostings,
    ...marketPostings,
  ];

  static const List<InterviewPlan> interviewPlans = <InterviewPlan>[
    csInterview,
    nursingInterview,
    medicineInterview,
    lawInterview,
    engineeringInterview,
    businessInterview,
    mathInterview,
    commInterview,
    scienceInterview,
  ];

  static final List<WorkplaceDef> workplaces = <WorkplaceDef>[
    ...csWorkplaces,
    ...nursingWorkplaces,
    ...medicineWorkplaces,
    ...lawWorkplaces,
    ...engineeringWorkplaces,
    ...businessWorkplaces,
    ...mathWorkplaces,
    ...commWorkplaces,
    ...scienceWorkplaces,
    ...marketWorkplaces,
  ];

  static Department? department(String id) {
    for (final Department d in departments) {
      if (d.id == id) return d;
    }
    return null;
  }

  /// The department a major trains in, or null when no department fits.
  static Department? forMajor(String majorId) {
    for (final Department d in departments) {
      if (d.majors.contains(majorId)) return d;
    }
    return null;
  }

  static JobPosting? posting(String id) {
    for (final JobPosting p in postings) {
      if (p.id == id) return p;
    }
    return null;
  }

  static InterviewPlan? interviewPlan(String id) {
    for (final InterviewPlan p in interviewPlans) {
      if (p.id == id) return p;
    }
    return null;
  }

  static WorkplaceDef? workplace(String id) {
    for (final WorkplaceDef w in workplaces) {
      if (w.id == id) return w;
    }
    return null;
  }

  static List<JobPosting> postingsFor(String deptId) =>
      postings.where((JobPosting p) => p.deptId == deptId).toList();

  static TrainingModule? module(String id) {
    for (final Department d in departments) {
      for (final TrainingModule m in d.modules) {
        if (m.id == id) return m;
      }
    }
    return null;
  }

  static Department? departmentOfModule(String moduleId) {
    for (final Department d in departments) {
      if (d.modules.any((TrainingModule m) => m.id == moduleId)) return d;
    }
    return null;
  }

  static ProjectSpec? project(String id) {
    for (final Department d in departments) {
      for (final ProjectSpec p in d.projects) {
        if (p.id == id) return p;
      }
    }
    return null;
  }

  static Certification? certification(String id) {
    for (final Department d in departments) {
      for (final Certification c in d.certifications) {
        if (c.id == id) return c;
      }
    }
    return null;
  }

  static AssignmentSpec? assignment(WorkplaceDef w, String id) {
    for (final AssignmentSpec a in w.assignments) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// The gradable problem behind a code task, or null if it is not in the bank.
  static LeetcodeProblem? problem(String key) {
    final bool debug = key.startsWith('debug:');
    final List<LeetcodeProblem> pool =
        debug ? LeetcodeProblemBank.allDebugProblems : LeetcodeProblemBank.allCuratedProblems;
    for (final LeetcodeProblem p in pool) {
      if (CodeJudgeService.problemKey(p) == key && p.hasRealTests) return p;
    }
    return null;
  }

  /// Every code task in the simulator, for checking that each one is gradable.
  static List<CodeTaskSpec> allCodeTasks() {
    final List<CodeTaskSpec> out = <CodeTaskSpec>[];
    void add(Iterable<TaskSpec> ts) => out.addAll(ts.whereType<CodeTaskSpec>());
    for (final Department d in departments) {
      for (final TrainingModule m in d.modules) {
        add(m.practice);
      }
      for (final ProjectSpec p in d.projects) {
        add(p.deliverables);
      }
      for (final Certification c in d.certifications) {
        add(c.tasks);
      }
    }
    for (final InterviewPlan p in interviewPlans) {
      add(p.bank.map((InterviewQuestion q) => q.practical).whereType<TaskSpec>());
    }
    for (final WorkplaceDef w in workplaces) {
      add(w.assignments.map((AssignmentSpec a) => a.task));
    }
    return out;
  }
}

/// Postings reopen every [cycle] days, so a missed deadline is not a dead end.
abstract final class PostingSchedule {
  static const int cycle = 60;

  static int _cycleStart(JobPosting p, int day) {
    if (day < p.openDay) return p.openDay;
    final int k = (day - p.openDay) ~/ cycle;
    return p.openDay + k * cycle;
  }

  static bool isOpen(JobPosting p, int day) {
    final int start = _cycleStart(p, day);
    return day >= start && day <= start + (p.deadlineDay - p.openDay);
  }

  /// Closing day of the current window, or of the next one when closed.
  static int deadline(JobPosting p, int day) {
    final int start = _cycleStart(p, day);
    final int close = start + (p.deadlineDay - p.openDay);
    if (day <= close) return close;
    return close + cycle;
  }

  static int reopens(JobPosting p, int day) => _cycleStart(p, day) + cycle;
}
