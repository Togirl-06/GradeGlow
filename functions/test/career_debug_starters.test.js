// The career simulator's bug-fix tasks must start from code that is really
// broken, and must be fixable. Runs every exported starter, and a reference
// fix kept only in this test fixture, through the server's own harness.
const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const { judge } = require("../code_judge/judge");
const { localRunner } = require("../code_judge/runner");

const startersPath = path.join(__dirname, "../../build/career_debug_starters.json");
const problems = require("../code_judge/problems.json");
const fixes = require("./fixtures/career_bugfix_refs.json");

test("career simulator bug-fix starters fail the hidden tests; reference fixes pass", { skip: !fs.existsSync(startersPath) && "run flutter test first" }, async () => {
  const starters = JSON.parse(fs.readFileSync(startersPath, "utf8"));
  const run = localRunner();
  const problemsSeen = new Set();
  const failures = [];
  for (const s of starters) {
    const problem = problems[s.key];
    if (!problem) { failures.push(`${s.key} missing from problems.json`); continue; }
    const r = await judge({ problem, language: s.language, code: s.code, includeHidden: true }, run);
    if (r.verdict !== "Wrong Answer") failures.push(`${s.task} (${s.language}): expected Wrong Answer, got ${r.verdict} ${r.message}`);
    problemsSeen.add(s.key);
  }
  for (const key of problemsSeen) {
    assert.ok(fixes[key], `no reference fix for ${key}`);
    const r = await judge({ problem: problems[key], language: "python3", code: fixes[key], includeHidden: true }, run);
    if (r.verdict !== "Accepted") failures.push(`${key}: reference fix got ${r.verdict}`);
  }
  assert.deepEqual(failures, []);
});
