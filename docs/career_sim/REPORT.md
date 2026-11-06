# GradeGlow career simulator — report

Branch `career-sim` (built on `sim-rebuild`; not merged, because `main` auto-deploys).
It replaces everything that used to be behind the **Labs** tab. The tab is now called **Career**.

Everything marked *tested* ran and passed in CI (GitHub Actions, full logs on the
`ci-reports` branch under `reports/<commit>/`). Final run, commit `8bc836f`:
analyzer 0 errors · Flutter tests **142 passed, 0 failed** (66 of them for the simulator) ·
Cloud Functions tests 16 passed.

## What was deleted

The life simulator (`lib/life_sim`), the three.js world (`web/life_world`), the
per-school "career games" (`vu_v2/labs`, `career_labs`, `health_career`,
`science_career`, `business_career`, `engineering_career`, `game`), the
`lifeSimGuard` function, and the 186 further files (~46k lines) that were only
reachable through them, with the tests that covered only that code. Every
remaining file in `lib/` is reachable from `main.dart`.

Kept: sign-in, Firebase, subscriptions, courses and lectures, the code judge,
the coding problem bank and the Firestore rules.

## What was built (`lib/career_sim`)

The flow is learn → practise → professional tasks → portfolio → apply →
interview → hired → work → promotion. Nothing is automatic: every stage change
comes from a rule-based review the student asks for.

| Part | What it does | Tested by |
|---|---|---|
| Departments | 9 departments: Computer Science, Nursing, Medicine, Law (with courtroom), Engineering (6 labs), Business & Economics (8 units), Mathematics, English & Communication, Natural Sciences (biology, chemistry and physics labs). No task is shared between departments. | `content_test`, `screens_test` (each screen opens) |
| Task types | Code (server judge), clinical/management decisions with critical-safety failures, patient work-ups, calculations with tolerance, journal entries, classification, procedures, written work with a published rubric, diagram labelling, courtroom objections | `rules_test`; `screens_test` passes every non-code module task through its screen |
| Training | Lessons, practice tasks, projects → portfolio, certification exams | journey + `store_test` |
| Career Centre | Readiness score, resume builder with checklist, cover letters, portfolio, mock interviews, trainee status review | journey, `screens_test` |
| Jobs | 20 postings with company, title, description, responsibilities, qualifications, skills, experience, type, salary range, deadline and requirements. Postings reopen every 60 days. | `content_test`, `screens_test` |
| Applications | Draft → Submitted → Under review → Shortlisted/Rejected → Interview scheduled → Interview completed → (Further assessment) → Offer → Hired / Declined / Withdrawn. The employer screening report scores training, skills, portfolio and materials, and lists strengths and gaps. | `store_test`, journey |
| Interviews | The next question depends on the last answer's score: a weak answer is probed, a strong one is stretched. Includes a live practical (code, clinical scenario, calculation, ledger, case study) and the candidate's own questions, which are answered from the company profile. Scored on communication, technical knowledge, problem solving and readiness. | `rules_test`, journey |
| Hiring | Offer if overall ≥ 70, every competency ≥ 50 and the practical passed; one further assessment at 58–69; otherwise rejected, with reasons | `rules_test` |
| Workplace | One workplace per employer, with a supervisor, environment, tools and assignment tickets. A handoff note is required. Supervisor evaluation: 60% quality, 20% timeliness, 20% communication. | journey, `store_test` |
| Progression | Student → Trainee → Intern → Entry-Level → Junior → Experienced → Senior → Team Lead, with published criteria (assignments, performance, on-time rate, days in role, certifications, a leadership assignment). Interns get a final evaluation and a return offer if they pass. | `rules_test`, `store_test` |
| Saving | Every change saves to the device, and to Firestore `users/{uid}/career_sim/profile` when signed in. The newer copy wins. A failed cloud save is reported in the app. | `store_test`, journey (restore) |
| AI | Lecturer, interview coach and supervisor panels, labelled "guidance only, never part of your score", told never to give answers. They never grade anything. | — (needs the OpenAI key; not run in CI) |

**The 20-step CS journey** (`test/career_sim/cs_journey_test.dart`) drives the
real screens. It goes from the department through a lesson, a coding exercise
(run and submit), a project and the portfolio, then resume and trainee status,
finds the internship and applies. It then covers employer review, the
invitation, an adaptive technical interview with live coding and candidate
questions, the hiring decision, the offer and acceptance, the workplace, an
assignment with a handoff note, the supervisor evaluation and the progress
update. Finally it reloads the saved record in a new session and checks it is
identical. The code judge is simulated in that test; real execution is covered
by the Cloud Functions tests.

