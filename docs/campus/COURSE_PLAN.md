# GradeGlow Campus — plan for every school and major

GradeGlow is a virtual university you can walk around. Every student has an apartment, every major has its own building, and every building has stations where you
**learn → practise → apply → interview → get hired → work → get paid → get promoted**.

This file has three parts:

1. **What exists today**: what was built in the campus rebuild.
2. **School-by-school plan**: for every major, its building, learning stations, career path, interview topics and workplace tasks, plus what to build next.
3. **Build order and rules**: the order to build in, and rules Cursor (or any developer) must follow.

Status legend: ✅ playable now · 🟡 exists but needs upgrading · 🔲 to build.

---

## Part 1 — What exists today

### The campus map (`lib/life_sim/world/city_map.dart`)
15 districts on one walkable map, rendered in 3D on web (`web/life_world/`) and as the 2D isometric map in the mobile apps.

| Row | Districts and buildings |
|---|---|
| North campus | **Student Housing** (apartments) and Corner Café · **University Hall** (enrolment, lectures, exams, graduation stage) and **University Library** · **Science Quarter**: Biological Sciences Center, Chemical Sciences Lab, Physical Sciences Center · **Health Sciences**: School of Medicine, College of Nursing · **Hospital District**: St. Gabriel General Hospital, Riverside Clinic |
| Schools and services | **Campus Commons**: Student Union, **Career Center** · **Technology Quarter**: School of Computer Science, Innovation Center · **Engineering & Mathematics**: Engineering Innovation Complex, Mathematical Sciences Center · **Law & Humanities**: College of Law & Justice; Arts, Humanities & Communication · **Business & Economics**: Business & Economics Tower, Meridian Group, Harbor Retail |
| City (workplaces) | Courthouse and two law firms · Mall and grocery · Bank, Ledger & Co, Ironclad Audit · Tech Park (Pixelforge, Nimbus Cloud) · Cinema, gym, park |

### Apartment ✅
Student Housing is a real multi-room home (walls with doorways):

| Room | Station | What it does |
|---|---|---|
| Bedroom | Bed, Closet | Sleep (energy), change clothes and appearance |
| Bathroom | Shower | Hygiene |
| Study | Study desk, Laptop | Study and do assignments; email, schedule, job applications, finances |
| Living room | Sofa, Educational TV, Decorate, Bills & Rent | Relax, build knowledge, buy furniture/wallpaper/floors, pay rent |
| Kitchen | Kitchen, Dining table | Cook (hunger), invite friends (social) |

Needs (energy, hunger, hygiene, happiness, social, stress) only change while you play, so students are never punished for being offline.

### School buildings ✅
Each school is its own building. Inside are **named lab areas** (one per station), a **Lecture Room**, a **professor** and a **student** you can talk to (AI chat with an offline fallback).
Walking up to a station and using it opens the matching GradeGlow activity. Time actually spent there (at least 45 seconds) raises the related skill (`LifeGame.practiceLab`). Skills feed job requirements.

- Station data: `lib/life_sim/campus/lab_info.dart` (57 stations)
- Station → screen: `lib/life_sim/campus/campus_labs.dart`
- Professors, students and majors: `lib/life_sim/campus/campus_schools.dart`
- Room layouts: `lib/life_sim/world/interiors.dart` (`_school`)

### Career loop ✅ (for 7 careers) / 🟡 (for the rest)
1. **Career Center**: job board, resume desk (built from your real achievements, with AI feedback), mock interview room and kiosk.
2. **Apply**: listings have requirements (degree, skills, experience). Outcomes are rule-based, not random.
3. **Interview**: at the employer's HR office with an AI interviewer (one question at a time, scored on relevance, clarity, problem-solving, professionalism and role knowledge). Possible outcomes: offer, rejection with feedback, waitlist, second interview, or more information requested.
4. **Contract**: accept or decline the offer.
5. **Work**: clock in, the manager assigns tasks, walk to work stations, complete real tasks, get performance reviews.
6. **Pay**: salary on payday; pay rent, groceries, furniture and clothes; save; promotions and raises.

