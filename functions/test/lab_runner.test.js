// The in-app lab runner (web/code_runner) executes real Python (Pyodide),
// JavaScript and SQL (sql.js) on the student's device and grades with the
// server judge's own harness. These tests run that exact code in Node.
const test = require("node:test");
const assert = require("node:assert/strict");
const path = require("node:path");
const fs = require("node:fs");

require(path.join(__dirname, "../../web/code_runner/gg_judge.js"));
const { createRunner, handle } = require(path.join(__dirname, "../../web/code_runner/runner_core.js"));
const { build, out } = require(path.join(__dirname, "../../tool/build_code_runner.js"));
const { judge: serverJudge } = require("../code_judge/judge");
const { localRunner } = require("../code_judge/runner");

const problems = require("../code_judge/problems.json");

let running = 0;
const runner = createRunner({
  judgeLib: globalThis.GGJudge,
  loadPyodide: () => require("pyodide").loadPyodide(),
  initSqlJs: () => require("sql.js")(),
  onRunning: () => { running++; },
});

const pairSumPy = `class Solution:
    def pairSum(self, nums, target):
        seen = {}
        for i, x in enumerate(nums):
            if target - x in seen:
                return [seen[target - x], i]
            seen[x] = i
        return []
`;
const pairSumJs = `var pairSum = function(nums, target) {
  const seen = new Map();
  for (let i = 0; i < nums.length; i++) {
    if (seen.has(target - nums[i])) return [seen.get(target - nums[i]), i];
    seen.set(nums[i], i);
  }
  return [];
};`;

test("bundled judge is up to date with functions/code_judge", () => {
  assert.equal(fs.readFileSync(out, "utf8"), build(), "run: node tool/build_code_runner.js");
});

test("Python runs in Pyodide and is graded with the server's rules", { timeout: 120000 }, async () => {
  const p = problems["impl:GGO-001"];
  const ok = await runner.judge({ problem: p, language: "python3", code: pairSumPy, includeHidden: true });
  assert.equal(ok.verdict, "Accepted", ok.message);
  const server = await serverJudge({ problem: p, language: "python3", code: pairSumPy, includeHidden: true }, localRunner());
  assert.equal(ok.total, server.total);

  const wrong = await runner.judge({ problem: p, language: "python3", code: "class Solution:\n    def pairSum(self, nums, target):\n        return [0, 1]\n", includeHidden: true });
  assert.equal(wrong.verdict, "Wrong Answer");

  const crash = await runner.judge({ problem: p, language: "python3", code: "class Solution:\n    def pairSum(self, nums, target):\n        return nums[99999]\n", includeHidden: false });
  assert.equal(crash.verdict, "Runtime Error");
  assert.match(crash.cases.find((c) => !c.passed).error, /IndexError/);

  const syntax = await runner.judge({ problem: p, language: "python3", code: "class Solution:\n    def pairSum(self, nums, target)\n        return []\n", includeHidden: false });
  assert.equal(syntax.verdict, "Compile Error");
  assert.match(syntax.message, /SyntaxError/);
  assert.ok(running > 0, "the time limit starts only when student code runs");
});

test("JavaScript runs and is graded", async () => {
  const p = problems["impl:GGO-001"];
  const ok = await runner.judge({ problem: p, language: "javascript", code: pairSumJs, includeHidden: true });
  assert.equal(ok.verdict, "Accepted", ok.message);
  const bad = await runner.judge({ problem: p, language: "javascript", code: "var pairSum = function(nums, target) { return [0, 1 };", includeHidden: false });
  assert.equal(bad.verdict, "Compile Error");
});

test("bug-fix starters fail in the app runner exactly as on the server", { timeout: 120000 }, async () => {
  const startersPath = path.join(__dirname, "../../build/career_debug_starters.json");
  if (!fs.existsSync(startersPath)) return;
  for (const s of JSON.parse(fs.readFileSync(startersPath, "utf8"))) {
    const r = await runner.judge({ problem: problems[s.key], language: s.language, code: s.code, includeHidden: true });
    assert.equal(r.verdict, "Wrong Answer", `${s.task} ${s.language}`);
  }
});

test("programs print output and read stdin", { timeout: 120000 }, async () => {
  const py = await handle(runner, { op: "program", language: "python3", code: "name = input()\nprint('Hello,', name)\nprint(sum(range(5)))", stdin: "Ada\n" });
  assert.equal(py.ok, true, py.stderr);
  assert.equal(py.stdout, "Hello, Ada\n10\n");
  const pyErr = await handle(runner, { op: "program", language: "python3", code: "print(1/0)" });
  assert.equal(pyErr.ok, false);
  assert.match(pyErr.stderr, /ZeroDivisionError/);
  const big = await handle(runner, { op: "program", language: "python3", code: "import sys\nprint(len(sys.stdin.read()))", stdin: "x".repeat(20000) });
  assert.equal(big.stdout, "20000\n", "large inputs (hidden tests) reach Python intact");
  const js = await handle(runner, { op: "program", language: "javascript", code: "console.log('sum', [1,2,3].reduce((a,b)=>a+b))" });
  assert.equal(js.stdout, "sum 6\n");
});

test("SQL runs against a fresh SQLite database each time", async () => {
  const setup = "CREATE TABLE students(id INTEGER PRIMARY KEY, name TEXT, major TEXT); INSERT INTO students VALUES (1,'Ada','CS'),(2,'Ben','Law'),(3,'Cy','CS');";
  const r = await handle(runner, { op: "sql", setup, statements: "SELECT name FROM students WHERE major = 'CS' ORDER BY name;" });
  assert.deepEqual(r.result, { columns: ["name"], rows: [["Ada"], ["Cy"]] });
  const dml = await handle(runner, { op: "sql", setup, statements: "UPDATE students SET major = 'CS' WHERE id = 2;", check: "SELECT COUNT(*) FROM students WHERE major = 'CS';" });
  assert.equal(dml.changes, 1);
  assert.deepEqual(dml.check.rows, [[3]]);
  const again = await handle(runner, { op: "sql", setup, statements: "SELECT COUNT(*) FROM students WHERE major = 'CS';" });
  assert.deepEqual(again.result.rows, [[2]], "each run starts from the lab's own data");
  const err = await handle(runner, { op: "sql", setup, statements: "SELEC name FROM students;" });
  assert.equal(err.ok, false);
  assert.match(err.error, /syntax error/);
});
