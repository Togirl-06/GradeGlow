"use strict";
/**
 * Server authority for GradeGlow Life.
 *
 * Every write to users/{uid}/life_sim/save is checked against the last trusted
 * checkpoint (users/{uid}/life_server/checkpoint). Clients cannot write
 * life_server/** (see firestore.rules), so only this function moves it.
 *   - plausible save  -> becomes the new checkpoint
 *   - impossible jump -> the save is rolled back to the checkpoint and an
 *                        audit record is written
 *   - first save looks impossible -> audit only, never becomes a checkpoint
 *   - save deleted    -> checkpoint cleared (new game)
 * Limits and caveats: docs/life_sim/FIREBASE_SCHEMA.md
 */
const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const { decide } = require("./life_sim/validate");

let adminReady = false;
function db() {
  const { initializeApp, getApps } = require("firebase-admin/app");
  const { getFirestore } = require("firebase-admin/firestore");
  if (!adminReady) {
    if (getApps().length === 0) initializeApp();
    adminReady = true;
  }
  return getFirestore();
}

exports.lifeSimGuard = onDocumentWritten(
  { document: "users/{uid}/life_sim/save", region: "us-central1" },
  async (event) => {
    const uid = event.params.uid;
    const firestore = db();
    const base = firestore.collection("users").doc(uid);
    const checkpointRef = base.collection("life_server").doc("checkpoint");
    const saveRef = base.collection("life_sim").doc("save");

    const after = event.data && event.data.after;
    if (!after || !after.exists) {
      await checkpointRef.delete().catch(() => {});
      return;
    }
    const incoming = after.data();
    const cp = await checkpointRef.get();
    const checkpoint = cp.exists ? cp.data() : null;
    const verdict = decide(checkpoint, incoming);

    if (verdict.action === "accept") {
      await checkpointRef.set({ data: incoming.data, savedAtMs: incoming.savedAtMs || Date.now(), verifiedAtMs: Date.now() });
      return;
    }
    await base.collection("life_server").doc("audit").collection("events").add({
      atMs: Date.now(),
      action: verdict.action,
      reasons: verdict.reasons,
    });
    // Only roll back when there is a trusted checkpoint to return to. A first
    // save that looks impossible is flagged in the audit log and simply never
    // becomes a checkpoint (we never delete a player's only save).
    if (verdict.action === "rollback") {
      await saveRef.set({ ...checkpoint, rolledBack: true, rolledBackAtMs: Date.now() });
    }
  }
);

