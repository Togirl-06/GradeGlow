// Every SQL and program answer key in the practical labs must be what a
// reference solution actually produces, in the same SQLite / Python the app uses.
const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

require(path.join(__dirname, "../../web/code_runner/gg_judge.js"));
const { createRunner } = require(path.join(__dirname, "../../web/code_runner/runner_core.js"));
const refs = require("./fixtures/career_lab_refs.json");
const stepsPath = path.join(__dirname, "../../build/career_lab_steps.json");

// Same cell format as SqlStep.rowKeys in Dart.
function cell(v) {
  if (typeof v === "number") return Number.isInteger(v) ? String(v) : (Math.round(v) === v ? String(v) : v.toFixed(4));
  return v === null ? "NULL" : String(v);
}
const keys = (rows) => rows.map((r) => r.map(cell).join("|"));

const runner = createRunner({
  judgeLib: globalThis.GGJudge,
  loadPyodide: () => require("pyodide").loadPyodide(),
  initSqlJs: () => require("sql.js")(),
});

test("lab answer keys match reference solutions", { skip: !fs.existsSync(stepsPath) && "run flutter test first", timeout: 120000 }, async () => {
  const steps = JSON.parse(fs.readFileSync(stepsPath, "utf8"));
  for (const s of steps.sql) {
    assert.ok(refs.sql[s.id], `no reference query for ${s.id}`);
    const r = await runner.runSql({ setup: s.setup, statements: refs.sql[s.id], check: s.check || undefined });
    assert.equal(r.ok, true, `${s.id}: ${r.error}`);
    const got = keys((s.check ? r.check : r.result).rows);
    const want = s.expected;
    if (s.ordered) assert.deepEqual(got, want, s.id);
    else assert.deepEqual([...got].sort(), [...want].sort(), s.id);
    if (s.starter) {
      const b = await runner.runSql({ setup: s.setup, statements: s.starter, check: s.check || undefined });
      const bk = b.ok ? keys((s.check ? b.check : b.result).rows) : [];
      assert.notDeepEqual([...bk].sort(), [...want].sort(), `${s.id}: the broken starter already gives the right answer`);
    }
  }
  for (const p of steps.programs) {
    assert.ok(refs.programs[p.id], `no reference program for ${p.id}`);
    for (const c of p.cases) {
      const out = await runner.runProgram({ language: "python3", code: refs.programs[p.id], stdin: c.stdin });
      assert.equal(out.ok, true, out.stderr);
      assert.equal(out.stdout.trim(), c.expected.trim(), `${p.id} input ${JSON.stringify(c.stdin)}`);
    }
  }
});
