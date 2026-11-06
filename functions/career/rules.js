"use strict";
// Server copy of the career simulator's scoring and pay rules.
//
// These functions mirror lib/career_sim (text_rubric.dart, resume_analysis.dart,
// market_rules.dart, interview_engine.dart, career_rules.dart, pay_rules.dart).
// The job catalogue comes from catalog.json, which a Dart test regenerates, and
// test/career_parity.test.js checks that this file returns exactly the numbers
// the app computes for the same inputs (fixtures/career_parity.json).

const CATALOG = require("./catalog.json");

const round = (x) => Math.round(x); // inputs are never negative here, so this matches Dart's round()
const clamp = (x, lo, hi) => Math.min(hi, Math.max(lo, x));

// ------------------------------------------------------------------ text rubric

const phraseCache = new Map();
function escapeRe(s) { return s.replace(/[.*+?^${}()|[\]\\\/-]/g, "\\$&"); }
function phrase(p) {
  if (!phraseCache.has(p)) {
    const parts = p.toLowerCase().trim().split(/\s+/);
    const body = parts.map((w) => {
      const stem = w.endsWith("*");
      const core = escapeRe(stem ? w.slice(0, -1) : w);
      return stem ? `${core}[a-z0-9]*` : core;
    }).join("\\s+");
    phraseCache.set(p, new RegExp(`(?<![a-z0-9])${body}(?![a-z0-9])`));
  }
  return phraseCache.get(p);
}
function words(text) { return (String(text).toLowerCase().match(/[a-z0-9']+/g) || []); }
function sentences(text) { return String(text).split(/[.!?;\n]+/).map((s) => s.trim()).filter((s) => s.length > 0); }
function mentions(text, concept) {
  const lower = String(text).toLowerCase();
  return concept.anyOf.some((p) => phrase(p).test(lower));
}

function assess(text, concepts, minWords = 40, maxWords = 400) {
  const all = words(text);
  const substantive = sentences(text).filter((s) => words(s).length >= 5);
  const countable = substantive.join(". ");
  let got = 0; let total = 0;
  for (const c of concepts) {
    const w = c.weight == null ? 1 : c.weight;
    total += w;
    if (mentions(countable, c)) got += w;
  }
  const coverage = total === 0 ? 1 : got / total;
  const n = all.length;
  let lengthFactor = 1;
  if (n < minWords) lengthFactor = minWords === 0 ? 1 : n / minWords;
  else if (n > maxWords) lengthFactor = maxWords / n;
  const sentenceFactor = substantive.length < 2 ? 0.5 : 1;
  let repetition = 1;
  if (n >= 20 && new Set(all).size / n < 0.35) repetition = 0.6;
  const structure = clamp(lengthFactor * sentenceFactor, 0, 1);
  let raw = (0.75 * coverage + 0.25 * structure) * repetition;
  if (n < minWords / 2) raw = clamp(raw, 0, 0.3);
  if (all.length === 0) raw = 0;
  return { score: clamp(round(raw * 100), 0, 100), structure, words: n };
}

// ------------------------------------------------------------------ resume

function countWords(t) { return (String(t).match(/[A-Za-z0-9][A-Za-z0-9'’+#.\-]*/g) || []).length; }
const BULLET = /^[•·▪●◦\-*–]\s*/;
function startsWithActionVerb(l) {
  const w = l.replace(BULLET, "").trim().split(/\s+/)[0].toLowerCase().replace(/[^a-z]/g, "");
  return CATALOG.actionVerbs.includes(w);
}
function asText(p) {
  return [p.name, p.headline, p.summary, ...p.education, ...p.experience, ...p.projects, p.skills.join(", "),
    ...p.certifications, ...p.achievements].filter((s) => String(s).trim().length > 0).join("\n");
}
function normaliseResume(r) {
  const s = (v) => (typeof v === "string" ? v : "");
  const l = (v) => (Array.isArray(v) ? v.filter((x) => typeof x === "string") : []);
  r = r || {};
  return { name: s(r.name), email: s(r.email), phone: s(r.phone), headline: s(r.headline), summary: s(r.summary),
    education: l(r.education), experience: l(r.experience), skills: l(r.skills), projects: l(r.projects),
    certifications: l(r.certifications), achievements: l(r.achievements) };
}

function resumeQuality(p) {
  const text = asText(p);
  const n = countWords(text);
  const bullets = [...p.experience, ...p.projects].flatMap((e) => e.split(/ — |; /));
  const quantified = bullets.filter((b) => /\d/.test(b) && /\d+\s?%|\$\s?\d|\d+\+?\s+[a-z]|\d{2,}/.test(b.toLowerCase())).length;
  const verbs = bullets.filter(startsWithActionVerb).length;
  const dated = [...p.experience, ...p.education].filter((e) => /\b(19|20)\d{2}\b|present/i.test(e)).length;
  const firstPerson = (text.match(/\b(I|me|my)\b/g) || []).length;
  const pts = [
    (p.name ? 5 : 0) + (p.email ? 5 : 0),
    p.phone ? 5 : 0,
    countWords(p.summary) >= 15 ? 10 : (p.summary ? 5 : 0),
    p.education.length ? 15 : 0,
    p.experience.length ? 15 : (p.projects.length ? 12 : 0),
    Math.min(10, p.skills.length * 2),
    Math.min(10, quantified * 5),
    Math.min(10, round(verbs * 10 / 3)),
    Math.min(5, dated * 3),
    n >= 150 && n <= 900 ? 5 : (n >= 80 ? 3 : 0),
    firstPerson <= 2 ? 5 : 0,
  ];
  return clamp(pts.reduce((a, b) => a + b, 0), 0, 100);
}

function resumeMentions(text, term) {
  const t = String(text).toLowerCase();
  const k = String(term).toLowerCase().trim();
  const has = (x) => (x.length <= 3 ? new RegExp(`(^|[^a-z0-9])${escapeRe(x)}([^a-z0-9]|$)`).test(t) : t.includes(x));
  if (has(k)) return true;
  return (CATALOG.aliases[k] || []).some(has);
}

function experienceYears(p, thisYear) {
  let years = 0;
  for (const e of p.experience) {
    const ys = [...e.matchAll(/\b((?:19|20)\d{2})\b/g)].map((m) => parseInt(m[1], 10));
    const present = /present|current|now/i.test(e);
    if (!ys.length) continue;
    const start = Math.min(...ys);
    const end = present ? thisYear : Math.max(...ys);
    years += Math.max(0.25, end - start);
  }
  return years;
}
function levelYears(level) { return ({ "Junior": 1, "Mid-level": 3, "Senior": 5, "Management": 7 })[level] || 0; }

function jobMatch(p, job, fullText, thisYear) {
  const text = `${asText(p)}\n${fullText || ""}`;
  const required = job.keywords.length ? job.keywords : (CATALOG.deptKeywords[job.deptId] || []);
  const matched = required.filter((k) => resumeMentions(text, k));
  const prefMatched = job.preferredKeywords.filter((k) => resumeMentions(text, k));
  const eduText = p.education.join(" ");
  const eduOk = job.educationFields.length === 0
    ? p.education.length > 0
    : job.educationFields.some((f) => resumeMentions(eduText === "" ? text : eduText, f));
  const need = levelYears(job.level);
  const have = experienceYears(p, thisYear);
  let exp;
  if (need === 0) exp = (p.experience.length || p.projects.length) ? 1 : 0.6;
  else exp = Math.min(1, have / need);
  const req = required.length === 0 ? 1 : matched.length / required.length;
  const pref = job.preferredKeywords.length === 0 ? (req > 0.5 ? 1 : 0.5) : prefMatched.length / job.preferredKeywords.length;
  return clamp(round(50 * req + 15 * pref + 20 * (eduOk ? 1 : 0.3) + 15 * exp), 0, 100);
}

// ------------------------------------------------------------------ screening

function postingOpen(job, day) {
  const cycle = 60;
  let start = job.openDay;
  if (day >= job.openDay) start = job.openDay + Math.floor((day - job.openDay) / cycle) * cycle;
  return day >= start && day <= start + (job.deadlineDay - job.openDay);
}
function stageIndex(name) { const i = CATALOG.stages.indexOf(name); return i < 0 ? 0 : i; }

function coverLetterRubric(job) {
  return [
    { id: "company", anyOf: [job.company] },
    { id: "role", anyOf: [job.title, ...job.title.split(" ").filter((w) => w.length > 5)] },
    ...CATALOG.coverLetterRubric,
  ];
}

function answersScore(job, answers) {
  if (!job.questions.length) return 100;
  let sum = 0;
  for (const q of job.questions) sum += assess((answers || {})[q.id] || "", q.rubric, q.minWords, 300).score;
  return round(sum / job.questions.length);
}

/** Screening for a marketplace posting (one with keywords). */
function screen(job, input) {
  let eligible = true;
  if (!postingOpen(job, input.submittedDay)) eligible = false;
  if (stageIndex(input.stage) < stageIndex(job.minStage)) eligible = false;
  const r = normaliseResume(input.resume);
  const match = jobMatch(r, job, input.resumeText || "", input.thisYear);
  const quality = resumeQuality(r);
  const evidence = Math.min(1, (clamp(input.labsPassed | 0, 0, 1000) + clamp(input.modules | 0, 0, 1000)) / 3);
  const letter = assess(input.coverLetter || "", coverLetterRubric(job), 120, 450).score;
  const answers = answersScore(job, input.answers);
  const materials = (0.5 * letter + 0.5 * answers) / 100;
  const total = 40 * match / 100 + 10 * quality / 100 + 25 * materials + 25 * evidence;
  const score = round(total);
  return { score, eligible, shortlisted: eligible && score >= job.shortlistMark };
}

// ------------------------------------------------------------------ interview

function interviewPlan(job, applicationId) {
  const base = CATALOG.plans[job.interviewPlanId];
  if (!base) return null;
  if (!job.keywords.length) return base;
  const res = { id: `res_${applicationId}`, competency: "communication", behavioural: true, minWords: 40,
    rubric: CATALOG.resumeQuestionRubric, options: 0, correctOption: -1, practical: false, probeId: null, stretchId: null };
  return {
    main: [res.id, ...job.roleQuestions.map((q) => q.id), ...base.main],
    bank: [res, ...job.roleQuestions, ...base.bank],
    maxQuestions: base.maxQuestions + 1 + job.roleQuestions.length,
  };
}

const TOPICS = [
  ["team", ["team", "work with", "colleague*", "report to", "manager", "supervisor"]],
  ["training", ["train*", "learn*", "mentor*", "develop*", "grow*", "progress*"]],
  ["success", ["success*", "expect*", "measure*", "first month*", "first 90", "first three", "evaluat*", "perform*"]],
  ["culture", ["culture", "values", "environment", "typical day", "day to day", "like to work"]],
  ["tools", ["tool*", "stack", "technolog*", "software", "system*", "equipment"]],
  ["next", ["next step*", "timeline", "hear back", "process", "decision"]],
];
function questionTopic(question) {
  const lower = String(question).trim().toLowerCase();
  for (const [topic, ws] of TOPICS) {
    if (ws.some((w) => mentions(lower, { anyOf: [w] }))) return topic;
  }
  return "";
}

/**
 * Replays an interview transcript against the posting's plan. Every question
 * must be the one the interviewer would have asked next, and every open or
 * choice answer is re-scored here. Returns null-with-reason when the
 * transcript does not follow the plan.
 */
function scoreInterview(job, applicationId, transcript) {
  const plan = interviewPlan(job, applicationId);
  if (!plan) return { error: "No interview plan for this role." };
  const byId = new Map(plan.bank.map((q) => [q.id, q]));
  const queue = [...plan.main];
  const asked = new Set();
  const probes = new Set();
  const turns = [];
  const structure = [];
  let practicalAsked = false;
  let practicalFailed = false;
  let current = null;
  const advance = () => {
    current = null;
    if (turns.length >= plan.maxQuestions) return;
    while (queue.length) {
      const id = queue.shift();
      if (asked.has(id)) continue;
      const q = byId.get(id);
      if (!q) continue;
      current = q; asked.add(id); return;
    }
  };
  advance();
  const given = Array.isArray(transcript.turns) ? transcript.turns : [];
  for (const t of given) {
    if (!current) return { error: "More answers than questions." };
    if (!t || t.q !== current.id) return { error: `Expected an answer to "${current.id}".` };
    const q = current;
    let score;
    if (q.practical) {
      practicalAsked = true;
      score = clamp(Number(t.practicalScore) | 0, 0, 100);
      if (!t.practicalPassed) practicalFailed = true;
    } else if (q.options > 0) {
      const i = Number(t.choice);
      if (!Number.isInteger(i) || i < 0 || i >= q.options) return { error: "Invalid choice." };
      score = i === q.correctOption ? 100 : 0;
    } else {
      const text = String(t.answer || "");
      if (!text.trim()) return { error: "Empty answer." };
      const rubric = [...q.rubric, ...(q.behavioural ? CATALOG.star : [])];
      const a = assess(text, rubric, q.minWords, 300);
      structure.push(a.structure);
      score = a.score;
    }
    turns.push({ competency: q.competency, score });
    if (score < 60 && q.probeId && !asked.has(q.probeId)) { queue.unshift(q.probeId); probes.add(q.probeId); }
    else if (score >= 85 && q.stretchId && !asked.has(q.stretchId)) queue.unshift(q.stretchId);
    advance();
  }
  if (current && transcript.peek) return { next: current };
  if (current) return { error: "The interview has unanswered questions." };
  const avg = (xs, fb) => (xs.length ? round(xs.reduce((a, b) => a + b, 0) / xs.length) : fb);
  const all = avg(turns.map((t) => t.score), 0);
  const comp = (c) => avg(turns.filter((t) => t.competency === c).map((t) => t.score), all);
  const struct = avg(structure.map((s) => round(s * 100)), all);
  const topics = new Set();
  for (const cq of (Array.isArray(transcript.candidateQuestions) ? transcript.candidateQuestions.slice(0, 3) : [])) {
    const topic = questionTopic(cq);
    if (topic) topics.add(topic);
  }
  const communication = round((comp("communication") + struct) / 2);
  const engagement = round(Math.min(topics.size, 3) / 3 * 100);
  const readiness = round(0.7 * comp("readiness") + 0.3 * engagement);
  const technical = comp("technical");
  const problemSolving = comp("problemSolving");
  const overall = round((communication + technical + problemSolving + readiness) / 4);
  return {
    communication, technical, problemSolving, readiness, overall,
    lowest: Math.min(communication, technical, problemSolving, readiness),
    practicalPassed: practicalAsked && !practicalFailed,
  };
}

// ------------------------------------------------------------------ decisions and pay

function decide(job, screeningScore, interview, assessment) {
  const a = assessment && Number.isFinite(Number(assessment.score))
    ? { score: clamp(Number(assessment.score) | 0, 0, 100), passed: !!assessment.passed } : null;
  const overall = a == null
    ? round(0.3 * screeningScore + 0.7 * interview.overall)
    : round(0.25 * screeningScore + 0.5 * interview.overall + 0.25 * a.score);
  const practicalOk = !job.practicalRequired || interview.practicalPassed;
  if (overall >= 70 && interview.lowest >= 50 && practicalOk && (a == null || a.passed)) return { outcome: "offer", overall };
  if (a == null && overall >= 58 && interview.lowest >= 40) return { outcome: "furtherAssessment", overall };
  return { outcome: "reject", overall };
}

function offerSalary(job, overall) {
  const t = clamp((overall - 70) / 30, 0, 1);
  const raw = job.salaryMin + (job.salaryMax - job.salaryMin) * t;
  const step = job.salaryPeriod === "year" ? 500 : 10;
  return round(raw / step) * step;
}

function raised(salary, period, factor) {
  const step = period === "year" ? 500 : (period === "month" ? 10 : 1);
  const r = round(salary * factor / step) * step;
  return r <= salary ? salary + step : r;
}

function negotiate(job, offerSalaryNow, offerPeriod, interviewOverall, message) {
  const t = assess(message, CATALOG.negotiationRubric, 40, 250).score;
  const ok = t >= 60 && interviewOverall >= 75 && offerSalaryNow < job.salaryMax;
  return { score: t, accepted: ok, salary: ok ? Math.min(job.salaryMax, raised(offerSalaryNow, offerPeriod, 1.05)) : offerSalaryNow };
}

function weeksPerPeriod(f) { return f === "weekly" ? 1 : (f === "monthly" ? 4 : 2); }
function annual(salary, period, hours) {
  switch (period) {
    case "hour": return salary * hours * 52;
    case "week": return salary * 52;
    case "month": return salary * 12;
    default: return salary;
  }
}
function weeklyGrossCents(salary, period, hours) {
  return period === "hour" ? salary * hours * 100 : round(annual(salary, period, hours) * 100 / 52);
}
function periodGrossCents(salary, period, frequency, hours) {
  if (frequency === "monthly") return round(annual(salary, period, hours) * 100 / 12);
  return weeklyGrossCents(salary, period, hours) * weeksPerPeriod(frequency);
}
function paycheck(e, period) {
  const gross = periodGrossCents(e.salary, e.salaryPeriod, e.payFrequency, e.hoursPerWeek);
  const deduction = round(gross * CATALOG.deductionRate);
  return { id: `${e.id}_p${period}`, period, grossCents: gross, deductionCents: deduction, netCents: gross - deduction };
}
function raiseFor(outcome) { return outcome === "Excellent performance" ? 5 : (outcome === "Meets expectations" ? 2 : 0); }
function stipend(level, score) { return round((CATALOG.stipendCents[level] || 0) * clamp(score | 0, 0, 100) / 100); }

module.exports = {
  CATALOG, assess, words, resumeQuality, jobMatch, screen, scoreInterview, interviewPlan, questionTopic, decide,
  offerSalary, negotiate, raised, paycheck, weeksPerPeriod, raiseFor, stipend, postingOpen, normaliseResume,
};
