import 'package:flutter/material.dart';

import '../../config/vu_schools_catalog.dart';
import '../../data/university_learning_engine.dart';
import '../career_labs/career_lab_home_screen.dart';
import '../career_labs/playable/playable_router.dart';
import 'course_labs_catalog.dart';
import 'engine/lab_blueprint.dart';
import 'investigation/investigation_flow.dart';

/// School of Career and Life Skills — workplace labs, never lectures.
abstract final class CareerPracticeLabs {
  static bool matches(String subjectId) =>
      VuSchoolsCatalog.isPracticeOnly(subjectId);

  static UniversityLabLink labFor(String subjectId, String lessonTitle) {
    final _Spec spec = _specFor(subjectId);
    return UniversityLabLink(
      labId: spec.labId,
      stationId: 'practical',
      title: '${spec.emoji} ${spec.labTitle} — $lessonTitle',
      purpose: spec.purpose,
      objectives: spec.objectives,
      estimatedMinutes: 30,
      difficulty: 'On the job',
    );
  }

  static LabBlueprint blueprint({
    required String subjectId,
    required String courseTitle,
    required String topicTitle,
    required String title,
    required int level,
  }) {
    final _Spec spec = _specFor(subjectId);
    return LabBlueprint(
      discipline: LabDiscipline.careerPractice,
      title: title.trim().isEmpty ? spec.labTitle : title,
      courseTitle: courseTitle,
      unitTitle: spec.unit,
      role: spec.role,
      mission: spec.mission,
      scenario: spec.scenario,
      objectives: spec.objectives,
      requiredKnowledge: spec.knowledge,
      tools: spec.tools,
      materials: spec.materials,
      layers: spec.layers,
      safety: spec.safety,
      hints: spec.hints,
      bottomTools: spec.bottom,
      environmentLabel: spec.environment,
      estimatedMinutes: 28 + level.clamp(1, 4) * 4,
      level: level.clamp(1, 4),
    );
  }

  static List<CourseLabEntry> catalog(String majorId) {
    final _Spec spec = _specFor(majorId);
    return <CourseLabEntry>[
      CourseLabEntry(
        id: '${majorId}_desk',
        courseId: majorId,
        emoji: spec.emoji,
        title: spec.labTitle,
        subtitle: spec.purpose,
        open: (BuildContext c) {
          final UniversityLabLink link = labFor(majorId, spec.labTitle);
          return InvestigationLabFlow.open(
            context: c,
            link: link,
            subjectId: majorId,
            courseTitle: spec.unit,
            topicTitle: spec.labTitle,
            level: 2,
          );
        },
      ),
      CourseLabEntry(
        id: '${majorId}_workplace',
        courseId: majorId,
        emoji: '🏢',
        title: spec.workplaceTitle,
        subtitle: spec.workplaceBlurb,
        open: (BuildContext c) => openWorkplace(c, majorId),
      ),
    ];
  }

  static String workplaceWorldId(String subjectId) {
    switch (subjectId.toLowerCase()) {
      case 'personal_finance':
        return 'personal_finance'; // Budget Boss (was the markets desk)
      case 'public_speaking':
      case 'communication_skills':
        return 'marketing';
      default:
        return 'business';
    }
  }

