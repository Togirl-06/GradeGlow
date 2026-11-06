"use strict";
// The server's record of a student's career simulation: applications it has
// screened and interviewed itself, employments it has approved, and the only
// wallet that counts. `applyAction` is a pure function so it can be tested
// without Firebase; index.js runs it inside a Firestore transaction.

const R = require("./rules");

const LIMITS = {
  work: { perHour: 12 },
  lab: { perHour: 12 },
  interview: { perHour: 10 },
};
const HOUR = 3600 * 1000;
const MAX_LEDGER = 200;
const MAX_OPS = 300;
let thisYear = new Date().getUTCFullYear();

function emptyState() {
  return { balanceCents: 0, ledger: [], applications: {}, employments: {}, stipends: {}, ops: {}, opOrder: [], recent: {} };
}

class Rejected extends Error {}
const reject = (m) => { throw new Rejected(m); };

function rate(state, kind, now) {
  const lim = LIMITS[kind];
  if (!lim) return;
  const list = (state.recent[kind] || []).filter((t) => now - t < HOUR);
  if (list.length >= lim.perHour) reject(`Too many ${kind} submissions this hour. Try again later.`);
  list.push(now);
  state.recent[kind] = list;
}

function credit(state, cents, text, kind, id, now) {
  if (cents <= 0) return;
  state.balanceCents += cents;
  state.ledger.push({ id, cents, text, kind, atMs: now });
  if (state.ledger.length > MAX_LEDGER) state.ledger.splice(0, state.ledger.length - MAX_LEDGER);
}

const posting = (id) => R.CATALOG.postings[id] || reject("Unknown job posting.");
const app = (state, id) => state.applications[id] || reject("The server has no record of this application.");
const emp = (state, id) => state.employments[id] || reject("The server has no record of this job.");
const activeJob = (state) => Object.values(state.employments).find((e) => !e.ended) || null;
const str = (v, max = 20000) => (typeof v === "string" ? v.slice(0, max) : "");

function payroll(state, e, now) {
  const weeks = R.weeksPerPeriod(e.payFrequency);
  while (e.unpaidWeeks >= weeks) {
    e.periodsPaid += 1;
    const c = R.paycheck(e, e.periodsPaid);
    e.unpaidWeeks -= weeks;
    credit(state, c.netCents, `Paycheck ${c.period}: ${e.title}`, "salary", c.id, now);
  }
}

function hire(state, a, employmentId, title, now) {
  if (activeJob(state)) reject("Resign from your current role first.");
  if (!employmentId || state.employments[employmentId]) reject("Invalid job id.");
  const p = posting(a.postingId);
  state.employments[employmentId] = {
    id: employmentId, postingId: a.postingId, applicationId: a.id, title: str(title, 200) || p.title,
    salary: a.offerSalary, salaryPeriod: p.salaryPeriod, payFrequency: p.payFrequency, hoursPerWeek: p.hoursPerWeek,
    stage: p.stageOnHire, weeks: 0, unpaidWeeks: 0, periodsPaid: 0, reviews: 0, promotedAtWeek: 0,
    assignments: [], startedMs: now, ended: false,
  };
  a.status = "hired";
}

