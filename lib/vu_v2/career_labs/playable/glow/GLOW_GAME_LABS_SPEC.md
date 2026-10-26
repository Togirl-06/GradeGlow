# Glow Game Labs Spec

**Every school gets labs that play like a game: levels, stars, XP, ranks, a boss.**

Engine: `playable/glow/` · First lab: `glow/life_skills/budget_boss_lab.dart`

Loop: **Brief → Play level → Consequence → Feedback → Stars/XP → Unlock next level → Boss**

## Why this exists

GradeGlow already has ~20 playable labs, but they are bespoke screens. Three of the ten
schools have none, so asking an AI editor to "add labs and simulators for every school"
at once is too big and too vague. The fix is one small shared engine plus **one lab per
prompt**, each defined mostly as data.

## Rules

- A lab is **5 levels**: 2 puzzles, 2 simulators, 1 boss. Level N+1 unlocks at 1 star.
- Simulation is the lesson. The decision is the assessment. The consequence is the feedback.
- **No quiz pages.** Multiple choice is allowed only as a secondary check after a visual task.
- Game logic lives in a **pure Dart engine file** (no Flutter imports) with unit tests.
- Every level reports `GlowLevelResult(stars 0–3, score 0–100, note)`. The note says what
  the player did and what it cost them.
- Boss levels remove hints (no live preview).
- Star thresholds must be checked: a careful player gets 3★, a careless one gets 0★. Prove it
  with a quick simulation before shipping (see `budget_boss_engine.dart` tests).

## Engine (built)

| File | Job |
|------|-----|
| `glow_models.dart` | `GlowLab`, `GlowLevel`, `GlowMechanic`, `GlowLevelResult` |
| `glow_progress.dart` | Stars (best-only), XP, daily streak. SharedPreferences, prefix `glow_<labId>_` |
| `glow_shell.dart` | `GlowLabScreen` (level map + rank/XP/streak HUD) and `GlowLevelPlayer` (retry + result card) |
| `glow_widgets.dart` | `GlowColors`, `GlowPanel`, `GlowMeter`, `GlowButton`, `GlowStars`, `GlowSliderRow`, `glowMoney` |

Mechanics: `simulator`, `sortPuzzle`, `spotPuzzle`, `orderPuzzle`, `matchPuzzle`, `boss`.

XP: a level's `xp` is paid for 3★; fewer stars pay proportionally and only improvements pay.
Rank = 1 title per 100 XP. Five levels at 80/80/120/120/200 XP reach rank 6.

### Add a lab in 3 steps

1. Create `glow/<school>/<lab>_engine.dart` (pure logic + scoring) and `<lab>_lab.dart`
   (a `GlowLab` with 5 `GlowLevel`s and a `xxxScreen()` function).
2. Add a `CareerLabDef` to `career_lab_registry.dart`.
3. Add `'<id>': xxxScreen` to `playableScreens` in `playable_router.dart`.

### Next engine step (before lab #2)

Level 1 and 2 of Budget Boss are hard-coded to finance. Extract them into data-driven
`GlowSortLevel(spec)` and `GlowSpotLevel(spec)`, and add `GlowOrderLevel` and
`GlowMatchLevel`. After that a puzzle level is ~15 lines of data.

## What exists today

Registry ids already playable: `law_firm, nursing_ed, medicine, medical_lab_science,
pharmacy, business, finance, accounting, marketing, economics, cs_career, psychology,
biology, chemistry, physics, engineering, mathematics, civil_engineering,
electrical_engineering, cybersecurity` + `personal_finance` (new).
Also outside the registry: Algorithm Arena, ER simulation, Law simulation hub, Anatomy game.

| School | Programs | Has a lab | Gap |
|--------|---------:|-----------|-----|
| Technology & CS | 8 | CS, Cybersecurity | AI, Data Science, IT, Web Dev, Mobile |
| Engineering | 6 | Bridge/Design, Civil, Electrical | Mechanical, Chemical, Aerospace, Industrial |
| Business & Economics | 8 | Business, Finance, Accounting, Marketing, Economics | Entrepreneurship, HR, Intl Business |
| Health & Medicine | 8 | Nursing, Medicine, MLS, Pharmacy | Public Health, Nutrition, Healthcare Mgmt |
| Math & Natural Sciences | 6 | Math, Physics, Chemistry, Biology | Environmental Science, Statistics |
| **Arts & Design** | 4 | **none** | all 4 |
| Social Sciences & Humanities | 6 | Psychology | Sociology, Political Science, History, Philosophy, Anthropology |
| Law & Public Policy | 4 | Law firm | Criminal Justice, Public Policy, Intl Relations |
| **Communication & Media** | 6 | **none** | all 6 |
| **Career & Life Skills** | 10 | **Personal Finance (Budget Boss)** | other 9 (practice-only school: labs are its whole product) |