Fully wired with paid jobs in the city: **Software Engineer, Nurse, Pharmacist, Doctor (trainee), Lawyer (trainee), Accountant, Business Manager**.
Every other major has a **career simulation** station inside its school (interview → job → first assignments), but no salaried employer in the city yet (🟡, see Part 3).

### Real Case Study Center ✅
College of Law: 8 landmark published decisions, each clearly labelled as a **real case**. Students go through Facts → Arguments → Predict → Decision and reasoning → Questions.
- US cases: Marbury v. Madison, Brown v. Board, Gideon v. Wainwright, Miranda v. Arizona, Tinker v. Des Moines.
- UK cases: Donoghue v Stevenson, Carlill v Carbolic Smoke Ball, Hadley v Baxendale.

Fictional practice cases stay in the Moot Courtroom and are labelled fictional.

---

## Part 2 — School-by-school plan

Every school follows the same six stages: **student life → learning and practice → professional preparation → job hunting → interviews and hiring → working life.**
Getting a job is never one button. Each employer checks demonstrated skills, and technical roles add an assessment.

### 1. School of Computer Science 💻
**Majors:** Computer Science, Software Engineering, Artificial Intelligence, Data Science, Cybersecurity, Information Technology, Web Development, Mobile App Development.

| Station (in the building) | Opens | Status |
|---|---|---|
| Algorithm Arena | `VuV2CsCodingArenaScreen`: 26 problems (Easy/Medium/Hard) with examples | 🟡 code runs are simulated by AI; few hidden tests |
| Software Company Floor | Science career hub → software engineering (tickets, code review, deploys) | ✅ |
| AI Research Lab | Science career hub → AI/ML | ✅ |
| Data Analytics Center | Science career hub → data science | ✅ |
| Cyber Defense Center | Science career hub → cybersecurity (sandboxed scenarios) | ✅ |
| IT Support Desk | Science career hub → IT (tickets) | ✅ |
| Web & Mobile Studio | Science career hub → web development | ✅ |
| Tech Career Simulation | Career world: incident brief → logs → bug → fix → deploy | ✅ |

**Career path:** Intern → Junior Developer → Software Engineer → Senior → Tech Lead → Engineering Manager. Side tracks: Data Analyst, AI Engineer, Cybersecurity Analyst, IT Support Specialist.
**Employers:** Pixelforge Studios, Nimbus Cloud Systems (paid ✅). 🔲 Add a data/AI company and a security firm.
**Interview:** tell me about yourself; explain a project; debugging approach; explain a data structure; **live coding problem** (graded by tests).
**Work tasks:** fix a bug until tests pass, build a feature from a ticket, review a pull request, write unit tests, handle an incident.

**Build next**
1. 🔲 **Real code execution, the top priority for this school.** Run submitted code in isolated, resource-limited containers, for example Judge0 or Piston on Cloud Run behind a Cloud Function, called with the user's Firebase ID token. Never run student code inside privileged functions. Show Accepted / Wrong Answer / Time Limit Exceeded / Runtime Error with time and memory. The problem model already supports hidden tests (`LeetcodeHiddenTest`), but most problems still need them written.
2. 🔲 Grow the bank from 26 to 150+ problems across arrays and strings, linked lists, stacks and queues, trees and graphs, dynamic programming, recursion and backtracking, sorting and searching, greedy, OOP and system design. Add Python, Java, JavaScript and C++ starter code.
3. 🔲 Points, badges, a leaderboard and weekly timed contests (Firestore, written by the server only).
4. 🔲 The Software Engineering workplace uses the same runner: the task is "make these failing tests pass".

### 2. School of Medicine 🫀
**Majors:** Medicine, Medical Laboratory Science, Anatomy & Physiology.

