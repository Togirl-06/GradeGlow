"use strict";
// The career server refuses anything it cannot verify: pay without a job it
// approved, hires without its own interview, edited salaries, repeated
// reports and bursts of submissions.

const test = require("node:test");
const assert = require("node:assert/strict");
const R = require("../career/rules");
const { applyAction, emptyState, Rejected, view } = require("../career/server");

const JOB_ID = Object.keys(R.CATALOG.postings).find((id) => R.CATALOG.postings[id].keywords.length && R.CATALOG.plans[R.CATALOG.postings[id].interviewPlanId]);
const JOB = R.CATALOG.postings[JOB_ID];
const T0 = Date.UTC(2026, 10, 6, 12);

const sentences = (rubric) => rubric.map((c) => `In my last placement I made sure that ${c.anyOf[0].replace("*", "")} was handled carefully and I checked the result with my supervisor.`).join(" ")
  + " As a result the work improved and I learned how to plan the next steps with the team.";

function strongScreen(appId) {
  return {
    applicationId: appId, postingId: JOB_ID, submittedDay: JOB.openDay + 1, stage: "graduate", labsPassed: 3, modules: 2,
    resume: { name: "Sam Taylor", email: "sam@example.com", phone: "555 0100", headline: "Graduate",
      summary: "Motivated graduate with practical project experience, strong communication and a record of delivering accurate work on time.",
      education: [`BSc ${JOB.educationFields[0] || "Studies"} — 2019 – 2023`], experience: ["Assistant 2018 – present — Built a tracker used by 40 staff; Reduced errors by 20%"],
      skills: [...JOB.keywords, ...JOB.preferredKeywords], projects: [], certifications: [], achievements: [] },
    resumeText: "",
    coverLetter: `Dear ${JOB.company}, I am applying for the ${JOB.title} role. ${sentences(R.CATALOG.coverLetterRubric)} Thank you, I look forward to discussing the opportunity.`,
    answers: Object.fromEntries(JOB.questions.map((q) => [q.id, sentences(q.rubric)])),
  };
}

function transcript(appId, good = true) {
  const turns = [];
  for (let i = 0; i < 60; i++) {
    const r = R.scoreInterview(JOB, appId, { turns, peek: true });
    if (!r.next) break;
    const q = r.next;
    if (q.practical) turns.push({ q: q.id, practicalScore: good ? 100 : 30, practicalPassed: good });
    else if (q.options > 0) turns.push({ q: q.id, choice: good ? q.correctOption : (q.correctOption + 1) % q.options });
    else turns.push({ q: q.id, answer: good ? sentences([...q.rubric, ...(q.behavioural ? R.CATALOG.star : [])]) : "I am not sure about that one." });
  }
  return { applicationId: appId, turns, candidateQuestions: ["Who would I work with on the team?", "What training do new starters get?", "How is success measured?"] };
}

function run(state, action, payload, opId, now = T0) { return applyAction(state, action, payload, opId, now).state; }
const rejects = (fn, re) => assert.throws(fn, (e) => e instanceof Rejected && (!re || re.test(e.message)));

function hired() {
  let s = emptyState();
  s = run(s, "screen", strongScreen("a1"), "o1");
  assert.equal(s.applications.a1.status, "shortlisted", JSON.stringify(s.applications.a1.screening));
  s = run(s, "interview", transcript("a1"), "o2");
  s = run(s, "decide", { applicationId: "a1" }, "o3");
  assert.equal(s.applications.a1.status, "offer", JSON.stringify(s.applications.a1.decision));
  s = run(s, "accept", { applicationId: "a1", employmentId: "job1", salary: 9999999, title: "Lead" }, "o4");
  return s;
}

test("an honest journey is hired at the server's salary, not the one sent", () => {
  const s = hired();
  const e = s.employments.job1;
  assert.equal(e.salary, s.applications.a1.offerSalary);
  assert.ok(e.salary >= JOB.salaryMin && e.salary <= JOB.salaryMax);
  assert.equal(s.balanceCents, 0);
});

test("pay needs a job the server approved", () => {
  rejects(() => run(emptyState(), "work", { employmentId: "fake", assignmentRecordId: "x#0" }, "w"), /no record of this job/);
  rejects(() => run(emptyState(), "accept", { applicationId: "nope", employmentId: "j" }, "a"), /no record of this application/);
});

