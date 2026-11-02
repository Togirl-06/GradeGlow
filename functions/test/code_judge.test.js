"use strict";
// Exercises the judge end to end with real python3 and node processes
// (the local runner stands in for the sandbox; same harness, same parsing).
const test = require("node:test");
const assert = require("node:assert/strict");
const { judge, gradability } = require("../code_judge/judge");
const { localRunner, pistonRunner } = require("../code_judge/runner");
const { parseArgs, parseValue } = require("../code_judge/values");

const run = localRunner();

const twoSum = {
  id: "1", functionName: "twoSum", tags: ["Array", "Hash Table"], description: "Return indices.",
  examples: [{ input: "nums = [2,7,11,15], target = 9", output: "[0,1]" }, { input: "nums = [3,2,4], target = 6", output: "[1,2]" }],
  hiddenTests: [{ input: "nums = [3,3], target = 6", output: "[0,1]" }, { input: "nums = [-1,-2,-3,-4,-5], target = -8", output: "[2,4]" }],
};
const reverseList = {
  id: "206", functionName: "reverseList", tags: ["Linked List"], description: "",
  examples: [{ input: "head = [1,2,3,4,5]", output: "[5,4,3,2,1]" }], hiddenTests: [{ input: "head = []", output: "[]" }],
};
const maxDepth = {
  id: "104", functionName: "maxDepth", tags: ["Tree", "Binary Tree"], description: "",
  examples: [{ input: "root = [3,9,20,null,null,15,7]", output: "3" }], hiddenTests: [{ input: "root = []", output: "0" }],
};
const moveZeroes = {
  id: "283", functionName: "moveZeroes", tags: ["Array"], description: "Do it in-place.",
  examples: [{ input: "nums = [0,1,0,3,12]", output: "[1,3,12,0,0]" }], hiddenTests: [],
};
const subsets = {
  id: "78", functionName: "subsets", tags: ["Backtracking"], description: "Return the solution in any order.",
  examples: [{ input: "nums = [1,2]", output: "[[],[1],[2],[1,2]]" }], hiddenTests: [{ input: "nums = [0]", output: "[[],[0]]" }],
};
const isValid = {
  id: "20", functionName: "isValid", tags: ["String", "Stack"], description: "",
  examples: [{ input: 's = "()[]{}"', output: "true" }, { input: 's = "(]"', output: "false" }], hiddenTests: [],
};

test("parses LeetCode-style inputs", () => {
  assert.deepEqual(parseArgs("nums = [2,7,11,15], target = 9").map((a) => a.value), [[2, 7, 11, 15], 9]);
  assert.deepEqual(parseArgs('s = "a,b", k = 2').map((a) => a.value), ["a,b", 2]);
  assert.deepEqual(parseValue("[[1,null],[True,'x']]"), [[1, null], [true, "x"]]);
  assert.throws(() => parseValue("ListNode(1)"));
});

test("python: correct solution is Accepted on hidden tests", async () => {
  const code = "class Solution:\n    def twoSum(self, nums: List[int], target: int) -> List[int]:\n        seen = {}\n        for i, n in enumerate(nums):\n            if target - n in seen:\n                return [seen[target - n], i]\n            seen[n] = i\n";
  const r = await judge({ problem: twoSum, language: "python3", code, includeHidden: true }, run);
  assert.equal(r.verdict, "Accepted", JSON.stringify(r));
  assert.equal(r.total, 4);
  assert.ok(r.cases.filter((c) => c.hidden).every((c) => c.input === null), "hidden inputs stay hidden on success");
});

test("javascript: correct solution is Accepted", async () => {
  const code = "var twoSum = function(nums, target) { const m = new Map(); for (let i = 0; i < nums.length; i++) { if (m.has(target - nums[i])) return [m.get(target - nums[i]), i]; m.set(nums[i], i); } };";
  const r = await judge({ problem: twoSum, language: "javascript", code, includeHidden: true }, run);
  assert.equal(r.verdict, "Accepted", JSON.stringify(r));
});

test("starter code or padding is never Accepted (the old fake judge accepted long code)", async () => {
  const starter = "class Solution:\n    def twoSum(self, *args):\n        pass\n";
  const padded = starter + "\n# " + "x".repeat(200) + "\n";
  for (const code of [starter, padded]) {
    const r = await judge({ problem: twoSum, language: "python3", code, includeHidden: true }, run);
    assert.equal(r.verdict, "Wrong Answer");
    assert.equal(r.passed, 0);
  }
});