| Station | Opens | Status |
|---|---|---|
| 3D Anatomy Table | `Anatomy3dViewerHubScreen`: skeleton and heart in 3D; orbit, tap bones and structures | 🟡 only skeleton + heart |
| Patient History Room | Medicine Lab 1: history taking (the patient answers what you ask) | ✅ |
| Diagnosis Board | Medicine Lab 2: tests, results, differential diagnosis | ✅ |
| Virtual Patient Clinic | `MedicineConsultationScreen`: full consultation | ✅ |
| Diagnostic Laboratory | Health hub → medical lab science (blood tests, imaging) | ✅ |
| Pharmacy & Counselling | Pharmacy Lab 2: counselling | ✅ |
| Hospital Rotation | Career world: medicine | ✅ |

**Career path (simulated, educational):** Medical Assistant → Clinical Research Assistant → Medical Lab Assistant → Junior Clinical Trainee → Medical Intern → resident scenarios. Real practice requires accredited education and licensing outside GradeGlow. Say so on every offer letter.
**Employers:** St. Gabriel General Hospital, Riverside Clinic (paid ✅).
**Interview:** handling an uncertain diagnosis; communicating bad news; prioritisation; patient safety.
**Work tasks:** consultation, ward round, lab results review, discharge plan.

**Build next**
1. 🔲 **Full-body anatomy, the top priority.** All 11 body systems as toggleable layers (skin, muscles, skeleton, organs, nervous, cardiovascular, respiratory, digestive, urinary, endocrine, lymphatic). Rotate, zoom and hide layers. Tapping a structure highlights it and shows a panel with name, location, function, structure, common diseases, related conditions and knowledge-check questions. Add an "identify the organ" quiz mode. Use licensed meshes (`assets/health_3d/` is reserved for them) or build procedurally like `web/health_3d`.
2. 🔲 Diagnostic image library: ECG strips, X-ray, CT, MRI and ultrasound with matching exercises. Only educational images with a clear licence.
3. 🔲 Procedures lab: history taking, physical assessment, injection principles, sterile technique, chart reading, medication orders. Educational steps only.
4. 🔲 Operating room tour: team roles, equipment, sterilisation, safety checklists, pre-op and post-op monitoring. It is a training tour, not a surgical qualification.
5. 🔲 AI patients remember what was asked during the encounter (keep the conversation in `HealthCareerProgress`). Vital signs and outcomes stay rule-based.

### 3. College of Nursing 💉
**Majors:** Nursing, Public Health.

| Station | Opens | Status |
|---|---|---|
| Patient Care Ward | Nursing Lab 1: ward shift, prioritisation | ✅ |
| Patient Assessment Lab | Nursing Lab 2: vital signs, pain, history, observations | ✅ |
| Clinical Case Simulator | `NursingClinicalCaseScreen`: deteriorating patient | ✅ |
| Anatomy & Skeleton Models | 3D anatomy | 🟡 (see Medicine) |
| Medication Safety Lab | Pharmacy Lab 1: verify orders (patient, drug, dose, route, time) | ✅ |
| Community & Public Health | Health hub → public health (outbreaks, prevention) | ✅ |
| Clinical Placement | Nursing clinical game (full shift) | ✅ |

**Career path (simulated):** Nursing Assistant → Patient Care Technician → Clinical Nurse Trainee → Registered Nurse (simulation) → ED / Pediatric / ICU Nurse → Nurse Manager. These are not professional credentials.
**Employers:** St. Gabriel, Riverside (paid ✅).
**Interview:** a deteriorating patient; prioritising care; communicating with patients and families; escalation.
**Work tasks:** bedside assessment, medication round, emergency bay, SBAR handover.

