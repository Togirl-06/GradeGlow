"use strict";
// Builds the program that runs inside the sandbox. The student's code is
// placed first, then a driver reads the test cases from stdin, calls the
// target function for each case, and prints exactly one line:
//   __GG_RESULT__<json array of {ok, value, error, ms}>
// so anything the student prints themselves is ignored.

const MARKER = "__GG_RESULT__";

/** Languages the judge can actually execute and grade. */
const SUPPORTED = {
  python3: { piston: "python", label: "Python 3" },
  python: { piston: "python", label: "Python" },
  javascript: { piston: "javascript", label: "JavaScript" },
};

function jsDriver(fn) {
  return `
;(function __ggMain() {
  class ListNode { constructor(val, next) { this.val = val === undefined ? 0 : val; this.next = next === undefined ? null : next; } }
  class TreeNode { constructor(val, left, right) { this.val = val === undefined ? 0 : val; this.left = left || null; this.right = right || null; } }
  globalThis.ListNode = globalThis.ListNode || ListNode; globalThis.TreeNode = globalThis.TreeNode || TreeNode;
  const toList = (a) => { let h = null; for (let i = a.length - 1; i >= 0; i--) h = new globalThis.ListNode(a[i], h); return h; };
  const toTree = (a) => { if (!a.length || a[0] === null) return null; const r = new globalThis.TreeNode(a[0]); const q = [r]; let i = 1;
    while (q.length && i < a.length) { const n = q.shift(); if (i < a.length && a[i] !== null) { n.left = new globalThis.TreeNode(a[i]); q.push(n.left); } i++;
      if (i < a.length && a[i] !== null) { n.right = new globalThis.TreeNode(a[i]); q.push(n.right); } i++; } return r; };
  const out = (v, seen) => {
    if (v && typeof v === 'object' && 'val' in v && ('next' in v)) { const a = []; let n = v, k = 0; while (n && k++ < 100000) { a.push(n.val); n = n.next; } return a; }
    if (v && typeof v === 'object' && 'val' in v && ('left' in v || 'right' in v)) { const a = []; const q = [v];
      while (q.length) { const n = q.shift(); if (n) { a.push(n.val); q.push(n.left || null, n.right || null); } else a.push(null); }
      while (a.length && a[a.length - 1] === null) a.pop(); return a; }
    if (v instanceof Set) return [...v]; if (v instanceof Map) return Object.fromEntries(v);
    if (typeof v === 'number' && !isFinite(v)) return null;
    return v === undefined ? null : v;
  };
  let target = null;
  try { target = eval(${JSON.stringify(fn)}); } catch (e) {}
  if (typeof target !== 'function') { try { if (typeof Solution === 'function') { const s = new Solution(); if (typeof s[${JSON.stringify(fn)}] === 'function') target = s[${JSON.stringify(fn)}].bind(s); } } catch (e) {} }
  if (typeof target !== 'function') { process.stdout.write('\\n${MARKER}' + JSON.stringify({ fatal: 'Define a function named ${fn}.' }) + '\\n'); return; }
  const tests = JSON.parse(require('fs').readFileSync(0, 'utf8'));
  const res = [];
  for (const t of tests) {
    const args = t.args.map((a, i) => t.kinds[i] === 'list' ? toList(a) : t.kinds[i] === 'tree' ? toTree(a) : a);
    const t0 = process.hrtime.bigint(); let value = null, error = null;
    try { const r = target(...args); value = (r === undefined && Array.isArray(args[0])) ? args[0] : out(r); }
    catch (e) { error = (e && e.name ? e.name + ': ' : '') + (e && e.message || String(e)); }
    const ms = Number(process.hrtime.bigint() - t0) / 1e6;
    let ser; try { ser = JSON.parse(JSON.stringify(value)); } catch (e) { ser = null; error = error || 'Return value is not serializable'; }
    res.push({ ok: !error, value: ser, error, ms });
  }
  process.stdout.write('\\n${MARKER}' + JSON.stringify(res) + '\\n');
})();
`;
}