const ACTIONS = {
  screen(state, p) {
    const id = str(p.applicationId, 100);
    if (!id) reject("Missing application id.");
    if (state.applications[id]) return { application: summary(state.applications[id]) };
    const job = posting(p.postingId);
    let s;
    if (job.keywords.length) {
      s = R.screen(job, { ...p, thisYear });
      s.verified = true;
    } else {
      // Older postings are screened on training progress the server cannot see.
      const score = Number.isFinite(Number(p.clientScore)) ? Math.max(0, Math.min(100, Number(p.clientScore) | 0)) : 0;
      s = { score, eligible: !!p.clientEligible, shortlisted: !!p.clientEligible && score >= job.shortlistMark, verified: false };
    }
    state.applications[id] = { id, postingId: p.postingId, screening: s, status: s.shortlisted ? "shortlisted" : "rejected" };
    return { application: summary(state.applications[id]) };
  },

  interview(state, p, now) {
    const a = app(state, str(p.applicationId, 100));
    if (a.interview) return { application: summary(a) };
    if (a.status !== "shortlisted") reject("This application was not shortlisted by the server.");
    rate(state, "interview", now);
    const r = R.scoreInterview(posting(a.postingId), a.id, p);
    if (r.error) reject(r.error);
    a.interview = r;
    a.status = "interviewed";
    return { application: summary(a) };
  },

  decide(state, p) {
    const a = app(state, str(p.applicationId, 100));
    if (a.decision && !(a.decision.outcome === "furtherAssessment" && p.assessment && !a.assessed)) return { application: summary(a) };
    if (!a.interview) reject("The server has no interview for this application.");
    const job = posting(a.postingId);
    const assessment = a.decision && a.decision.outcome === "furtherAssessment" ? p.assessment : null;
    if (assessment) a.assessed = true;
    const d = R.decide(job, a.screening.score, a.interview, assessment);
    a.decision = d;
    if (d.outcome === "offer") { a.offerSalary = R.offerSalary(job, d.overall); a.status = "offer"; }
    else a.status = d.outcome === "reject" ? "rejected" : "furtherAssessment";
    return { application: summary(a) };
  },

  negotiate(state, p) {
    const a = app(state, str(p.applicationId, 100));
    if (a.status !== "offer") reject("There is no open offer on the server.");
    if (a.negotiation) return { application: summary(a) };
    const job = posting(a.postingId);
    const n = R.negotiate(job, a.offerSalary, job.salaryPeriod, a.interview ? a.interview.overall : 0, str(p.message, 5000));
    a.negotiation = { score: n.score, accepted: n.accepted };
    a.offerSalary = n.salary;
    return { application: summary(a) };
  },

  accept(state, p, now) {
    const a = app(state, str(p.applicationId, 100));
    if (a.status !== "offer") reject("There is no offer on the server to accept.");
    hire(state, a, str(p.employmentId, 100), p.title, now);
    return { employment: state.employments[p.employmentId] };
  },

  returnOffer(state, p) {
    const intern = emp(state, str(p.internEmploymentId, 100));
    const wp = R.CATALOG.workplaces[R.CATALOG.postings[intern.postingId].workplaceId] || {};
    if (!intern.ended || intern.stage !== "intern") reject("Finish the internship first.");
    if (intern.weeks < (wp.internshipLength || 3)) reject("The internship has too few approved assignments.");
    if (!wp.returnOfferPostingId) reject("This workplace makes no return offers.");
    if (intern.returnOfferApplicationId) return { application: summary(state.applications[intern.returnOfferApplicationId]) };
    const id = str(p.applicationId, 100);
    if (!id || state.applications[id]) reject("Invalid application id.");
    const job = posting(wp.returnOfferPostingId);
    const perf = Math.max(0, Math.min(100, Number(p.performance) | 0));
    state.applications[id] = { id, postingId: wp.returnOfferPostingId, status: "offer", returnOffer: true,
      offerSalary: R.offerSalary(job, Math.max(70, perf)) };
    intern.returnOfferApplicationId = id;
    return { application: summary(state.applications[id]) };
  },

  work(state, p, now) {
    const e = emp(state, str(p.employmentId, 100));
    if (e.ended) reject("This job has ended.");
    const id = str(p.assignmentRecordId, 200);
    if (!id) reject("Missing assignment id.");
    if (e.assignments.includes(id)) return { employment: e };
    rate(state, "work", now);
    e.assignments.push(id);
    if (e.assignments.length > 500) e.assignments.shift();
    e.weeks += 1;
    e.unpaidWeeks += 1;
    payroll(state, e, now);
    return { employment: e };
  },

  review(state, p) {
    const e = emp(state, str(p.employmentId, 100));
    if (e.ended) reject("This job has ended.");
    if (e.reviews >= Math.floor(e.weeks / 4)) reject("No performance review is due yet.");
    e.reviews += 1;
    const pct = R.raiseFor(str(p.outcome, 100));
    if (pct > 0) e.salary = R.raised(e.salary, e.salaryPeriod, 1 + pct / 100);
    return { employment: e };
  },

  promote(state, p) {
    const e = emp(state, str(p.employmentId, 100));
    if (e.ended) reject("This job has ended.");
    if (e.weeks - e.promotedAtWeek < 4) reject("A promotion needs at least four approved assignments since the last one.");
    const stages = R.CATALOG.stages;
    const next = stages.indexOf(e.stage) + 1;
    if (next <= 0 || next >= stages.length) reject("No further promotion is available.");
    e.stage = stages[next];
    e.promotedAtWeek = e.weeks;
    e.salary = R.raised(e.salary, e.salaryPeriod, 1.12);
    if (p.title) e.title = str(p.title, 200);
    return { employment: e };
  },

  end(state, p) {
    const e = emp(state, str(p.employmentId, 100));
    e.ended = true;
    return { employment: e };
  },

  lab(state, p, now) {
    const labId = str(p.labId, 200); const scenarioId = str(p.scenarioId, 200);
    const level = (R.CATALOG.labs[labId] || {})[scenarioId];
    if (!level) reject("Unknown lab scenario.");
    const key = `${labId}/${scenarioId}`;
    if (state.stipends[key] != null) return { stipend: state.stipends[key] };
    if (activeJob(state)) reject("Training stipends are paid only while you are not employed.");
    rate(state, "lab", now);
    const cents = R.stipend(level, Number(p.score) | 0);
    state.stipends[key] = cents;
    credit(state, cents, `Training stipend: ${labId}`, "lab", `lab:${key}`, now);
    return { stipend: cents };
  },

  state() { return {}; },
};

function summary(a) {
  if (!a) return null;
  return { id: a.id, postingId: a.postingId, status: a.status, screening: a.screening || null, interview: a.interview || null,
    decision: a.decision || null, offerSalary: a.offerSalary == null ? null : a.offerSalary };
}

/** Public view of the state sent back to the app. */
function view(state) {
  return {
    balanceCents: state.balanceCents,
    ledger: state.ledger.slice(-50),
    employments: Object.values(state.employments).map((e) => ({ id: e.id, title: e.title, salary: e.salary, salaryPeriod: e.salaryPeriod,
      payFrequency: e.payFrequency, weeks: e.weeks, periodsPaid: e.periodsPaid, ended: e.ended, stage: e.stage })),
    applications: Object.values(state.applications).map(summary),
  };
}

/**
 * Runs one action. Repeating an opId returns the first reply, so retries after
 * a dropped connection never pay twice.
 */
function applyAction(state, action, payload, opId, now) {
  thisYear = new Date(now).getUTCFullYear();
  state = state || emptyState();
  if (opId && state.ops[opId]) return { state, reply: { ok: true, duplicate: true } };
  const fn = ACTIONS[action];
  if (!fn) reject("Unknown action.");
  const reply = { ok: true, ...fn(state, payload || {}, now) };
  if (opId && action !== "state") {
    state.ops[opId] = true;
    state.opOrder.push(opId);
    while (state.opOrder.length > MAX_OPS) delete state.ops[state.opOrder.shift()];
  }
  return { state, reply };
}

module.exports = { applyAction, emptyState, view, Rejected, LIMITS };