**Build next**
1. 🔲 Emergency nursing lab: unresponsive patient, breathing difficulty, fever, allergic reaction, falling vital signs. Recognise warning signs and escalate.
2. 🔲 Maternal and newborn unit: prenatal, labour education, newborn assessment, postpartum care, safe sleep.
3. 🔲 Pediatric ward: age-appropriate assessment and communication.
4. 🔲 Mental health ward: AI patients with different emotional states; practise de-escalation and referral. Requires careful review of safety-sensitive content.
5. 🔲 Admission scenario: an elderly patient after a fall (fall-risk assessment, documentation, care-team communication).

### 4. College of Law & Justice ⚖️
**Majors:** Law, Criminal, Civil, Constitutional and Corporate Law, Legal Research, Trial Advocacy.

| Station | Opens | Status |
|---|---|---|
| Real Case Study Center | `RealCaseCenterScreen`: 8 published decisions | ✅ |
| Law Library & Lessons | `LawProgramScreen`: lessons, objections, negotiation, exams | ✅ |
| Client Interview Room | Law Lab: a client explains the problem; gather facts | ✅ |
| Law Firm Desk | Law workplace: senior attorney assignments | ✅ |
| Moot Courtroom | Career world: brief → file → evidence → witness → inconsistency → argue → ruling | ✅ |

**Career path (simulated):** Legal Assistant → Paralegal → Legal Researcher → Junior Associate → Associate (simulation) → Senior Associate → Partner. A simulated position does not authorise anyone to practise law.
**Employers:** Whitmore & Lane LLP, Civic Legal Aid (paid ✅); the Courthouse has a public gallery.
**Interview:** analyse a legal problem; prepare for a client consultation; support an argument with authority.
**Work tasks:** research memos, document drafting, client meetings, court appearances.

**Build next**
1. 🔲 Grow the case library to 40+ cases by area (criminal, civil, constitutional, contract, tort, corporate). Source decisions from public court databases (for example CourtListener / Caselaw Access Project for the US, BAILII for the UK, and local databases for other countries). Write original summaries and keep the citation and jurisdiction on every case. Real and fictional cases must never be mixed.
2. 🔲 A full trial where the student chooses a role (prosecution or defence). The AI judge, opposing counsel and witnesses behave consistently. Objections are checked against an evidence rule set. The judge scores legal reasoning, organisation, use of evidence and procedure.
3. 🔲 Legal research lab: search a statute and precedent corpus, then write a memo that the AI marks against a rubric.
4. 🔲 Negotiation and mediation rooms: contract, property, employment, family and personal-injury disputes.

### 5. Engineering Innovation Complex ⚙️
**Majors:** Mechanical, Civil, Electrical, Chemical, Aerospace and Industrial Engineering.

| Station | Opens | Status |
|---|---|---|
| Mechanical Workshop | Engineering hub → mechanical | ✅ |
| Civil Construction Site | Engineering hub → civil | ✅ |
| Electrical Lab | Engineering hub → electrical | ✅ |
| Chemical Process Plant | Engineering hub → chemical | ✅ |
| Aerospace Hangar | Engineering hub → aerospace | ✅ |
| Industrial Factory Floor | Engineering hub → industrial | ✅ |
| Engineering Firm | Career world: engineering | ✅ |

**Career path:** Engineering Intern → Graduate Engineer → Engineer → Senior Engineer → Lead → Engineering Manager.
**Employers:** 🔲 none paid yet. Add a construction firm, an aerospace company, a manufacturing plant, an energy utility and a consultancy, each with a **technical assessment** before hire (`JobListing` + interview packs).
**Interview:** a design trade-off; a failure analysis; safety; calculations.
**Work tasks:** design a cooling system (choose components, calculate, test); inspect a structure; troubleshoot a circuit; balance a process; optimise a production line.

**Build next**
1. 🔲 Paid employers and work tasks in the life sim (copy the pattern of `workplace/content/*_tasks.dart`).
2. 🔲 Interactive calculators wired to pass/fail tests: bridge load tests, circuit solvers, gas-law and process simulations.

