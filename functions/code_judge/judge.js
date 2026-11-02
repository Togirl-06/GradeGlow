"use strict";
// Grades one submission. Pure logic: the sandbox runner is injected.
//
// Verdicts (LeetCode vocabulary):
//   Accepted | Wrong Answer | Runtime Error | Time Limit Exceeded |
//   Memory Limit Exceeded | Compile Error | Not Gradable | Runner Unavailable

const { parseArgs, parseValue, argKinds } = require("./values");
const { equal, equalUnordered, anyOrder } = require("./compare");
const { buildProgram, readResults, SUPPORTED, PY_PRELUDE } = require("./harness");
const { LIMITS } = require("./runner");

/** Turn the problem's text cases into runnable cases. Throws ParseError if any case is unparseable. */
function compileCases(problem, { includeHidden }) {
  const examples = (problem.examples || []).map((e) => ({ input: e.input, output: e.output, hidden: false }));
  const hidden = includeHidden ? (problem.hiddenTests || []).map((e) => ({ input: e.input, output: e.output, hidden: true })) : [];
  return examples.concat(hidden).map((c) => {
    const args = parseArgs(c.input);
    return { input: c.input, hidden: c.hidden, args: args.map((a) => a.value), kinds: argKinds(problem, args), expected: parseValue(c.output), expectedText: c.output };
  });
}

/** Whether every case of a problem can be parsed (used to label problems in the app). */
function gradability(problem) {
  try { const n = compileCases(problem, { includeHidden: true }).length; return n > 0 ? { gradable: true, cases: n } : { gradable: false, reason: "No test cases." }; }
  catch (e) { return { gradable: false, reason: e.message }; }
}

function shiftPythonLines(text) {
  const offset = PY_PRELUDE.split("\n").length;
  return String(text || "").replace(/line (\d+)/g, (m, n) => `line ${Math.max(1, Number(n) - offset)}`)
    .replace(/File "[^"]*main\.py"/g, 'File "solution.py"');
}

function preview(v) { const s = JSON.stringify(v); return s === undefined ? "null" : s.length > 300 ? s.slice(0, 300) + "…" : s; }

/**
 * @param {{problem:object, language:string, code:string, includeHidden:boolean}} sub
 * @param {(job)=>Promise<object>} run sandbox runner
 */
async function judge({ problem, language, code, includeHidden }, run) {
  const base = { problemId: problem.id, language, mode: includeHidden ? "submit" : "run" };
  if (!SUPPORTED[language]) return Object.assign(base, { verdict: "Not Gradable", message: `${language} submissions are not graded yet. Use Python 3 or JavaScript.`, cases: [] });
  if (typeof code !== "string" || !code.trim()) return Object.assign(base, { verdict: "Compile Error", message: "Write a solution first.", cases: [] });
  if (Buffer.byteLength(code, "utf8") > LIMITS.maxCodeBytes) return Object.assign(base, { verdict: "Compile Error", message: "Code is larger than 64 KB.", cases: [] });

  let cases;
  try { cases = compileCases(problem, { includeHidden }); }
  catch (e) { return Object.assign(base, { verdict: "Not Gradable", message: "This problem's tests can't be graded automatically yet.", cases: [] }); }
  if (!cases.length) return Object.assign(base, { verdict: "Not Gradable", message: "This problem has no test cases.", cases: [] });

  const program = buildProgram(language, code, problem.functionName);
  let out;
  try {
    out = await run(Object.assign({}, program, { stdin: JSON.stringify(cases.map((c) => ({ args: c.args, kinds: c.kinds }))) }));
  } catch (e) {
    return Object.assign(base, { verdict: "Runner Unavailable", message: "The code runner could not be reached. Your submission was not graded.", cases: [] });
  }
  const isPy = program.language === "python";
  const stderr = isPy ? shiftPythonLines(out.stderr) : String(out.stderr || "");
  const results = readResults(out.stdout);

  if (out.timedOut) return Object.assign(base, { verdict: "Time Limit Exceeded", message: `Your program ran longer than ${LIMITS.runTimeoutMs / 1000} seconds for all test cases together.`, cases: [], stderr: stderr.slice(0, 2000) });
  if (out.outOfMemory) return Object.assign(base, { verdict: "Memory Limit Exceeded", message: "Your program used more than 256 MB.", cases: [], stderr: stderr.slice(0, 2000) });
  if (!results) {
    const syntax = /SyntaxError|IndentationError|ReferenceError|TabError|NameError/.test(stderr);
    return Object.assign(base, { verdict: syntax ? "Compile Error" : "Runtime Error", message: stderr.split("\n").filter(Boolean).slice(-6).join("\n") || "Your program exited without producing results.", cases: [], stderr: stderr.slice(0, 2000) });
  }
  if (results.fatal) return Object.assign(base, { verdict: "Compile Error", message: results.fatal, cases: [] });

  const unordered = anyOrder(problem);
  let verdict = "Accepted", firstFail = null; let totalMs = 0;
  const rows = cases.map((c, i) => {
    const r = results[i] || { ok: false, error: "No result", value: null, ms: 0 };
    totalMs += r.ms || 0;
    // An empty linked list / tree is written [] in the bank but returned as null/None.
    if (r.ok && r.value === null && Array.isArray(c.expected) && c.expected.length === 0 && c.kinds.some((k) => k !== "plain")) r.value = [];
    const passed = r.ok && (unordered ? equalUnordered(r.value, c.expected) : equal(r.value, c.expected));
    if (!passed && verdict === "Accepted") { verdict = r.ok ? "Wrong Answer" : "Runtime Error"; firstFail = i; }
    return { index: i + 1, hidden: c.hidden, passed, ms: Math.round((r.ms || 0) * 100) / 100,
      input: c.hidden ? null : c.input, expected: c.hidden ? null : c.expectedText, output: c.hidden ? null : (r.ok ? preview(r.value) : null), error: r.error || null };
  });
  // On failure of a hidden case, reveal that one case (LeetCode does the same) so the student can fix it.
  if (firstFail !== null && cases[firstFail].hidden) {
    const c = cases[firstFail], r = results[firstFail] || {};
    Object.assign(rows[firstFail], { input: c.input, expected: c.expectedText, output: r.ok ? preview(r.value) : null });
  }
  const passedCount = rows.filter((r) => r.passed).length;
  return Object.assign(base, {
    verdict,
    message: verdict === "Accepted" ? `All ${rows.length} test cases passed.` : `${passedCount} of ${rows.length} test cases passed.`,
    passed: passedCount, total: rows.length,
    runtimeMs: Math.round(totalMs * 100) / 100,
    memoryKb: out.memoryBytes ? Math.round(out.memoryBytes / 1024) : null,
    cases: rows,
    stderr: stderr ? stderr.slice(0, 2000) : "",
  });
}

module.exports = { judge, compileCases, gradability };