## Lab catalog by school

Format: **Lab** — program · puzzle levels · simulator levels · boss.

### Career & Life Skills (build first: smallest, zero coverage, practice-only)
- **Budget Boss** — Personal Finance · Needs/Wants sort, Spot the Fee · First Paycheck, Credit Card Trap · Rent Crisis. **BUILT.**
- **Hiring Desk** — Resume Writing · Spot weak bullets, Sort ATS keywords · Rewrite-and-rank 3 candidates · Beat the ATS with a 1-page deadline.
- **Hot Seat** — Interview Prep · Sort STAR parts, Spot red-flag answers · Branching interview with a confidence meter · Panel of three.
- **Open Mic** — Public Speaking · Order a speech structure, Spot filler words in a transcript · Live pacing sim (speech_to_text already in the app) · Hostile Q&A.
- **Team Lead** — Leadership · Sort delegate/do/drop · Morale-vs-deadline sim · Team conflict.
- **Clear Message** — Communication Skills · Match tone to audience, Spot ambiguous emails · Inbox triage sim · Escalation email.
- **Gig Desk** — Freelancing · Sort scope creep, Spot unpaid-work traps · Pricing and proposal sim · Client who won't pay.
- **Sprint Board** — Project Management · Order tasks by dependency, Match risk to response · Gantt-lite schedule sim · Scope-change boss.
- **Day Planner** — Time Management · Eisenhower sort, Spot time-wasters · Plan a packed day with energy meter · Finals week.
- **Home Office** — Remote Work · Sort async vs sync, Spot security risks · Timezone scheduling sim · Outage on a Friday.

### Arts & Design (zero coverage)
- **Kern & Align** — Graphic Design · Match type pairings, Spot hierarchy mistakes · Tune spacing/contrast to a brief · Client rebrand with 3 constraints.
- **Tap Target** — UI/UX · Spot usability bugs on a mock screen, Order a user flow · A/B test sim (conversion meter) · Redesign a checkout.
- **Tween Time** — Animation · Order keyframes, Match easing curves · Slider-tune motion to a target · Timed animatic.
- **Palette Lab** — Digital Illustration · Match color harmonies, Light-direction shading puzzle · Value/saturation sim · Commission with a mood board.

### Communication & Media (zero coverage)
- **Newsroom Deadline** — Journalism · Spot unverified claims, Order an inverted pyramid · Breaking-news sim (accuracy vs speed) · Correction crisis.
- **Crisis Comms** — Public Relations · Sort holding statements, Spot tone-deaf phrases · Trust meter over 5 news cycles · Viral scandal.
- **Viral Lab** — Content Creation · Match hook to platform, Spot weak thumbnails · Upload-schedule/analytics sim · Algorithm change.
- **Cut to the Chase** — Film Studies · Match shot types, Order a scene's edit · Pacing sim · Reshoot with budget cap.
- **On Air** — Broadcasting · Order a show rundown, Spot dead-air risks · Live timing sim · Breaking story mid-show.
- **Media Mix** — Mass Communication · Match theory to example, Sort media effects · Campaign reach sim · Misinformation wave.

### Social Sciences & Humanities (psychology only today)
- **Survey Says** — Sociology · Spot sampling bias, Sort variables · Design-a-survey sim · Disputed poll.
- **Build a Bill** — Political Science · Match institution to power, Sort checks and balances · Coalition vote-counting sim · Filibuster.
- **Primary Source** — History · Spot source bias, Order a timeline · Investigate-an-event sim · Conflicting archives.
- **Argument Court** — Philosophy · Sort valid/invalid arguments, Spot fallacies · Debate-tree sim · Trolley-problem panel.
- **Field Notes** — Anthropology · Sort observation vs interpretation, Match artifact to culture · Participant-observation sim · Ethics review.