### 6. Business & Economics Tower 📈
**Majors:** Business Administration, Accounting, Finance, Economics, Entrepreneurship, Marketing, Human Resources, International Business.

| Station | Opens | Status |
|---|---|---|
| Corporate HQ | Business hub → business administration | ✅ |
| Accounting Firm | Business hub → accounting | ✅ |
| Markets Desk | Business hub → finance (virtual money only) | ✅ |
| Marketing Agency | Business hub → marketing | ✅ |
| HR Department | Business hub → HR | ✅ |
| Startup Incubator | Business hub → entrepreneurship (also in the Innovation Center) | ✅ |
| Economic Policy Center | `EconomicsPlayableScreen` | ✅ |
| Business Lecture Rooms | `BusinessSchoolScreen` | ✅ |

**Career path:** Intern → Analyst / Junior Accountant / Coordinator → Associate → Senior → Manager → Director / Controller / Partner. Founders can also register a company (Innovation Center).
**Employers:** Meridian Group, Harbor Retail (business manager ✅), Ledger & Co, Ironclad Audit (accountant ✅). 🔲 Add an investment firm, a marketing agency, an HR consultancy, a trade company and an economic research institute.
**Interview:** reconciling an account; finding a discrepancy (accounting); valuation (finance); a campaign brief (marketing); a policy recommendation (economics).
**Work tasks:** "sales dropped 30%" recovery plan; journal entries → trial balance → statements; portfolio rebalancing; campaign budget and results; screening resumes; an inflation policy brief.

**Build next**
1. 🔲 Paid employers for finance, marketing, HR, economics and international business.
2. 🔲 Simulated market with fictional companies and prices (never real-money trading).
3. 🔲 International business: exchange rates, trade rules and a cross-cultural negotiation scenario.

### 7. Mathematical Sciences Center 📐
**Majors:** Mathematics, Statistics, Applied Mathematics.

| Station | Opens | Status |
|---|---|---|
| Interactive Whiteboard | `MathematicsDegreeHomeScreen`: algebra, calculus, statistics, geometry | ✅ |
| Applied Math Lab | `MathematicsPlayableScreen` | ✅ |
| Quant Career Simulation | Career world: math | ✅ |

**Build next**
1. 🔲 **Step-checking whiteboard:** the student enters each line. Equivalence is checked by solving or substituting random values, and the first wrong step is flagged with a reason (for example "you distributed the negative sign incorrectly"). AI explains; a computer-algebra check decides.
2. 🔲 Separate labs for algebra, calculus, statistics, geometry and applied maths with interactive graphs and 3D solids.
3. 🔲 Employers: actuarial firm, quant desk, data team.

### 8. Arts, Humanities & Communication 🎭
**Majors:** English & Literature, Creative Writing, Journalism, Communication (Psychology also has a lab here).

| Station | Opens | Status |
|---|---|---|
| Writing Studio | `EnglishProgramScreen`: grammar, essays and literature with AI feedback | ✅ |
| Psychology Lab | `PsychologyPlayableScreen`: case studies, behaviour, ethics | ✅ |
| Newsroom | Career world: english (research, verify, publish) | ✅ |

**Build next**
1. 🔲 Essay submission with rubric feedback (grammar, clarity, organisation, argument) and revision history.
2. 🔲 Creative-writing workshop: character, plot and script exercises, with peer-style AI critique.
3. 🔲 Newsroom loop: interview AI sources, verify claims against a fact sheet, write and publish; ethics checks.
4. 🔲 Public speaking: speech-to-text practice with feedback on pace and filler words (the `speech_to_text` package is already a dependency).
5. 🔲 Employers: newspaper, PR agency, publisher.