**Bug-fix tasks** start from broken code. CI runs every bug-fix starter through
the server's own harness to show that it fails the hidden tests, and runs a
reference fix to show that it passes (`functions/test/career_debug_starters.test.js`).

## Practical labs (`lib/career_sim/labs`)

Every lab follows the same six screens: introduction, a professional
environment with working tools, assignment briefing, interactive work,
evaluation that explains each mark, and completion. Progress is saved after
every step, so leaving and coming back resumes at the same step with drafts kept.

**Code runs on the student's device** (`web/code_runner`): Python 3 through
Pyodide, JavaScript in a worker, SQL through SQLite (sql.js, bundled). On the
web this is a Web Worker; on Android/iOS it is a hidden WebView. Grading uses
the server judge's own harness, bundled by `tool/build_code_runner.js`, and CI
checks the results match the server. Infinite loops hit a 6-second limit.

**198 labs across 33 majors, all "Tested"** (tools, grading and saving
work, automated tests cover them, 15+ levelled scenarios: beginner,
intermediate and advanced, with each level unlocked by two passes at the level
below). Full per-lab status: `docs/career_sim/LAB_TRACKER.md` (generated by
`tool/lab_tracker.py`). None is "Verified complete": that needs a person to
play it.

* **CAD drawing sheet** (`labs/work/drawing_*`): draw the outline and holes on
  a 1 mm grid, dimension them from real edges and hole centres, fill in the
  title block. Checked like a drawing office would: geometry within tolerance,
  every hole located from the datums, redundant dimensions and missing
  tolerances (H7, ±0.05) flagged. 2D only, no 3D modelling.
* **3D anatomy** (`web/anatomy_3d`, `labs/anatomy3d`): a three.js body with 58
  structures in 8 switchable systems; rotate, zoom, tap to identify. Runs in
  an iframe on the web and a WebView on phones, with a list alternative.
  Structures are placed anatomically but built from geometric shapes — a
  teaching schematic, not a scan. Checked in headless Chromium (rendering,
  tapping, the message bridge); not tried on a phone.
* **Levels are different work, not repeats.** Design problems use a fresh
  worked case at each level; cases go queue → follow-up conversation →
  procedure and document; investigations go evidence → quantify → correct. A
  test fails if any scenario repeats another step for step.
* **Every lab's first scenario is played through the screens** by a test
  (intro → environment → briefing → each task → evaluation → completion).

Every lab is framed as a job: a named employer and supervisor per major
(`workplace.dart`), briefings from colleagues or clients, conversations where
some replies are essential, some unhelpful and some unsafe, and a performance
rating with a supervisor review at the end. Work types:

* **Programs** (Python or JavaScript, run on the device) for tickets such as
  fixing a legacy shipping calculator, a NEWS2 calculator, a firewall rule
  engine, a Banker's algorithm or an aged-receivables report. Many start from
  deliberately broken code. CI re-runs every reference program in Pyodide.
* **SQL** against the lab's SQLite database (answers checked in sql.js by CI).
* **Design problems** with live sliders and specifications that tighten by level.
* **Investigations**: gather evidence, name the cause, choose the fix, do a
  calculation, order the procedure.
* **Cases**: triage queues, conversations, procedures and written documents
  marked against rubrics (with checks for forbidden content such as invented
  citations or opinions of guilt).
* **Maths** working checked line by line (first wrong step named), graphs,
  matrices and ODEs.

Most content is generated from `tool/labgen/majors/*.py` by
`python3 tool/labgen/build.py`, which refuses to build if any model answer
fails, any starting setting already passes, any buggy starter already passes
its tests, any option list has no wrong answer, any lab lacks 15 scenarios, or
a skill doesn't belong to the department. The original hand-built labs (CS,
Nursing, Medicine, Accounting) keep their own tools and gain 15 generated
scenarios each.

Readiness for a job now counts the labs of the student's own major track:
departments host several majors (CS hosts Software Engineering, AI, Data
Science, Cybersecurity, IT, Web and Mobile), and a student isn't expected to
complete every one.

