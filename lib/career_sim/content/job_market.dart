/// The job marketplace: simulated employers and vacancies for every major,
/// from internships to management. Every role's daily work is carried out
/// in that field's practical labs (the IDE, ward, ledger, drawing office,
/// law library …), so the work is real and graded by the lab's own checks.
///
/// All employers are fictional and every salary is illustrative virtual USD.
library;

import 'dart:math' as math;

import '../engine/text_rubric.dart';
import '../hospital/hospital_cases.dart';
import '../hospital/hospital_models.dart';
import '../labs/lab_catalog.dart';
import '../labs/lab_models.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../model/tasks.dart';

const String simulatedEmployer = '(simulated employer)';

CompanyProfile _co(String name, String industry, String about, {required String team, required String tools, String culture = '', String training = ''}) => CompanyProfile(
      name: name,
      industry: industry,
      about: '$about This is a simulated employer for GradeGlow training.',
      team: team,
      training: training.isNotEmpty ? training : 'You get an onboarding week, a named buddy, weekly one-to-ones with your manager and written feedback on every assignment.',
      culture: culture.isNotEmpty ? culture : 'Clear written tickets, honest feedback and handoff notes at the end of each piece of work.',
      success: 'In the first months we look for work that passes review first time, on-time delivery and clear handoff notes. Reviews happen every four assignments.',
      tools: tools,
      nextSteps: 'We review applications within two days, interview shortlisted candidates and decide the day after the interview.',
    );

final Map<String, CompanyProfile> marketCompanies = <String, CompanyProfile>{
  'novatech': _co('NovaTech Solutions', 'Software products', 'NovaTech builds mobile and web apps for retailers and clinics.',
      team: 'A product squad of six engineers, a designer and a product manager; you report to the engineering manager.', tools: 'Flutter, Dart, Firebase, Python services, Git pull requests, CI that runs every test, an issue tracker.'),
  'quantumleaf': _co('QuantumLeaf Analytics', 'Data and AI consultancy', 'QuantumLeaf helps hospitals and retailers make decisions from their data.',
      team: 'An insights team of analysts and data scientists led by an analytics manager.', tools: 'SQL, Python notebooks, dashboards, model evaluation reports and a shared data dictionary.'),
  'ironclad': _co('Ironclad Security Group', 'Managed security services', 'Ironclad runs a 24/7 security operations centre for 300 small companies.',
      team: 'A SOC shift of five analysts with a shift lead; tier-2 handles escalations.', tools: 'SIEM alerts, packet captures, vulnerability scanners and an incident runbook.'),
  'bluehelix': _co('BlueHelix IT Services', 'IT service desk', 'BlueHelix supports 2,000 staff across schools and clinics.',
      team: 'A service desk of eight technicians and a service manager.', tools: 'Ticketing system, remote support, Active Directory, network monitoring and a knowledge base.'),
  'mercy': _co('Mercy Valley Medical Center', 'Teaching hospital (simulation)', 'A 450-bed simulated teaching hospital used for supervised GradeGlow placements.',
      team: 'Ward and department teams led by a nurse unit manager or attending physician who supervises every decision.', tools: 'Electronic health record, bedside monitors, early-warning charts, SBAR handovers.',
      culture: 'Patient safety first: escalate early, document everything, and never act outside your scope.'),
  'cedar': _co('Cedar Clinical Research Institute', 'Clinical research', 'Cedar runs clinical trials and laboratory testing for regional hospitals.',
      team: 'A trial coordination team and a diagnostics laboratory, each with a supervising scientist.', tools: 'Trial protocols, case report forms, laboratory information system, quality-control logs.'),
  'harlow': _co('Harlow & Pierce LLP', 'Law firm', 'Harlow & Pierce advises businesses and individuals on litigation, contracts and compliance.',
      team: 'A practice group of associates and paralegals supervised by a partner.', tools: 'Case files, legal research databases, document templates and a matter-management system.'),
  'meridian': _co('Meridian Engineering Group', 'Engineering consultancy', 'Meridian designs machines, structures and electrical systems for industrial clients.',
      team: 'A design office of engineers and technicians; every calculation is checked by a chartered engineer.', tools: 'CAD, calculation sheets, design-review checklists, test rigs and technical reports.'),
  'skyforge': _co('SkyForge Aerospace', 'Aerospace manufacturing', 'SkyForge builds small aircraft structures and propulsion components.',
      team: 'Design and test teams led by a chief engineer.', tools: 'Aerodynamic models, structural analysis, test data and design reviews.'),
  'summit': _co('Summit Ledger Partners', 'Accounting and advisory', 'Summit Ledger keeps the books and audits 150 small and mid-sized businesses.',
      team: 'An accounts team of accountants and clerks led by an audit manager.', tools: 'General ledger, bank feeds, spreadsheets, audit workpapers and month-end checklists.'),
  'atlas': _co('Atlas Capital Advisors', 'Investment and corporate finance', 'Atlas Capital analyses companies for investors and advises on financing.',
      team: 'An investment desk of analysts reporting to a portfolio manager.', tools: 'Financial statements, valuation models, risk reports and investment memos.'),
  'brightwave': _co('Brightwave Marketing Co.', 'Marketing agency', 'Brightwave plans and runs campaigns for consumer brands.',
      team: 'A campaigns team with a strategist, content creators and an account director.', tools: 'Audience research, content calendars, ad platforms and campaign dashboards.'),
  'peoplefirst': _co('PeopleFirst Logistics', 'Logistics (HR department)', 'A 1,800-employee logistics company with a central people team.',
      team: 'An HR team of business partners and assistants led by the HR manager.', tools: 'Applicant tracking, onboarding checklists, HR policies and case notes.'),
  'keystone': _co('Keystone Business Group', 'Operations and strategy', 'Keystone runs retail and service businesses across 40 locations.',
      team: 'A business operations team reporting to the operations director.', tools: 'Spreadsheets, KPI dashboards, project plans and business cases.'),
  'policylab': _co('Civic Policy Lab', 'Economic research', 'A research institute that analyses economic data for local governments.',
      team: 'A research unit of economists and research assistants.', tools: 'Economic datasets, regression analysis, policy briefs.'),
  'quantis': _co('Quantis Modelling', 'Mathematical consulting', 'Quantis builds models and statistical analyses for engineering and finance clients.',
      team: 'A modelling team led by a principal analyst.', tools: 'Python, R, numerical methods and model review notes.'),
  'verdant': _co('Verdant BioLabs', 'Life-science research', 'Verdant runs biology, chemistry and physics research laboratories.',
      team: 'Research groups led by a group leader, with a laboratory manager for safety and quality.', tools: 'Laboratory notebooks, microscopes, titration and analytical instruments, experimental data analysis.'),
  'inkwell': _co('Inkwell Media House', 'Publishing and communications', 'Inkwell publishes, edits and runs communications for companies and nonprofits.',
      team: 'An editorial and communications team led by a managing editor.', tools: 'Style guide, content management system, editorial calendar and media lists.'),
};

/// A career ladder: the title at each stage, the labs the work happens in,
/// and the employer's own application and interview questions.
class RoleFamily {
  const RoleFamily({
    required this.id,
    required this.deptId,
    required this.company,
    required this.team,
    required this.supervisor,
    required this.supervisorRole,
    required this.labs,
    required this.titles,
    required this.questions,
    required this.interview,
    this.payFrequency = 'biweekly',
    this.note = '',
    this.hospital = const <String>[],
  });

  /// Virtual-hospital cases (or the ward shift) assigned as work.
  final List<String> hospital;

  final String id;
  final String deptId;
  final String company;
  final String team;
  final String supervisor;
  final String supervisorRole;
  final List<String> labs;
  final Map<CareerStage, String> titles;
  final List<ApplicationQuestion> questions;
  final List<InterviewQuestion> interview;
  final String payFrequency;
  final String note;
}

const String _clinicalNote = 'Educational simulation: this role does not grant or imply a nursing or medical licence, and no real patients are involved. All clinical work is supervised practice on virtual patients.';
const String _legalNote = 'Educational simulation: this role does not make you a licensed attorney or allow you to give real legal advice.';

const Concept _why = Concept('why', 'Why this role and employer', <String>['because', 'interest*', 'excit*', 'your company', 'this role', 'mission', 'motivat*']);
const Concept _evidence = Concept('evidence', 'A specific example', <String>['for example', 'when i', 'in my', 'during', 'project', 'placement', 'internship', 'course']);
const Concept _result = Concept('result', 'The result', <String>['result*', 'which led', 'improv*', 'reduc*', 'increas*', 'saved', 'learned', 'outcome']);

ApplicationQuestion _motivation(String id) => ApplicationQuestion(
      id: '${id}_why',
      prompt: 'Why do you want this role, and what will you bring to the team in your first three months?',
      rubric: const <Concept>[_why, _evidence, Concept('contribution', 'What you will contribute', <String>['i will', 'i can', 'contribut*', 'bring', 'help the team', 'first three months', 'deliver'])],
    );

InterviewQuestion _iq(String id, String prompt, Competency c, List<Concept> rubric, {bool behavioural = false, int minWords = 30}) =>
    InterviewQuestion(id: id, prompt: prompt, competency: c, rubric: rubric, behavioural: behavioural, minWords: minWords);

ApplicationQuestion _aq(String id, String prompt, List<Concept> rubric, {int minWords = 40}) => ApplicationQuestion(id: id, prompt: prompt, rubric: rubric, minWords: minWords);

Map<CareerStage, String> _ladder(String intern, String entry, String junior, String mid, String senior, String lead) => <CareerStage, String>{
      CareerStage.intern: intern,
      CareerStage.entryLevel: entry,
      CareerStage.junior: junior,
      CareerStage.experienced: mid,
      CareerStage.senior: senior,
      CareerStage.lead: lead,
    };

