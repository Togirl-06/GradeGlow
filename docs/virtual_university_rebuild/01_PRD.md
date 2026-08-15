# 01 — Product Requirements Document  
## GradeGlow Virtual University V2

> Rebuild from zero. Current UI is a temporary prototype. Every screen in V2 is new.

---

# 1. Executive Summary

### Vision
Make GradeGlow Virtual University the default way ambitious US students learn — an AI-powered campus where every subject is practiced in realistic environments until mastery is undeniable.

### Mission
Help every learner master any subject through personalized AI professors, immersive simulations, and active practice that builds career-ready confidence — not short-term test memory.

### Product Overview
A mobile-first (Flutter) + web-capable **Virtual University** inside GradeGlow:
- Digital campus with faculties, courses, labs, library, career center
- AI Professor–led lessons (voice, whiteboard, adaptive Q&A)
- Subject-specific simulations (hospital, courtroom, labs, IDE, markets)
- Notes, flashcards, assessments, community, gamification
- Free core path + Premium unlimited AI / advanced sims / offline / career coaching

### Goals (12 months)
1. Be the highest-rated AI learning app in US education store categories
2. Complete end-to-end degree-style paths for ≥12 faculties
3. ≥40% free→premium conversion among weekly active learners
4. Median lesson completion rate ≥70%
5. NPS ≥60 among premium students

### Success Metrics
| Metric | Target (Year 1) |
|--------|-----------------|
| WAU (weekly active users) | 250k+ |
| Lesson completion rate | ≥70% |
| 7-day retention | ≥45% |
| Premium conversion | ≥40% of WAU who finish onboarding |
| Avg. study minutes / WAU / week | ≥90 |
| Simulation sessions / learner / week | ≥2 |
| Crash-free sessions | ≥99.5% |
| App Store rating | ≥4.8 |

### Long-Term Vision (3–5 years)
VR/AR classrooms, live human professors + AI TAs, AI classmates, global competitions, content marketplace, enterprise/university partnerships, accredited pathways.

---

# 2. Product Philosophy

### What makes Virtual University different
| Traditional edtech | GradeGlow VU |
|--------------------|--------------|
| Watch → forget | Learn → practice → feedback → master → apply |
| Generic chatbot | Named AI Professor with memory + teaching style |
| Text chapters | Simulations + interactive classrooms |
| One-size courses | Adaptive paths from placement + weakness detection |
| Dashboard of cards | Immersive campus + faculty worlds |

### Learning-first design
UI exists to reduce friction between **curiosity → explanation → doing → feedback**. If a control doesn’t help learning, cut it.

### AI-first approach
AI is the teacher of record for lectures, tutoring, grading drafts, study plans, and moderation — always with safety rails and offline fallbacks.

### Student-centered experience
Students choose major, pace, and modality. Progress is visible. Struggle triggers help, not shame.

### Accessibility principles
WCAG 2.2 AA as baseline; captions for all AI voice; reduce-motion; scalable type; high-contrast theme; color-blind-safe status colors.

---

# 3. Brand Identity (summary)

Full tokens in `02_DESIGN_SYSTEM.md`.

- **Brand:** GradeGlow  
- **Product line:** Virtual University  
- **Tagline:** Learn by doing — not just memorizing  
- **Voice:** Confident, warm, precise, never condescending  
- **AI Professors:** Distinct personas per faculty (name, tone, metaphor style)  
- **Visual:** Dark academic night campus + warm GradeGlow orange accent (not generic purple SaaS)  
- **Illustration:** Realistic subject worlds (labs, courts, clinics) over abstract blobs  

---

# 4. Design System

See `02_DESIGN_SYSTEM.md` for complete component library, motion, grids, states.

**Hard rules for V2 UI**
- No prototype cards reused from current dashboard
- One composition per first viewport
- Faculty accent ≠ purple-by-default; use GradeGlow orange + faculty secondary
- Glass used sparingly for campus overlays only
- Empty/loading/error states required for every list and stream

---

# 5. Information Architecture

### Top-level navigation (Student)
```
Tab bar
├── Campus          (map / hubs)
├── Learn           (degree → course → lesson)
├── Practice        (sims, quizzes, flashcards)
├── Progress        (grades, XP, analytics)
└── Profile         (settings, premium, notes)
```

### Sitemap (core)
```
Welcome → Onboarding → Campus Home
Campus Home
  ├── Faculties / Degrees
  ├── Library / Research Center
  ├── Labs Hub
  ├── Career Center
  ├── Clubs & Events
  └── Graduation Hall
Degree Home → Course Home
  ├── Modules
  ├── Lesson
  │     ├── AI Professor
  │     ├── Interactive / Simulation
  │     ├── Practice
  │     ├── Quiz
  │     └── Reflection / Notes
  ├── Assignments
  ├── Discussion
  ├── Grades
  └── Resources
AI Tutor (global FAB, context-aware)
Notes / Flashcards / Community
Premium / Membership
Admin (separate app surface)
```

