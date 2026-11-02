# GradeGlow simulator rebuild — final report

Branch: `sim-rebuild` (not merged; `main` auto-deploys). Backup of the starting
point: branch `backup/pre-sim-rebuild-2026-11-02` (= `main` @ `dadc8ee`).
Audit: [AUDIT.md](AUDIT.md). Code runner setup: [CODE_RUNNER_SETUP.md](CODE_RUNNER_SETUP.md).

Everything below marked **tested** was exercised by an automated test that ran
and passed in CI (GitHub Actions, Flutter 3.47.9 / Dart 3.13.7, full reports in
the `ci-reports` branch), or by a headless-Chromium check of the 3D page.

## Final CI result (commit `2a1e438`)

Analyzer: 0 errors · Flutter tests: **259 passed, 0 failed** (8 were failing on `main`) ·
Cloud Functions tests: 30 passed · 3D world tests: 3 passed.

## What the audit found

* The life simulator (`lib/life_sim`) and the three.js 3D world (`web/life_world`)
  were real and worth keeping: walkable city, Sims-style characters, a
  5-room apartment, interviews with follow-ups, jobs, shifts, pay, saves.
* **The coding arena was fake.** Code was never executed; any answer at least
  9 characters longer than the starter was "Accepted" with made-up test rows.
* **479 of 484 arena problems were placeholders** ("Sample input for Arena
  arrays Challenge 1" → "Expected output", no hidden tests, statement naming a
  different function). Unsolvable, but hidden by the fake judge.
* 292 files (~95k lines) unreachable from `main.dart`, including a second
  career engine. 8 tests were already failing on `main`.
* Science-track interviews passed long filler answers.
* Bought furniture never appeared in the 3D apartment.
* 3D only on web; phones used a 2D view. No School of Economics building.

## Features completed

| Area | What changed | Tested by |
|---|---|---|
| Cleanup | 292 orphaned files and the tests that only covered them removed; every remaining `lib/` file is reachable | analyzer 0 errors; import graph |
| Coding judge | Cloud Function `codeJudge`: Python 3 + JavaScript harness, linked lists, trees, in-place and any-order answers; verdicts Accepted / Wrong Answer / Runtime Error / Compile Error / Time Limit / Memory Limit; hidden cases stay hidden except the first failing one; runtime + memory; rate limit 20/min | `functions/test/code_judge.test.js` (real `python3`/`node` processes) |
| Trust | Results, submissions, rate limits and the leaderboard are written only by the server; Firestore rules make them read-only for students | rules diff; record-merge tests |
| Code Bench (app) | Run/Submit call the server; verdict, cases, runtime, memory shown; ungraded languages labelled "not graded yet" and cannot be submitted; nothing is ever accepted locally | `test/coding/code_judge_service_test.dart` |
| Problem bank | Only problems with real tests are listed; a copy with real tests always beats a placeholder; 22 new GradeGlow-original problems whose expected outputs come from reference solutions; server bank kept in sync with the app | both references Accepted, starters fail; drift test; "every listed problem is gradable" |
| Interviews | Science-track interview scored on role concepts, reasoning and steps, starting from 1/5 | `test/science_interview_scoring_test.dart` |
| School of Economics | Own building (University Quarter), 3 stations, professor, student, 3D facade | campus tests; 3D screenshot |
| Apartment | Placed furniture is drawn in the 3D apartment and the room rebuilds when it changes | 3D screenshot; `web/life_world/test` |
| Phones | Android/iOS load the same 3D world in a WebView (`GGNative` channel); 2D fallback if the page never loads | page side in headless Chromium (ready, scene, ack, render); Dart side compiles |
| Bugs fixed | Career-world painter crash (10 stations never rendered); science hub and titration overflows (7 stations); login "Remember me" tile assertion | station acceptance test; `widget_test` |

## Acceptance tests (brief §12)

`test/acceptance/student_journey_test.dart` drives the real engine, save service,
campus wiring and coding client. `test/acceptance/campus_stations_test.dart`
opens every station's real screen inside the full app.

| # | Test | Result |
|---|---|---|
| 1 | Create and customize a character | pass |
| 2 | Enter the apartment, use furniture, buy and place furniture (money deducted, comfort rises) | pass |
| 3 | Save and reload | pass |
| 4–5 | Walk tile by tile across campus, enter Computer Science, walk inside | pass |
| 6 | Coding challenge: run and submit through the judge client | pass (execution itself: functions tests) |
| 7–8 | Career Center stations, resume | pass |
| 8–14 | Degree → resume → application → AI interview with follow-ups → hiring decision → contract → workplace shifts with graded tasks → promotion → salary → save/reload, for **7 careers** (software engineer, nurse, lawyer, accountant, doctor, pharmacist, business manager) | pass |
| 14 | Close and reopen restores identical state | pass |
| — | **All 59 campus stations** in 12 school buildings open their screen inside the full app without an error | pass |

## Features still in progress / not implemented

* **Code runner not deployed.** The sandbox needs a VM and two secrets
  (see CODE_RUNNER_SETUP.md). Until then Submit says the runner is not configured.
* **Graded languages:** Python 3 and JavaScript only; 14 others are editor-only.
* **Arena size:** 43 gradable problems (31 implementation, 12 debug). Most older
  hand-written problems have one example and no hidden tests, so they are not
  listed; add more with `tool/arena_originals`.
* **One wallet:** per-school career packages (science, health, business,
  engineering) still keep their own progress and money, separate from the life
  sim wallet.
* **Server-authoritative economy:** life-sim saves are still client-written and
  bounded by the existing `lifeSimGuard` plausibility checks, not computed on
  the server. Coding results are server-authoritative.
* **Unity:** not adopted (see `docs/life_sim_engine_decision.md`); the three.js
  world now runs on web and phones.
* Coding competitions beyond the leaderboard; group interviews; speech input.

## Known technical limitations

* Flutter and pub.dev cannot be downloaded in the agent workspace, so Dart was
  analyzed and tested only in CI. The Android/iOS WebView path compiles but was
  not run on a device.
* Phones need network access for the hosted 3D page (`LIFE_WORLD_URL`).
* 53 analyzer warnings/infos pre-date this work (unused code in lecture/physics
  modules).

## Before merging

1. Review the PR from `sim-rebuild`.
2. Deploy the code runner and `firebase deploy --only functions,firestore:rules`.
3. Run the app on one Android and one iOS device to confirm the 3D WebView.
