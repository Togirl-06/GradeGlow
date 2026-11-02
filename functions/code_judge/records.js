"use strict";
// Server-written coding records. All paths here are read-only for clients.
//
//   users/{uid}/coding_results/{problemKey}   best result per problem
//   users/{uid}/coding_submissions/{auto}     every graded submission (with code)
//   users/{uid}/server/coding_rate            rate-limit window
//   leaderboards/coding/entries/{uid}         points + solved count

const POINTS = { Easy: 10, Medium: 20, Hard: 40 };
const RATE_WINDOW_MS = 60 * 1000;
const RATE_MAX = 20;

function pointsFor(problem) { return POINTS[problem.difficulty] || 10; }

/** Pure: compute the next stored result and score delta. */
function mergeResult(prev, { problem, language, result, now }) {
  const accepted = result.verdict === "Accepted";
  const wasAccepted = !!(prev && prev.accepted);
  const next = {
    problemId: problem.id,
    title: problem.title || problem.id,
    difficulty: problem.difficulty || "Easy",
    kind: problem.kind || "implement",
    attempts: ((prev && prev.attempts) || 0) + 1,
    accepted: wasAccepted || accepted,
    lastVerdict: result.verdict,
    lastLanguage: language,
    lastAt: now,
    acceptedAt: wasAccepted ? prev.acceptedAt : (accepted ? now : null),
    bestRuntimeMs: accepted
      ? Math.min(result.runtimeMs == null ? Infinity : result.runtimeMs, prev && prev.bestRuntimeMs != null ? prev.bestRuntimeMs : Infinity)
      : (prev && prev.bestRuntimeMs != null ? prev.bestRuntimeMs : null),
  };
  if (next.bestRuntimeMs === Infinity) next.bestRuntimeMs = null;
  const firstSolve = accepted && !wasAccepted;
  return { next, pointsDelta: firstSolve ? pointsFor(problem) : 0, solvedDelta: firstSolve ? 1 : 0 };
}

async function recordSubmission(db, { uid, displayName, problemKey, problem, language, code, result }) {
  const admin = require("firebase-admin");
  const now = admin.firestore.Timestamp.now();
  const resultRef = db.doc(`users/${uid}/coding_results/${problemKey.replace(/[/]/g, "_")}`);
  const boardRef = db.doc(`leaderboards/coding/entries/${uid}`);
  await db.runTransaction(async (tx) => {
    const prev = (await tx.get(resultRef)).data();
    const { next, pointsDelta, solvedDelta } = mergeResult(prev, { problem, language, result, now });
    tx.set(resultRef, next);
    if (pointsDelta) {
      tx.set(boardRef, {
        displayName: displayName.slice(0, 40),
        points: admin.firestore.FieldValue.increment(pointsDelta),
        solved: admin.firestore.FieldValue.increment(solvedDelta),
        updatedAt: now,
      }, { merge: true });
    }
  });
  await db.collection(`users/${uid}/coding_submissions`).add({
    problemKey, language, verdict: result.verdict, passed: result.passed || 0, total: result.total || 0,
    runtimeMs: result.runtimeMs == null ? null : result.runtimeMs, memoryKb: result.memoryKb == null ? null : result.memoryKb,
    code: String(code).slice(0, 64 * 1024), at: now,
  });
}

/** Sliding one-minute window, 20 runs. Returns false when over the limit. */
async function checkRate(db, uid, nowMs = Date.now()) {
  const ref = db.doc(`users/${uid}/server/coding_rate`);
  return db.runTransaction(async (tx) => {
    const d = (await tx.get(ref)).data() || {};
    const recent = (d.times || []).filter((t) => nowMs - t < RATE_WINDOW_MS);
    if (recent.length >= RATE_MAX) return false;
    recent.push(nowMs);
    tx.set(ref, { times: recent });
    return true;
  });
}

module.exports = { recordSubmission, checkRate, mergeResult, pointsFor, RATE_MAX };
