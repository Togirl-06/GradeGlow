"use strict";
const test = require("node:test");
const assert = require("node:assert/strict");
const { validate, decide, LIMITS } = require("../life_sim/validate");

function save(over = {}) {
  const base = {
    clock: { day: 10, minuteOfDay: 480 },
    avatar: { educationLevel: "high_school" },
    economy: { cash: 700, savings: 100, debt: 0 },
    skills: { points: { programming: 10, communication: 12 } },
    university: { courses: {}, completedDegrees: [], associateEarned: [] },
    certificates: [],
    job: null,
    company: null,
  };
  return { ...base, ...over };
}
const doc = (s) => ({ data: JSON.stringify(s), savedAtMs: 1 });

test("normal progress is accepted", () => {
  const a = save();
  const b = save({ clock: { day: 12, minuteOfDay: 0 }, economy: { cash: 1500, savings: 100, debt: 0 } });
  assert.equal(validate(a, b).ok, true);
});

test("cash cheat is rolled back", () => {
  const a = save();
  const b = save({ economy: { cash: 9_999_999, savings: 0, debt: 0 } });
  const v = validate(a, b);
  assert.equal(v.ok, false);
  assert.match(v.reasons.join(), /wealth rose/);
  assert.equal(decide(doc(a), doc(b)).action, "rollback");
});

test("first save with impossible wealth is rejected, not rolled back", () => {
  const b = save({ economy: { cash: 5_000_000, savings: 0, debt: 0 } });
  assert.equal(decide(null, doc(b)).action, "reject");
});

test("legit first save for an old game is accepted", () => {
  const b = save({ clock: { day: 400, minuteOfDay: 0 }, economy: { cash: 90_000, savings: 40_000, debt: 0 } });
  assert.equal(validate(null, b).ok, true);
});

test("max legal salary growth is accepted", () => {
  const a = save();
  const b = save({ clock: { day: 40, minuteOfDay: 0 }, economy: { cash: 700 + 30 * 400, savings: 100, debt: 0 } });
  assert.equal(validate(a, b).ok, true);
});

test("skills cannot jump", () => {
  const a = save();
  const b = save({ skills: { points: { programming: 100, communication: 12 } } });
  assert.match(validate(a, b).reasons.join(), /skill programming/);
});

test("skills out of range / NaN", () => {
  assert.equal(validate(save(), save({ skills: { points: { x: 400 } } })).ok, false);
  assert.equal(validate(save(), save({ economy: { cash: "lots", savings: 0, debt: 0 } })).ok, false);
});

test("negative values rejected", () => {
  assert.equal(validate(save(), save({ economy: { cash: 5, savings: -1, debt: 0 } })).ok, false);
  assert.equal(validate(save(), save({ economy: { cash: 5, savings: 0, debt: -20 } })).ok, false);
});

test("time cannot move backwards", () => {
  assert.match(validate(save(), save({ clock: { day: 3, minuteOfDay: 0 } })).reasons.join(), /backwards/);
});

test("certificate requires a completed degree", () => {
  const b = save({ certificates: [{ degreeId: "deg_cs" }] });
  assert.match(validate(save(), b).reasons.join(), /certificate/);
  const ok = save({
    certificates: [{ degreeId: "deg_cs" }],
    university: { courses: { a: { passed: true } }, completedDegrees: ["deg_cs"], associateEarned: [] },
    avatar: { educationLevel: "bachelor" },
  });
  const prev = save({ university: { courses: {}, completedDegrees: [], associateEarned: [] } });
  assert.equal(validate(prev, ok).ok, true);
});

test("education level cannot be raised without degrees", () => {
  const b = save({ avatar: { educationLevel: "doctorate" } });
  assert.match(validate(save(), b).reasons.join(), /education/);
});

test("degree needs passed courses", () => {
  const b = save({
    university: { courses: {}, completedDegrees: ["deg_law"], associateEarned: [] },
    avatar: { educationLevel: "master" },
  });
  assert.match(validate(save(), b).reasons.join(), /degree without passing/);
});

test("promotion speed is bounded", () => {
  const job = (rank) => ({ contract: { rank } });
  const a = save({ job: job(0) });
  assert.equal(validate(a, save({ job: job(1), clock: { day: 20, minuteOfDay: 0 } })).ok, true);
  assert.match(validate(a, save({ job: job(5), clock: { day: 11, minuteOfDay: 0 } })).reasons.join(), /promoted too quickly/);
});

test("company cash counts as wealth", () => {
  const b = save({ company: { cash: 50_000_000 } });
  assert.equal(validate(save(), b).ok, false);
});

test("garbage input is rejected safely", () => {
  assert.equal(validate(save(), null).ok, false);
  assert.equal(decide(null, { data: "{not json" }).action, "reject");
  assert.ok(LIMITS.maxWealthPerDay > 386);
});
