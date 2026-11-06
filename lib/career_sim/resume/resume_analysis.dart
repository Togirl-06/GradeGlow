/// Resume quality and job compatibility. Both are rule-based and explain
/// every point, so the same resume always gets the same, checkable result.
library;

import 'dart:math' as math;

import '../model/career_models.dart';
import '../model/content_models.dart';
import 'resume_parser.dart';

class ResumeCheck {
  const ResumeCheck(this.label, this.points, this.max, this.advice);
  final String label;
  final int points;
  final int max;

  /// What to change when the check is not fully met.
  final String advice;
  bool get met => points >= max;
}

class ResumeQuality {
  const ResumeQuality({required this.score, required this.checks, required this.words});
  final int score;
  final List<ResumeCheck> checks;
  final int words;

  List<String> get strengths => <String>[for (final ResumeCheck c in checks) if (c.met) c.label];
  List<String> get weaknesses => <String>[for (final ResumeCheck c in checks) if (!c.met) c.label];
  List<String> get suggestions => <String>[for (final ResumeCheck c in checks) if (!c.met && c.advice.isNotEmpty) c.advice];
}

int _countWords(String t) => RegExp(r"[A-Za-z0-9][A-Za-z0-9'’+#.\-]*").allMatches(t).length;

/// Scores how well-made a resume is (0–100), independent of any job.
ResumeQuality resumeQuality(ParsedResume p) {
  final String text = p.asText;
  final int words = _countWords(text);
  final List<String> bullets = <String>[
    for (final String e in <String>[...p.experience, ...p.projects]) ...e.split(RegExp(r' — |; ')),
  ];
  final int quantified = bullets.where((String b) => RegExp(r'\d').hasMatch(b) && RegExp(r'\d+\s?%|\$\s?\d|\d+\+?\s+[a-z]|\d{2,}').hasMatch(b.toLowerCase())).length;
  final int verbs = bullets.where(startsWithActionVerb).length;
  final int dated = <String>[...p.experience, ...p.education].where((String e) => RegExp(r'\b(19|20)\d{2}\b|present', caseSensitive: false).hasMatch(e)).length;
  final int firstPerson = RegExp(r'\b(I|me|my)\b').allMatches(text).length;
  final List<ResumeCheck> checks = <ResumeCheck>[
    ResumeCheck('Name and email', (p.name.isNotEmpty ? 5 : 0) + (p.email.isNotEmpty ? 5 : 0), 10, 'Put your full name and a professional email at the top.'),
    ResumeCheck('Phone number', p.phone.isNotEmpty ? 5 : 0, 5, 'Add a phone number so employers can reach you.'),
    ResumeCheck('Professional summary', _countWords(p.summary) >= 15 ? 10 : (p.summary.isNotEmpty ? 5 : 0), 10,
        'Add a 2–3 sentence summary: who you are, your strongest skills and the role you want.'),
    ResumeCheck('Education listed', p.education.isNotEmpty ? 15 : 0, 15, 'Add an Education section with your degree, institution and dates.'),
    ResumeCheck('Experience or projects', p.experience.isNotEmpty ? 15 : (p.projects.isNotEmpty ? 12 : 0), 15,
        'Add work, placement, volunteer or project experience — student projects count.'),
    ResumeCheck('Skills section (5+ skills)', math.min(10, p.skills.length * 2), 10, 'List at least five specific skills or tools under a Skills heading.'),
    ResumeCheck('Quantified results', math.min(10, quantified * 5), 10, 'Add numbers to your bullets: how many, how much, how often, by what %.'),
    ResumeCheck('Bullets start with action verbs', math.min(10, (verbs * 10 / 3).round()), 10, 'Start each bullet with a verb such as Built, Led, Analyzed or Reduced.'),
    ResumeCheck('Dates on education and roles', math.min(5, dated * 3), 5, 'Add start and end dates (month/year) to each role and qualification.'),
    ResumeCheck('Length (150–900 words)', words >= 150 && words <= 900 ? 5 : (words >= 80 ? 3 : 0), 5,
        words < 150 ? 'Your resume is short; describe what you did in each role.' : 'Trim to the most relevant points (one to two pages).'),
    ResumeCheck('Written without "I/me/my"', firstPerson <= 2 ? 5 : 0, 5, 'Resumes are written without "I" — start lines with the verb instead.'),
  ];
  final int score = checks.fold<int>(0, (int a, ResumeCheck c) => a + c.points);
  return ResumeQuality(score: score.clamp(0, 100), checks: checks, words: words);
}