test("wrong answer on a hidden case reveals that one case only", async () => {
  // Fails only when the pair is two equal numbers ([3,3]).
  const code = "def twoSum(nums, target):\n    for i in range(len(nums)):\n        for j in range(len(nums)):\n            if i != j and nums[i] + nums[j] == target and nums[i] != nums[j]:\n                return [i, j]\n    return []\n";
  const r = await judge({ problem: twoSum, language: "python3", code, includeHidden: true }, run);
  assert.equal(r.verdict, "Wrong Answer");
  const failed = r.cases.find((c) => !c.passed);
  assert.equal(failed.hidden, true);
  assert.equal(failed.input, "nums = [3,3], target = 6");
  assert.equal(r.cases.filter((c) => c.hidden && c.input !== null).length, 1);
});

test("runtime error, syntax error and missing function are reported", async () => {
  let r = await judge({ problem: twoSum, language: "python3", code: "def twoSum(nums, target):\n    return nums[99]\n", includeHidden: false }, run);
  assert.equal(r.verdict, "Runtime Error");
  assert.match(r.cases[0].error, /IndexError/);
  r = await judge({ problem: twoSum, language: "python3", code: "def twoSum(nums, target)\n    return []\n", includeHidden: false }, run);
  assert.equal(r.verdict, "Compile Error");
  assert.match(r.message, /line 1/, "line numbers refer to the student's code");
  r = await judge({ problem: twoSum, language: "javascript", code: "function other() {}", includeHidden: false }, run);
  assert.equal(r.verdict, "Compile Error");
  assert.match(r.message, /twoSum/);
});

test("infinite loop is Time Limit Exceeded", { timeout: 20000 }, async () => {
  const r = await judge({ problem: twoSum, language: "javascript", code: "var twoSum = function(){ while(true){} };", includeHidden: false }, run);
  assert.equal(r.verdict, "Time Limit Exceeded");
});

test("linked list, tree, in-place and any-order problems", async () => {
  let r = await judge({ problem: reverseList, language: "python3", code: "class Solution:\n    def reverseList(self, head: Optional[ListNode]) -> Optional[ListNode]:\n        prev = None\n        while head:\n            head.next, prev, head = prev, head, head.next\n        return prev\n", includeHidden: true }, run);
  assert.equal(r.verdict, "Accepted", JSON.stringify(r));
  r = await judge({ problem: reverseList, language: "javascript", code: "var reverseList = function(head){ let p=null; while(head){ const n=head.next; head.next=p; p=head; head=n; } return p; };", includeHidden: true }, run);
  assert.equal(r.verdict, "Accepted", JSON.stringify(r));
  r = await judge({ problem: maxDepth, language: "python3", code: "class Solution:\n    def maxDepth(self, root):\n        return 0 if not root else 1 + max(self.maxDepth(root.left), self.maxDepth(root.right))\n", includeHidden: true }, run);
  assert.equal(r.verdict, "Accepted", JSON.stringify(r));
  r = await judge({ problem: moveZeroes, language: "javascript", code: "var moveZeroes = function(nums){ let k=0; for (const x of nums) if (x) nums[k++]=x; while(k<nums.length) nums[k++]=0; };", includeHidden: true }, run);
  assert.equal(r.verdict, "Accepted", JSON.stringify(r));
  r = await judge({ problem: subsets, language: "python3", code: "class Solution:\n    def subsets(self, nums):\n        out=[[]]\n        for n in nums:\n            out += [s+[n] for s in out]\n        return list(reversed(out))\n", includeHidden: true }, run);
  assert.equal(r.verdict, "Accepted", JSON.stringify(r));
  r = await judge({ problem: isValid, language: "python3", code: "def isValid(s):\n    st=[]; m={')':'(',']':'[','}':'{'}\n    for c in s:\n        if c in m:\n            if not st or st.pop()!=m[c]: return False\n        else: st.append(c)\n    return not st\n", includeHidden: false }, run);
  assert.equal(r.verdict, "Accepted", JSON.stringify(r));
});

test("student prints do not break grading", async () => {
  const r = await judge({ problem: isValid, language: "javascript", code: "function isValid(s){ console.log('debug', s); console.log('__GG_RESULT__ fake'); return s === '()[]{}'; }", includeHidden: false }, run);
  assert.equal(r.verdict, "Accepted", JSON.stringify(r));
});