### Law & Public Policy
- **Evidence Room** — Criminal Justice · Sort admissible/inadmissible, Order chain of custody · Case-file sim · Suppression hearing.
- **Budget the City** — Public Policy · Match policy to tool, Spot unintended effects · Allocate-a-budget sim with stakeholder meters · Budget shortfall.
- **Summit** — International Relations · Match actor to interest, Sort treaty types · Negotiation trade-off sim · Border crisis.

### Health & Medicine
- **Outbreak!** — Public Health · Match intervention to disease, Spot data errors · SIR spread sim with levers · New pandemic.
- **Plate Builder** — Nutrition · Sort foods to targets, Spot misleading labels · Weekly meal-plan sim · Athlete with allergies.
- **Bed Manager** — Healthcare Management · Order triage, Match staffing to demand · Hospital flow sim · Mass-casualty event.

### Math & Natural Sciences
- **Ecosystem Keeper** — Environmental Science · Match cause to effect, Order a food web · Predator–prey / carbon-budget sim · Invasive species.
- **Stats Court** — Statistics · Spot misleading graphs, Sort test to question · Sampling/CLT sim · P-hacking scandal.

### Technology & Computer Science
- **Train the Model** — AI · Sort bias sources, Spot overfitting · Tune learning rate/data size sim · Biased model in production.
- **Data Detective** — Data Science · Spot dirty data, Match chart to question · Cleaning pipeline sim · Misleading dashboard.
- **Help Desk Hero** — IT · Order troubleshooting steps, Match port to service · Ticket-queue SLA sim · Network outage.
- **Ship the Site** — Web Development · Assemble the box model, Spot accessibility bugs · Performance-budget sim · Launch-day traffic.
- **App Store Launch** — Mobile · Sort release checklist, Spot permission overreach · Crash-rate/rating sim · Rejected build.

### Engineering
- **Gear Up** — Mechanical · Match gear ratio to goal, Spot stress points · Torque/load sim with redesign · Jammed machine.
- **Reactor Control** — Chemical · Order process flow, Match valve to variable · Keep temp/pressure in band · Runaway reaction.
- **Lift-Off** — Aerospace · Match force to flight phase, Order a launch sequence · Thrust/drag/fuel sim · Abort and recover.
- **Line Balancer** — Industrial · Sort tasks to stations, Spot bottlenecks · Takt-time sim · Supplier delay.

### Business & Economics
- **Runway** — Entrepreneurship · Sort fixed vs variable costs, Spot unrealistic projections · Price/demand/cash-runway sim · Down round.
- **People Ops** — HR · Spot biased screening, Sort policy to situation · Conflict-resolution sim · Layoff round.
- **Customs Desk** — International Business · Match incoterm to risk, Sort tariff effects · FX hedging sim · Trade-war shock.

## Build order

0. **Done:** engine + Budget Boss.
1. Extract generic Sort/Spot levels; add Order and Match. (Engine v1.1)
2. The other 9 **Career & Life Skills** labs.
3. **Arts & Design** (4) and **Communication & Media** (6).
4. Social Sciences, Law & Policy, Health, Math & Natural Sciences gaps.
5. Technology, Engineering, Business gaps.

## Optional AI layer

After each level, an "AI coach" note can replace the canned `note` using `openai_service.dart`,
with the canned note as the offline fallback. Do this after the engine is generic, not before.

## Definition of done (per lab)

- [ ] 5 levels: 2 puzzle, 2 sim, 1 boss; boss has no hints
- [ ] Pure `*_engine.dart` with unit tests; thresholds checked for both a careful and a careless player
- [ ] Registered in `career_lab_registry.dart` and `playable_router.dart`
- [ ] No lesson text longer than 3 sentences on any screen
- [ ] Works at phone width (no horizontal overflow) in dark theme
- [ ] `flutter analyze` and `flutter test` pass

## Prompt template for Cursor (one lab per prompt)

> Read `lib/vu_v2/career_labs/playable/glow/GLOW_GAME_LABS_SPEC.md` and
> `glow/life_skills/budget_boss_lab.dart`. Build the **<LAB NAME>** lab for the **<PROGRAM>**
> program, following the same structure. Use the existing Glow engine; do not create a new one.
> Levels: <2 puzzles>, <2 sims>, <boss>. Put game logic in a pure `<lab>_engine.dart` with unit
> tests. Register it in `career_lab_registry.dart` and `playable_router.dart`. Only touch those
> files plus the new ones. Run `flutter analyze` and `flutter test` and fix what they report.