/// Common alternative spellings, so "JS" matches "JavaScript".
const Map<String, List<String>> resumeAliases = <String, List<String>>{
  'javascript': <String>['js', 'node.js', 'nodejs', 'typescript'],
  'rest apis': <String>['rest api', 'restful', 'api', 'apis'],
  'sql': <String>['mysql', 'postgresql', 'postgres', 'sqlite', 'sql server'],
  'machine learning': <String>['ml', 'scikit-learn', 'tensorflow', 'pytorch'],
  'excel': <String>['spreadsheets', 'microsoft excel', 'ms excel'],
  'git': <String>['github', 'gitlab', 'version control'],
  'testing': <String>['unit test', 'unit testing', 'widget test', 'test coverage', 'tests'],
  'vital signs': <String>['vitals', 'observations', 'blood pressure'],
  'patient assessment': <String>['assessments', 'assessing patients', 'patient assessments'],
  'infection control': <String>['infection prevention', 'hand hygiene'],
  'documentation': <String>['charting', 'clinical notes', 'records'],
  'reconciliation': <String>['reconciliations', 'reconciled', 'reconcile'],
  'financial statements': <String>['financial statement', 'balance sheet', 'income statement'],
  'legal research': <String>['westlaw', 'lexisnexis', 'case law research'],
  'cad': <String>['solidworks', 'autocad', 'fusion 360', 'inventor', 'catia'],
  'communication': <String>['communicat', 'presented', 'presentation'],
  'data analysis': <String>['analyzed data', 'analysed data', 'analytics', 'pandas'],
  'statistics': <String>['statistical', 'regression', 'r studio', 'spss'],
  'writing': <String>['wrote', 'copywriting', 'content writing', 'editing'],
};

bool resumeMentions(String text, String term) {
  final String t = text.toLowerCase();
  final String k = term.toLowerCase().trim();
  bool has(String x) {
    if (x.length <= 3) return RegExp('(^|[^a-z0-9])${RegExp.escape(x)}([^a-z0-9]|\$)').hasMatch(t);
    return t.contains(x);
  }

  if (has(k)) return true;
  for (final String a in resumeAliases[k] ?? const <String>[]) {
    if (has(a)) return true;
  }
  return false;
}

/// Years of work found in date ranges in the experience section.
double experienceYears(ParsedResume p, {int? thisYear}) {
  final int now = thisYear ?? DateTime.now().year;
  double years = 0;
  for (final String e in p.experience) {
    final List<int> ys = <int>[for (final RegExpMatch m in RegExp(r'\b((?:19|20)\d{2})\b').allMatches(e)) int.parse(m[1]!)];
    final bool present = RegExp(r'present|current|now', caseSensitive: false).hasMatch(e);
    if (ys.isEmpty) continue;
    final int start = ys.reduce(math.min);
    final int end = present ? now : ys.reduce(math.max);
    years += math.max(0.25, (end - start).toDouble()); // a single-year role counts as a season
  }
  return years;
}

/// Minimum years of experience the level expects (interns and entry roles expect none).
double levelYears(String level) => switch (level) {
      'Junior' => 1,
      'Mid-level' => 3,
      'Senior' => 5,
      'Management' => 7,
      _ => 0,
    };

class JobMatch {
  const JobMatch({
    required this.score,
    required this.matched,
    required this.missing,
    required this.preferredMatched,
    required this.educationOk,
    required this.experienceNote,
    required this.reasons,
  });

  final int score;
  final List<String> matched;
  final List<String> missing;
  final List<String> preferredMatched;
  final bool educationOk;
  final String experienceNote;

  /// Why the resume does or does not match, line by line.
  final List<String> reasons;
}

/// Department fallbacks for older postings that list no keywords.
const Map<String, List<String>> deptKeywords = <String, List<String>>{
  'cs': <String>['Python', 'Java', 'JavaScript', 'SQL', 'Git', 'Testing', 'Data structures', 'Algorithms'],
  'nursing': <String>['Vital signs', 'Patient assessment', 'Infection control', 'Documentation', 'Medication safety', 'Patient education'],
  'medicine': <String>['History taking', 'Clinical reasoning', 'Patient assessment', 'Documentation', 'Communication', 'Research'],
  'law': <String>['Legal research', 'Legal writing', 'Case', 'Contract', 'Drafting', 'Communication'],
  'engineering': <String>['CAD', 'Calculations', 'Design', 'Technical report', 'MATLAB', 'Excel'],
  'business': <String>['Excel', 'Financial statements', 'Reconciliation', 'Budgeting', 'Data analysis', 'Presentation'],
  'mathematics': <String>['Statistics', 'Python', 'R', 'Modelling', 'Data analysis', 'Excel'],
  'communication': <String>['Writing', 'Editing', 'Social media', 'Content', 'Research', 'Presentation'],
  'sciences': <String>['Laboratory', 'Experiments', 'Data analysis', 'Report writing', 'Safety', 'Statistics'],
};

