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

| School | Labs built | What the student actually does |
|---|---|---|
| Computer Science | 5 | Writes and runs programs, fixes failing code against hidden tests, queries a university database in a SQL workbench, simulates CPU scheduling and paging, traces a search |
| Nursing | 6 | Works from patient charts: identity checks, history taking, vitals with NEWS2 scoring (RCP 2017), medication administration against a MAR, escalation decisions |
| Medicine | 3 | Patient history, clinical reasoning on the same records, anatomy identification |
| Mathematics | 6 labs × 15 scenarios | Enters working line by line (the first wrong step is named), uses sliders on live graphs, fills matrix grids, analyses datasets, solves ODEs checked by substitution; calculator, grapher and saved whiteboard |
| Accounting | 3 | Posts journal entries to a bakery's ledger, bank reconciliation, builds statements that must balance |

**Not built to the blueprint yet:** Software Engineering, AI, Data Science,
Cybersecurity, IT, Web and Mobile specialisations; Law; all Engineering
disciplines; the other Business majors; Biology, Chemistry,
Physics; English. Full per-lab status: `docs/career_sim/LAB_TRACKER.md` (generated by `tool/lab_tracker.py`). These schools still have only their department training
tasks. No 3D anatomy. Python downloads Pyodide from jsDelivr on first use, so
it needs internet once. The phone runner compiles but was not tried on a device.

## Fixes to existing code found along the way

* Debug Desk starters kept the old function names, so the judge could never
  find the function the student fixed. They now use the judged name.
* At least one Debug Desk problem (`GG-0012`) ships correct code as its "buggy"
  starter (verified: Accepted 3/3). The simulator no longer uses it. The Arena
  problem itself is unchanged.

## Not done / limitations

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
* No 3D: anatomy and cell labelling are 2D diagrams. Phones were not run on a device.
* Workplaces reuse their assignment list once it has been completed.

## Before merging

1. Review the PR from `career-sim` (it also contains the `sim-rebuild` work and supersedes PR #4).
2. Deploy the code runner and run `firebase deploy --only functions,firestore:rules`.
3. Try the Career tab on a phone.