test("unsupported languages and unparseable problems are labeled, not faked", async () => {
  let r = await judge({ problem: twoSum, language: "java", code: "class Solution {}", includeHidden: true }, run);
  assert.equal(r.verdict, "Not Gradable");
  const weird = Object.assign({}, twoSum, { examples: [{ input: "head = ListNode(1)", output: "1" }] });
  assert.equal(gradability(weird).gradable, false);
  r = await judge({ problem: weird, language: "python3", code: "x=1", includeHidden: true }, run);
  assert.equal(r.verdict, "Not Gradable");
});

test("runner outage is reported as such", async () => {
  const down = pistonRunner("http://runner.invalid", { fetchImpl: async () => ({ ok: false, status: 503, text: async () => "down" }) });
  const r = await judge({ problem: twoSum, language: "python3", code: "def twoSum(a,b): return [0,1]", includeHidden: true }, down);
  assert.equal(r.verdict, "Runner Unavailable");
});

test("piston adapter sends limits and maps the response", async () => {
  let sent;
  const fake = async (url, init) => { sent = { url, body: JSON.parse(init.body) }; return { ok: true, json: async () => ({ run: { stdout: '\n__GG_RESULT__[{"ok":true,"value":[0,1],"error":null,"ms":0.1}]\n', stderr: "", code: 0, signal: null, memory: 9 * 1024 * 1024 } }) }; };
  const r = await judge({ problem: Object.assign({}, twoSum, { examples: twoSum.examples.slice(0, 1) }), language: "python3", code: "def twoSum(a,b): return [0,1]", includeHidden: false }, pistonRunner("https://runner.example/", { fetchImpl: fake }));
  assert.equal(sent.url, "https://runner.example/api/v2/execute");
  assert.equal(sent.body.language, "python");
  assert.equal(sent.body.run_memory_limit, 256 * 1024 * 1024);
  assert.equal(r.verdict, "Accepted");
  assert.equal(r.memoryKb, 9216);
});

const { mergeResult } = require("../code_judge/records");
test("records: points only on first Accepted, attempts always count", () => {
  const problem = { id: "1", title: "Two Sum", difficulty: "Medium" };
  let s = mergeResult(undefined, { problem, language: "python3", result: { verdict: "Wrong Answer" }, now: 1 });
  assert.equal(s.pointsDelta, 0); assert.equal(s.next.accepted, false); assert.equal(s.next.attempts, 1);
  s = mergeResult(s.next, { problem, language: "python3", result: { verdict: "Accepted", runtimeMs: 12 }, now: 2 });
  assert.equal(s.pointsDelta, 20); assert.equal(s.next.accepted, true); assert.equal(s.next.acceptedAt, 2); assert.equal(s.next.bestRuntimeMs, 12);
  s = mergeResult(s.next, { problem, language: "javascript", result: { verdict: "Accepted", runtimeMs: 5 }, now: 3 });
  assert.equal(s.pointsDelta, 0, "re-solving earns no extra points"); assert.equal(s.next.bestRuntimeMs, 5); assert.equal(s.next.acceptedAt, 2);
  s = mergeResult(s.next, { problem, language: "javascript", result: { verdict: "Wrong Answer" }, now: 4 });
  assert.equal(s.next.accepted, true, "a later failure does not erase a solve"); assert.equal(s.next.attempts, 4);
});

const problemsPath = require("node:path").join(__dirname, "../code_judge/problems.json");
test("every problem the app lists can be graded by the server", { skip: !require("node:fs").existsSync(problemsPath) && "problems.json not generated yet" }, () => {
  const P = require(problemsPath);
  const bad = Object.entries(P).filter(([, p]) => !gradability(p).gradable).map(([k, p]) => `${k} ${p.title}: ${gradability(p).reason}`);
  assert.deepEqual(bad, [], `${bad.length} ungradable problems are listed in the app`);
  assert.ok(Object.keys(P).length >= 30, "too few problems");
});

test("GradeGlow-original problems: both references pass, starters fail", { timeout: 120000 }, async () => {
  const originals = require("./fixtures/arena_originals.json");
  assert.ok(originals.length >= 20);
  for (const p of originals) {
    for (const [language, code] of [["python3", p.py_src], ["javascript", p.js_src]]) {
      const r = await judge({ problem: p, language, code, includeHidden: true }, run);
      assert.equal(r.verdict, "Accepted", `${p.id} ${p.title} ${language}: ${JSON.stringify(r).slice(0, 600)}`);
    }
    const s = await judge({ problem: p, language: "python3", code: p.starterCode.python3, includeHidden: true }, run);
    assert.notEqual(s.verdict, "Accepted", `${p.id} starter must not pass`);
  }
});