### 9–11. Sciences 🧬 ⚗️ 🔭
| School | Stations (all ✅) | Build next |
|---|---|---|
| **Biological Sciences** | Biology Lab (cells, genetics, microscopy, ecology), Anatomy Models, Research Career | 🔲 3D cell explorer (click organelles), Punnett squares, microbiology identification, ecology food-web sim, evolution lab |
| **Chemical Sciences** | Chemistry Bench (simulated reactions, titrations), Chemistry Lessons, Chemist Career | 🔲 Drag-and-combine reactions that show equations, products, molecular structures, calculations and safety info. Simulated only, never real-world instructions for hazardous experiments |
| **Physical Sciences** | Physics Lab (change variables, see results), Practical Experiments, Physicist Career | 🔲 Mechanics, E&M, waves and optics, thermodynamics and modern-physics labs with live sliders |

Science employers 🔲: research lab, pharmaceutical company, environmental agency, energy company.

---

## Part 3 — Build order and rules

### Order (each step must be playable end to end before the next)
1. **Vertical slice (CS):** apartment → walk to School of CS → Algorithm Arena with **real code execution** → Career Center → apply for an internship → interview including a coding question → offer → Pixelforge → fix-a-bug task graded by tests → payday → save/restore.
2. **Health:** full-body 3D anatomy + quiz, then nursing emergency/maternal/pediatric labs.
3. **Law:** larger real case library + full trial with roles.
4. **Paid employers for every remaining major** (engineering, finance, marketing, HR, economics, maths, journalism, sciences). Use the `Employer` + `CareerDef` + `WorkTaskBank` pattern so the Career Center, interviews, contracts, salaries and promotions just work.
5. **Life:** apartment upgrades, more furniture, roommates, campus events, clubs at the Student Union, schedule/calendar reminders.
6. **Later:** multiplayer campus spaces (start single-player; add shared spaces later), real job listings from an external API (optional), native 3D in the mobile apps (reuse `web/life_world` through a WebView).

### Rules
- **Never decorative:** every clickable object must do something (`test/life_sim/world_test.dart` enforces reachability; `campus_test.dart` enforces that every station opens a screen).
- **Rules vs AI:** money, time, grades, hiring decisions, salaries, promotions, patient vital signs and medication rules are deterministic code. AI only writes dialogue, interview questions, feedback and explanations, within the existing ±2 score nudge.
- **Security:** AI calls go through Cloud Functions (`/api/openai`); no API keys in Flutter or the 3D page. Firestore rules plus the server guard (`functions/life_sim.js`) stop students editing their own grades, salary, interview results or credentials. Move the economy and hiring to callable functions next.
- **Code execution:** isolated, resource-limited containers only, with time and memory limits and no network.
- **Medical:** educational scenarios and fictional patients. Never present results as real diagnoses or as authorisation to practise.
- **Legal:** real published decisions are labelled with citation and jurisdiction, summarised in original words. Fictional cases are labelled fictional. Simulated legal jobs are not authorisation to practise law.
- **Performance:** keep 3D scenes small (one room at a time), merge static meshes (done in `web/life_world/util.js` `mergeStatic`), test on a mid-range phone.

### Where things live
| What | File |
|---|---|
| Campus map and buildings | `lib/life_sim/world/city_map.dart` |
| Rooms, stations and NPCs | `lib/life_sim/world/interiors.dart` |
| Station list and screen wiring | `lib/life_sim/campus/lab_info.dart`, `campus_labs.dart` |
| Schools (professor, student, majors) | `lib/life_sim/campus/campus_schools.dart` |
| Real cases | `lib/life_sim/campus/real_cases.dart`, `real_case_center_screen.dart` |
| Jobs, interviews, work, pay | `lib/life_sim/employment/`, `interview/`, `workplace/`, `economy/` |
| 3D world (web) | `web/life_world/` (preview: `/life_world/index.html?demo=1&scene=school_cs`) |
| Preview data generator | `tool/gen_life_world_demo.py` (re-run after changing the map or rooms) |
