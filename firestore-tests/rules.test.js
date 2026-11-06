"use strict";
// Firestore security rules, tested against the real emulator.
// Focus: career data the server keeps (users/{uid}/career_server) can be read
// by its owner but never written by any client, while everything the app
// already saves keeps working.

const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const { initializeTestEnvironment, assertFails, assertSucceeds } = require("@firebase/rules-unit-testing");
const { doc, getDoc, setDoc, updateDoc, deleteDoc } = require("firebase/firestore");

let env;
test.before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-gradeglow",
    firestore: { rules: fs.readFileSync(path.join(__dirname, "..", "firestore.rules"), "utf8") },
  });
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), "users/alice/career_server/state"), { balanceCents: 5000 });
    await setDoc(doc(ctx.firestore(), "users/alice"), { plan: "free" });
  });
});
test.after(async () => { if (env) await env.cleanup(); });

const alice = () => env.authenticatedContext("alice").firestore();
const bob = () => env.authenticatedContext("bob").firestore();

test("the owner can read the verified career record", async () => {
  await assertSucceeds(getDoc(doc(alice(), "users/alice/career_server/state")));
});

test("no client can write, change or delete the verified career record", async () => {
  await assertFails(setDoc(doc(alice(), "users/alice/career_server/state"), { balanceCents: 99999999 }));
  await assertFails(updateDoc(doc(alice(), "users/alice/career_server/state"), { balanceCents: 99999999 }));
  await assertFails(deleteDoc(doc(alice(), "users/alice/career_server/state")));
  await assertFails(setDoc(doc(alice(), "users/alice/career_server/other"), { x: 1 }));
});

test("other students cannot read it", async () => {
  await assertFails(getDoc(doc(bob(), "users/alice/career_server/state")));
});

test("the app's own career save still works", async () => {
  await assertSucceeds(setDoc(doc(alice(), "users/alice/career_sim/profile"), { data: "{}", updatedAtMs: 1, schema: 1 }));
  await assertSucceeds(getDoc(doc(alice(), "users/alice/career_sim/profile")));
  await assertFails(setDoc(doc(bob(), "users/alice/career_sim/profile"), { data: "{}" }));
});

test("existing protections are unchanged", async () => {
  await assertFails(updateDoc(doc(alice(), "users/alice"), { plan: "pro" }));
  await assertFails(setDoc(doc(alice(), "users/alice/coding_results/x"), { verdict: "Accepted" }));
  await assertFails(setDoc(doc(alice(), "users/alice/life_server/x"), { coins: 1 }));
});
