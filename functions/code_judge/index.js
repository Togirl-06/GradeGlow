"use strict";
// Callable Cloud Function: codeJudge
//
// Request:  { problemKey: 'impl:1' | 'debug:dbg-3', language: 'python3'|'javascript', code, mode: 'run'|'submit' }
// Response: the judge result (verdict, per-case rows, runtime, memory).
//
// Trust boundary: the app never decides whether code is accepted. This
// function grades against its own copy of the tests (problems.json) in an
// isolated sandbox and writes results with the Admin SDK into collections the
// client may read but not write (see firestore.rules).

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const { judge, gradability } = require("./judge");
const { pistonRunner } = require("./runner");
const { SUPPORTED } = require("./harness");
const { recordSubmission, checkRate } = require("./records");

const CODE_RUNNER_URL = defineSecret("CODE_RUNNER_URL");
const CODE_RUNNER_KEY = defineSecret("CODE_RUNNER_KEY");

let PROBLEMS = null;
function problems() {
  if (!PROBLEMS) {
    try { PROBLEMS = require("./problems.json"); } catch (e) { PROBLEMS = {}; }
  }
  return PROBLEMS;
}

function readSecret(s) { try { return s.value() || ""; } catch (e) { return ""; } }

exports.codeJudge = onCall(
  { secrets: [CODE_RUNNER_URL, CODE_RUNNER_KEY], timeoutSeconds: 60, memory: "256MiB", maxInstances: 20, cors: true },
  async (request) => {
    if (!request.auth) throw new HttpsError("unauthenticated", "Sign in to run code.");
    const { problemKey, language, code, mode } = request.data || {};
    if (typeof problemKey !== "string" || typeof language !== "string" || typeof code !== "string") {
      throw new HttpsError("invalid-argument", "problemKey, language and code are required.");
    }
    const problem = problems()[problemKey];
    if (!problem) throw new HttpsError("not-found", "Unknown problem.");
    const submit = mode === "submit";
    const uid = request.auth.uid;

    if (!admin.apps.length) admin.initializeApp();
    const db = admin.firestore();
    const allowed = await checkRate(db, uid);
    if (!allowed) throw new HttpsError("resource-exhausted", "Too many runs. Wait a minute and try again.");

    const url = readSecret(CODE_RUNNER_URL);
    let result;
    if (!url && SUPPORTED[language]) {
      result = { problemId: problem.id, language, mode: submit ? "submit" : "run", verdict: "Runner Unavailable",
        message: "The code runner is not configured on this server yet. Your code was not graded.", cases: [] };
    } else {
      result = await judge({ problem, language, code, includeHidden: submit }, pistonRunner(url || "http://unset", { apiKey: readSecret(CODE_RUNNER_KEY) || undefined }));
    }
    if (submit && result.verdict !== "Runner Unavailable" && result.verdict !== "Not Gradable") {
      const name = request.auth.token && (request.auth.token.name || request.auth.token.email) || "Student";
      await recordSubmission(db, { uid, displayName: String(name).split("@")[0], problemKey, problem, language, code, result });
    }
    return result;
  },
);

/** Lets the app label problems the server cannot grade. */
exports.codeJudgeCatalog = onCall({ cors: true }, async () => {
  const out = {};
  for (const [k, p] of Object.entries(problems())) out[k] = gradability(p).gradable;
  return { gradable: out };
});