const PY_PRELUDE = `from typing import *
import collections, heapq, bisect, math, functools, itertools, string, re
from collections import deque, defaultdict, Counter, OrderedDict
from functools import lru_cache, cache, reduce
from heapq import heappush, heappop, heapify
from bisect import bisect_left, bisect_right
from math import inf
class ListNode:
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next
class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right
`;

function pyDriver(fn) {
  return `

import sys as __gg_sys, json as __gg_json, time as __gg_time
def __gg_to_list(a):
    h = None
    for v in reversed(a):
        h = ListNode(v, h)
    return h
def __gg_to_tree(a):
    if not a or a[0] is None:
        return None
    r = TreeNode(a[0]); q = [r]; i = 1
    while q and i < len(a):
        n = q.pop(0)
        if i < len(a) and a[i] is not None:
            n.left = TreeNode(a[i]); q.append(n.left)
        i += 1
        if i < len(a) and a[i] is not None:
            n.right = TreeNode(a[i]); q.append(n.right)
        i += 1
    return r
def __gg_out(v):
    if hasattr(v, 'val') and hasattr(v, 'next'):
        a = []; k = 0
        while v is not None and k < 100000:
            a.append(v.val); v = v.next; k += 1
        return a
    if hasattr(v, 'val') and (hasattr(v, 'left') or hasattr(v, 'right')):
        a = []; q = [v]
        while q:
            n = q.pop(0)
            if n is not None:
                a.append(n.val); q.append(getattr(n, 'left', None)); q.append(getattr(n, 'right', None))
            else:
                a.append(None)
        while a and a[-1] is None:
            a.pop()
        return a
    if isinstance(v, (set, frozenset, tuple)):
        return [__gg_out(x) for x in v]
    if isinstance(v, list):
        return [__gg_out(x) for x in v]
    if isinstance(v, float) and (v != v or v in (float('inf'), float('-inf'))):
        return None
    return v
def __gg_main():
    target = None
    if 'Solution' in globals():
        try:
            target = getattr(globals()['Solution'](), ${JSON.stringify(fn)}, None)
        except Exception:
            target = None
    if target is None and callable(globals().get(${JSON.stringify(fn)})):
        target = globals()[${JSON.stringify(fn)}]
    if target is None:
        print('\\n${MARKER}' + __gg_json.dumps({'fatal': 'Define ${fn} (inside class Solution or as a function).'}))
        return
    tests = __gg_json.loads(__gg_sys.stdin.read())
    res = []
    for t in tests:
        args = [__gg_to_list(a) if k == 'list' else __gg_to_tree(a) if k == 'tree' else a for a, k in zip(t['args'], t['kinds'])]
        t0 = __gg_time.perf_counter(); value = None; error = None
        try:
            r = target(*args)
            value = args[0] if (r is None and args and isinstance(args[0], list)) else __gg_out(r)
        except Exception as e:
            error = type(e).__name__ + ': ' + str(e)
        ms = (__gg_time.perf_counter() - t0) * 1000
        try:
            __gg_json.dumps(value)
        except Exception:
            value = None; error = error or 'Return value is not serializable'
        res.append({'ok': error is None, 'value': value, 'error': error, 'ms': ms})
    print('\\n${MARKER}' + __gg_json.dumps(res))
__gg_main()
`;
}

/** @returns {{language:string, source:string, fileName:string}} */
function buildProgram(languageId, userCode, functionName) {
  const lang = SUPPORTED[languageId];
  if (!lang) throw new Error(`Language ${languageId} is not graded yet.`);
  if (!/^[A-Za-z_][A-Za-z0-9_]*$/.test(functionName)) throw new Error("Bad function name");
  if (lang.piston === "javascript") return { language: "javascript", fileName: "main.js", source: `${userCode}\n${jsDriver(functionName)}` };
  return { language: "python", fileName: "main.py", source: `${PY_PRELUDE}\n${userCode}\n${pyDriver(functionName)}` };
}

/** Extract the driver's JSON line from stdout. */
function readResults(stdout) {
  const idx = String(stdout || "").lastIndexOf(MARKER);
  if (idx < 0) return null;
  const line = stdout.slice(idx + MARKER.length).split("\n")[0];
  try { return JSON.parse(line); } catch (e) { return null; }
}

module.exports = { buildProgram, readResults, SUPPORTED, MARKER, PY_PRELUDE };
