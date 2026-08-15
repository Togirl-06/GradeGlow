# 05 — Roadmap, Acceptance Criteria & QA  
## GradeGlow Virtual University V2

---

## 1. Development roadmap

### Phase A — Foundation (Weeks 1–3)
- V2 scaffold + design tokens + shell  
- Onboarding  
- Campus home + map  
- Feature flag entry  

**Exit:** New user can enter V2 campus and finish onboarding.

### Phase B — One faculty excellence (Weeks 4–7)
Pick **Computer Science** or **Biology** and make it world-class end-to-end:
Course → Module → Professor → Practice → Quiz → Sim → Notes → Progress → Premium gate  

**Exit:** External testers say “this feels like a real university class.”

### Phase C — Expand faculties (Weeks 8–14)
Port remaining faculties via identity packs + adapters. Shared course shell stays identical.

### Phase D — Platform depth (Weeks 15–22)
Assignments, community, research center, offline packs, stronger analytics, admin console.

### Phase E — US #1 push (Weeks 23–30)
Performance, a11y audit, store positioning, content density, referral loops, career center polish.

---

## 2. Acceptance criteria (by feature)

### Onboarding
- [ ] Completes in ≤4 minutes on mid-tier phone  
- [ ] Produces persisted study plan  
- [ ] First course CTA opens real course  

### Campus
- [ ] Continue deep-links to exact lesson activity  
- [ ] No fake progress rows  
- [ ] Map buildings navigate correctly  

### Course / Lesson
- [ ] No text-only lessons in required path  
- [ ] Professor voice has captions  
- [ ] Knowledge check before mark-complete  
- [ ] Progress % reflects real completions  

### AI Tutor
- [ ] Receives lesson context  
- [ ] Free quota enforced with upgrade path  
- [ ] History survives app restart  

### Simulations
- [ ] Objectives → play → debrief → XP  
- [ ] Failure still teaches (feedback)  

### Assessments
- [ ] Shuffled options  
- [ ] Explanations after submit  
- [ ] Pass threshold enforced  

### Notes / Flashcards
- [ ] Highlight + bookmark persist  
- [ ] Search works  
- [ ] Spaced repetition schedules due cards  

### Premium / Offline
- [ ] Entitlement unlocks caps  
- [ ] Offline pack opens without network  
- [ ] Sync resumes safely  

### A11y / Quality
- [ ] TalkBack/VoiceOver critical paths  
- [ ] Reduce motion honored  
- [ ] Crash-free ≥99.5% on staging  

---

## 3. Testing checklist

### Automated
- Unit: progress, quotas, SM-2, grade letter  
- Widget: buttons, course home states, onboarding  
- Golden: design system components  
- Integration: complete lesson → quiz pass → XP  

### Manual smoke (each faculty release)
1. Onboard → open faculty → start lesson  
2. Play TTS → ask tutor → complete interactive  
3. Pass quiz → see progress update  
4. Launch sim → return with score  
5. Hit free AI cap → upgrade sheet  
6. Airplane mode + premium pack  

### Performance
- Scroll module list 100+ items without jank  
- Lesson open cached < 1.5s  

### Security
- Rules: cannot read another user’s notes  
- Tokens not logged  

---

## 4. Definition of “#1 educational app” for this project

We treat “#1” as measurable product quality, not a slogan:
1. Highest lesson completion among AI study apps we benchmark  
2. Best-in-class simulation depth per faculty  
3. Store rating ≥4.8 with volume  
4. Students describe it as a **campus**, not a chatbot wrapper  

---

## 5. Immediate next action

In Cursor, start **Module 0 — Scaffold** from `04_CURSOR_IMPLEMENTATION_PROMPTS.md` with the global instruction block.  
Do not continue patching the prototype Virtual University UI.