### User journeys (priority)
1. New student → onboarding → first course lesson → first quiz pass  
2. Continue learning deep-link → exact lesson activity  
3. Struggle → AI Tutor → practice set → mastery bump  
4. Free limit hit → premium value screen → upgrade  
5. Simulation session → lab report → grade  

### Deep linking
`gradeglow://vu/faculty/{id}/course/{id}/module/{id}/lesson/{id}/activity/{kind}`  
Also: notes, assignment submit, premium, campus building.

### Search
Global campus search: faculties, courses, lessons, notes, community posts. Results deep-link; never open only the faculty root.

---

# 6. User Roles & Permissions

| Capability | Guest | Student | Premium | Parent | Instructor | TA | Admin | Staff | Super Admin |
|------------|:-----:|:-------:|:-------:|:------:|:----------:|:--:|:-----:|:-----:|:-----------:|
| Browse marketing campus | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Take free intro courses | | ✓ | ✓ | | | | ✓ | | ✓ |
| Unlimited AI / TTS | | | ✓ | | ✓ | ✓ | ✓ | | ✓ |
| Advanced simulations | | limited | ✓ | | ✓ | ✓ | ✓ | | ✓ |
| Offline packs | | | ✓ | | | | ✓ | | ✓ |
| View child progress | | | | ✓ | | | ✓ | | ✓ |
| Create/edit course content | | | | | ✓ | draft | ✓ | ✓ | ✓ |
| Grade / rubrics | | | | | ✓ | ✓ | ✓ | | ✓ |
| Moderate community | | | | | ✓ | ✓ | ✓ | ✓ | ✓ |
| User management | | | | | | | ✓ | | ✓ |
| Billing / feature flags | | | | | | | | | ✓ |
| Audit logs | | | | | | | ✓ | ✓ | ✓ |

---

# 8. Student Onboarding

### Screens
1. **Welcome** — brand hero, “Enter Virtual University”  
2. **Meet your AI** — short professor intro + voice sample  
3. **Goals** — exam, career, curiosity, catch-up (multi-select)  
4. **Choose major / interest cluster**  
5. **Skill self-rating** (1–5 per foundation skill)  
6. **Placement micro-test** (8–12 adaptive items)  
7. **Personal study plan** — weekly minutes, streak goal, first course CTA  

### Acceptance
- Completes in ≤4 minutes  
- Produces `StudyPlan` persisted + first course recommended  
- Skippable placement with weaker personalization warning  

---

# 9. Dashboard (Campus Home “Today”)

Not a prototype card dump. One calm composition:

- Greeting + streak  
- **Continue** (real deep-link, real %)  
- Today’s plan (≤3 items)  
- AI recommendation (computed from weakness + schedule)  
- Upcoming assessments  
- Campus shortcuts (Library, Labs, Career)  
- Notifications inbox entry  

XP / achievements appear as secondary, not hero spam.

---

# 10. Virtual Campus

Interactive campus map (2.5D illustrated) with buildings:

| Building | Opens |
|----------|-------|
| Lecture Halls | Degrees / courses |
| Laboratories | Simulation hub |
| Library | Research Center + notes |
| Student Center | Community / clubs |
| Career Center | Interview prep, paths |
| Cafeteria | Light social / daily challenges |
| Events Plaza | Live events calendar |
| Graduation Hall | Certificates & ceremonies |

Each building has enter animation + ambient audio toggle (off by default).

---

# 11. Degree Programs

Every faculty has:
- Identity pack (emoji/world art, accent, professor roster, simulators)
- Year/level structure OR professional certificate tracks
- Shared course contract (see §12)

**Launch faculties (V2):** Biology, Chemistry, Physics, Mathematics, Computer Science, Engineering, Business, Medicine, Nursing, Psychology, Law, English, Economics, Political Science, Environmental Science, Finance, Marketing, Education, History, Architecture, Art & Design.

---

# 12. Course Experience

### Course Home
Banner art · title · description · AI Professor card · progress · continue · weekly goals · XP · grade · upcoming · announcements · resources

### Modules
Ordered modules with lesson / interactive / sim / quiz / assignment / discussion items + completion state

### Lesson
Never text-only. Required blocks: goals → AI Professor → interactive check → practice → reflection

### Grades / Progress
Module mastery, course grade estimate, attendance/streak, skills radar

---

# 13. AI Professor

### Personality
Named, faculty-specific, consistent metaphors, remembers last 20 mistakes in-course.

### Behaviors
- Speaks naturally (TTS) with captions  
- Step-by-step teaching  
- Whiteboard / diagram mode  
- Pause for questions  
- Embedded knowledge checks  
- Adaptive simplify / challenge  
- Recommends review items  

### Offline
Full textbook-quality chapter always available; live stream enhances when online.

### Safety
No fabricated drug doses / legal advice as fact; principle-level + cite uncertainty.

---

# 14. AI Tutor (global)

Always-available FAB. Context: faculty, course, lesson, last quiz item, notes selection.

Intents: explain again · example · simplify · challenge · quiz me · step-by-step · another method · real-world use.

History per course. Premium: unlimited; Free: daily cap with clear upgrade.

---

# 15. Lesson Experience Spec