/// How well a resume matches a job's written requirements (0–100) and why.
/// Students and limited experience are not rejected here: internships and
/// entry roles weigh projects and coursework the same as jobs.
JobMatch jobMatch(ParsedResume p, JobPosting job, {String? fullText, int? thisYear}) {
  final String text = '${p.asText}\n${fullText ?? ''}';
  final List<String> required = job.keywords.isNotEmpty ? job.keywords : (deptKeywords[job.deptId] ?? const <String>[]);
  final List<String> matched = <String>[for (final String k in required) if (resumeMentions(text, k)) k];
  final List<String> missing = <String>[for (final String k in required) if (!matched.contains(k)) k];
  final List<String> prefMatched = <String>[for (final String k in job.preferredKeywords) if (resumeMentions(text, k)) k];
  final List<String> prefMissing = <String>[for (final String k in job.preferredKeywords) if (!prefMatched.contains(k)) k];
  final String eduText = p.education.join(' ');
  final bool eduOk = job.educationFields.isEmpty
      ? p.education.isNotEmpty
      : job.educationFields.any((String f) => resumeMentions(eduText.isEmpty ? text : eduText, f));
  final double need = levelYears(job.level);
  final double have = experienceYears(p, thisYear: thisYear);
  final bool hasProjects = p.projects.isNotEmpty;
  double exp;
  String expNote;
  if (need == 0) {
    exp = (p.experience.isNotEmpty || hasProjects) ? 1 : 0.6;
    expNote = p.experience.isNotEmpty
        ? 'Has work or placement experience — more than this ${job.levelLabel.toLowerCase()} role requires.'
        : hasProjects
            ? 'No paid experience needed: your projects count for this ${job.levelLabel.toLowerCase()} role.'
            : 'No experience needed for this role, but adding projects or placements would strengthen it.';
  } else {
    exp = math.min(1, have / need);
    expNote = have >= need
        ? 'About ${have.toStringAsFixed(have < 2 ? 1 : 0)} years of experience found; the role asks for ${need.toStringAsFixed(0)}+.'
        : 'About ${have.toStringAsFixed(1)} years of experience found; the role asks for ${need.toStringAsFixed(0)}+.';
  }
  final double req = required.isEmpty ? 1 : matched.length / required.length;
  final double pref = job.preferredKeywords.isEmpty ? (req > 0.5 ? 1 : 0.5) : prefMatched.length / job.preferredKeywords.length;
  final int score = (50 * req + 15 * pref + 20 * (eduOk ? 1 : 0.3) + 15 * exp).round().clamp(0, 100);
  final List<String> reasons = <String>[
    'Required skills: ${matched.length} of ${required.length} found${matched.isEmpty ? '' : ' (${matched.join(', ')})'}.',
    if (missing.isNotEmpty) 'Not found on your resume: ${missing.join(', ')}.',
    if (job.preferredKeywords.isNotEmpty) 'Preferred: ${prefMatched.length} of ${job.preferredKeywords.length} found${prefMissing.isEmpty ? '' : '; missing ${prefMissing.join(', ')}'}.',
    eduOk
        ? 'Education matches${job.requiredEducation.isEmpty ? '' : ' "${job.requiredEducation}"'}.'
        : 'Education: ${job.requiredEducation.isEmpty ? 'no matching qualification found' : 'the role asks for ${job.requiredEducation}'}.',
    expNote,
  ];
  return JobMatch(
    score: score,
    matched: matched,
    missing: <String>[...missing, ...prefMissing],
    preferredMatched: prefMatched,
    educationOk: eduOk,
    experienceNote: expNote,
    reasons: reasons,
  );
}

/// The parsed fields of the student's built resume, for matching.
ParsedResume parsedFromResume(Resume r) => ParsedResume(
      name: r.fullName,
      email: r.email,
      phone: r.phone,
      headline: r.headline,
      summary: r.summary,
      education: <String>[for (final ResumeEntry e in r.education) '${e.heading} — ${e.detail}'],
      experience: <String>[for (final ResumeEntry e in r.experience) '${e.heading} — ${e.detail}'],
      skills: r.skills,
      projects: <String>[for (final ResumeEntry e in r.projects) '${e.heading} — ${e.detail}'],
      certifications: r.certifications,
      achievements: r.achievements,
    );
