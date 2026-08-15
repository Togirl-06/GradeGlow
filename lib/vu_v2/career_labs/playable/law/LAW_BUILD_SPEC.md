# Law Lab — Cursor Build Spec (Playable Simulation)

## Principle

Law Lab is **not** a mission list, quiz, or chatbot.
It is a **law firm simulation**. The student is a junior associate who walks into work, receives a client, works a case, and is evaluated on professional performance.

Loop: **Environment → Role → Situation → Interaction → Decision → Consequence → Resolution → Evaluation → Progression**

---

## Screen 0 — Firm Arrival (Workplace Hub)

**When Law opens, do NOT show Lab 1 / Lab 2 / Start Simulation.**

Show:

```
HARTWELL & ASSOCIATES
Monday — 8:47 AM
You are a Junior Law Associate.
```

**Locations (tappable rooms):**
Reception · Associates Bullpen · Conference Room · Law Library · Evidence Room · Partner Office · Courtroom (locked until later)

**First visit:** Senior Associate Maya Chen walks up (modal / overlay).

> “Good morning. We have a new client. I want you to handle the initial interview. Conference room. Don’t make me regret this.”

**CTA:** `Meet the client` → Lab 1

Progress bar / XP can exist in chrome, but must not dominate the first viewport.

---

## Screen 1 — Client Interview (Lab 1)

**Location:** Conference Room  
**Role:** Junior Associate interviewing client Jordan Hale  
**Situation:** Client walked in; they will NOT dump the full case.

### Interaction model
- Free-text questions (chat-style composer)
- AI client replies from a **fact bank** (keyword + topic unlock)
- Conversation memory shown as transcript
- Useful questions unlock critical facts; missed facts make later labs harder

### Fact bank (example case — Hale v. Northline Delivery)
| Fact ID | Topic | Revealed by keywords | Critical? |
|---------|-------|----------------------|-----------|
| what | collision at loading dock | what happened, accident, crash | yes |
| when | March 14, ~4:20 PM | when, date, time | yes |
| where | Northline warehouse dock 3 | where, location, dock | yes |
| injury | lower back + ER visit | injury, hurt, hospital, pain | yes |
| witnesses | one coworker saw it | witness, see, anyone | yes |
| contract | independent contractor agreement signed Jan | contract, agreement, employee | yes |
| prior | company emailed about wet floor week before | email, warn, wet, before | yes |
| offer | company offered $2k release | offer, settle, money | no |

Client stonewalls or is vague if student asks irrelevant questions.

### End interview
Student must produce a **Case Intake Sheet**:
1. Facts
2. Timeline
3. People involved
4. Possible legal issues
5. Missing information

Then Maya reviews: scores based on critical facts unlocked + completeness of intake.

**Unlock:** Case File (Lab 2)

---

## Screen 2 — Case File (Lab 2)

**Location:** Evidence Room / War Room  
**Digital folder** with openable documents:
- Police report
- Contract
- Emails
- Witness statement
- Photographs (described stills)
- Medical record
- Blank timeline

### Tools
- Open document → read body
- Tag: Important / Irrelevant / Needs verification
- Place evidence onto timeline slots
- Maya may ask: “Why is this email important?” (free text)

**Unlock:** Legal Research (Lab 3) when ≥3 important tags + timeline has ≥3 events

---

## Screen 3 — Legal Research (Lab 3) — later build
Virtual research desk: search simulated authorities, pick relevant vs irrelevant, write short analysis, Maya challenges authority use.

## Screen 4 — Deposition (Lab 4) — later build
Witness across table; free-text Qs; prior-statement challenge; objections.

## Screen 5 — Courtroom (Lab 5) — later build
Opening → exam → evidence → objections → cross → closing.

## Boss — THE CASE — later build
Full pipeline on a new case file.

---

## Evaluation axes (shared)
legal reasoning · issue spotting · evidence analysis · questioning · argument · professionalism · communication

## Do NOT
- Present labs as a quiz list
- Use identical UI to Nursing with different colors
- Let “Start Simulation” be the product
- Dump the full case on the student without interviewing