| Block | Required |
|-------|----------|
| AI lecture (voice + transcript) | ✓ |
| Rich explanation | ✓ |
| Visual (image/diagram/chart) | ✓ when applicable |
| Interactive graphic or sim hook | ✓ |
| Example + real-world application | ✓ |
| Instant knowledge check (1–3 Q) | ✓ |
| Reflection prompt | ✓ |

---

# 16. Simulations

| Faculty | Simulation |
|---------|------------|
| Biology | Virtual lab / microscope / dissection |
| Chemistry | Experiment bench |
| Physics | Force/circuit/wave sims |
| Engineering | Design + test workshop |
| Medicine / Nursing | Virtual hospital / patients |
| Law | Courtroom / objections |
| Business / Marketing | Company / campaign sims |
| Economics / Finance | Market / portfolio sims |
| CS | Live coding IDE + debug |
| Architecture / Art | Studio critique boards |

Free: limited monthly sim sessions. Premium: unlimited advanced scenarios.

---

# 17. Assessments

Practice · Quiz · Midterm · Final · Oral (voice) · Project · Essay · Case study · Peer review  

All graded activities return explanation, not only score. Pass thresholds explicit.

---

# 18. Assignments

Instructions · rubric · due date · AI hints (rate-limited) · submission · AI draft feedback · “teacher-style” grade · revision loop  

Store versions. Plagiarism-lite check (similarity to known bank).

---

# 19. Research Center

Paper search · AI research assistant · citation generator · PDF reader · highlight · export to notes  

Premium: advanced research assistant + citation styles pack.

---

# 20. Notes System

Rich text · draw · highlight · bookmark · AI summarize · auto-organize by course · search · export · cloud sync  

---

# 21. Flashcards

AI-generated from lesson · manual · spaced repetition (SM-2 variant) · favorites · share decks  

---

# 23. Community

Forums per course · study groups · clubs · peer tutoring requests · AI moderation  

Voice/video rooms: Phase 2 (WebRTC). Phase 1: async + scheduled text rooms.

---

# 24. Gamification

XP · levels · coins · achievements · badges · optional leaderboards (opt-in) · challenges · daily rewards  

Never block learning behind energy systems. Cosmetics/coins optional.

---

# 26. Premium Features

- Unlimited AI Professor Q&A + TTS  
- Advanced simulations  
- Longer lecture generations  
- Exclusive projects  
- Downloadable / offline packs  
- AI study plans  
- Mock exams  
- Interview prep + career guidance  
- Personalized mentorship weekly summary  

Paywall copy must be honest and faculty-aware.

---

# 27. Notifications

Push + in-app: assignment due · exam · streak at risk · community reply · achievement · study plan nudge  

Quiet hours + per-type toggles.

---

# 28. Analytics (student-facing)

Time spent · completion · grade trends · skill mastery · weak topics · AI recommendations  

Privacy: student owns data; parent view is aggregated.

---

# 29. Settings

Profile · theme · language · accessibility · privacy · notifications · security · downloads/offline  

---

# 30. Accessibility

Screen reader labels · captions · keyboard (web) · dynamic type · high contrast · color-blind palette · reduce motion  

---

# 31. Security

Auth (email/OAuth) · encrypted transit · secure storage for tokens · privacy policy · recovery · audit logs for admin  

---

# 32. Performance

Cold start targets · image CDN · caching · background sync · **Offline mode for Premium** (pack download per course)  

---

# 33. Admin Dashboard

Users · courses · faculties · analytics · reports · moderation · feature flags  

Separate web console; not stuffed into student app.

---

# 34. Backend Architecture

See `03_TECHNICAL_SPEC.md` — Auth, AI gateway, Firestore/Postgres hybrid recommendation, storage, notifications, analytics pipeline.

---

# 35. Quality Assurance

Unit · widget · golden (design system) · integration · performance · a11y · security · faculty smoke paths  

---

# 36. Deployment

Dev · Staging · Production · monitoring (Crashlytics/Sentry) · backups · DR runbook  

---

# 37. Future Roadmap

VR classrooms · AR labs · live professors · AI classmates · global competitions · marketplace · enterprise  

---

## Wireframe index (text)

### Campus Home
```
┌─────────────────────────────┐
│ Good evening, Alex    🔥 4  │
│ Continue: Stacks · 62%  ▶   │
│ Today: Lesson · Quiz · Lab  │
│ [Library] [Labs] [Career]   │
│ Campus Map (full-bleed)     │
└─────────────────────────────┘
```

### Course Home
```
┌─────────────────────────────┐
│ Banner + Professor avatar   │
│ Title · 72% · Grade A-      │
│ [Continue Learning]         │
│ Upcoming · Announcements    │
│ Modules preview             │
└─────────────────────────────┘
```

### Lesson
```
┌─────────────────────────────┐
│ AI Professor stage + caps   │
│ Tabs: Learn | Do | Check    │
│ Content / Interactive       │
│ FAB: Ask AI Tutor           │
└─────────────────────────────┘
```

---

*Continue in companion docs for design tokens, technical schemas, Cursor prompts, and acceptance/roadmap.*