  static Future<void> openWorkplace(BuildContext context, String subjectId) {
    final String worldId = workplaceWorldId(subjectId);
    final Widget? playable = playableScreenFor(worldId);
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => playable ?? CareerLabHomeScreen(labId: worldId),
      ),
    );
  }

  static _Spec _specFor(String subjectId) {
    switch (subjectId.toLowerCase()) {
      case 'resume_writing':
        return const _Spec(
          labId: 'resume_desk',
          emoji: '📄',
          labTitle: 'Hiring desk',
          unit: 'Talent screen',
          role: 'Hiring coordinator',
          purpose: 'Rewrite a live resume against a real job requisition.',
          workplaceTitle: 'Talent office floor',
          workplaceBlurb: 'Screen, rewrite, and send a packet a hiring manager would open.',
          mission:
              'A hiring manager dumped 40 resumes. Take one candidate, rewrite the top half against the req, and decide whether to advance.',
          scenario:
              'You are on the hiring desk. The req is open on the left. The candidate draft is on the right. ATS keywords, quantified wins, and a clean narrative decide this — not a lecture.',
          objectives: <String>[
            'Open the job requisition',
            'Mark missing quantified wins',
            'Rewrite one bullet to match the req',
            'Decide advance or reject with a reason',
          ],
          knowledge: <String>[
            'Match language to the job, not a template',
            'Every bullet needs a verb, a result, and a number when you have one',
            'ATS scans for the same nouns as the requisition',
          ],
          tools: <String>['Req', 'Draft', 'ATS scan', 'Decision'],
          materials: <String>['Job requisition', 'Candidate resume', 'Keyword list'],
          layers: <String>['Headline', 'Bullets', 'Skills', 'Decision'],
          safety: 'Do not invent experience. Tighten what is true.',
          hints: <String>[
            'Read the requisition first.',
            'The first three bullets are the only screen most managers give you.',
            'Swap duties for results.',
            'If you cannot name a result, that bullet is not ready.',
          ],
          bottom: <String>['open', 'compare', 'decide'],
          environment: 'Talent office · hiring desk',
        );
      case 'interview_preparation':
        return const _Spec(
          labId: 'interview_suite',
          emoji: '🎙️',
          labTitle: 'Mock interview suite',
          unit: 'Interview floor',
          role: 'Candidate on a live loop',
          purpose: 'Run a structured interview and debrief the answer, not the nerves.',
          workplaceTitle: 'Interview loop floor',
          workplaceBlurb: 'Behavioral, technical, and close — then a hiring-manager debrief.',
          mission:
              'You have 25 minutes with a hiring manager. Deliver STAR stories, handle a curveball, and close with a real question.',
          scenario:
              'Glass door, water, a notepad. The interviewer already has your resume. This is a conversation with stakes, not a rehearsal speech.',
          objectives: <String>[
            'Open the job story bank',
            'Answer one behavioral prompt in STAR',
            'Handle a follow-up that challenges a number',
            'Close with one question that shows you researched the role',
          ],
          knowledge: <String>[
            'Situation, Task, Action, Result — in that order',
            'A number turns a story into evidence',
            'The close should be about the work, not vacation policy',
          ],
          tools: <String>['Prompt', 'STAR pad', 'Timer', 'Debrief'],
          materials: <String>['Job description', 'Your three stories', 'Company one-pager'],
          layers: <String>['Open', 'Behavioral', 'Probe', 'Close'],
          safety: 'Do not badmouth a former manager. Own the miss.',
          hints: <String>[
            'Pick the story before you start talking.',
            'Most candidates skip the result.',
            'If they challenge a number, slow down and show the math.',
            'Close with a question about the first 90 days.',
          ],
          bottom: <String>['open', 'inspect', 'decide'],
          environment: 'Interview suite',
        );
      case 'public_speaking':
        return const _Spec(
          labId: 'pitch_stage',
          emoji: '🎤',
          labTitle: 'Pitch stage',
          unit: 'Delivery studio',
          role: 'Speaker with a live audience',
          purpose: 'Deliver a timed talk, read the room, and handle Q&A.',
          workplaceTitle: 'Studio stage',
          workplaceBlurb: 'Open, story, ask, and a live Q&A — the talk you would actually give.',
          mission:
              'You have six minutes. Open with a hook, one story, one ask. Then take two questions without collapsing.',
          scenario:
              'Lights, a clicker, twelve people who did not come for a lecture. They came to decide whether they trust you.',
          objectives: <String>[
            'Set the clock and the one-sentence promise',
            'Land a story before the slide dump',
            'Ask for one concrete next step',
            'Answer a hostile question without repeating the slide',
          ],
          knowledge: <String>[
            'Hook, point, proof, ask',
            'If they remember one sentence, write that sentence first',
            'Q&A is part of the talk, not an afterthought',
          ],
          tools: <String>['Timer', 'Deck', 'Notes', 'Q&A'],
          materials: <String>['Talk outline', 'Two slides', 'Audience brief'],
          layers: <String>['Open', 'Story', 'Ask', 'Q&A'],
          safety: 'Do not fill time with more slides. Cut.',
          hints: <String>[
            'Write the last line before the first.',
            'Look at one person per sentence.',
            'The ask must be something a person can do this week.',
            'Repeat the question before you answer it.',
          ],
          bottom: <String>['open', 'run', 'decide'],
          environment: 'Pitch stage',
        );
      case 'personal_finance':
        return const _Spec(
          labId: 'money_desk',
          emoji: '💵',
          labTitle: 'Household money desk',
          unit: 'Personal cash desk',
          role: 'You, running your own money',
          purpose: 'Budget, shock, and a written next move — not a markets class.',
          workplaceTitle: 'Money desk',
          workplaceBlurb: 'Income, bills, emergency fund, and a shock you have to absorb.',
          mission:
              'Pay this month, keep a three-month cushion, and survive a \$900 car hit without a payday loan.',
          scenario:
              'Laptop, bank tabs, a rent date in nine days. The question is not “what is a 401(k).” It is whether this month still works after the shock.',
          objectives: <String>[
            'List must-pay bills vs wants',
            'Fund or protect the emergency line',
            'Absorb a \$900 shock',
            'Write the one change for next month',
          ],
          knowledge: <String>[
            'Needs, sinking funds, then investing',
            'High-interest debt is the first fire',
            'An emergency fund is for shocks, not for wants',
          ],
          tools: <String>['Budget', 'Bills', 'Shock', 'Plan'],
          materials: <String>['Pay stubs', 'Rent', 'Card statement'],
          layers: <String>['Income', 'Bills', 'Cushion', 'Shock'],
          safety: 'Do not skip rent to “invest.” Solvency first.',
          hints: <String>[
            'Pay the must-pays before the wants.',
            'If the shock wipes the cushion, the next move is income or a pause — not more lifestyle.',
            'A number on paper beats a vibe.',
            'Write the change in one sentence.',
          ],
          bottom: <String>['open', 'allocate', 'decide'],
          environment: 'Household money desk',
        );
      case 'leadership':
        return const _Spec(
          labId: 'team_standup',
          emoji: '🧭',
          labTitle: 'Team stand-up',
          unit: 'People leadership',
          role: 'Team lead on a messy Monday',
          purpose: 'Make one people call under conflict and own it in the room.',
          workplaceTitle: 'Leadership floor',
          workplaceBlurb: 'Priorities, a conflict, and a decision the team can execute.',
          mission:
              'Two reports are blocked, a deadline moved up, and someone is hiding a miss. Run stand-up. Make one call. Explain why.',
          scenario:
              'Slack is red. The skip-level will walk by in twenty minutes. Leadership here is a decision in public, not a quote about vision.',
          objectives: <String>[
            'Name the single most important outcome today',
            'Surface the hidden miss without humiliation',
            'Reassign work in the room',
            'Close with who owns what by when',
          ],
          knowledge: <String>[
            'One priority beats five',
            'Conflict that stays private becomes rumor',
            'A decision without an owner is theatre',
          ],
          tools: <String>['Board', 'People', 'Call', 'Follow-up'],
          materials: <String>['Sprint board', 'Slack thread', 'Deadline note'],
          layers: <String>['Goal', 'Blockers', 'Call', 'Owners'],
          safety: 'Do not blame in public and coach in private on the same fact. Pick one lane.',
          hints: <String>[
            'Ask what is blocked before you assign more.',
            'The hidden miss is usually in the “almost done.”',
            'Say the tradeoff out loud.',
            'Write names and times, not vibes.',
          ],
          bottom: <String>['open', 'inspect', 'decide'],
          environment: 'Team room',
        );
      case 'communication_skills':
        return const _Spec(
          labId: 'hard_conversation',
          emoji: '💬',
          labTitle: 'Difficult conversation room',
          unit: 'Workplace dialogue',
          role: 'Colleague who has to say the hard thing',
          purpose: 'Plan, say, and repair a workplace conversation.',
          workplaceTitle: 'Conversation studio',
          workplaceBlurb: 'A live talk with stakes: feedback, a miss, and a repair.',
          mission:
              'A teammate shipped late and blamed “process.” You have ten minutes. Stay specific. Leave with a next step both of you can keep.',
          scenario:
              'Closed door, two chairs, no audience. The work still has to ship. This is a conversation, not a speech and not a lecture.',
          objectives: <String>[
            'State the observable fact first',
            'Name the impact on the work',
            'Ask one genuine question',
            'Agree a next step and a check-in',
          ],
          knowledge: <String>[
            'Fact, impact, question, ask',
            'You cannot control their story. You can control specificity',
            'Repair is part of the talk',
          ],
          tools: <String>['Fact card', 'Impact', 'Ask', 'Follow-up'],
          materials: <String>['Timeline', 'Slack snippet', 'Shared calendar'],
          layers: <String>['Fact', 'Impact', 'Listen', 'Ask'],
          safety: 'Do not stack old grievances. Stay on this miss.',
          hints: <String>[
            'If you cannot point at a date, you are not ready.',
            'Ask before you diagnose character.',
            'Repeat what you heard.',
            'The next step needs a time.',
          ],
          bottom: <String>['open', 'inspect', 'decide'],
          environment: 'Conversation room',
        );
      case 'freelancing':
        return const _Spec(
          labId: 'client_studio',
          emoji: '🖋️',
          labTitle: 'Client studio',
          unit: 'Independent practice',
          role: 'Freelancer on a live inquiry',
          purpose: 'Scope, price, and protect a client engagement.',
          workplaceTitle: 'Studio floor',
          workplaceBlurb: 'Inquiry → proposal → scope guard — the work that pays.',
          mission:
              'A client wants “a quick website.” Translate that into scope, a price, and a written boundary so the work cannot explode.',
          scenario:
              'Inbox ping. Vague brief. They want it Friday. Your rent does not care that you were flattered. This is a business conversation.',
          objectives: <String>[
            'Turn the brief into three deliverables',
            'Price time and risk, not a guess',
            'Write the out-of-scope line',
            'Send a proposal a client can accept today',
          ],
          knowledge: <String>[
            'Scope is a sentence, not a vibe',
            'Revisions are a number',
            'Payment terms before production',
          ],
          tools: <String>['Brief', 'Scope', 'Rate', 'Send'],
          materials: <String>['Inquiry email', 'Rate card', 'Contract template'],
          layers: <String>['Ask', 'Scope', 'Price', 'Send'],
          safety: 'Do not start production on a handshake.',
          hints: <String>[
            'Name three things that are in. Name one thing that is out.',
            'Half up front is not rude.',
            'If they cannot describe success, you cannot price it.',
            'Send today. Waiting is unpaid.',
          ],
          bottom: <String>['open', 'compare', 'decide'],
          environment: 'Freelance studio',
        );
      case 'project_management':
        return const _Spec(
          labId: 'project_war_room',
          emoji: '📋',
          labTitle: 'Project war room',
          unit: 'Delivery desk',
          role: 'Project coordinator',
          purpose: 'Hold a deadline: risks, tradeoffs, and a status a sponsor can use.',
          workplaceTitle: 'Delivery floor',
          workplaceBlurb: 'Timeline, risk, and a status that names the tradeoff.',
          mission:
              'The demo is Thursday. Two tasks are red. Cut, crash, or slip — pick one and write the sponsor note.',
          scenario:
              'Whiteboard, sticky risks, a calendar that does not care. Project management is the tradeoff in writing, not a Gantt lecture.',
          objectives: <String>[
            'Mark the critical path',
            'Name the two red risks',
            'Choose cut, crash, or slip',
            'Write a four-line sponsor update',
          ],
          knowledge: <String>[
            'Critical path is the work that moves the end date',
            'A risk without an owner is decoration',
            'Sponsors need a decision, not a diary',
          ],
          tools: <String>['Board', 'Risks', 'Tradeoff', 'Update'],
          materials: <String>['Plan', 'Capacity', 'Stakeholder list'],
          layers: <String>['Path', 'Risk', 'Call', 'Note'],
          safety: 'Do not hide a slip behind “we are iterating.”',
          hints: <String>[
            'If everything is priority one, nothing is.',
            'Red tasks on the path move Thursday.',
            'Crash costs people. Cut costs scope. Slip costs trust.',
            'Four lines: status, cause, options, ask.',
          ],
          bottom: <String>['open', 'inspect', 'decide'],
          environment: 'Project war room',
        );
      case 'time_management':
        return const _Spec(
          labId: 'week_board',
          emoji: '🗓️',
          labTitle: 'Week board',
          unit: 'Personal operations',
          role: 'You, with too much on the calendar',
          purpose: 'Triage a overloaded week so the important work actually happens.',
          workplaceTitle: 'Personal ops board',
          workplaceBlurb: 'Calendar, energy, and three things that survive the week.',
          mission:
              'Forty hours of asks on a 30-hour week. Protect deep work, kill or park the rest, and leave one recovery block.',
          scenario:
              'Calendar is a pile of meetings. Tomorrow has a ship date. Time management is a board with names, not a productivity lecture.',
          objectives: <String>[
            'Circle the three outcomes that matter this week',
            'Kill or decline two meetings',
            'Block two hours of deep work',
            'Leave one recovery block that is real',
          ],
          knowledge: <String>[
            'Importance before urgency theatre',
            'A calendar without white space will steal the work',
            'Decline is a professional skill',
          ],
          tools: <String>['Calendar', 'Triage', 'Block', 'Protect'],
          materials: <String>['Week view', 'Task list', 'Energy notes'],
          layers: <String>['Must', 'Meeting', 'Deep work', 'Recovery'],
          safety: 'Do not stack 14-hour days and call it grit.',
          hints: <String>[
            'Write the three outcomes before you open email.',
            'If a meeting has no decision, it is a candidate to kill.',
            'Deep work needs a locked block, not a leftover.',
            'Recovery that can be stolen is not recovery.',
          ],
          bottom: <String>['open', 'allocate', 'decide'],
          environment: 'Week board',
        );
      case 'remote_work_skills':
        return const _Spec(
          labId: 'remote_floor',
          emoji: '🏠',
          labTitle: 'Distributed team floor',
          unit: 'Remote operations',
          role: 'Remote teammate on a distributed squad',
          purpose: 'Run async work so the team can move without another meeting.',
          workplaceTitle: 'Remote floor',
          workplaceBlurb: 'Async update, meeting that earns its time, and a boundary.',
          mission:
              'Your team is in three time zones. Write an async update that unblocks London, run a 15-minute huddle only if needed, and protect a shutdown time.',
          scenario:
              'Slack, a doc, a calendar spanning continents. Remote work fails when everything becomes a meeting. This floor rewards writing and boundaries.',
          objectives: <String>[
            'Write a status that names blockers and owners',
            'Decide meeting vs async',
            'Record decisions in the doc, not the chat',
            'Set a shutdown time and an emergency rule',
          ],
          knowledge: <String>[
            'Write so a teammate can act without you online',
            'Meetings need a decision, not a vibe check',
            'Boundaries are part of professional practice',
          ],
          tools: <String>['Doc', 'Slack', 'Huddle', 'Shutdown'],
          materials: <String>['Standup template', 'Time zone map', 'Decision log'],
          layers: <String>['Update', 'Blockers', 'Decision', 'Boundary'],
          safety: 'Do not be the always-on hero. That trains the team to wait.',
          hints: <String>[
            'If London can act from the doc, skip the huddle.',
            'Decisions in chat disappear. Put them in the log.',
            'A shutdown time is a professional agreement.',
            'Ping for true blockers, not for company.',
          ],
          bottom: <String>['open', 'inspect', 'decide'],
          environment: 'Distributed team floor',
        );
      default:
        return const _Spec(
          labId: 'career_desk',
          emoji: '🚀',
          labTitle: 'Workplace desk',
          unit: 'Professional practice',
          role: 'Practitioner on a live task',
          purpose: 'Do the job in the room. Not a lecture.',
          workplaceTitle: 'Workplace floor',
          workplaceBlurb: 'A live professional desk with a task, a decision, and a reason.',
          mission:
              'A real task is on the desk. Inspect the artifacts, make a call, and write why it holds.',
          scenario:
              'No lecture hall. A desk, a brief, and a person waiting on your decision.',
          objectives: <String>[
            'Open the brief',
            'Inspect the artifacts',
            'Make one professional call',
            'Write the reason in a sentence',
          ],
          knowledge: <String>[
            'The artifacts beat the slogan',
            'A decision without a reason is incomplete',
            'Practice is the course',
          ],
          tools: <String>['Brief', 'Artifacts', 'Call', 'Note'],
          materials: <String>['Live packet'],
          layers: <String>['Brief', 'Evidence', 'Call', 'Note'],
          safety: 'Do not hide behind theory. The desk is the test.',
          hints: <String>[
            'Read the brief first.',
            'Point at evidence before you decide.',
            'One call, not five.',
            'Write the why.',
          ],
          bottom: <String>['open', 'inspect', 'decide'],
          environment: 'Workplace desk',
        );
    }
  }
}

class _Spec {
  const _Spec({
    required this.labId,
    required this.emoji,
    required this.labTitle,
    required this.unit,
    required this.role,
    required this.purpose,
    required this.workplaceTitle,
    required this.workplaceBlurb,
    required this.mission,
    required this.scenario,
    required this.objectives,
    required this.knowledge,
    required this.tools,
    required this.materials,
    required this.layers,
    required this.safety,
    required this.hints,
    required this.bottom,
    required this.environment,
  });

  final String labId;
  final String emoji;
  final String labTitle;
  final String unit;
  final String role;
  final String purpose;
  final String workplaceTitle;
  final String workplaceBlurb;
  final String mission;
  final String scenario;
  final List<String> objectives;
  final List<String> knowledge;
  final List<String> tools;
  final List<String> materials;
  final List<String> layers;
  final String safety;
  final List<String> hints;
  final List<String> bottom;
  final String environment;
}
