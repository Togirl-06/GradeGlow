# GradeGlow simulator audit (2 Nov 2026)

Baseline: `main` @ `dadc8ee`, saved as branch `backup/pre-sim-rebuild-2026-11-02`.
Work happens on branch `sim-rebuild`; nothing is merged to `main` (which auto-deploys).

## Method

* Built an import graph of `lib/` starting at `lib/main.dart` (relative, `package:`, `part` and
  conditional imports). Files not reachable from `main.dart` cannot run in the app.
* Scanned all reachable simulator code for empty callbacks, `TODO`, "coming soon",
  placeholder/fake/stub markers, snackbar-only buttons, and grading based on text length.
* Rendered `web/life_world` (the 3D world) in headless Chromium in demo mode and took screenshots.
* Read the save path, Cloud Functions and Firestore rules.

## What exists

| Area | Path | Size | Reachable | Verdict |
|---|---|---|---|---|
| Life simulator core (needs, clock, economy, jobs, interviews, workplace, university) | `lib/life_sim` | 66 files, 20k lines | yes (Labs tab → Enter GradeGlow Life) | **Keep.** Deterministic, unit-tested, interview engine has free-text answers, follow-ups and 4 outcomes. |
| 3D world (three.js city, Sims-style characters, cut-away rooms, apartment with 5 rooms) | `web/life_world` | 8 files, 5.4k lines | web only, via iframe | **Keep.** Real interactive 3D. Native builds fall back to a 2D isometric painter. |
| Station → activity map (57 stations in 11 school buildings) | `lib/life_sim/campus/campus_labs.dart` | | yes | **Keep**, extend. |
| Per-school career packages (science, health, business, engineering) | `lib/vu_v2/*_career` | ~40k lines | yes (from campus stations **and** the School hub) | **Keep the activities; route through the campus.** Each has its own progress and money store, so the student's wallet differs by screen. |
| Playable career labs | `lib/vu_v2/career_labs` | 128 files | 76 live, 52 orphaned | Keep live files, remove orphans. |
| `vu_v2/career_sim` (a second career engine) | | 29 files, 11k lines | **no** | **Remove.** Never opened anywhere. |
| `vu_v2/labs` | | 46 files | 21 live, 25 orphaned | Remove orphans. |
| Older per-subject screens (`lib/screens/biology`, `computer_science`, `chemistry`, …) | | | partly | Remove orphans. |

Orphaned code in total: **325 files, ~103,000 lines** (full list: `docs/sim_rebuild/orphans.txt`).
Ten tests only exercise orphaned files; they are removed with them.

## Fake or weak functionality found in live code

| Severity | Where | Problem |
|---|---|---|
| **Critical** | `lib/vu_v2/labs/vu_v2_cs_problem_workspace.dart` `_grade()` | Code is never executed. Any answer ≥ 9 characters longer than the starter is "Accepted"; test-case rows are fabricated. Language picker offers Python/Java/C++ with nothing behind it. |
| **Critical** | `lib/services/leetcode_debug_judge.dart` | Debug problems "pass" if the code changed and a regex for the original bug is absent. |
| High | `lib/vu_v2/science_career/interview_center_screen.dart` | Interview score rises with answer length; a 30-character answer after long earlier ones can pass. Separate from the real interview engine in `life_sim`. |
| Medium | Firestore rules | Owners may write every subcollection, so any score or result a client writes is trusted. Only `life_server/**` is server-owned. |
| Low | `lib/vu_v2/campus/vu_v2_progress_tab.dart:215` | `_AppearanceCard(onChanged: () {})` (no-op callback; the card still works through its service). |
| Low | `medical_lab_screen.dart` | +5 for report length on top of real checks (acceptable). |

No empty `onPressed` handlers, `TODO` actions or "coming soon" buttons were found in reachable simulator code.

## Coverage against the brief's 19 places

All present in `city_map.dart` and rendered in 3D **except a separate School of Economics** (economics
lives inside the Business & Economics Tower). Hospital = St Gabriel's + Riverside; Innovation Center =
`company_registry`; Humanities = `school_arts`.

## Cleanup and rebuild plan

1. **Checkpoint**: backup branch + `sim-rebuild` branch + CI (analyze, Flutter tests, functions tests,
   3D-world tests) that publishes full reports to the `ci-reports` branch.
2. **Remove orphans** (325 files) and their tests. CI must stay green.
3. **Real code judge**: Cloud Function `codeJudge` runs submissions in an isolated, resource-limited
   sandbox (Piston-compatible runner, configured by secret), grades hidden tests on the server, and
   records the result in a server-owned collection. The app never marks code Accepted on its own;
   if the runner is not configured it says so and Submit is disabled.
4. **Trust boundary**: server-owned `coding_results` and `assessments` collections (client read-only).
5. **Interview grading** in the science interview center: score on evidence (keywords, structure),
   never length alone.
6. **School of Economics** as its own building with its own stations.
7. **Native 3D**: evaluate reusing `web/life_world` in a WebView on Android/iOS.
8. **Acceptance tests** for the 14 journeys in the brief, plus a final report.

## Known constraints of this environment

* The Flutter SDK and pub.dev cannot be downloaded in the agent workspace, so Dart is analyzed and
  tested in GitHub Actions only. Node and the 3D page are tested locally as well.
* Unity is not adopted (see `docs/life_sim_engine_decision.md`); the three.js world stays.
