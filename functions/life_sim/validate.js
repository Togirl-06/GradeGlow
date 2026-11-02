"use strict";
/**
 * Server-side plausibility rules for GradeGlow Life saves.
 *
 * The Flutter client runs the whole simulation, so a modified client could
 * write any numbers to its own save. These rules are deliberately independent
 * of Firebase so they can be unit tested with plain Node. They bound how fast
 * a legitimate game can possibly change; anything faster is rolled back to the
 * last trusted checkpoint by `lifeSimGuard` (see ../life_sim.js).
 *
 * Limits come from the game's own data (see docs/life_sim/FIREBASE_SCHEMA.md):
 *  - highest listed salary is $11,570/month (~$386/day)
 *  - at most ~8 exam hours per weekday; skills gain < 3 per action
 */

const LIMITS = {
  startCash: 600,
  // Net-worth growth allowed per game day (salary + business + generous slack).
  maxWealthPerDay: 3000,
  wealthSlack: 1500,
  maxSkillPerDay: 25,
  skillSlack: 15,
  maxPassedCoursesPerDay: 8,
  passedCoursesSlack: 2,
  maxPromotionsPerWeek: 1,
  maxDay: 100000,
};

const EDU = ["high_school", "associate", "bachelor", "master", "doctorate"];
const DEGREE_RANK = {
  deg_cs: 2,
  deg_nursing: 2,
  deg_accounting: 2,
  deg_business: 2,
  deg_law: 3,
  deg_medicine: 4,
};

function parseSave(doc) {
  if (!doc || typeof doc.data !== "string") return null;
  try {
    const s = JSON.parse(doc.data);
    return s && typeof s === "object" ? s : null;
  } catch (_) {
    return null;
  }
}

const num = (v, d = 0) => (typeof v === "number" && Number.isFinite(v) ? v : d);

function wealth(s) {
  const e = s.economy || {};
  const co = s.company && typeof s.company === "object" ? num(s.company.cash) : 0;
  return num(e.cash) + num(e.savings) - num(e.debt) + Math.max(0, co);
}

function dayOf(s) {
  return Math.floor(num((s.clock || {}).day, 1));
}

function passedCount(s) {
  const courses = ((s.university || {}).courses) || {};
  return Object.values(courses).filter((c) => c && c.passed === true).length;
}

function completed(s) {
  const c = (s.university || {}).completedDegrees;
  return Array.isArray(c) ? c : [];
}

function eduRank(s) {
  const i = EDU.indexOf((s.avatar || {}).educationLevel);
  return i < 0 ? 0 : i;
}

function jobRank(s) {
  const j = s.job;
  return j && j.contract ? num(j.contract.rank, -1) : -1;
}

/**
 * @returns {{ok: boolean, reasons: string[]}}
 * @param prev last trusted save (parsed) or null
 * @param next the incoming save (parsed)
 */
function validate(prev, next) {
  const reasons = [];
  if (!next || typeof next !== "object") return { ok: false, reasons: ["unreadable save"] };

  const e = next.economy || {};
  for (const k of ["cash", "savings", "debt"]) {
    const v = e[k];
    if (typeof v !== "number" || !Number.isFinite(v)) reasons.push(`economy.${k} is not a number`);
  }
  if (num(e.cash) < -100) reasons.push("cash below zero");
  if (num(e.savings) < 0) reasons.push("negative savings");
  if (num(e.debt) < 0) reasons.push("negative debt");

  const day = dayOf(next);
  if (day < 1 || day > LIMITS.maxDay) reasons.push("day out of range");

  const points = (next.skills || {}).points || {};
  for (const [id, v] of Object.entries(points)) {
    if (typeof v !== "number" || v < 0 || v > 100) reasons.push(`skill ${id} out of range`);
  }

  // Certificates need the matching completed degree.
  const done = new Set(completed(next));
  for (const c of next.certificates || []) {
    if (!c || !done.has(c.degreeId)) reasons.push("certificate without a completed degree");
  }
  // Education level needs completed degrees (or an associate milestone).
  let maxEdu = 0;
  for (const d of done) maxEdu = Math.max(maxEdu, DEGREE_RANK[d] || 0);
  if ((((next.university || {}).associateEarned) || []).length > 0) maxEdu = Math.max(maxEdu, 1);

  if (!prev) {
    // First checkpoint: nobody can have more than the fastest legal growth.
    const cap = LIMITS.startCash + (day - 1) * LIMITS.maxWealthPerDay + LIMITS.wealthSlack;
    if (wealth(next) > cap) reasons.push(`wealth ${Math.round(wealth(next))} exceeds what is possible by day ${day}`);
    if (eduRank(next) > maxEdu && day < 3 && eduRank(next) > 0) {
      reasons.push("education level without degrees");
    }
    return { ok: reasons.length === 0, reasons };
  }

  const pd = dayOf(prev);
  const dd = day - pd;
  if (dd < 0) reasons.push("time moved backwards");
  const days = Math.max(0, dd);

  const gain = wealth(next) - wealth(prev);
  const maxGain = days * LIMITS.maxWealthPerDay + LIMITS.wealthSlack;
  if (gain > maxGain) reasons.push(`wealth rose by ${Math.round(gain)} in ${days} day(s) (max ${maxGain})`);

  const prevPoints = (prev.skills || {}).points || {};
  for (const [id, v] of Object.entries(points)) {
    const before = num(prevPoints[id]);
    if (v - before > days * LIMITS.maxSkillPerDay + LIMITS.skillSlack) {
      reasons.push(`skill ${id} rose too fast`);
    }
  }

  const passedGain = passedCount(next) - passedCount(prev);
  if (passedGain > days * LIMITS.maxPassedCoursesPerDay + LIMITS.passedCoursesSlack) {
    reasons.push("too many courses passed");
  }
  const degreeGain = completed(next).length - completed(prev).length;
  if (degreeGain > passedGain) reasons.push("degree without passing courses");

  if (eduRank(next) > Math.max(eduRank(prev), maxEdu)) reasons.push("education level raised without degrees");

  const pr = jobRank(prev);
  const nr = jobRank(next);
  if (pr >= 0 && nr > pr) {
    const allowed = LIMITS.maxPromotionsPerWeek * Math.ceil(Math.max(days, 1) / 7);
    if (nr - pr > allowed) reasons.push("promoted too quickly");
  }
  // Hired with no application history from nothing: rank 3+ job within a week of no job.
  if (pr < 0 && nr >= 3 && days < 14) reasons.push("senior role without career history");

  return { ok: reasons.length === 0, reasons };
}

/** Decision for a save write. checkpointDoc / incomingDoc are Firestore doc data. */
function decide(checkpointDoc, incomingDoc) {
  const next = parseSave(incomingDoc);
  const prev = checkpointDoc ? parseSave(checkpointDoc) : null;
  const result = validate(prev, next);
  if (result.ok) return { action: "accept", reasons: [] };
  return { action: prev ? "rollback" : "reject", reasons: result.reasons };
}

module.exports = { validate, decide, parseSave, wealth, LIMITS };
