# 04 — Cursor Implementation Prompts  
## Build V2 module-by-module (do not edit prototype UI)

**Global instruction to paste at the start of every Cursor chat:**

```text
You are building GradeGlow Virtual University V2 from scratch.
- Do NOT modify existing prototype screens under lib/screens/practice_labs_screen.dart,
  lib/screens/virtual_university/vu_campus_dashboard_body.dart, or old faculty list UIs
  to “look like” V2.
- Implement only inside lib/vu_v2/ (new module) + docs in docs/virtual_university_rebuild/.
- Follow docs/virtual_university_rebuild/01_PRD.md, 02_DESIGN_SYSTEM.md, 03_TECHNICAL_SPEC.md.
- Reuse services (OpenAI, auth, subscription, catalogs, sim engines) via adapters.
- Ship working vertical slices with empty/loading/error states.
- Brand: GradeGlow orange primary (#F97316), navy surfaces — not generic purple AI UI.
```

---

## Module 0 — Scaffold

```text
Create lib/vu_v2/ app scaffold:
1) design tokens + VuPrimaryButton, VuScaffold, VuProgressBar, VuEmptyState, VuErrorState, VuSkeleton
2) GoRouter (or Navigator 2) routes for: onboarding, campus, learn, practice, progress, profile
3) Bottom nav shell with 5 tabs
4) Feature flag `vuV2Enabled` to open V2 from a single debug entry without replacing the whole app yet
Acceptance: I can open V2 shell with placeholder pages and tokens applied.
```

---

## Module 1 — Onboarding

```text
Implement lib/vu_v2/onboarding per PRD §8:
Welcome → Meet AI → Goals → Major → Skill rating → Placement (8 Q) → Study plan CTA.
Persist StudyPlan locally + UserService fields.
Acceptance: finishes ≤4 min; recommends first course; skip placement works.
```

---

## Module 2 — Campus Home + Map

```text
Build Virtual Campus home (PRD §9–10):
- One-composition today header (continue deep-link, today’s 3 tasks)
- Illustrated campus map with buildings: Lecture Halls, Labs, Library, Student Center, Career, Events, Graduation
- Building tap → destination route
No prototype “Learn without limits” hero. No fake 5% Open Chemistry rows.
Acceptance: continue opens real lesson route; map buildings navigate.
```

---

## Module 3 — Design system completion

```text
Finish 02_DESIGN_SYSTEM component checklist items 1–9 with golden tests for buttons/progress/empty.
Add reduce-motion support.
```

---

## Module 4 — Course experience shell

```text
Implement Course Home + Modules + Grades tabs (PRD §12) under lib/vu_v2/learn/.
Data via adapters from existing degree/health catalogs — but NEW UI only.
Include professor card, progress, continue, upcoming, announcements, resources.
Acceptance: Biology or CS course opens fully with module list and completion plumbing.
```

---

## Module 5 — AI Professor stage

```text
Build Professor stage (PRD §13, §15):
voice TTS + captions, transcript, whiteboard slot, pause-for-question, knowledge check.
Wire OpenAI lecture stream + offline chapter fallback (reuse AiProfessorOfflineChapter / prompts).
Quota via VirtualUniversityPremium.
Acceptance: online stream works; offline chapter works; TTS gated for free users.
```

---

## Module 6 — AI Tutor FAB

```text
Global Ask AI Tutor (PRD §14) with course/lesson context + history.
Intents: explain / example / simplify / challenge / quiz / step-by-step.
Acceptance: context appears in prompt; free cap shows upgrade sheet.
```

---

## Module 7 — Practice & Assessments

```text
Practice bank + Quiz flow (PRD §17): shuffled options, explanations, pass threshold, timed exam mode.
Persist Attempt + Progress.
Acceptance: failing quiz does not mark complete; passing awards XP.
```

---

## Module 8 — Simulations hub

```text
Practice tab → Simulations (PRD §16).
Adapter into existing hospital/court/lab/IDE screens WITHOUT redesigning those engines yet —
wrap them in V2 chrome (intro, objectives, debrief, XP).
Acceptance: one sim per of Bio, Chem, Law, CS launches and returns score to V2 progress.
```

---

## Module 9 — Notes + Flashcards

```text
Notes (PRD §20): rich text, highlight, bookmark, search, export, AI summarize.
Flashcards (PRD §21): AI generate from lesson, SM-2 scheduling.
Reuse VuNotesService patterns but new V2 UI.
```

---

## Module 10 — Assignments

```text
Assignment detail: instructions, rubric, due date, submit, AI feedback, revision (PRD §18).
```

---

## Module 11 — Community

```text
Course forum + study group list + AI moderation stubs (PRD §23). Phase 1 text-only.
```

---

## Module 12 — Progress analytics

```text
Progress tab: mastery ring, skills radar, time spent, weak topics, recommendations (PRD §28).
```

---

## Module 13 — Premium + Offline

```text
Paywall, entitlement, offline pack download/manifest (PRD §26, §32).
Honest copy; restore purchases.
```

---

## Module 14 — Research Center

```text
Library building → research assistant, citations, PDF highlight → notes (PRD §19).
```

---

## Module 15 — Settings + A11y + Notifications

```text
Settings (PRD §29–30), notification preferences (PRD §27), high contrast + captions defaults.
```

---

## Module 16 — Faculty identity packs

```text
For each faculty: world art, accent, professor roster, default sims, onboarding blurb.
Start with CS, Biology, Medicine, Law, Business — then remaining list in PRD §11.
```

---

## Module 17 — Admin console (web)

```text
Separate admin routes: users, courses, moderation, flags (PRD §33). Not inside student tab bar.
```

---

## Module 18 — QA hardening

```text
Add tests from 05_ROADMAP_ACCEPTANCE.md checklist; fix crash/async gaps; performance pass.
```

---

## Anti-prompts (never do)

```text
- Do not “quickly restyle” PracticeLabsScreen or old degree list tiles into V2.
- Do not keep fake Continue items like “Open Chemistry” at 5%.
- Do not ship placeholder “Coming soon” as a primary path.
- Do not use purple-gradient generic AI aesthetics as the brand.
```
