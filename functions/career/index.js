"use strict";
// Callable Cloud Function: careerServer
//
// Request:  { opId, action, payload }
// Response: { reply, state } where state is the server's view of the student's
//           applications, jobs and verified wallet.
//
// Trust boundary: the app cannot write users/{uid}/career_server/** (see
// firestore.rules). Scores, salaries and pay are computed here from the
// server's own catalogue; the app only reports what the student did.

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const { applyAction, emptyState, view, Rejected } = require("./server");

exports.careerServer = onCall({ timeoutSeconds: 30, memory: "256MiB", maxInstances: 20, cors: true }, async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in to save verified progress.");
  const { opId, action, payload } = request.data || {};
  if (typeof action !== "string") throw new HttpsError("invalid-argument", "action is required.");
  if (opId != null && (typeof opId !== "string" || opId.length > 100)) throw new HttpsError("invalid-argument", "Bad opId.");
  if (JSON.stringify(payload || {}).length > 100000) throw new HttpsError("invalid-argument", "Request too large.");
  if (!admin.apps.length) admin.initializeApp();
  const db = admin.firestore();
  const ref = db.collection("users").doc(request.auth.uid).collection("career_server").doc("state");
  try {
    return await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      const current = snap.exists ? { ...emptyState(), ...snap.data() } : emptyState();
      const { state, reply } = applyAction(current, action, payload || {}, opId || null, Date.now());
      if (action !== "state") tx.set(ref, JSON.parse(JSON.stringify(state)));
      return { reply, state: view(state) };
    });
  } catch (e) {
    if (e instanceof Rejected) throw new HttpsError("failed-precondition", e.message);
    throw e;
  }
});