test("no interview or offer without the server's own screening and scoring", () => {
  rejects(() => run(emptyState(), "interview", transcript("zz"), "i"), /no record/);
  let s = run(emptyState(), "screen", { ...strongScreen("weak"), coverLetter: "", answers: {}, labsPassed: 0, modules: 0, resume: { name: "x" } }, "s");
  assert.equal(s.applications.weak.status, "rejected");
  rejects(() => run(s, "interview", transcript("weak"), "i"), /not shortlisted/);
  // A weak interview cannot be turned into an offer by the app.
  s = run(emptyState(), "screen", strongScreen("a2"), "s2");
  s = run(s, "interview", transcript("a2", false), "i2");
  s = run(s, "decide", { applicationId: "a2" }, "d2");
  assert.notEqual(s.applications.a2.status, "offer");
  rejects(() => run(s, "accept", { applicationId: "a2", employmentId: "j2" }, "x2"), /no offer/);
});

test("an interview transcript that skips or reorders questions is refused", () => {
  let s = run(emptyState(), "screen", strongScreen("a3"), "s3");
  const t = transcript("a3");
  rejects(() => run(s, "interview", { ...t, turns: t.turns.slice(1) }, "i3"), /Expected an answer/);
  rejects(() => run(s, "interview", { ...t, turns: t.turns.slice(0, -1) }, "i3b"), /unanswered/);
  s = run(s, "interview", t, "i3c");
  assert.ok(s.applications.a3.interview.overall >= 70);
});

test("paychecks are computed by the server, once per period", () => {
  let s = hired();
  const e = s.employments.job1;
  const weeks = R.weeksPerPeriod(e.payFrequency);
  for (let i = 0; i < 4; i++) s = run(s, "work", { employmentId: "job1", assignmentRecordId: `job1#${i}` }, `w${i}`, T0 + i * 60000);
  // The same assignment again, and the same report again, pay nothing.
  s = run(s, "work", { employmentId: "job1", assignmentRecordId: "job1#3" }, "w-dup", T0 + 5 * 60000);
  s = run(s, "work", { employmentId: "job1", assignmentRecordId: "job1#9" }, "w0", T0 + 6 * 60000);
  const periods = Math.floor(4 / weeks);
  const net = R.paycheck(e, 1).netCents;
  assert.equal(s.employments.job1.periodsPaid, periods);
  assert.equal(s.balanceCents, periods * net);
  assert.equal(view(s).balanceCents, s.balanceCents);
});

test("bursts of work reports are limited", () => {
  let s = hired();
  for (let i = 0; i < 12; i++) s = run(s, "work", { employmentId: "job1", assignmentRecordId: `r${i}` }, `b${i}`, T0 + i * 1000);
  rejects(() => run(s, "work", { employmentId: "job1", assignmentRecordId: "r12" }, "b12", T0 + 13000), /Too many/);
  s = run(s, "work", { employmentId: "job1", assignmentRecordId: "r12" }, "b12", T0 + 3600 * 1000 + 1);
  assert.equal(s.employments.job1.weeks, 13);
});

test("raises only at review time, capped by the published rule", () => {
  let s = hired();
  rejects(() => run(s, "review", { employmentId: "job1", outcome: "Excellent performance" }, "r0"), /No performance review/);
  for (let i = 0; i < 4; i++) s = run(s, "work", { employmentId: "job1", assignmentRecordId: `k${i}` }, `k${i}`, T0 + i * 60000);
  const before = s.employments.job1.salary;
  s = run(s, "review", { employmentId: "job1", outcome: "Excellent performance", raisePercent: 80 }, "r1");
  assert.equal(s.employments.job1.salary, R.raised(before, JOB.salaryPeriod, 1.05));
  rejects(() => run(s, "review", { employmentId: "job1", outcome: "Excellent performance" }, "r2"), /No performance review/);
});

test("training stipends: known labs only, once each, never while employed", () => {
  const [labId, scenarios] = Object.entries(R.CATALOG.labs).find(([, v]) => Object.keys(v).length);
  const [scenarioId, level] = Object.entries(scenarios)[0];
  rejects(() => run(emptyState(), "lab", { labId: "made_up", scenarioId: "x", score: 100 }, "l0"), /Unknown lab/);
  let s = run(emptyState(), "lab", { labId, scenarioId, score: 250 }, "l1");
  assert.equal(s.balanceCents, R.stipend(level, 100), "score is capped at 100");
  s = run(s, "lab", { labId, scenarioId, score: 100 }, "l2");
  assert.equal(s.balanceCents, R.stipend(level, 100), "paid once per scenario");
  const h = hired();
  rejects(() => run(h, "lab", { labId, scenarioId, score: 100 }, "l3"), /not employed/);
});

test("unknown actions are refused", () => {
  rejects(() => run(emptyState(), "setBalance", { balanceCents: 1e9 }, "x"), /Unknown action/);
});