Python downloads Pyodide from jsDelivr on first use, so it needs internet once.
The phone runner compiles but was not tried on a device. Model answers for
programs and SQL were written by me and checked by running them, but expected
outputs for SQL are computed from my reference queries. The medical, nursing,
legal and accounting content follows published rules (NEWS2, Sepsis Six,
Holliday–Segar, CURB-65, Wells, CHA2DS2-VASc, UK GDPR breach timing, UK VAT
basics) but has not been reviewed by a practising professional, and it is
teaching material, not clinical guidance.

## Navigation and simulated pay

* **Simpler home page.** The Career tab is now one short page: earnings chip,
  a "Find" search box, the next step, practical training, and large shortcut
  tiles in three groups (Learn, Get hired, Work and earn). Long lists moved to
  their own screens (Progress, Portfolio, Applications).
* **Find** (`ui/money_find_screens.dart`) searches every lab (title, summary,
  objectives), training module, open job and main screen; the student's own
  field ranks first. Practical Labs has its own search box and lists the
  student's major first.
* **Simulated pay** (`engine/pay_rules.dart`). Passing a lab scenario the first
  time pays £60 / £110 / £180 by level, scaled by score. Each evaluated work
  assignment pays a week's salary, +10% at a supervisor score of 85+, and a
  promotion pays two weeks at the new salary. It is kept as a ledger in the
  saved profile (old profiles load with £0). "My Earnings" shows the balance and
  history and says plainly that it is in-game money, not real money.
  Nothing can be withdrawn or spent.

## Employment journey with real resumes (virtual USD)

* **Resume upload** (`lib/career_sim/resume/`). PDF and Word .docx files are
  read on the device by a pure-Dart extractor (works on web and phones):
  PDF objects and compressed object streams, Flate/ASCII85, ToUnicode CMaps
  and WinAnsi fonts; DOCX body, tables and headers. The text is split into
  an editable profile (name, contact, summary, education, experience,
  skills, projects, certifications, achievements). Nothing is added that is
  not in the file. Scanned (image-only) PDFs are refused with a message.
  Files are stored at `users/{uid}/resumes/` in Firebase Storage. New rules
  allow only the owner, PDF/DOCX and under 5 MB. Students can replace or
  delete a resume.
* **Resume analysis**: a rule-based quality score with strengths,
  weaknesses and suggestions, and a per-job compatibility score that names
  the matched and missing skills, checks education and experience, and
  explains each point. Internships and entry roles count projects instead
  of paid experience.
* **Job marketplace** (`content/job_market.dart`): 67 roles from
  internship to management. They cover every title in the brief, across
  computing, health, law, engineering, business, mathematics, sciences and
  communication, at 18 simulated employers. Each listing has a department,
  employment type, level, hours, location and remote status, a USD salary,
  a deadline, the number of positions, required education, required and
  preferred skills, responsibilities and benefits. Clinical and legal roles
  carry a no-licence notice.
* **Application**: choose the uploaded or built resume, write a cover
  letter, answer the employer's questions (graded by rubric), review and
  submit. Screening weighs the resume match (40), resume quality (10),
  letter and answers (25) and practical evidence from GradeGlow labs (25).
  It shortlists or rejects with written gaps. Duplicate applications are
  refused.
* **Interview**: opens with a question about the candidate's own resume,
  then the role's questions (the brief's examples for software, nursing,
  finance and law, and others), then the department panel. Follow-ups adapt
  to the answers. The report shows four competency scores and the strongest
  and weakest answers.
* **Offer → contract → onboarding**: the offer shows the salary, annual and
  monthly gross, pay schedule, hours, start day, responsibilities, benefits
  and expectations. One reasoned negotiation can raise it by up to 5%
  within the band. Accepting means signing a simulated contract with the
  profile name. A five-item onboarding checklist must be finished before
  the first assignment.
* **Work**: each role's assignments are real scenarios from that field's
  practical labs, harder over time, with advanced tasks counting as
  leadership. Nursing and medicine jobs also assign virtual-hospital
  placements, including the full ward shift.
* **Pay** (`engine/pay_rules.dart`): each evaluated assignment is one
  approved work week. Paychecks are processed per period (weekly,
  biweekly or a 4-week simulated month), with 10% simulated deductions and
  net pay, and each period is paid only once (unique paycheck ids). My
  Earnings shows the balance, totals, last paycheck, next payday and
  history, with the required notice. Students not yet employed get a small
  training stipend for passing labs.
* **Reviews and promotion**: every four assignments, a review scores
  quality, accuracy, problem-solving, communication, teamwork, reliability
  and deadlines from the real work. Raises are 2% at 70+, and 5% at 85+
  with 75+ on deadlines. The existing promotion criteria lead up each
  role's ladder (Intern → … → Manager) with a 12% raise.