final List<RoleFamily> roleFamilies = <RoleFamily>[
  // ---------------------------------------------------------------- computing
  RoleFamily(
    id: 'software', deptId: 'cs', company: 'novatech', team: 'Product Engineering', supervisor: 'Priya Natarajan', supervisorRole: 'Engineering Manager',
    labs: <String>['se_lab_development', 'cs_lab_fundamentals', 'se_lab_testing', 'se_lab_git', 'cs_lab_project', 'se_lab_maintenance'],
    titles: _ladder('Software Engineering Intern', 'Associate Software Developer', 'Junior Software Developer', 'Software Developer', 'Senior Developer', 'Engineering Manager'),
    questions: <ApplicationQuestion>[
      _motivation('software'),
      _aq('software_bug', 'Describe a bug you tracked down. How did you find the cause and confirm the fix?', const <Concept>[
        Concept('repro', 'Reproduced the problem', <String>['reproduc*', 'steps', 'logs', 'error message', 'stack trace']),
        Concept('cause', 'Found the root cause', <String>['root cause', 'because', 'the cause', 'turned out', 'debug*', 'breakpoint']),
        Concept('verify', 'Verified the fix', <String>['test*', 'verified', 'confirm*', 'regression']),
      ]),
    ],
    interview: <InterviewQuestion>[
      _iq('mk_sw_crash', 'How would you debug an application that keeps crashing in production?', Competency.problemSolving, const <Concept>[
        Concept('logs', 'Gather evidence (logs, crash reports)', <String>['log*', 'crash report*', 'stack trace', 'monitoring', 'error']),
        Concept('repro', 'Reproduce it', <String>['reproduc*', 'same steps', 'same device', 'replicate']),
        Concept('isolate', 'Isolate the cause', <String>['isolate', 'narrow', 'recent change*', 'bisect', 'root cause', 'debugger']),
        Concept('fix', 'Fix safely and verify', <String>['test*', 'rollback', 'hotfix', 'verify', 'regression']),
      ]),
      _iq('mk_sw_structure', 'How do you structure code in a large application so a team can keep changing it?', Competency.technical, const <Concept>[
        Concept('layers', 'Separation into layers/modules', <String>['layer*', 'module*', 'separat*', 'feature folder*', 'architecture']),
        Concept('state', 'State and data flow', <String>['state', 'repository', 'service*', 'provider', 'bloc', 'mvvm', 'data flow']),
        Concept('tests', 'Tests and reviews', <String>['test*', 'code review*', 'pull request*', 'ci']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'frontend', deptId: 'cs', company: 'novatech', team: 'Web Experience', supervisor: 'Lucas Moreau', supervisorRole: 'Frontend Lead',
    labs: <String>['web_lab_frontend', 'web_lab_js', 'web_lab_htmlcss', 'web_lab_a11y', 'web_lab_client'],
    titles: _ladder('Web Development Intern', 'Associate Frontend Developer', 'Frontend Developer', 'Frontend Developer II', 'Senior Frontend Developer', 'Frontend Team Lead'),
    questions: <ApplicationQuestion>[_motivation('frontend')],
    interview: <InterviewQuestion>[
      _iq('mk_fe_slow', 'A page loads slowly on phones. How would you find and fix the cause?', Competency.problemSolving, const <Concept>[
        Concept('measure', 'Measure first', <String>['devtools', 'lighthouse', 'network tab', 'measure', 'profil*']),
        Concept('assets', 'Assets and requests', <String>['image*', 'bundle', 'lazy', 'cache', 'compress*', 'request*']),
        Concept('verify', 'Verify the improvement', <String>['re-test', 'compare', 'before and after', 'verify']),
      ]),
      _iq('mk_fe_a11y', 'How do you make a form accessible?', Competency.technical, const <Concept>[
        Concept('labels', 'Labels and semantics', <String>['label*', 'semantic', 'aria']),
        Concept('keyboard', 'Keyboard and focus', <String>['keyboard', 'focus', 'tab order']),
        Concept('errors', 'Clear errors and contrast', <String>['error message*', 'contrast', 'screen reader']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'backend', deptId: 'cs', company: 'novatech', team: 'Platform Services', supervisor: 'Oskar Lindgren', supervisorRole: 'Backend Lead',
    labs: <String>['web_lab_backend', 'cs_lab_database', 'se_lab_design', 'cs_lab_os'],
    titles: _ladder('Backend Engineering Intern', 'Associate Backend Developer', 'Backend Developer', 'Backend Developer II', 'Senior Backend Developer', 'Platform Team Lead'),
    questions: <ApplicationQuestion>[_motivation('backend')],
    interview: <InterviewQuestion>[
      _iq('mk_be_api', 'How would you design a REST API endpoint that creates an order?', Competency.technical, const <Concept>[
        Concept('verb', 'Method, path and status codes', <String>['post', '201', 'status code*', 'endpoint', '/orders']),
        Concept('validate', 'Validation and errors', <String>['validat*', '400', 'error*', 'required field*']),
        Concept('data', 'Data and transactions', <String>['database', 'transaction', 'idempot*', 'duplicate']),
      ]),
      _iq('mk_be_prodbug', 'How would you handle a difficult production bug that is losing customer orders?', Competency.problemSolving, const <Concept>[
        Concept('contain', 'Contain the impact', <String>['rollback', 'disable', 'feature flag', 'mitigat*', 'stop the']),
        Concept('communicate', 'Communicate', <String>['incident', 'tell', 'team', 'stakeholder*', 'status']),
        Concept('root', 'Root cause and prevention', <String>['root cause', 'postmortem', 'test*', 'prevent*']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'mobile', deptId: 'cs', company: 'novatech', team: 'Mobile Engineering', supervisor: 'Daniel Okafor', supervisorRole: 'Mobile Lead',
    labs: <String>['mob_lab_flutter', 'mob_lab_ui', 'mob_lab_backend', 'mob_lab_testing', 'mob_lab_deploy', 'mob_lab_project'],
    titles: _ladder('Mobile Development Intern', 'Associate Flutter Developer', 'Junior Flutter Developer', 'Flutter Developer', 'Senior Mobile Developer', 'Mobile Team Lead'),
    questions: <ApplicationQuestion>[
      _motivation('mobile'),
      _aq('mobile_app', 'Tell us about an app (or screen) you built. What did you use and how did you test it?', const <Concept>[
        Concept('build', 'What you built', <String>['built', 'app', 'screen', 'flutter', 'dart', 'widget*']),
        Concept('data', 'Data/API', <String>['api', 'firebase', 'backend', 'database', 'json']),
        Concept('test', 'Testing', <String>['test*', 'device*', 'emulator', 'users']),
      ]),
    ],
    interview: <InterviewQuestion>[
      _iq('mk_mob_login', 'Users report the login screen sometimes freezes. How would you investigate?', Competency.problemSolving, const <Concept>[
        Concept('repro', 'Reproduce on devices', <String>['reproduc*', 'device*', 'emulator', 'network']),
        Concept('async', 'Async and state', <String>['async', 'await', 'future', 'state', 'main thread', 'loading']),
        Concept('test', 'Test the fix', <String>['test*', 'widget test', 'verify']),
      ]),
      _iq('mk_mob_state', 'How do you manage state in a Flutter app that talks to an API?', Competency.technical, const <Concept>[
        Concept('pattern', 'A state-management approach', <String>['provider', 'riverpod', 'bloc', 'changenotifier', 'setstate']),
        Concept('repo', 'Repository/service layer', <String>['repository', 'service', 'api client', 'layer']),
        Concept('errors', 'Loading and errors', <String>['loading', 'error*', 'retry', 'offline']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'aiml', deptId: 'cs', company: 'quantumleaf', team: 'Applied AI', supervisor: 'Dr Mei Lin', supervisorRole: 'Lead Data Scientist',
    labs: <String>['ai_lab_ml', 'ai_lab_nn', 'ai_lab_nlp', 'ai_lab_ethics', 'ai_lab_genai'],
    titles: _ladder('AI/ML Intern', 'Associate ML Engineer', 'Machine Learning Engineer I', 'Machine Learning Engineer', 'Senior ML Engineer', 'AI Team Lead'),
    questions: <ApplicationQuestion>[_motivation('aiml')],
    interview: <InterviewQuestion>[
      _iq('mk_ai_overfit', 'Your model scores 99% on training data and 70% on test data. What is happening and what do you do?', Competency.technical, const <Concept>[
        Concept('overfit', 'Names overfitting', <String>['overfit*', 'memoriz*', 'variance']),
        Concept('fix', 'Remedies', <String>['regulari*', 'more data', 'simpler model', 'dropout', 'cross-validation', 'early stopping']),
        Concept('eval', 'Proper evaluation', <String>['validation set', 'test set', 'cross-validation', 'held-out']),
      ]),
      _iq('mk_ai_bias', 'How would you check whether a model treats groups of users unfairly?', Competency.problemSolving, const <Concept>[
        Concept('groups', 'Compare by group', <String>['group*', 'subgroup*', 'demographic*', 'slice*']),
        Concept('metrics', 'Fairness metrics', <String>['false positive*', 'false negative*', 'recall', 'precision', 'error rate*']),
        Concept('act', 'Act on findings', <String>['retrain', 'rebalanc*', 'report', 'mitigat*']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'data', deptId: 'cs', company: 'quantumleaf', team: 'Insights', supervisor: 'Oluwaseun Adeyemi', supervisorRole: 'Analytics Manager',
    labs: <String>['ds_lab_cleaning', 'ds_lab_analysis', 'ds_lab_viz', 'cs_lab_database', 'ds_lab_stats', 'ds_lab_predictive'],
    titles: _ladder('Data Analytics Intern', 'Data Analyst', 'Junior Data Scientist', 'Data Scientist', 'Senior Data Scientist', 'Analytics Manager'),
    questions: <ApplicationQuestion>[
      _motivation('data'),
      _aq('data_clean', 'A dataset has missing values and duplicates. How would you prepare it for analysis?', const <Concept>[
        Concept('profile', 'Profile the data', <String>['explore', 'profile', 'count', 'summary statistics', 'check']),
        Concept('missing', 'Handle missing values', <String>['missing', 'impute', 'drop', 'null*']),
        Concept('dupes', 'Remove duplicates', <String>['duplicate*', 'dedup*', 'unique']),
      ]),
    ],
    interview: <InterviewQuestion>[
      _iq('mk_da_drop', 'Weekly sales dropped 15%. How would you find out why?', Competency.problemSolving, const <Concept>[
        Concept('data', 'Check the data first', <String>['data quality', 'tracking', 'missing data', 'check the data']),
        Concept('segment', 'Segment the drop', <String>['segment*', 'region*', 'product*', 'channel*', 'break down']),
        Concept('cause', 'Test causes', <String>['hypothes*', 'season*', 'price*', 'compare', 'last year']),
      ]),
      _iq('mk_da_sql', 'How would you write a query to find the top five customers by total spend?', Competency.technical, const <Concept>[
        Concept('group', 'GROUP BY and SUM', <String>['group by', 'sum']),
        Concept('order', 'ORDER BY DESC and LIMIT', <String>['order by', 'desc', 'limit', 'top']),
        Concept('join', 'Join to customers', <String>['join', 'customer_id', 'customers']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'security', deptId: 'cs', company: 'ironclad', team: 'Security Operations Centre', supervisor: 'Rachel Moreno', supervisorRole: 'SOC Shift Lead',
    labs: <String>['cy_lab_monitoring', 'cy_lab_network', 'cy_lab_vuln', 'cy_lab_ir', 'cy_lab_forensics', 'cy_lab_awareness'],
    titles: _ladder('Security Intern', 'SOC Analyst (Tier 1)', 'Cybersecurity Analyst', 'Security Engineer', 'Senior Security Engineer', 'SOC Manager'),
    questions: <ApplicationQuestion>[_motivation('security')],
    interview: <InterviewQuestion>[
      _iq('mk_sec_phish', 'An employee clicked a phishing link and entered their password. What do you do?', Competency.problemSolving, const <Concept>[
        Concept('contain', 'Contain', <String>['reset', 'password', 'disable', 'revoke', 'session*', 'isolate']),
        Concept('investigate', 'Investigate', <String>['log*', 'sign-in*', 'mfa', 'forward*', 'mailbox']),
        Concept('report', 'Report and learn', <String>['report', 'incident', 'notify', 'training', 'block']),
      ]),
      _iq('mk_sec_alert', 'How do you decide whether an alert is a real incident or a false positive?', Competency.technical, const <Concept>[
        Concept('context', 'Context', <String>['context', 'baseline', 'normal', 'user', 'asset']),
        Concept('evidence', 'Corroborating evidence', <String>['correlat*', 'other log*', 'evidence', 'indicator*']),
        Concept('escalate', 'Escalate/document', <String>['escalat*', 'document', 'ticket', 'tier 2']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'itsupport', deptId: 'cs', company: 'bluehelix', team: 'Service Desk', supervisor: 'Gareth Hughes', supervisorRole: 'Service Desk Manager',
    labs: <String>['it_lab_helpdesk', 'it_lab_hardware', 'it_lab_netadmin', 'it_lab_itsm', 'it_lab_sysadmin'],
    titles: _ladder('IT Support Intern', 'IT Support Specialist', 'IT Support Analyst', 'Systems Administrator', 'Senior Systems Administrator', 'IT Service Manager'),
    questions: <ApplicationQuestion>[_motivation('itsupport')],
    interview: <InterviewQuestion>[
      _iq('mk_it_wifi', 'A teacher says the Wi-Fi does not work in her classroom. Walk me through what you do.', Competency.problemSolving, const <Concept>[
        Concept('questions', 'Ask and scope', <String>['ask', 'which device*', 'others', 'when', 'error']),
        Concept('check', 'Check basics', <String>['restart', 'ip', 'ping', 'access point', 'connected', 'ssid']),
        Concept('record', 'Record and follow up', <String>['ticket', 'document', 'follow up', 'escalat*']),
      ]),
      _iq('mk_it_angry', 'A frustrated user has been waiting two days for a fix. How do you handle the call?', Competency.communication, const <Concept>[
        Concept('empathy', 'Acknowledge', <String>['apologi*', 'understand', 'sorry', 'frustrat*']),
        Concept('own', 'Take ownership', <String>['i will', 'own', 'priority', 'update']),
        Concept('time', 'Give a timeline', <String>['by', 'today', 'timeline', 'hour*', 'follow up']),
      ]),
    ],
  ),
  // ---------------------------------------------------------------- health
  RoleFamily(
    id: 'nursing', deptId: 'nursing', company: 'mercy', team: 'Medical-Surgical Unit', supervisor: 'Joy Mensah, RN', supervisorRole: 'Nurse Unit Manager',
    labs: <String>['nu_lab_vitals', 'nu_lab_assessment', 'nu_lab_meds', 'nu_lab_documentation', 'nu_lab_medsurg', 'nu_lab_procedures', 'nu_lab_emergency', 'nu_lab_shift'],
    hospital: <String>['ward_postop', 'shift_ward_am', 'ed_asthma', 'ward_diabetes', 'medsurg_delirium', 'peds_bronchiolitis', 'onc_neutropenic', 'maternity_pph', 'icu_sepsis'],
    titles: _ladder('Nursing Assistant Trainee', 'Nursing Graduate Trainee', 'Staff Nurse (simulation)', 'Senior Staff Nurse (simulation)', 'Charge Nurse (simulation)', 'Nurse Unit Manager (simulation)'),
    note: _clinicalNote,
    questions: <ApplicationQuestion>[
      _motivation('nursing'),
      _aq('nursing_safety', 'Describe how you keep patients safe during a busy shift.', const <Concept>[
        Concept('prioritise', 'Prioritising', <String>['priorit*', 'most unwell', 'abc', 'airway', 'urgent']),
        Concept('escalate', 'Escalating', <String>['escalat*', 'sbar', 'call', 'charge nurse', 'doctor', 'rapid response']),
        Concept('check', 'Checks and documentation', <String>['check*', 'document*', 'chart', 'hand hygiene', 'identity']),
      ]),
    ],
    interview: <InterviewQuestion>[
      _iq('mk_nu_deteriorate', 'How would you respond to a patient whose condition suddenly deteriorates?', Competency.problemSolving, const <Concept>[
        Concept('abcde', 'Assess ABCDE / vital signs', <String>['abcde', 'airway', 'breathing', 'vital sign*', 'observations', 'oxygen saturation']),
        Concept('escalate', 'Escalate with SBAR', <String>['escalat*', 'sbar', 'rapid response', 'call for help', 'physician', 'doctor']),
        Concept('stay', 'Stay, monitor and document', <String>['stay with', 'monitor', 'document*', 'reassess']),
      ]),
      _iq('mk_nu_family', 'How would you communicate with a worried family member?', Competency.communication, const <Concept>[
        Concept('listen', 'Listen and acknowledge', <String>['listen', 'acknowledg*', 'understand', 'empath*']),
        Concept('privacy', 'Respect confidentiality', <String>['consent', 'confidential*', 'privacy', 'hipaa', 'permission']),
        Concept('clear', 'Clear, honest information', <String>['explain', 'plain language', 'honest', 'update', 'doctor will']),
      ]),
      _iq('mk_nu_prioritise', 'You have four patients and two need you at once. How do you prioritise?', Competency.readiness, const <Concept>[
        Concept('acuity', 'By clinical urgency', <String>['urgent', 'abc', 'unstable', 'acuity', 'deteriorat*', 'pain']),
        Concept('delegate', 'Delegate safely', <String>['delegat*', 'colleague', 'assistant', 'charge nurse', 'ask for help']),
        Concept('communicate', 'Tell the other patient', <String>['tell', 'explain', 'come back', 'reassure']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'medtrainee', deptId: 'medicine', company: 'mercy', team: 'Internal Medicine', supervisor: 'Dr Farah Siddiqui', supervisorRole: 'Attending Physician',
    labs: <String>['md_lab_assessment', 'md_lab_exam', 'md_lab_diagnostics', 'md_lab_reasoning', 'md_lab_emergency', 'md_lab_anatomy'],
    hospital: <String>['ed_chest_pain', 'cardio_af', 'medsurg_delirium', 'neuro_stroke', 'lab_potassium', 'icu_sepsis', 'radiology_contrast'],
    titles: _ladder('Clinical Observer', 'Medical Graduate Trainee (simulation)', 'Resident Physician (simulation)', 'Senior Resident (simulation)', 'Chief Resident (simulation)', 'Attending Physician (simulation)'),
    note: _clinicalNote,
    payFrequency: 'monthly',
    questions: <ApplicationQuestion>[
      _motivation('medtrainee'),
      _aq('med_reasoning', 'Describe how you approach a patient with chest pain, from history to first investigations.', const <Concept>[
        Concept('history', 'Focused history', <String>['history', 'onset', 'character', 'radiat*', 'risk factor*']),
        Concept('danger', 'Rule out dangerous causes', <String>['acs', 'myocardial', 'heart attack', 'pulmonary embol*', 'dissection', 'red flag*']),
        Concept('tests', 'ECG and tests', <String>['ecg', 'troponin', 'chest x-ray', 'blood test*']),
      ]),
    ],
    interview: <InterviewQuestion>[
      _iq('mk_md_ddx', 'A 58-year-old has chest pain, sweating and dizziness. What is your differential and first steps?', Competency.technical, const <Concept>[
        Concept('acs', 'Acute coronary syndrome first', <String>['acs', 'myocardial infarction', 'heart attack', 'mi', 'stemi']),
        Concept('others', 'Other dangerous causes', <String>['pulmonary embol*', 'dissection', 'pneumothorax', 'arrhythmia']),
        Concept('steps', 'ECG within minutes and escalate', <String>['ecg', 'troponin', 'senior', 'escalat*', 'aspirin', 'monitor']),
      ]),
      _iq('mk_md_mistake', 'You realise you prescribed the wrong dose. What do you do?', Competency.readiness, const <Concept>[
        Concept('patient', 'Patient safety first', <String>['patient', 'check', 'harm', 'stop', 'hold']),
        Concept('tell', 'Tell your senior and pharmacist', <String>['senior', 'attending', 'pharmacist', 'tell', 'inform']),
        Concept('report', 'Report and learn', <String>['incident report', 'report', 'duty of candour', 'disclose', 'learn']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'clinresearch', deptId: 'medicine', company: 'cedar', team: 'Clinical Trials Unit', supervisor: 'Dr Helena Brooks', supervisorRole: 'Principal Investigator',
    labs: <String>['md_lab_research', 'md_lab_assessment', 'ds_lab_analysis', 'nu_lab_documentation'],
    titles: _ladder('Clinical Research Intern', 'Clinical Research Assistant', 'Clinical Research Associate', 'Clinical Research Coordinator', 'Senior Clinical Research Associate', 'Clinical Operations Manager'),
    note: _clinicalNote,
    questions: <ApplicationQuestion>[_motivation('clinresearch')],
    interview: <InterviewQuestion>[
      _iq('mk_cr_consent', 'What makes informed consent valid in a clinical trial?', Competency.technical, const <Concept>[
        Concept('info', 'Understandable information', <String>['information', 'risks', 'benefits', 'understand']),
        Concept('voluntary', 'Voluntary, can withdraw', <String>['voluntary', 'withdraw', 'no pressure', 'coercion']),
        Concept('capacity', 'Capacity and documentation', <String>['capacity', 'signed', 'document*', 'witness']),
      ]),
      _iq('mk_cr_deviation', 'You notice a protocol deviation in a participant\'s record. What do you do?', Competency.problemSolving, const <Concept>[
        Concept('report', 'Report it', <String>['report', 'investigator', 'sponsor', 'deviation log']),
        Concept('safety', 'Check participant safety', <String>['safety', 'participant', 'adverse']),
        Concept('prevent', 'Prevent recurrence', <String>['retrain', 'prevent', 'corrective', 'capa']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'medlab', deptId: 'medicine', company: 'cedar', team: 'Diagnostics Laboratory', supervisor: 'Marcus Webb', supervisorRole: 'Laboratory Supervisor',
    labs: <String>['md_lab_diagnostics', 'bi_lab_micro', 'ch_lab_analytical', 'bi_lab_microscopy'],
    hospital: <String>['lab_potassium'],
    titles: _ladder('Laboratory Intern', 'Medical Laboratory Assistant', 'Medical Laboratory Technician', 'Medical Laboratory Scientist', 'Senior Laboratory Scientist', 'Laboratory Manager'),
    note: _clinicalNote,
    payFrequency: 'weekly',
    questions: <ApplicationQuestion>[_motivation('medlab')],
    interview: <InterviewQuestion>[
      _iq('mk_ml_qc', 'Your quality-control sample is out of range. What do you do before releasing patient results?', Competency.technical, const <Concept>[
        Concept('hold', 'Hold the results', <String>['hold', 'do not release', 'stop', "don't release"]),
        Concept('troubleshoot', 'Troubleshoot', <String>['recalibrat*', 'reagent', 'repeat', 'rerun', 'instrument']),
        Concept('record', 'Record and inform', <String>['document*', 'log', 'supervisor', 'inform']),
      ]),
      _iq('mk_ml_label', 'A sample arrives unlabelled. What do you do?', Competency.readiness, const <Concept>[
        Concept('reject', 'Do not process', <String>['reject', 'do not process', "don't process", 'cannot be used']),
        Concept('contact', 'Contact the ward', <String>['contact', 'call', 'ward', 'recollect', 're-collect']),
        Concept('record', 'Record it', <String>['document*', 'record', 'incident']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'healthadmin', deptId: 'medicine', company: 'mercy', team: 'Patient Services Administration', supervisor: 'Angela Ruiz', supervisorRole: 'Practice Manager',
    labs: <String>['ba_lab_operations', 'nu_lab_documentation', 'ba_lab_people', 'ba_lab_projects'],
    hospital: <String>['pharmacy_allergy'],
    titles: _ladder('Healthcare Admin Intern', 'Healthcare Administration Assistant', 'Healthcare Administrator', 'Healthcare Operations Coordinator', 'Senior Healthcare Administrator', 'Practice Manager'),
    questions: <ApplicationQuestion>[_motivation('healthadmin')],
    interview: <InterviewQuestion>[
      _iq('mk_ha_records', 'A patient asks you to email their records to a friend. How do you respond?', Competency.readiness, const <Concept>[
        Concept('privacy', 'Privacy rules', <String>['privacy', 'hipaa', 'confidential*', 'consent', 'authori*']),
        Concept('identity', 'Verify identity and request', <String>['verify', 'identity', 'written request', 'form']),
        Concept('help', 'Offer the correct route', <String>['explain', 'process', 'portal', 'help them']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'publichealth', deptId: 'nursing', company: 'cedar', team: 'Population Health Research', supervisor: 'Dr Samuel Ortiz', supervisorRole: 'Epidemiologist',
    labs: <String>['md_lab_research', 'ds_lab_analysis', 'ma_lab_stats', 'ds_lab_viz'],
    titles: _ladder('Public Health Intern', 'Public Health Research Assistant', 'Public Health Analyst', 'Epidemiologist', 'Senior Epidemiologist', 'Public Health Program Manager'),
    questions: <ApplicationQuestion>[_motivation('publichealth')],
    interview: <InterviewQuestion>[
      _iq('mk_ph_outbreak', 'Clinics report more stomach illness than usual this week. How would you investigate?', Competency.problemSolving, const <Concept>[
        Concept('define', 'Case definition and counts', <String>['case definition', 'count', 'baseline', 'compare']),
        Concept('pattern', 'Time, place, person', <String>['time', 'place', 'person', 'map', 'common source']),
        Concept('act', 'Report and control', <String>['report', 'health department', 'control', 'notify']),
      ]),
    ],
  ),
  // ---------------------------------------------------------------- law
  RoleFamily(
    id: 'law', deptId: 'law', company: 'harlow', team: 'Litigation and Commercial', supervisor: 'Eleanor Harlow', supervisorRole: 'Supervising Partner',
    labs: <String>['law_lab_research', 'law_lab_analysis', 'law_lab_drafting', 'law_lab_consultation', 'law_lab_negotiation', 'law_lab_courtroom', 'law_lab_fullcase'],
    titles: _ladder('Legal Intern', 'Legal Research Assistant', 'Junior Legal Associate', 'Legal Associate', 'Senior Associate', 'Legal Practice Manager'),
    note: _legalNote,
    payFrequency: 'monthly',
    questions: <ApplicationQuestion>[
      _motivation('law'),
      _aq('law_research', 'How would you research a legal issue you have never seen before?', const <Concept>[
        Concept('facts', 'Identify the issue and facts', <String>['issue', 'facts', 'question']),
        Concept('sources', 'Primary and secondary sources', <String>['statute*', 'case law', 'cases', 'secondary', 'treatise', 'database']),
        Concept('check', 'Check authority is current', <String>['still good law', 'current', 'citator', 'shepardi*', 'overruled']),
      ]),
    ],
    interview: <InterviewQuestion>[
      _iq('mk_law_evidence', 'How would you organise evidence for a case?', Competency.technical, const <Concept>[
        Concept('index', 'Index and chronology', <String>['index', 'chronolog*', 'timeline', 'bundle']),
        Concept('link', 'Link evidence to issues', <String>['issue*', 'element*', 'prove', 'link']),
        Concept('privilege', 'Privilege and disclosure', <String>['privilege*', 'disclos*', 'confidential*']),
      ]),
      _iq('mk_law_weakness', 'How would you identify weaknesses in a legal argument?', Competency.problemSolving, const <Concept>[
        Concept('counter', 'Argue the other side', <String>['other side', 'opposing', 'counter*', 'devil']),
        Concept('authority', 'Test the authority', <String>['distinguish*', 'precedent', 'binding', 'authority']),
        Concept('facts', 'Test the facts', <String>['evidence', 'facts', 'gap*', 'assumption*']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'compliance', deptId: 'law', company: 'harlow', team: 'Regulatory and Compliance', supervisor: 'Marcus Lee', supervisorRole: 'Head of Compliance',
    labs: <String>['law_lab_analysis', 'law_lab_drafting', 'law_lab_research', 'ba_lab_operations'],
    titles: _ladder('Compliance Intern', 'Corporate Legal Assistant', 'Compliance Analyst', 'Senior Compliance Analyst', 'Compliance Manager', 'Chief Compliance Officer'),
    note: _legalNote,
    questions: <ApplicationQuestion>[_motivation('compliance')],
    interview: <InterviewQuestion>[
      _iq('mk_co_breach', 'You find a team skipping a required check to hit a deadline. What do you do?', Competency.readiness, const <Concept>[
        Concept('assess', 'Assess the risk', <String>['risk', 'impact', 'regulation', 'law']),
        Concept('escalate', 'Escalate', <String>['escalat*', 'report', 'manager', 'compliance officer']),
        Concept('fix', 'Fix the process', <String>['process', 'control', 'training', 'remediat*']),
      ]),
    ],
  ),
  // ---------------------------------------------------------------- engineering
  RoleFamily(
    id: 'mechanical', deptId: 'engineering', company: 'meridian', team: 'Mechanical Design Office', supervisor: 'Ian Fraser, PE', supervisorRole: 'Principal Engineer',
    labs: <String>['me_lab_mechanics', 'me_lab_machine', 'me_lab_cad', 'me_lab_failure', 'me_lab_thermo', 'me_lab_fluids'],
    titles: _ladder('Mechanical Engineering Intern', 'Graduate Mechanical Engineer', 'Junior Mechanical Engineer', 'Mechanical Engineer', 'Senior Design Engineer', 'Engineering Manager'),
    questions: <ApplicationQuestion>[
      _motivation('mechanical'),
      _aq('mech_design', 'Describe a design or calculation you did. How did you check it was right?', const <Concept>[
        Concept('calc', 'Calculation/design', <String>['calculat*', 'design*', 'load*', 'stress', 'cad']),
        Concept('check', 'Independent check', <String>['check*', 'verified', 'hand calc*', 'simulation', 'test*']),
        Concept('margin', 'Safety factor/standards', <String>['safety factor', 'margin', 'standard*', 'tolerance*']),
      ]),
    ],
    interview: <InterviewQuestion>[
      _iq('mk_me_fail', 'A shaft keeps failing in service. How would you investigate?', Competency.problemSolving, const <Concept>[
        Concept('evidence', 'Examine the failure', <String>['fracture', 'surface', 'beach mark*', 'inspect*', 'examine']),
        Concept('cause', 'Identify the mechanism', <String>['fatigue', 'overload', 'corrosion', 'stress concentration']),
        Concept('fix', 'Recommend a fix', <String>['redesign', 'fillet', 'material', 'recommend*']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'civil', deptId: 'engineering', company: 'meridian', team: 'Structures and Site', supervisor: 'Amina Yusuf, PE', supervisorRole: 'Project Engineer',
    labs: <String>['ce_lab_structures', 'ce_lab_materials', 'ce_lab_geotech', 'ce_lab_surveying', 'ce_lab_transport', 'ce_lab_construction'],
    titles: _ladder('Civil Engineering Intern', 'Graduate Civil Engineer', 'Junior Civil Engineer', 'Civil Engineer', 'Senior Structural Engineer', 'Engineering Manager'),
    questions: <ApplicationQuestion>[_motivation('civil')],
    interview: <InterviewQuestion>[
      _iq('mk_ce_crack', 'Cracks appear in a newly poured slab. What do you check?', Competency.problemSolving, const <Concept>[
        Concept('pattern', 'Crack pattern and width', <String>['pattern', 'width', 'measure', 'map']),
        Concept('causes', 'Possible causes', <String>['shrinkage', 'curing', 'settlement', 'overload', 'reinforcement']),
        Concept('tests', 'Tests and records', <String>['cube*', 'core*', 'test*', 'records', 'mix']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'electrical', deptId: 'engineering', company: 'meridian', team: 'Electrical Test Laboratory', supervisor: 'Peter Lindqvist', supervisorRole: 'Senior Electrical Engineer',
    labs: <String>['ee_lab_construction', 'ee_lab_analysis', 'ee_lab_faults', 'ee_lab_electronics', 'ee_lab_logic', 'ee_lab_power'],
    titles: _ladder('Electrical Engineering Intern', 'Electrical Engineering Technician', 'Junior Electrical Engineer', 'Electrical Engineer', 'Senior Electrical Engineer', 'Engineering Manager'),
    questions: <ApplicationQuestion>[_motivation('electrical')],
    interview: <InterviewQuestion>[
      _iq('mk_ee_fault', 'A circuit board powers on but the output is zero. How do you find the fault safely?', Competency.problemSolving, const <Concept>[
        Concept('safe', 'Work safely', <String>['isolate', 'de-energi*', 'safe', 'ppe', 'discharge']),
        Concept('measure', 'Measure systematically', <String>['multimeter', 'voltage', 'continuity', 'measure', 'oscilloscope']),
        Concept('trace', 'Trace from supply to output', <String>['supply', 'stage by stage', 'trace', 'half-split']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'chemical', deptId: 'engineering', company: 'meridian', team: 'Process Engineering', supervisor: 'Dr Kavita Rao', supervisorRole: 'Process Engineering Manager',
    labs: <String>['che_lab_fundamentals', 'che_lab_reaction', 'che_lab_separation', 'che_lab_flowsheet', 'che_lab_control', 'che_lab_safety'],
    titles: _ladder('Process Engineering Intern', 'Chemical Engineering Trainee', 'Junior Process Engineer', 'Process Engineer', 'Senior Process Engineer', 'Process Engineering Manager'),
    questions: <ApplicationQuestion>[_motivation('chemical')],
    interview: <InterviewQuestion>[
      _iq('mk_che_temp', 'A reactor temperature is rising above its limit. What do you do?', Competency.problemSolving, const <Concept>[
        Concept('safe', 'Make it safe', <String>['cooling', 'stop feed', 'shut down', 'emergency', 'alarm']),
        Concept('inform', 'Inform the control room/supervisor', <String>['inform', 'supervisor', 'control room', 'escalat*']),
        Concept('cause', 'Find the cause', <String>['cause', 'instrument', 'runaway', 'exotherm*', 'investigat*']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'aerospace', deptId: 'engineering', company: 'skyforge', team: 'Design and Test', supervisor: 'Colin Marsh', supervisorRole: 'Chief Engineer',
    labs: <String>['ae_lab_aero', 'ae_lab_design', 'ae_lab_flight', 'ae_lab_propulsion', 'ae_lab_systems', 'ae_lab_project'],
    titles: _ladder('Aerospace Engineering Intern', 'Graduate Aerospace Engineer', 'Junior Aerospace Engineer', 'Aerospace Engineer', 'Senior Aerospace Engineer', 'Chief Engineer'),
    questions: <ApplicationQuestion>[_motivation('aerospace')],
    interview: <InterviewQuestion>[
      _iq('mk_ae_lift', 'How would you increase the lift of a wing without changing its span?', Competency.technical, const <Concept>[
        Concept('cl', 'Lift coefficient/camber/flaps', <String>['camber', 'flap*', 'angle of attack', 'lift coefficient', 'cl']),
        Concept('area', 'Area or speed', <String>['chord', 'area', 'speed', 'velocity', 'density']),
        Concept('tradeoff', 'Trade-offs', <String>['drag', 'stall', 'weight', 'trade-off']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'industrial', deptId: 'engineering', company: 'keystone', team: 'Operations Excellence', supervisor: 'Lucia Fernández', supervisorRole: 'Operations Manager',
    labs: <String>['ie_lab_improvement', 'ie_lab_quality', 'ie_lab_manufacturing', 'ie_lab_or', 'ie_lab_supply', 'ie_lab_simulation'],
    titles: _ladder('Industrial Engineering Intern', 'Industrial Engineering Analyst', 'Industrial Engineer', 'Senior Industrial Engineer', 'Operations Excellence Lead', 'Operations Director'),
    questions: <ApplicationQuestion>[_motivation('industrial')],
    interview: <InterviewQuestion>[
      _iq('mk_ie_bottleneck', 'A production line misses its daily target. How would you find the bottleneck?', Competency.problemSolving, const <Concept>[
        Concept('measure', 'Measure cycle times', <String>['cycle time*', 'time study', 'measure', 'data']),
        Concept('constraint', 'Find the constraint', <String>['bottleneck', 'constraint', 'queue', 'utili*']),
        Concept('improve', 'Improve and verify', <String>['balance', 'kaizen', 'improve', 'verify', 'pilot']),
      ]),
    ],
  ),
  // ---------------------------------------------------------------- business
  RoleFamily(
    id: 'accounting', deptId: 'business', company: 'summit', team: 'Accounts and Audit', supervisor: 'Helen Carter, CPA', supervisorRole: 'Audit Manager',
    labs: <String>['acc_lab_bookkeeping', 'acc_lab_reconciliation', 'acc_lab_ledger', 'acc_lab_statements', 'acc_lab_double', 'acc_lab_audit', 'acc_lab_cost'],
    titles: _ladder('Accounting Intern', 'Junior Accountant', 'Staff Accountant', 'Accountant', 'Senior Accountant', 'Finance Manager'),
    payFrequency: 'monthly',
    questions: <ApplicationQuestion>[
      _motivation('accounting'),
      _aq('acc_recon', 'Your bank reconciliation is off by \$450. How would you find the difference?', const <Concept>[
        Concept('timing', 'Timing differences', <String>['outstanding', 'deposit* in transit', 'uncleared', 'timing']),
        Concept('errors', 'Errors and missing items', <String>['error*', 'transpos*', 'missing', 'bank fee*', 'duplicate']),
        Concept('adjust', 'Adjust and document', <String>['adjust*', 'journal', 'document*', 'review']),
      ]),
    ],
    interview: <InterviewQuestion>[
      _iq('mk_acc_reconcile', 'What would you do if your financial figures did not reconcile at month end?', Competency.problemSolving, const <Concept>[
        Concept('trace', 'Trace the difference', <String>['trace', 'compare', 'ledger', 'statement', 'difference']),
        Concept('causes', 'Look for common causes', <String>['timing', 'duplicate', 'transpos*', 'missing', 'cut-off']),
        Concept('escalate', 'Document and escalate', <String>['document*', 'manager', 'escalat*', 'not force']),
      ]),
      _iq('mk_acc_invoice', 'An invoice arrives with no purchase order. What do you do?', Competency.readiness, const <Concept>[
        Concept('verify', 'Verify it', <String>['verify', 'check', 'approval', 'goods received']),
        Concept('hold', 'Hold payment', <String>['hold', 'do not pay', "don't pay", 'query']),
        Concept('contact', 'Contact the right people', <String>['contact', 'supplier', 'budget holder', 'manager']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'finance', deptId: 'business', company: 'atlas', team: 'Investment Desk', supervisor: 'Victor Mensah, CFA', supervisorRole: 'Portfolio Manager',
    labs: <String>['fi_lab_fsa', 'fi_lab_corporate', 'fi_lab_risk', 'fi_lab_investment', 'fi_lab_portfolio', 'fi_lab_math'],
    titles: _ladder('Finance Intern', 'Financial Analyst', 'Investment Research Analyst', 'Senior Financial Analyst', 'Associate Portfolio Manager', 'Portfolio Manager'),
    payFrequency: 'monthly',
    questions: <ApplicationQuestion>[_motivation('finance')],
    interview: <InterviewQuestion>[
      _iq('mk_fi_perf', 'How would you analyse a company\'s financial performance?', Competency.technical, const <Concept>[
        Concept('statements', 'Use the three statements', <String>['income statement', 'balance sheet', 'cash flow']),
        Concept('ratios', 'Ratios and trends', <String>['margin*', 'ratio*', 'growth', 'trend*', 'return on']),
        Concept('compare', 'Compare to peers', <String>['peer*', 'industry', 'compare', 'benchmark']),
      ]),
      _iq('mk_fi_risk', 'How would you identify financial risk in a company?', Competency.problemSolving, const <Concept>[
        Concept('liquidity', 'Liquidity and leverage', <String>['liquidity', 'current ratio', 'debt', 'leverage', 'interest cover']),
        Concept('cash', 'Cash flow', <String>['cash flow', 'burn', 'working capital']),
        Concept('external', 'Market and concentration risk', <String>['customer concentration', 'market', 'currency', 'interest rate']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'marketing', deptId: 'business', company: 'brightwave', team: 'Campaigns', supervisor: 'Chloe Bennett', supervisorRole: 'Account Director',
    labs: <String>['mk_lab_research', 'mk_lab_content', 'mk_lab_ads', 'mk_lab_analytics', 'mk_lab_social', 'mk_lab_brand', 'mk_lab_campaign'],
    titles: _ladder('Marketing Intern', 'Marketing Associate', 'Marketing Specialist', 'Marketing Manager', 'Senior Marketing Manager', 'Head of Marketing'),
    questions: <ApplicationQuestion>[_motivation('marketing')],
    interview: <InterviewQuestion>[
      _iq('mk_mk_campaign', 'How would you plan a campaign for a new product with a \$10,000 budget?', Competency.problemSolving, const <Concept>[
        Concept('audience', 'Audience and goal', <String>['audience', 'target', 'goal', 'objective', 'persona']),
        Concept('channels', 'Channels and budget split', <String>['channel*', 'budget', 'social', 'search', 'email', 'allocat*']),
        Concept('measure', 'Measure results', <String>['measure', 'kpi', 'conversion*', 'roi', 'ctr', 'track']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'hr', deptId: 'business', company: 'peoplefirst', team: 'People Team', supervisor: 'Samuel Osei', supervisorRole: 'HR Manager',
    labs: <String>['hr_lab_recruitment', 'hr_lab_onboarding', 'hr_lab_interviews', 'hr_lab_relations', 'hr_lab_performance', 'hr_lab_workforce'],
    titles: _ladder('HR Intern', 'Human Resources Assistant', 'HR Coordinator', 'HR Business Partner', 'Senior HR Business Partner', 'HR Manager'),
    questions: <ApplicationQuestion>[_motivation('hr')],
    interview: <InterviewQuestion>[
      _iq('mk_hr_complaint', 'An employee tells you a manager is treating them unfairly. What do you do?', Competency.readiness, const <Concept>[
        Concept('listen', 'Listen and record', <String>['listen', 'record', 'notes', 'document*']),
        Concept('policy', 'Follow policy', <String>['policy', 'grievance', 'procedure', 'confidential*']),
        Concept('fair', 'Investigate fairly', <String>['investigat*', 'both sides', 'impartial', 'fair']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'business', deptId: 'business', company: 'keystone', team: 'Business Operations', supervisor: 'Jonathan Reid', supervisorRole: 'Operations Director',
    labs: <String>['ba_lab_analytics', 'ba_lab_operations', 'ba_lab_projects', 'ba_lab_strategy', 'ib_lab_supply', 'en_lab_discovery', 'en_lab_validation', 'ib_lab_research'],
    titles: _ladder('Business Intern', 'Operations Associate', 'Business Analyst', 'Senior Business Analyst', 'Business Operations Manager', 'Director of Operations'),
    questions: <ApplicationQuestion>[_motivation('business')],
    interview: <InterviewQuestion>[
      _iq('mk_ba_case', 'Store profits fell this quarter although sales rose. How would you analyse it?', Competency.problemSolving, const <Concept>[
        Concept('costs', 'Look at costs and margins', <String>['cost*', 'margin*', 'expense*']),
        Concept('mix', 'Product/customer mix and price', <String>['mix', 'discount*', 'price*', 'product*']),
        Concept('data', 'Use data and recommend', <String>['data', 'compare', 'recommend*', 'spreadsheet']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'economics', deptId: 'business', company: 'policylab', team: 'Economic Research Unit', supervisor: 'Dr Ruth Adler', supervisorRole: 'Senior Economist',
    labs: <String>['ec_lab_data', 'ec_lab_policy', 'ec_lab_macro', 'ec_lab_micro', 'ec_lab_structures', 'ec_lab_international'],
    titles: _ladder('Economics Intern', 'Economics Research Assistant', 'Research Economist I', 'Economist', 'Senior Economist', 'Research Director'),
    questions: <ApplicationQuestion>[_motivation('economics')],
    interview: <InterviewQuestion>[
      _iq('mk_ec_minwage', 'How would you estimate the effect of a minimum-wage increase on local employment?', Competency.technical, const <Concept>[
        Concept('data', 'Data before and after', <String>['data', 'before and after', 'employment', 'time series']),
        Concept('control', 'A comparison group', <String>['control', 'comparison', 'difference-in-difference*', 'counterfactual']),
        Concept('caveats', 'Other factors', <String>['confound*', 'other factors', 'season*', 'bias']),
      ]),
    ],
  ),
  // ---------------------------------------------------------------- mathematics and sciences
  RoleFamily(
    id: 'maths', deptId: 'mathematics', company: 'quantis', team: 'Modelling Team', supervisor: 'Dr Amara Osei', supervisorRole: 'Principal Analyst',
    labs: <String>['ma_lab_stats', 'ma_lab_linalg', 'ma_lab_de', 'ma_lab_applied', 'ma_lab_calculus', 'ma_lab_algebra'],
    titles: _ladder('Mathematics Research Intern', 'Mathematics Research Assistant', 'Junior Data Analyst', 'Quantitative Analyst', 'Senior Quantitative Analyst', 'Analytics Manager'),
    questions: <ApplicationQuestion>[_motivation('maths')],
    interview: <InterviewQuestion>[
      _iq('mk_ma_model', 'How would you build and check a model that predicts demand?', Competency.technical, const <Concept>[
        Concept('assume', 'State assumptions', <String>['assum*', 'variable*', 'simplif*']),
        Concept('fit', 'Fit to data', <String>['fit', 'regression', 'data', 'parameter*', 'estimate']),
        Concept('validate', 'Validate', <String>['validat*', 'residual*', 'test data', 'error', 'sensitivity']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'biology', deptId: 'sciences', company: 'verdant', team: 'Cell and Molecular Biology', supervisor: 'Dr Isaac Mwangi', supervisorRole: 'Group Leader',
    labs: <String>['bi_lab_cell', 'bi_lab_microscopy', 'bi_lab_genetics', 'bi_lab_micro', 'bi_lab_research', 'bi_lab_human'],
    titles: _ladder('Biology Research Intern', 'Laboratory Research Assistant', 'Biology Research Assistant', 'Research Scientist', 'Senior Research Scientist', 'Laboratory Manager'),
    questions: <ApplicationQuestion>[_motivation('biology')],
    interview: <InterviewQuestion>[
      _iq('mk_bi_contam', 'Your cell cultures look contaminated. What do you do?', Competency.problemSolving, const <Concept>[
        Concept('contain', 'Contain and dispose safely', <String>['discard', 'dispose', 'autoclave', 'isolate', 'biosafety']),
        Concept('cause', 'Find the source', <String>['source', 'aseptic', 'media', 'incubator', 'check']),
        Concept('record', 'Record and inform', <String>['record', 'notebook', 'inform', 'supervisor']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'chemistry', deptId: 'sciences', company: 'verdant', team: 'Analytical Chemistry', supervisor: 'Dr Elena Petrova', supervisorRole: 'Laboratory Manager',
    labs: <String>['ch_lab_titration', 'ch_lab_analytical', 'ch_lab_stoichiometry', 'ch_lab_acids', 'ch_lab_equations', 'ch_lab_capstone'],
    titles: _ladder('Chemistry Intern', 'Chemistry Laboratory Assistant', 'Laboratory Analyst', 'Analytical Chemist', 'Senior Analytical Chemist', 'Laboratory Manager'),
    payFrequency: 'weekly',
    questions: <ApplicationQuestion>[_motivation('chemistry')],
    interview: <InterviewQuestion>[
      _iq('mk_ch_titr', 'Three titration results disagree. What do you do?', Competency.technical, const <Concept>[
        Concept('repeat', 'Repeat for concordant results', <String>['repeat', 'concordant', 'within 0.1', 'again']),
        Concept('technique', 'Check technique', <String>['burette', 'end point', 'meniscus', 'rinse', 'calibrat*']),
        Concept('record', 'Record everything', <String>['record', 'notebook', 'all results']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'physics', deptId: 'sciences', company: 'verdant', team: 'Measurement Laboratory', supervisor: 'Dr Tom Okonkwo', supervisorRole: 'Lead Physicist',
    labs: <String>['ph_lab_experimental', 'ph_lab_mechanics', 'ph_lab_electricity', 'ph_lab_waves', 'ph_lab_thermo', 'ph_lab_modern'],
    titles: _ladder('Physics Research Intern', 'Junior Physicist', 'Physicist', 'Research Physicist', 'Senior Physicist', 'Head of Measurement'),
    questions: <ApplicationQuestion>[_motivation('physics')],
    interview: <InterviewQuestion>[
      _iq('mk_ph_uncert', 'How do you report a measurement and its uncertainty?', Competency.technical, const <Concept>[
        Concept('repeat', 'Repeat readings', <String>['repeat*', 'mean', 'average']),
        Concept('uncertainty', 'Estimate uncertainty', <String>['uncertaint*', 'standard deviation', 'error bar*', 'resolution']),
        Concept('sigfig', 'Significant figures and units', <String>['significant figure*', 'unit*', '±']),
      ]),
    ],
  ),
  // ---------------------------------------------------------------- communication
  RoleFamily(
    id: 'writing', deptId: 'communication', company: 'inkwell', team: 'Editorial', supervisor: 'Grace Whitmore', supervisorRole: 'Managing Editor',
    labs: <String>['eg_lab_professional', 'eg_lab_editing', 'eg_lab_grammar', 'eg_lab_academic', 'eg_lab_reading', 'mk_lab_content'],
    titles: _ladder('Editorial Intern', 'Editorial Assistant', 'Content Writer', 'Senior Writer', 'Senior Editor', 'Managing Editor'),
    payFrequency: 'weekly',
    questions: <ApplicationQuestion>[
      _motivation('writing'),
      _aq('writing_edit', 'How do you edit a draft that is accurate but hard to read?', const <Concept>[
        Concept('reader', 'Write for the reader', <String>['reader', 'audience', 'plain language']),
        Concept('structure', 'Structure', <String>['headline', 'structure', 'order', 'heading*', 'lead']),
        Concept('trim', 'Shorten and clarify', <String>['shorten', 'cut', 'concise', 'active voice', 'jargon']),
      ]),
    ],
    interview: <InterviewQuestion>[
      _iq('mk_wr_deadline', 'Two editors give you conflicting feedback an hour before deadline. What do you do?', Competency.communication, const <Concept>[
        Concept('clarify', 'Clarify priorities', <String>['ask', 'clarify', 'priorit*', 'who decides']),
        Concept('style', 'Use the style guide/brief', <String>['style guide', 'brief', 'audience']),
        Concept('deliver', 'Deliver on time', <String>['deadline', 'on time', 'deliver', 'note the change*']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'techwriting', deptId: 'communication', company: 'inkwell', team: 'Technical Documentation', supervisor: 'Arjun Mehta', supervisorRole: 'Documentation Lead',
    labs: <String>['eg_lab_professional', 'eg_lab_editing', 'eg_lab_academic', 'eg_lab_communication'],
    titles: _ladder('Documentation Intern', 'Junior Technical Writer', 'Technical Writer', 'Senior Technical Writer', 'Lead Technical Writer', 'Documentation Manager'),
    questions: <ApplicationQuestion>[_motivation('techwriting')],
    interview: <InterviewQuestion>[
      _iq('mk_tw_steps', 'How would you write instructions for setting up a new app for non-technical users?', Competency.technical, const <Concept>[
        Concept('test', 'Do it yourself first', <String>['do it myself', 'test', 'try', 'follow the steps']),
        Concept('steps', 'Numbered steps and screenshots', <String>['numbered', 'step*', 'screenshot*', 'one action']),
        Concept('users', 'Test with users', <String>['user*', 'feedback', 'usability']),
      ]),
    ],
  ),
  RoleFamily(
    id: 'comms', deptId: 'communication', company: 'inkwell', team: 'Communications and PR', supervisor: 'Nadia Haddad', supervisorRole: 'Communications Director',
    labs: <String>['eg_lab_communication', 'eg_lab_speaking', 'mk_lab_social', 'mk_lab_content', 'mk_lab_ads', 'eg_lab_professional'],
    titles: _ladder('Communications Intern', 'Communications Assistant', 'Public Relations Associate', 'Communications Specialist', 'Senior Communications Manager', 'Head of Communications'),
    questions: <ApplicationQuestion>[_motivation('comms')],
    interview: <InterviewQuestion>[
      _iq('mk_pr_crisis', 'A client is criticised online for a product fault. How would you respond?', Competency.problemSolving, const <Concept>[
        Concept('facts', 'Get the facts', <String>['facts', 'verify', 'what happened', 'legal']),
        Concept('respond', 'Respond quickly and honestly', <String>['acknowledg*', 'apologi*', 'statement', 'honest', 'quick*']),
        Concept('plan', 'Plan follow-up', <String>['update*', 'monitor', 'q&a', 'spokesperson', 'follow-up']),
      ]),
    ],
  ),
];

RoleFamily? roleFamily(String id) {
  for (final RoleFamily f in roleFamilies) {
    if (f.id == id) return f;
  }
  return null;
}

/// The family a market posting or workplace belongs to.
RoleFamily? familyOfWorkplace(String workplaceId) => workplaceId.startsWith('mk_') ? roleFamily(workplaceId.substring(3)) : null;

const Map<String, String> _deptPlan = <String, String>{
  'cs': 'cs_tech',
  'nursing': 'nu_iv',
  'medicine': 'md_iv',
  'law': 'law_iv',
  'engineering': 'en_iv',
  'business': 'bz_iv',
  'mathematics': 'ma_iv',
  'communication': 'co_iv',
  'sciences': 'sc_iv',
};

const Map<String, String> _city = <String, String>{
  'novatech': 'Austin, TX', 'quantumleaf': 'Denver, CO', 'ironclad': 'Arlington, VA', 'bluehelix': 'Columbus, OH', 'mercy': 'Portland, OR',
  'cedar': 'Raleigh, NC', 'harlow': 'Chicago, IL', 'meridian': 'Pittsburgh, PA', 'skyforge': 'Wichita, KS', 'summit': 'Minneapolis, MN',
  'atlas': 'New York, NY', 'brightwave': 'Atlanta, GA', 'peoplefirst': 'Memphis, TN', 'keystone': 'Charlotte, NC', 'policylab': 'Washington, DC',
  'quantis': 'Boston, MA', 'verdant': 'San Diego, CA', 'inkwell': 'Seattle, WA',
};

const Map<String, (JobType, CareerStage, CareerStage, int, String)> _levels = <String, (JobType, CareerStage, CareerStage, int, String)>{
  //            type               hired as                 needs (stage)           shortlist  experience text
  'Internship': (JobType.internship, CareerStage.intern, CareerStage.student, 45, 'No experience needed — coursework and projects count.'),
  'Entry-level': (JobType.entryLevel, CareerStage.entryLevel, CareerStage.student, 50, 'Open to students and graduates; projects, placements and part-time work count.'),
  'Junior': (JobType.junior, CareerStage.junior, CareerStage.student, 55, 'About a year of relevant experience, an internship or strong projects.'),
  'Mid-level': (JobType.midLevel, CareerStage.experienced, CareerStage.junior, 60, 'Two to three years in the field (in the simulation: reach Junior level first).'),
  'Senior': (JobType.senior, CareerStage.senior, CareerStage.experienced, 62, 'Five years or more (in the simulation: reach Experienced level first).'),
  'Management': (JobType.management, CareerStage.lead, CareerStage.senior, 65, 'Seven years or more including leading people (in the simulation: reach Senior level first).'),
};

JobPosting _role({
  required String id,
  required String family,
  required String title,
  required String level,
  required int salary,
  required List<String> keywords,
  required String education,
  required List<String> educationFields,
  required List<String> responsibilities,
  required String description,
  List<String> preferredKeywords = const <String>[],
  List<String> preferred = const <String>[],
  List<String> majors = const <String>[],
  String period = 'year',
  int positions = 2,
  String mode = 'Hybrid',
  int hours = 40,
  int openDay = 1,
  int window = 45,
}) {
  final RoleFamily f = roleFamily(family)!;
  final (JobType type, CareerStage hired, CareerStage needs, int mark, String exp) = _levels[level]!;
  final CompanyProfile c = marketCompanies[f.company]!;
  final int step = period == 'year' ? 500 : 1;
  int r(double v) => (v / step).round() * step;
  return JobPosting(
    id: 'mk_$id',
    deptId: f.deptId,
    company: c,
    title: title,
    type: type,
    stageOnHire: hired,
    description: '$description ${f.note}'.trim(),
    responsibilities: responsibilities,
    qualifications: <String>[education, ...keywords.take(4).map((String k) => 'Working knowledge of $k')],
    experience: exp,
    requirements: JobRequirements(minStage: needs),
    salaryMin: r(salary * 0.95),
    salaryMax: r(salary * 1.08),
    salaryPeriod: period,
    location: '${_city[f.company]} · $mode',
    openDay: openDay,
    deadlineDay: openDay + window,
    interviewPlanId: _deptPlan[f.deptId]!,
    workplaceId: 'mk_${f.id}',
    shortlistMark: mark,
    practicalRequired: false,
    level: level,
    department: f.team,
    hoursPerWeek: hours,
    positions: positions,
    workMode: mode,
    requiredEducation: education,
    preferred: preferred,
    keywords: keywords,
    preferredKeywords: preferredKeywords,
    educationFields: educationFields,
    questions: f.questions,
    roleQuestions: f.interview,
    payFrequency: period == 'hour' ? 'weekly' : f.payFrequency,
    benefits: <String>[
      'Simulated health, dental and vision cover',
      'Simulated 401(k) with 4% match',
      '${level == 'Internship' ? 10 : 15} days paid time off (simulated)',
      'Training budget and a named mentor',
    ],
    simulationNote: f.note,
    majors: majors,
  );
}

const List<String> _csEdu = <String>['computer science', 'software engineering', 'information technology', 'computer engineering', 'data science', 'computing'];
const List<String> _nuEdu = <String>['nursing', 'bsn', 'nursing assistant', 'cna', 'health'];
const List<String> _mdEdu = <String>['medicine', 'medical', 'md', 'biomedical', 'biology', 'health', 'pre-med', 'life science'];
const List<String> _lawEdu = <String>['law', 'legal', 'juris doctor', 'jd', 'paralegal', 'political science', 'criminal justice'];
const List<String> _engEdu = <String>['engineering', 'mechanical', 'civil', 'electrical', 'chemical', 'aerospace', 'industrial'];
const List<String> _bizEdu = <String>['business', 'accounting', 'finance', 'economics', 'marketing', 'management', 'commerce', 'bba', 'human resource'];
const List<String> _mathEdu = <String>['mathematics', 'statistics', 'math', 'data science', 'physics', 'economics'];
const List<String> _sciEdu = <String>['biology', 'chemistry', 'physics', 'biochemistry', 'life science', 'science'];
const List<String> _comEdu = <String>['english', 'communication', 'journalism', 'media', 'marketing', 'writing', 'literature'];

/// Every vacancy in the marketplace (illustrative virtual USD salaries).
final List<JobPosting> marketPostings = <JobPosting>[
  // --- School of Computer Science and Technology
  _role(id: 'swe_intern', family: 'software', title: 'Software Engineering Intern', level: 'Internship', salary: 35000, positions: 4,
      keywords: <String>['Python', 'Git', 'Testing', 'Data structures'], preferredKeywords: <String>['JavaScript', 'SQL', 'REST APIs'],
      education: 'Enrolled in a computing degree', educationFields: _csEdu,
      responsibilities: <String>['Fix small bugs from the issue tracker', 'Write unit tests for new code', 'Open pull requests and respond to code review', 'Write a handoff note for each ticket'],
      description: 'A 12-week paid internship in a product squad. You ship real tickets with a mentor reviewing every pull request.'),
  _role(id: 'jr_swdev', family: 'software', title: 'Junior Software Developer', level: 'Junior', salary: 62000,
      keywords: <String>['Python', 'Git', 'Testing', 'REST APIs', 'SQL'], preferredKeywords: <String>['Dart', 'Flutter', 'JavaScript', 'Docker'],
      education: "Bachelor's in computer science or equivalent experience", educationFields: _csEdu,
      responsibilities: <String>['Build and maintain features end to end', 'Debug production issues with the team', 'Write tests and review colleagues\' pull requests', 'Join stand-ups and sprint planning'],
      description: 'Join a squad shipping apps used by thousands of customers. You own tickets from design note to release.'),
  _role(id: 'frontend_dev', family: 'frontend', title: 'Frontend Developer', level: 'Entry-level', salary: 58000,
      keywords: <String>['HTML', 'CSS', 'JavaScript', 'Accessibility'], preferredKeywords: <String>['React', 'TypeScript', 'Testing'],
      education: "Bachelor's in computing, web development or equivalent portfolio", educationFields: <String>[..._csEdu, 'web development', 'web design'],
      responsibilities: <String>['Build responsive pages from designs', 'Make forms accessible and keyboard-friendly', 'Fix layout and performance issues', 'Test across browsers and devices'],
      description: 'Build the customer-facing web app with designers and backend engineers.'),
  _role(id: 'backend_dev', family: 'backend', title: 'Backend Developer', level: 'Junior', salary: 66000,
      keywords: <String>['SQL', 'REST APIs', 'Python', 'Git'], preferredKeywords: <String>['Docker', 'Testing', 'Linux'],
      education: "Bachelor's in computer science or equivalent", educationFields: _csEdu,
      responsibilities: <String>['Design and build API endpoints', 'Write database queries and migrations', 'Monitor services and fix incidents', 'Write design notes for changes'],
      description: 'Own services that handle orders, payments and notifications.'),
  _role(id: 'flutter_dev', family: 'mobile', title: 'Junior Flutter Developer', level: 'Junior', salary: 62000, majors: <String>['mobile_app_development', 'computer_science', 'software_engineering'],
      keywords: <String>['Flutter', 'Dart', 'Firebase', 'Git'], preferredKeywords: <String>['REST APIs', 'Testing', 'UI design'],
      education: "Bachelor's in computing or equivalent app portfolio", educationFields: <String>[..._csEdu, 'mobile'],
      responsibilities: <String>['Build new app screens and connect them to APIs', 'Fix reported bugs such as login issues', 'Write widget and unit tests', 'Submit code for review and respond to feedback'],
      description: 'Build our Flutter apps for iOS and Android with a mobile squad.'),
  _role(id: 'aiml_intern', family: 'aiml', title: 'AI/ML Intern', level: 'Internship', salary: 38000, majors: <String>['artificial_intelligence', 'data_science', 'computer_science'],
      keywords: <String>['Python', 'Machine learning', 'Statistics'], preferredKeywords: <String>['Neural networks', 'NLP', 'SQL'],
      education: 'Enrolled in computing, AI, data science or mathematics', educationFields: <String>[..._csEdu, 'artificial intelligence', 'mathematics', 'statistics'],
      responsibilities: <String>['Prepare and clean training data', 'Train and evaluate models', 'Check models for bias and errors', 'Write evaluation reports'],
      description: 'Work in the applied AI team on models that help clinics and retailers.'),
  _role(id: 'data_analyst', family: 'data', title: 'Data Analyst', level: 'Entry-level', salary: 58000, majors: <String>['data_science', 'computer_science', 'mathematics'],
      keywords: <String>['SQL', 'Excel', 'Data analysis', 'Data visualization'], preferredKeywords: <String>['Python', 'Statistics', 'Tableau'],
      education: "Bachelor's in a quantitative field", educationFields: <String>[..._csEdu, ..._mathEdu],
      responsibilities: <String>['Clean and join datasets', 'Answer business questions with SQL', 'Build charts and dashboards', 'Present findings to managers'],
      description: 'Turn messy data into decisions for our clients.'),
  _role(id: 'jr_datasci', family: 'data', title: 'Junior Data Scientist', level: 'Junior', salary: 72000, majors: <String>['data_science', 'artificial_intelligence'],
      keywords: <String>['Python', 'Statistics', 'Machine learning', 'SQL'], preferredKeywords: <String>['Data visualization', 'Regression'],
      education: "Bachelor's or master's in data science, statistics or computing", educationFields: <String>[..._csEdu, ..._mathEdu],
      responsibilities: <String>['Build predictive models', 'Test assumptions statistically', 'Explain results to non-specialists', 'Document every analysis'],
      description: 'Build and explain predictive models for client projects.'),
  _role(id: 'cyber_analyst', family: 'security', title: 'Cybersecurity Analyst', level: 'Entry-level', salary: 64000, majors: <String>['cybersecurity', 'information_technology'],
      keywords: <String>['Networking', 'Incident response', 'Linux', 'Security monitoring'], preferredKeywords: <String>['Security+', 'Python', 'SIEM'],
      education: "Bachelor's in cybersecurity, IT or computing", educationFields: <String>[..._csEdu, 'cybersecurity', 'security'],
      responsibilities: <String>['Triage security alerts', 'Investigate suspicious activity', 'Follow and improve incident runbooks', 'Write incident reports'],
      description: 'Defend 300 client companies from a 24/7 security operations centre.'),
  _role(id: 'it_support', family: 'itsupport', title: 'IT Support Specialist', level: 'Entry-level', salary: 46000, majors: <String>['information_technology', 'cybersecurity', 'computer_science'],
      keywords: <String>['Troubleshooting', 'Customer service', 'Windows', 'Networking'], preferredKeywords: <String>['Active Directory', 'CompTIA A+', 'Ticketing'],
      education: 'Associate or bachelor\'s in IT, or equivalent experience', educationFields: <String>[..._csEdu, 'it'],
      responsibilities: <String>['Resolve help-desk tickets', 'Set up hardware and accounts', 'Fix network and printer issues', 'Write knowledge-base articles'],
      description: 'Keep 2,000 staff working: first-line support across schools and clinics.', mode: 'On-site'),
  _role(id: 'swdev_mid', family: 'software', title: 'Software Developer', level: 'Mid-level', salary: 92000,
      keywords: <String>['Python', 'Testing', 'REST APIs', 'Git'], preferredKeywords: <String>['System design', 'Mentoring'],
      education: "Bachelor's in computer science or equivalent", educationFields: _csEdu,
      responsibilities: <String>['Lead features from design to release', 'Review code and mentor juniors', 'Improve reliability and performance'], description: 'A mid-level role for developers who have proven themselves as juniors.'),
  _role(id: 'swdev_senior', family: 'software', title: 'Senior Developer', level: 'Senior', salary: 125000, positions: 1,
      keywords: <String>['System design', 'Testing', 'Mentoring'], education: "Bachelor's in computer science or equivalent", educationFields: _csEdu,
      responsibilities: <String>['Own architecture decisions', 'Lead incident response', 'Mentor the squad'], description: 'Technical leadership for a product squad.'),
  _role(id: 'eng_manager', family: 'software', title: 'Engineering Manager', level: 'Management', salary: 150000, positions: 1,
      keywords: <String>['Leadership', 'Planning', 'Mentoring'], education: "Bachelor's in computer science or equivalent", educationFields: _csEdu,
      responsibilities: <String>['Manage a team of engineers', 'Plan delivery with product', 'Run performance reviews'], description: 'Lead and grow an engineering team.'),
  // --- School of Medicine and Health Sciences
  _role(id: 'nursing_asst', family: 'nursing', title: 'Nursing Assistant Trainee', level: 'Internship', salary: 18, period: 'hour', mode: 'On-site', hours: 36, positions: 6,
      keywords: <String>['Vital signs', 'Patient care', 'Infection control', 'Communication'], preferredKeywords: <String>['BLS', 'Documentation'],
      education: 'Enrolled in a nursing or nursing-assistant programme', educationFields: _nuEdu, majors: <String>['nursing'],
      responsibilities: <String>['Record vital signs and report abnormal values', 'Help patients with hygiene and mobility', 'Follow infection-prevention procedures', 'Hand over to the nurse in charge'],
      description: 'Supervised simulated shifts on a medical-surgical unit.'),
  _role(id: 'nursing_grad', family: 'nursing', title: 'Nursing Graduate Trainee', level: 'Entry-level', salary: 68000, mode: 'On-site', hours: 36, positions: 5,
      keywords: <String>['Patient assessment', 'Vital signs', 'Medication safety', 'Documentation', 'Infection control'], preferredKeywords: <String>['BLS', 'Patient education', 'Wound care'],
      education: 'BSN (or final year of a nursing degree)', educationFields: _nuEdu, majors: <String>['nursing'],
      responsibilities: <String>['Assess and monitor assigned virtual patients', 'Prioritise care across a shift', 'Give medicines safely in the simulation', 'Document care and give SBAR handovers'],
      description: 'A supervised simulated graduate programme with full virtual shifts.'),
  _role(id: 'clin_research', family: 'clinresearch', title: 'Clinical Research Assistant', level: 'Entry-level', salary: 48000, positions: 2,
      keywords: <String>['Research', 'Documentation', 'Data analysis', 'Communication'], preferredKeywords: <String>['Informed consent', 'Excel', 'Statistics'],
      education: "Bachelor's in a health or life-science field", educationFields: _mdEdu,
      responsibilities: <String>['Screen and consent participants (simulated)', 'Complete case report forms accurately', 'Check data for errors', 'Report protocol deviations'],
      description: 'Support clinical trials from recruitment to data checks.'),
  _role(id: 'medlab_asst', family: 'medlab', title: 'Medical Laboratory Assistant', level: 'Entry-level', salary: 19, period: 'hour', mode: 'On-site', positions: 3,
      keywords: <String>['Laboratory', 'Quality control', 'Safety', 'Documentation'], preferredKeywords: <String>['Microscopy', 'Phlebotomy'],
      education: 'Coursework in biology, chemistry or medical laboratory science', educationFields: <String>[..._mdEdu, ..._sciEdu, 'medical laboratory'],
      responsibilities: <String>['Receive and label samples', 'Run quality-control checks', 'Prepare slides and run analysers', 'Record results in the laboratory system'],
      description: 'Process samples in a diagnostics laboratory (simulated).'),
  _role(id: 'health_admin', family: 'healthadmin', title: 'Healthcare Administration Assistant', level: 'Entry-level', salary: 42000, mode: 'On-site',
      keywords: <String>['Scheduling', 'Customer service', 'Documentation', 'Excel'], preferredKeywords: <String>['HIPAA', 'Medical terminology'],
      education: 'Degree or coursework in healthcare management or business', educationFields: <String>[..._mdEdu, ..._bizEdu, 'healthcare management'],
      responsibilities: <String>['Manage appointments and referrals', 'Keep records accurate and private', 'Answer patient questions', 'Track department metrics'],
      description: 'Keep a hospital department running smoothly.'),
  _role(id: 'ph_research', family: 'publichealth', title: 'Public Health Research Assistant', level: 'Entry-level', salary: 47000, majors: <String>['public_health', 'nursing'],
      keywords: <String>['Research', 'Data analysis', 'Statistics', 'Report writing'], preferredKeywords: <String>['Epidemiology', 'Excel', 'Survey'],
      education: "Bachelor's in public health, nursing or a related field", educationFields: <String>[..._nuEdu, 'public health', 'epidemiology'],
      responsibilities: <String>['Collect and clean health data', 'Describe trends with statistics', 'Write research summaries', 'Support outbreak investigations'],
      description: 'Analyse population health data for local health departments.'),
  _role(id: 'med_grad', family: 'medtrainee', title: 'Medical Graduate Trainee', level: 'Entry-level', salary: 64000, mode: 'On-site', hours: 48, positions: 4,
      keywords: <String>['History taking', 'Clinical reasoning', 'Patient assessment', 'Communication'], preferredKeywords: <String>['ECG', 'Research', 'BLS'],
      education: 'Medical degree (or final year of medical school)', educationFields: _mdEdu, majors: <String>['medicine'],
      responsibilities: <String>['Take histories and examine virtual patients', 'Request and interpret investigations', 'Present cases to your attending', 'Escalate deteriorating patients'],
      description: 'Supervised simulated clinical rotations in a teaching hospital.'),
  _role(id: 'nurse_senior', family: 'nursing', title: 'Senior Staff Nurse (simulation)', level: 'Mid-level', salary: 86000, mode: 'On-site', hours: 36, positions: 1,
      keywords: <String>['Patient assessment', 'Leadership', 'Medication safety'], education: 'BSN', educationFields: _nuEdu,
      responsibilities: <String>['Coordinate care for complex patients', 'Support junior nurses', 'Lead handovers'], description: 'A senior simulated nursing role.'),
  _role(id: 'charge_nurse', family: 'nursing', title: 'Charge Nurse (simulation)', level: 'Senior', salary: 98000, mode: 'On-site', hours: 36, positions: 1,
      keywords: <String>['Leadership', 'Patient safety', 'Delegation'], education: 'BSN', educationFields: _nuEdu,
      responsibilities: <String>['Run the unit for a shift', 'Allocate patients and staff', 'Escalate risks'], description: 'Lead a simulated ward shift.'),
  _role(id: 'nurse_manager', family: 'nursing', title: 'Nurse Unit Manager (simulation)', level: 'Management', salary: 118000, mode: 'On-site', positions: 1,
      keywords: <String>['Leadership', 'Budgeting', 'Quality improvement'], education: 'BSN; master\'s preferred', educationFields: _nuEdu,
      responsibilities: <String>['Manage the unit team', 'Own safety and quality metrics', 'Run staff reviews'], description: 'Manage a simulated hospital unit.'),
  // --- School of Law
  _role(id: 'legal_intern', family: 'law', title: 'Legal Intern', level: 'Internship', salary: 36000, positions: 3,
      keywords: <String>['Legal research', 'Writing', 'Case analysis'], preferredKeywords: <String>['Westlaw', 'Moot court'],
      education: 'Enrolled in law school or a pre-law programme', educationFields: _lawEdu,
      responsibilities: <String>['Research legal questions for associates', 'Summarise cases', 'Organise case files', 'Draft short memos'],
      description: 'A summer internship in a litigation and commercial practice.'),
  _role(id: 'legal_research', family: 'law', title: 'Legal Research Assistant', level: 'Entry-level', salary: 42000,
      keywords: <String>['Legal research', 'Legal writing', 'Case analysis', 'Citation'], preferredKeywords: <String>['Westlaw', 'LexisNexis'],
      education: "Bachelor's in law, legal studies or political science", educationFields: _lawEdu,
      responsibilities: <String>['Review simulated case files', 'Research relevant legal principles', 'Draft legal memoranda', 'Present findings to a supervising attorney'],
      description: 'Research and write for the litigation team.'),
  _role(id: 'paralegal', family: 'law', title: 'Paralegal Trainee', level: 'Entry-level', salary: 45000,
      keywords: <String>['Legal research', 'Drafting', 'Case management', 'Communication'], preferredKeywords: <String>['Paralegal certificate', 'E-discovery'],
      education: "Paralegal certificate or bachelor's in a legal field", educationFields: _lawEdu,
      responsibilities: <String>['Prepare case bundles and chronologies', 'Draft letters and court forms', 'Interview clients with an attorney', 'Track deadlines'],
      description: 'Support attorneys across active cases.'),
  _role(id: 'jr_associate', family: 'law', title: 'Junior Legal Associate', level: 'Junior', salary: 78000, positions: 1,
      keywords: <String>['Legal research', 'Legal writing', 'Advocacy', 'Negotiation'], preferredKeywords: <String>['Moot court', 'Client counseling'],
      education: 'JD (or final year of law school)', educationFields: _lawEdu,
      responsibilities: <String>['Advise clients under supervision', 'Draft pleadings and contracts', 'Prepare for hearings', 'Negotiate settlements'],
      description: 'Junior associate in a busy practice (simulation).'),
  _role(id: 'corp_legal', family: 'compliance', title: 'Corporate Legal Assistant', level: 'Entry-level', salary: 46000,
      keywords: <String>['Contracts', 'Drafting', 'Legal research', 'Attention to detail'], preferredKeywords: <String>['Corporate law', 'Compliance'],
      education: "Bachelor's in law, business law or legal studies", educationFields: <String>[..._lawEdu, 'business'],
      responsibilities: <String>['Prepare and review contracts', 'Maintain company records', 'Research regulatory questions', 'Support the general counsel'],
      description: 'Support corporate and contracts work.'),
  _role(id: 'compliance', family: 'compliance', title: 'Compliance Analyst', level: 'Junior', salary: 64000,
      keywords: <String>['Compliance', 'Risk', 'Legal research', 'Report writing'], preferredKeywords: <String>['Auditing', 'Excel'],
      education: "Bachelor's in law, business or finance", educationFields: <String>[..._lawEdu, ..._bizEdu],
      responsibilities: <String>['Monitor regulatory changes', 'Test controls', 'Investigate breaches', 'Report to management'],
      description: 'Keep the firm and its clients compliant.'),
  _role(id: 'legal_associate', family: 'law', title: 'Legal Associate', level: 'Mid-level', salary: 105000, positions: 1,
      keywords: <String>['Advocacy', 'Legal writing', 'Client management'], education: 'JD', educationFields: _lawEdu,
      responsibilities: <String>['Run matters day to day', 'Supervise paralegals', 'Appear at hearings (simulated)'], description: 'Mid-level associate (simulation).'),
  _role(id: 'senior_associate', family: 'law', title: 'Senior Associate', level: 'Senior', salary: 140000, positions: 1,
      keywords: <String>['Advocacy', 'Leadership', 'Negotiation'], education: 'JD', educationFields: _lawEdu,
      responsibilities: <String>['Lead complex matters', 'Mentor associates'], description: 'Senior associate (simulation).'),
  _role(id: 'practice_mgr', family: 'law', title: 'Legal Practice Manager', level: 'Management', salary: 155000, positions: 1,
      keywords: <String>['Leadership', 'Budgeting', 'Client management'], education: 'JD or management degree', educationFields: _lawEdu,
      responsibilities: <String>['Manage the practice group', 'Own budgets and quality'], description: 'Run a practice group (simulation).'),
  // --- School of Engineering
  _role(id: 'jr_mech', family: 'mechanical', title: 'Junior Mechanical Engineer', level: 'Junior', salary: 70000, majors: <String>['mechanical_engineering'],
      keywords: <String>['CAD', 'Mechanics', 'Machine design', 'Technical report'], preferredKeywords: <String>['SolidWorks', 'MATLAB', 'Failure analysis'],
      education: "Bachelor's in mechanical engineering", educationFields: _engEdu,
      responsibilities: <String>['Size components with hand calculations', 'Produce dimensioned drawings', 'Investigate failures', 'Present at design reviews'],
      description: 'Design and check machine components in the design office.'),
  _role(id: 'civil_intern', family: 'civil', title: 'Civil Engineering Intern', level: 'Internship', salary: 38000, majors: <String>['civil_engineering'],
      keywords: <String>['Structural analysis', 'Materials', 'Surveying', 'Excel'], preferredKeywords: <String>['AutoCAD', 'Site experience'],
      education: 'Enrolled in civil engineering', educationFields: _engEdu,
      responsibilities: <String>['Check beam and slab calculations', 'Test concrete and soil samples', 'Help with site surveys', 'Write site reports'],
      description: 'Office and site experience on infrastructure projects.'),
  _role(id: 'ee_tech', family: 'electrical', title: 'Electrical Engineering Technician', level: 'Entry-level', salary: 54000, majors: <String>['electrical_engineering'], mode: 'On-site',
      keywords: <String>['Circuits', 'Multimeter', 'Fault finding', 'Safety'], preferredKeywords: <String>['Oscilloscope', 'PLC', 'Soldering'],
      education: "Associate or bachelor's in electrical engineering", educationFields: _engEdu,
      responsibilities: <String>['Build and test circuits', 'Find faults safely', 'Record test results', 'Support engineers in the lab'],
      description: 'Hands-on testing in the electrical laboratory.'),
  _role(id: 'chem_trainee', family: 'chemical', title: 'Chemical Engineering Trainee', level: 'Entry-level', salary: 66000, majors: <String>['chemical_engineering'], mode: 'On-site',
      keywords: <String>['Mass balance', 'Process safety', 'Reaction engineering', 'Excel'], preferredKeywords: <String>['HAZOP', 'Aspen', 'Process control'],
      education: "Bachelor's in chemical engineering", educationFields: _engEdu,
      responsibilities: <String>['Do mass and energy balances', 'Support process-safety reviews', 'Monitor plant data', 'Write technical notes'],
      description: 'A graduate rotation through process, safety and control.'),
  _role(id: 'aero_intern', family: 'aerospace', title: 'Aerospace Engineering Intern', level: 'Internship', salary: 40000, majors: <String>['aerospace_engineering'],
      keywords: <String>['Aerodynamics', 'MATLAB', 'Structures', 'Technical report'], preferredKeywords: <String>['CFD', 'CAD'],
      education: 'Enrolled in aerospace or mechanical engineering', educationFields: _engEdu,
      responsibilities: <String>['Run aerodynamic and performance calculations', 'Support design reviews', 'Analyse test data', 'Write test reports'],
      description: 'Design and test work on small-aircraft programmes.'),
  _role(id: 'ie_analyst', family: 'industrial', title: 'Industrial Engineering Analyst', level: 'Entry-level', salary: 62000, majors: <String>['industrial_engineering'],
      keywords: <String>['Process improvement', 'Excel', 'Quality', 'Data analysis'], preferredKeywords: <String>['Lean', 'Six Sigma', 'Simulation'],
      education: "Bachelor's in industrial engineering", educationFields: _engEdu,
      responsibilities: <String>['Time studies and line balancing', 'Quality data analysis', 'Run improvement projects', 'Report savings'],
      description: 'Make operations faster, safer and cheaper.'),
  _role(id: 'mech_eng', family: 'mechanical', title: 'Mechanical Engineer', level: 'Mid-level', salary: 92000, positions: 1,
      keywords: <String>['Machine design', 'CAD', 'Project management'], education: "Bachelor's in mechanical engineering", educationFields: _engEdu,
      responsibilities: <String>['Lead component design', 'Check junior engineers\' work'], description: 'Mid-level design engineer.'),
  _role(id: 'senior_design', family: 'mechanical', title: 'Senior Design Engineer', level: 'Senior', salary: 115000, positions: 1,
      keywords: <String>['Design reviews', 'Leadership', 'Failure analysis'], education: "Bachelor's in engineering; PE preferred", educationFields: _engEdu,
      responsibilities: <String>['Approve designs', 'Lead reviews'], description: 'Senior design authority.'),
  _role(id: 'eng_mgr', family: 'mechanical', title: 'Engineering Manager (Mechanical)', level: 'Management', salary: 140000, positions: 1,
      keywords: <String>['Leadership', 'Budgeting', 'Planning'], education: "Bachelor's in engineering", educationFields: _engEdu,
      responsibilities: <String>['Manage the design office', 'Own delivery and quality'], description: 'Manage engineering teams.'),
  // --- School of Business and Economics
  _role(id: 'biz_analyst', family: 'business', title: 'Business Analyst', level: 'Junior', salary: 66000, majors: <String>['business_administration', 'international_business'],
      keywords: <String>['Excel', 'Data analysis', 'Requirements gathering', 'Presentation'], preferredKeywords: <String>['SQL', 'Project management'],
      education: "Bachelor's in business, economics or a related field", educationFields: _bizEdu,
      responsibilities: <String>['Analyse business performance', 'Write business cases', 'Run meetings with stakeholders', 'Present recommendations'],
      description: 'Help leaders make decisions with clear analysis.'),
  _role(id: 'jr_accountant', family: 'accounting', title: 'Junior Accountant', level: 'Entry-level', salary: 48000, majors: <String>['accounting', 'finance'],
      keywords: <String>['Reconciliation', 'Excel', 'Financial statements', 'Accounts payable'], preferredKeywords: <String>['QuickBooks', 'GAAP', 'Audit'],
      education: "Bachelor's in accounting or finance", educationFields: _bizEdu,
      responsibilities: <String>['Review invoices and record transactions', 'Reconcile bank and ledger accounts', 'Prepare financial statements', 'Identify discrepancies and write accounting reports'],
      description: 'Keep clients\' books accurate and audit-ready.', mode: 'On-site'),
  _role(id: 'fin_analyst', family: 'finance', title: 'Financial Analyst', level: 'Entry-level', salary: 68000, majors: <String>['finance', 'accounting', 'economics'],
      keywords: <String>['Financial statements', 'Excel', 'Valuation', 'Financial modeling'], preferredKeywords: <String>['CFA', 'Risk'],
      education: "Bachelor's in finance, accounting or economics", educationFields: _bizEdu,
      responsibilities: <String>['Analyse company financial statements', 'Build valuation models', 'Write risk reports', 'Present investment memos'],
      description: 'Analyse companies for the investment desk.'),
  _role(id: 'marketing_assoc', family: 'marketing', title: 'Marketing Associate', level: 'Entry-level', salary: 45000, majors: <String>['marketing', 'business_administration'],
      keywords: <String>['Market research', 'Content', 'Social media', 'Analytics'], preferredKeywords: <String>['Google Ads', 'SEO', 'Copywriting'],
      education: "Bachelor's in marketing, communications or business", educationFields: <String>[..._bizEdu, ..._comEdu],
      responsibilities: <String>['Research target audiences', 'Create campaign strategies and content', 'Allocate and track a budget', 'Review campaign performance and present results'],
      description: 'Plan and run campaigns for consumer brands.'),
  _role(id: 'hr_asst', family: 'hr', title: 'Human Resources Assistant', level: 'Entry-level', salary: 44000, majors: <String>['human_resource_management', 'business_administration'],
      keywords: <String>['Recruitment', 'Onboarding', 'Communication', 'Confidentiality'], preferredKeywords: <String>['HRIS', 'Employment law'],
      education: "Bachelor's in HR, business or psychology", educationFields: <String>[..._bizEdu, 'psychology'],
      responsibilities: <String>['Post jobs and screen applications', 'Schedule and support interviews', 'Run onboarding', 'Keep employee records accurate and private'],
      description: 'Support recruitment, onboarding and employee relations.'),
  _role(id: 'inv_research', family: 'finance', title: 'Investment Research Analyst', level: 'Junior', salary: 78000, majors: <String>['finance', 'economics'],
      keywords: <String>['Valuation', 'Financial statements', 'Research', 'Excel'], preferredKeywords: <String>['Portfolio', 'CFA', 'Python'],
      education: "Bachelor's in finance or economics", educationFields: _bizEdu,
      responsibilities: <String>['Research companies and sectors', 'Build valuation models', 'Write investment notes', 'Monitor portfolio risk'],
      description: 'Equity research for the portfolio team.'),
  _role(id: 'ops_assoc', family: 'business', title: 'Operations Associate', level: 'Entry-level', salary: 50000, majors: <String>['business_administration', 'international_business', 'industrial_engineering'],
      keywords: <String>['Operations', 'Excel', 'Process improvement', 'Communication'], preferredKeywords: <String>['Supply chain', 'Project management'],
      education: "Bachelor's in business or operations", educationFields: _bizEdu,
      responsibilities: <String>['Track daily operations KPIs', 'Fix process problems', 'Coordinate suppliers', 'Report to the operations director'],
      description: 'Keep 40 locations running smoothly.'),
  _role(id: 'bizdev_assoc', family: 'business', title: 'Business Development Associate', level: 'Entry-level', salary: 52000, majors: <String>['entrepreneurship', 'marketing', 'international_business'],
      keywords: <String>['Market research', 'Sales', 'Communication', 'Presentation'], preferredKeywords: <String>['CRM', 'Negotiation'],
      education: "Bachelor's in business or marketing", educationFields: _bizEdu,
      responsibilities: <String>['Research new markets and customers', 'Interview prospective customers', 'Build proposals', 'Track the pipeline'],
      description: 'Find and win new business.'),
  _role(id: 'econ_research', family: 'economics', title: 'Economics Research Assistant', level: 'Entry-level', salary: 50000, majors: <String>['economics'],
      keywords: <String>['Economics', 'Statistics', 'Data analysis', 'Report writing'], preferredKeywords: <String>['Stata', 'R', 'Regression'],
      education: "Bachelor's in economics", educationFields: <String>[..._bizEdu, ..._mathEdu],
      responsibilities: <String>['Clean and analyse economic data', 'Run regressions', 'Draft policy briefs', 'Check figures in reports'],
      description: 'Research for local-government policy questions.'),
  _role(id: 'accountant', family: 'accounting', title: 'Accountant', level: 'Mid-level', salary: 72000, positions: 1,
      keywords: <String>['Financial statements', 'Audit', 'Reconciliation'], education: "Bachelor's in accounting; CPA track", educationFields: _bizEdu,
      responsibilities: <String>['Own month-end for clients', 'Review junior work'], description: 'Mid-level accountant.'),
  _role(id: 'senior_accountant', family: 'accounting', title: 'Senior Accountant', level: 'Senior', salary: 88000, positions: 1,
      keywords: <String>['Audit', 'Leadership', 'GAAP'], education: 'CPA preferred', educationFields: _bizEdu,
      responsibilities: <String>['Lead audits', 'Train staff'], description: 'Senior accountant.'),
  _role(id: 'finance_mgr', family: 'accounting', title: 'Finance Manager', level: 'Management', salary: 120000, positions: 1,
      keywords: <String>['Leadership', 'Budgeting', 'Reporting'], education: 'CPA or MBA', educationFields: _bizEdu,
      responsibilities: <String>['Manage the accounts team', 'Own reporting and budgets'], description: 'Finance manager.'),
  // --- School of Mathematics and Sciences
  _role(id: 'math_research', family: 'maths', title: 'Mathematics Research Assistant', level: 'Entry-level', salary: 48000,
      keywords: <String>['Mathematics', 'Statistics', 'Python', 'Modelling'], preferredKeywords: <String>['Linear algebra', 'Differential equations', 'LaTeX'],
      education: "Bachelor's in mathematics or statistics", educationFields: _mathEdu,
      responsibilities: <String>['Build and solve mathematical models', 'Check derivations and code', 'Run simulations', 'Write technical notes'],
      description: 'Modelling support for engineering and finance clients.'),
  _role(id: 'jr_data_math', family: 'maths', title: 'Junior Data Analyst', level: 'Entry-level', salary: 56000,
      keywords: <String>['Statistics', 'Excel', 'Data analysis', 'SQL'], preferredKeywords: <String>['Python', 'R'],
      education: "Bachelor's in mathematics, statistics or a quantitative field", educationFields: _mathEdu,
      responsibilities: <String>['Clean data and compute statistics', 'Test hypotheses', 'Chart results', 'Explain findings to clients'],
      description: 'Statistics and analysis for client projects.'),
  _role(id: 'lab_research', family: 'biology', title: 'Laboratory Research Assistant', level: 'Entry-level', salary: 45000, mode: 'On-site',
      keywords: <String>['Laboratory', 'Microscopy', 'Safety', 'Data analysis'], preferredKeywords: <String>['Cell culture', 'PCR'],
      education: "Bachelor's in biology or a life science", educationFields: _sciEdu,
      responsibilities: <String>['Prepare samples and run experiments', 'Use microscopes and lab instruments', 'Record results in the notebook', 'Write experiment reports'],
      description: 'Bench work in a cell and molecular biology group.'),
  _role(id: 'physics_intern', family: 'physics', title: 'Physics Research Intern', level: 'Internship', salary: 36000, mode: 'On-site',
      keywords: <String>['Physics', 'Experiments', 'Data analysis', 'Uncertainty'], preferredKeywords: <String>['Python', 'MATLAB'],
      education: 'Enrolled in physics or engineering physics', educationFields: _sciEdu,
      responsibilities: <String>['Set up and run measurements', 'Analyse data with uncertainties', 'Calibrate instruments', 'Report results'],
      description: 'Measurement and instrumentation research.'),
  _role(id: 'chem_lab_asst', family: 'chemistry', title: 'Chemistry Laboratory Assistant', level: 'Entry-level', salary: 20, period: 'hour', mode: 'On-site',
      keywords: <String>['Titration', 'Laboratory', 'Safety', 'Analytical chemistry'], preferredKeywords: <String>['HPLC', 'Spectroscopy'],
      education: 'Coursework or degree in chemistry', educationFields: _sciEdu,
      responsibilities: <String>['Prepare solutions and standards', 'Run titrations and analyses', 'Keep quality-control records', 'Follow chemical-safety procedures'],
      description: 'Analytical testing in a contract laboratory.'),
  _role(id: 'bio_research', family: 'biology', title: 'Biology Research Assistant', level: 'Junior', salary: 52000, mode: 'On-site',
      keywords: <String>['Genetics', 'Microbiology', 'Laboratory', 'Report writing'], preferredKeywords: <String>['PCR', 'Statistics'],
      education: "Bachelor's in biology", educationFields: _sciEdu,
      responsibilities: <String>['Plan and run experiments', 'Analyse genetic and microbiology data', 'Present at lab meetings', 'Maintain biosafety'],
      description: 'Research assistant in genetics and microbiology projects.'),
  _role(id: 'research_scientist', family: 'biology', title: 'Research Scientist', level: 'Mid-level', salary: 85000, positions: 1,
      keywords: <String>['Research', 'Experimental design', 'Publication'], education: "Master's or PhD in a life science", educationFields: _sciEdu,
      responsibilities: <String>['Design studies', 'Supervise assistants'], description: 'Research scientist.'),
  // --- School of English and Communication
  _role(id: 'content_writer', family: 'writing', title: 'Content Writer', level: 'Entry-level', salary: 46000, mode: 'Remote',
      keywords: <String>['Writing', 'Editing', 'Research', 'SEO'], preferredKeywords: <String>['Content strategy', 'Social media'],
      education: "Bachelor's in English, journalism or communications", educationFields: _comEdu,
      responsibilities: <String>['Write articles and web copy', 'Research and fact-check', 'Edit to the style guide', 'Meet weekly deadlines'],
      description: 'Write clear, accurate content for client websites and newsletters.'),
  _role(id: 'tech_writer', family: 'techwriting', title: 'Technical Writer', level: 'Junior', salary: 62000, mode: 'Remote',
      keywords: <String>['Technical writing', 'Editing', 'Documentation', 'Research'], preferredKeywords: <String>['Markdown', 'Software'],
      education: "Bachelor's in English, communications or a technical field", educationFields: _comEdu,
      responsibilities: <String>['Write user guides and how-tos', 'Interview engineers', 'Test instructions', 'Maintain the documentation site'],
      description: 'Make complex products easy to use.'),
  _role(id: 'comms_asst', family: 'comms', title: 'Communications Assistant', level: 'Entry-level', salary: 42000,
      keywords: <String>['Writing', 'Communication', 'Social media', 'Presentation'], preferredKeywords: <String>['Press releases', 'Event planning'],
      education: "Bachelor's in communications or English", educationFields: _comEdu,
      responsibilities: <String>['Draft newsletters and announcements', 'Post and monitor social media', 'Prepare presentations', 'Track coverage'],
      description: 'Support internal and external communications.'),
  _role(id: 'copywriter', family: 'writing', title: 'Copywriter', level: 'Junior', salary: 52000, mode: 'Hybrid',
      keywords: <String>['Copywriting', 'Editing', 'Advertising', 'Writing'], preferredKeywords: <String>['Brand voice', 'A/B testing'],
      education: "Bachelor's in English, marketing or communications", educationFields: _comEdu,
      responsibilities: <String>['Write ad and email copy', 'Adapt copy to brand voice', 'Edit for clarity and accuracy', 'Test headlines with the team'],
      description: 'Write campaigns that are clear, honest and persuasive.'),
  _role(id: 'editorial_asst', family: 'writing', title: 'Editorial Assistant', level: 'Entry-level', salary: 21, period: 'hour',
      keywords: <String>['Editing', 'Proofreading', 'Grammar', 'Research'], preferredKeywords: <String>['AP style', 'Chicago style'],
      education: "Bachelor's in English or journalism", educationFields: _comEdu,
      responsibilities: <String>['Proofread and copy-edit articles', 'Fact-check claims', 'Manage the editorial calendar', 'Prepare files for publication'],
      description: 'Help the editorial team publish accurate, polished work.'),
  _role(id: 'pr_assoc', family: 'comms', title: 'Public Relations Associate', level: 'Junior', salary: 54000,
      keywords: <String>['Public relations', 'Writing', 'Media relations', 'Communication'], preferredKeywords: <String>['Crisis communication', 'Social media'],
      education: "Bachelor's in communications, PR or journalism", educationFields: _comEdu,
      responsibilities: <String>['Write press releases', 'Pitch stories to media', 'Prepare spokespeople', 'Handle issues and crises'],
      description: 'Manage reputation for clients across media.'),
  _role(id: 'comms_specialist', family: 'comms', title: 'Communications Specialist', level: 'Mid-level', salary: 72000, positions: 1,
      keywords: <String>['Strategy', 'Writing', 'Media relations'], education: "Bachelor's in communications", educationFields: _comEdu,
      responsibilities: <String>['Own communication plans', 'Mentor assistants'], description: 'Mid-level communications role.'),
];

/// Number of workplace tasks drawn from each lab (beginner tasks first).
List<AssignmentSpec> _assignmentsFor(RoleFamily f) {
  final List<List<LabScenario>> perLab = <List<LabScenario>>[];
  final List<LabSpec> labs = <LabSpec>[];
  for (final String id in f.labs) {
    final LabSpec? l = LabCatalog.lab(id);
    if (l == null) continue;
    labs.add(l);
    // Two tasks per level from each lab, so the work grows harder over time.
    perLab.add(<LabScenario>[for (final LabDifficulty d in LabDifficulty.values) ...l.atLevel(d).take(2)]);
  }
  final List<AssignmentSpec> hospitalWork = <AssignmentSpec>[
    for (final String id in f.hospital)
      if (id == wardShift.id)
        AssignmentSpec(
          id: 'mk_${f.id}_h_$id',
          title: wardShift.title,
          ticket: wardShift.brief,
          acceptance: const <String>['Care for all three patients safely', 'No critical safety errors', 'Give a handover at the end of the shift'],
          task: HospitalTaskSpec(id: 'mk_${f.id}_h_$id', title: wardShift.title, brief: wardShift.brief, caseId: id),
          deadlineDays: 2,
        )
      else if (hospitalCase(id) case final PatientCase c)
        AssignmentSpec(
          id: 'mk_${f.id}_h_$id${c.level == CaseLevel.advanced ? '_lead' : ''}',
          title: '${c.dept.short}: ${c.name} — ${c.complaint}',
          ticket: 'You are assigned ${c.name}, ${c.age == 0 ? 'an infant' : '${c.age} years old'}, in the ${c.dept.label}: ${c.complaint.toLowerCase()}. Assess, act within your scope, escalate and document.',
          acceptance: const <String>['Score 70 or more on the clinical rubric', 'No critical safety errors', 'Documentation complete'],
          task: HospitalTaskSpec(id: 'mk_${f.id}_h_$id', title: '${c.name}: ${c.complaint}', brief: c.complaint, caseId: id),
          deadlineDays: c.level == CaseLevel.advanced ? 3 : 2,
          leadership: c.level == CaseLevel.advanced,
        ),
  ];
  final List<AssignmentSpec> out = <AssignmentSpec>[];
  // Round-robin across labs so consecutive days bring different kinds of work.
  for (int round = 0; round < 6; round++) {
    for (int k = 0; k < labs.length; k++) {
      if (round >= perLab[k].length) continue;
      final LabSpec l = labs[k];
      final LabScenario sc = perLab[k][round];
      final bool lead = sc.level == LabDifficulty.advanced;
      out.add(AssignmentSpec(
        id: 'mk_${f.id}_${sc.id}${lead ? '_lead' : ''}',
        title: sc.title,
        ticket: '${sc.briefing.what} ${sc.briefing.why}'.trim(),
        acceptance: <String>[
          ...sc.briefing.requirements.take(3),
          'Pass the workstation checks (score 70 or more)',
          'Hand off with a note: what you did, how you checked it, what happens next',
        ],
        task: LabTaskSpec(
          id: 'mk_${f.id}_${sc.id}',
          title: '${l.title}: ${sc.title}',
          brief: sc.briefing.what,
          labId: l.id,
          scenarioId: sc.id,
          skills: l.skills,
        ),
        deadlineDays: switch (sc.level) {
          LabDifficulty.foundation => 2,
          LabDifficulty.intermediate => 3,
          LabDifficulty.advanced => 4,
        },
        leadership: lead,
      ));
    }
  }
  if (hospitalWork.isEmpty) return out;
  // Alternate hospital placements with workstation tasks.
  final List<AssignmentSpec> mixed = <AssignmentSpec>[];
  for (int i = 0; i < math.max(hospitalWork.length, out.length); i++) {
    if (i < hospitalWork.length) mixed.add(hospitalWork[i]);
    if (i < out.length) mixed.add(out[i]);
  }
  return mixed;
}

final List<WorkplaceDef> marketWorkplaces = <WorkplaceDef>[
  for (final RoleFamily f in roleFamilies)
    WorkplaceDef(
      id: 'mk_${f.id}',
      deptId: f.deptId,
      name: '${marketCompanies[f.company]!.name} — ${f.team}',
      environment: '${marketCompanies[f.company]!.industry}. ${marketCompanies[f.company]!.culture}${f.note.isEmpty ? '' : ' ${f.note}'}',
      supervisor: f.supervisor,
      supervisorRole: f.supervisorRole,
      tools: marketCompanies[f.company]!.tools.split(RegExp(r',\s*')).map((String s) => s.replaceAll(RegExp(r'\.$'), '')).toList(),
      assignments: _assignmentsFor(f),
      titles: f.titles,
    ),
];
