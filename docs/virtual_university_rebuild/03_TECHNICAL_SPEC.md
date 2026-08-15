# 03 — Technical Specification  
## GradeGlow Virtual University V2

---

## 1. Architecture principles

- **New Flutter feature module:** `lib/vu_v2/` (UI + state). Do not edit prototype screens to “become” V2.  
- **Reuse:** OpenAI service, auth, subscription, content catalogs, sim engines — behind adapters.  
- **Offline-first for Premium packs;** online-enhanced AI streams.  
- **Context-aware AI:** every tutor/professor call includes `facultyId`, `courseId`, `lessonId`, `activityKind`, `recentMistakes[]`.

```
┌─────────────┐     ┌──────────────┐     ┌────────────────┐
│ Flutter V2  │────▶│ API Gateway  │────▶│ Auth / Users   │
│ lib/vu_v2   │     │ (Cloud Fn)   │     │ Courses/CMS    │
└─────────────┘     └──────┬───────┘     │ Progress/XP    │
                           │             │ Community      │
                           ├────────────▶│ AI Gateway     │
                           ├────────────▶│ Storage/CDN    │
                           └────────────▶│ Analytics      │
```

---

## 2. Suggested folder structure (Flutter)

```
lib/vu_v2/
  app/                 # V2 shell, router, tabs
  design/              # tokens, components
  campus/              # map, buildings
  onboarding/
  learn/               # degree, course, module, lesson
  professor/           # stage, voice, whiteboard
  tutor/               # FAB, chat, memory
  simulations/
  assessments/
  notes/
  flashcards/
  community/
  progress/
  premium/
  research/
  settings/
  admin/               # optional embedded stubs
  data/                # repositories, DTOs
  domain/              # entities, use cases
```

---

## 3. Core domain entities

```
User { id, role, displayName, majorId?, plan: free|premium }
StudyPlan { userId, weeklyMinutes, streakGoal, recommendedCourseIds[] }
Faculty { id, title, accent, worldArt, professorIds[] }
Professor { id, name, facultyId, voiceId, teachingStyle, systemPrompt }
Course { id, facultyId, title, description, bannerUrl, moduleIds[] }
Module { id, courseId, title, order, itemIds[] }
LessonItem { id, moduleId, kind, title, estimatedMinutes, xp }
ActivityKind: lecture|interactive|simulation|practice|quiz|assignment|discussion|project
Progress { userId, itemId, status, score?, completedAt? }
Attempt { id, userId, assessmentId, answers, score, feedback }
Note { id, userId, lessonId?, body, highlights[] }
Flashcard { id, deckId, front, back, ease, dueAt }
SimulationSession { id, labId, userId, stateJson, score? }
Assignment { id, courseId, rubric, dueAt }
Submission { id, assignmentId, userId, files[], aiFeedback?, grade? }
CommunityPost { id, courseId, authorId, body, replyCount }
 entitlement { userId, premiumUntil?, offlinePackIds[] }
```

---

## 4. Database schema (logical)

**Primary store:** Cloud Firestore (mobile realtime) + optional Postgres for admin analytics.

### Collections
- `users/{uid}`  
- `users/{uid}/progress/{itemId}`  
- `users/{uid}/notes/{noteId}`  
- `users/{uid}/flashcards/{cardId}`  
- `users/{uid}/studyPlan`  
- `catalog/faculties/{facultyId}`  
- `catalog/courses/{courseId}`  
- `catalog/modules/{moduleId}`  
- `catalog/items/{itemId}`  
- `community/{courseId}/posts/{postId}`  
- `assignments/{assignmentId}/submissions/{uid}`  
- `simSessions/{sessionId}`  
- `aiMemory/{uid}/{courseId}` — rolling mistake/summary memory  
- `entitlements/{uid}`  

Indexes: progress by user+status; posts by course+createdAt; flashcards by dueAt.

---

## 5. API specifications (high level)

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/v2/onboarding/complete` | Save goals, major, plan |
| GET | `/v2/campus/home` | Today feed |
| GET | `/v2/courses/{id}` | Course aggregate |
| POST | `/v2/progress/complete` | Mark item + XP |
| POST | `/v2/ai/professor/lecture` | Stream lecture |
| POST | `/v2/ai/professor/answer` | Q&A |
| POST | `/v2/ai/tutor` | Context tutor |
| POST | `/v2/ai/grade` | Assignment/essay draft grade |
| GET | `/v2/sims/{labId}/scenario` | Scenario payload |
| POST | `/v2/sims/{labId}/session` | Save session |
| POST | `/v2/assessments/{id}/submit` | Quiz submit |
| GET | `/v2/notes` | List/search |
| POST | `/v2/notes` | Create/update |
| GET | `/v2/premium/status` | Entitlement |
| POST | `/v2/offline/packs/{courseId}` | Manifest for download |

All AI routes require auth + quota check (free caps).

---

## 6. AI behavior definitions

### Professor system contract
- Role: university professor in `{faculty}` for `{course}` / `{topic}`  
- Output: full teaching chapter or spoken lecture segments  
- Must include: definition, intuition, worked example, pitfalls, check question  
- Must not: invent precise medical dosages; claim legal outcomes as advice  

### Tutor system contract
- Shorter replies (≤180 words default)  
- Always reference current lesson context  
- Offer next action: example / simplify / quiz  

### Memory
Store compact summaries: `{misconception, correction, count}` per course. Inject top 5 into prompts.

### Quotas
- Free: 10 AI Q/day, 15 TTS min/day, N sims/month  
- Premium: unlimited within abuse limits  

---

## 7. Offline (Premium)

1. User downloads course pack (lessons text, diagrams, quiz bank, offline professor chapters)  
2. Progress queues locally; syncs on reconnect  
3. AI live stream disabled offline → offline chapter + local tutor heuristics  

---

## 8. Security & privacy

- Firebase Auth / OAuth  
- TLS everywhere  
- Field-level security rules: users read/write only own progress/notes  
- Instructors scoped to assigned courses  
- PII minimized in analytics  
- Parent accounts see aggregates, not private chat logs by default  

---

## 9. Analytics events (minimum)

`onboarding_completed`, `course_opened`, `lesson_started`, `lecture_played`, `tutor_asked`, `quiz_submitted`, `sim_completed`, `assignment_submitted`, `premium_paywall_view`, `premium_purchase`, `streak_increment`

---

## 10. Error handling

| Case | UX |
|------|----|
| No network | Offline banner; cached content |
| AI quota | Paywall sheet with remaining counts |
| AI failure | Offline chapter + retry |
| Submit fail | Keep draft; retry |
| Corrupt pack | Re-download CTA |

---

## 11. Performance budgets

- Campus home interactive < 2.5s on mid Android  
- Lesson open < 1.5s cached  
- AI first token < 2s P50 when online  
- 60fps scroll on module lists  