* **Career Centre**: shows the employment status and the next action, plus
  the ten sections from the brief.

## Virtual hospital (`lib/career_sim/hospital/`)

* 16 virtual patients in 13 departments: ED, ICU, ward, pediatrics,
  maternity, theatre, med-surg, cardiology, neurology, oncology, pharmacy,
  laboratory and radiology. There is also a reception triage board (six
  arrivals) and a 7 AM ward shift with three patients on one clock.
* Every action takes simulated minutes. Vital signs drift and deteriorate
  by each case's cause-and-effect rules, and stabilise when the right
  treatment is given. Nothing is random.
* Rooms show:
  * a drawn patient whose colour and expression change with their state;
  * an animated bedside monitor with ECG and pleth traces, NEWS2 and alarms;
  * free-text conversation answered only from the case history, the same
    way each time;
  * examinations, an equipment trolley and a chart: allergy record, history,
    medications, vitals chart, results, and drawn X-ray and CT images;
  * orders, treatments, SBAR escalation, a working diagnosis or nursing
    priority, and notes.
* Unsafe actions are stopped and explained. Examples: a penicillin given
  despite an allergy, sedating asthma, or insulin during a hypo. Medicines
  require allergy and identity checks first. Nursing and medicine have
  different scopes and requirements.
* The debrief covers eight rubric categories, the patient's outcome,
  appropriate, missed and late actions, and teaching points. A critical
  safety error is shown on its own and blocks a pass, whatever the total
  score.
* Every action is saved; the engine replays the log to resume exactly.

## Fixes to existing code found along the way

* Debug Desk starters kept the old function names, so the judge could never
  find the function the student fixed. They now use the judged name.
* At least one Debug Desk problem (`GG-0012`) ships correct code as its "buggy"
  starter (verified: Accepted 3/3). The simulator no longer uses it. The Arena
  problem itself is unchanged.

## Not done / limitations

* **Pay, screening and interview results are computed on the device.**
  Firestore and Storage rules keep each student's records private, but there
  is no server-side recalculation yet, so a determined user could edit their
  own saved profile. Paycheck ids prevent double payment inside the app.
* **The interviewer, patients and supervisor are rule-based**, not free-form
  AI: their replies come from rubrics and case scripts, so they are consistent
  and cannot invent medical facts, but they only understand phrasings their
  keyword lists cover.
* **Hospital scenarios have not been reviewed by a practising clinician.**
* Resume reading works on text-based PDFs and .docx; multi-column layouts can
  come out in a different order, and scanned PDFs are refused.


* **Server code runner not deployed.** Labs and career coding tasks now run on
  the device, so they work without it. Arena submissions that need the server
  still need `docs/sim_rebuild/CODE_RUNNER_SETUP.md`.
* **The interviewer is rule-driven**, not a free-form AI conversation. Question
  choice and scores come from rubrics, so they are reproducible. AI only adds
  coaching afterwards.
* **Written answers are scored by concept rubrics.** Keyword lists and fragments
  don't score, but a rubric is not a human marker.
* **Career records are written by the app.** Unlike code results, they are not
  computed on the server, so a determined user could edit their own saved profile.
* Only the CS journey has a full end-to-end test. The other departments are
  covered by screen, task and rule tests, plus the generic internship → return
  offer test.
* Cell labelling is still 2D. The 3D anatomy model is a geometric schematic. Phones were not run on a device.
* **No lab has been run end to end by a person** (status "Verified complete" is 0 of 198). Tests play the first scenario of every lab through the screens and drive each step type, but not all of the roughly 2,500 scenarios.
* Workplaces reuse their assignment list once it has been completed.

## Before merging

1. Review the PR from `career-sim` (it also contains the `sim-rebuild` work and supersedes PR #4).
2. Deploy the code runner and run `firebase deploy --only functions,firestore:rules`.
3. Try the Career tab on a phone.

## Visual redesign

The career, workplace, code lab and hospital screens now follow the supplied mockup:
- dark navy panels and violet accents;
- a campus hero with school tiles;
- a tabbed Career Center with a job board;
- a sidebar workplace with a salary, a gauge and an earnings chart;
- a three-pane code lab;
- an illustrated patient room with info and action panels;
- a sidebar patient record.

The shared widgets are in `lib/career_sim/ui/gg_kit.dart`. Illustrations are drawn in code (no photos). `test/screenshots/` renders 14 screens on every CI run.
