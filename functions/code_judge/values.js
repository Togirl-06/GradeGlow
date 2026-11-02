"use strict";
// Parsing of the problem bank's textual test cases, e.g.
//   input:  'nums = [2,7,11,15], target = 9'
//   output: '[0,1]'
// Values are JSON plus a few LeetCode-isms: single-quoted strings, null/None,
// true/false/True/False. Anything else is reported as unparseable so the
// problem is marked "not auto-gradable" rather than graded wrongly.

class ParseError extends Error {}

function parseValue(src) {
  const s = String(src).trim();
  let i = 0;
  const ws = () => { while (i < s.length && /\s/.test(s[i])) i++; };
  function value() {
    ws();
    const c = s[i];
    if (c === "[") {
      i++; const out = []; ws();
      if (s[i] === "]") { i++; return out; }
      for (;;) {
        out.push(value()); ws();
        if (s[i] === ",") { i++; continue; }
        if (s[i] === "]") { i++; return out; }
        throw new ParseError(`expected , or ] at ${i} in ${s}`);
      }
    }
    if (c === "{") {
      i++; const out = {}; ws();
      if (s[i] === "}") { i++; return out; }
      for (;;) {
        ws(); const k = value(); ws();
        if (s[i] !== ":") throw new ParseError(`expected : at ${i} in ${s}`);
        i++; out[String(k)] = value(); ws();
        if (s[i] === ",") { i++; continue; }
        if (s[i] === "}") { i++; return out; }
        throw new ParseError(`expected , or } at ${i} in ${s}`);
      }
    }
    if (c === '"' || c === "'") {
      const q = c; i++; let out = "";
      while (i < s.length && s[i] !== q) {
        if (s[i] === "\\") {
          const n = s[i + 1];
          const map = { n: "\n", t: "\t", r: "\r", '"': '"', "'": "'", "\\": "\\", "/": "/" };
          if (n === "u") { out += String.fromCharCode(parseInt(s.slice(i + 2, i + 6), 16)); i += 6; continue; }
          out += map[n] !== undefined ? map[n] : n; i += 2; continue;
        }
        out += s[i++];
      }
      if (s[i] !== q) throw new ParseError(`unterminated string in ${s}`);
      i++; return out;
    }
    const m = /^-?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?/.exec(s.slice(i));
    if (m) { i += m[0].length; return Number(m[0]); }
    const w = /^[A-Za-z_]+/.exec(s.slice(i));
    if (w) {
      i += w[0].length;
      const word = w[0];
      if (word === "null" || word === "None") return null;
      if (word === "true" || word === "True") return true;
      if (word === "false" || word === "False") return false;
      throw new ParseError(`unknown word ${word} in ${s}`);
    }
    throw new ParseError(`unexpected ${c === undefined ? "end" : JSON.stringify(c)} at ${i} in ${s}`);
  }
  const v = value(); ws();
  if (i !== s.length) throw new ParseError(`trailing text at ${i} in ${s}`);
  return v;
}

/** Split on commas that are not inside brackets, braces or quotes. */
function splitTopLevel(s) {
  const parts = []; let depth = 0, q = null, start = 0;
  for (let i = 0; i < s.length; i++) {
    const c = s[i];
    if (q) { if (c === "\\") i++; else if (c === q) q = null; continue; }
    if (c === '"' || c === "'") q = c;
    else if (c === "[" || c === "{" || c === "(") depth++;
    else if (c === "]" || c === "}" || c === ")") depth--;
    else if (c === "," && depth === 0) { parts.push(s.slice(start, i)); start = i + 1; }
  }
  parts.push(s.slice(start));
  return parts.map((p) => p.trim()).filter((p) => p.length);
}

/**
 * 'nums = [2,7], target = 9' → [{name:'nums', value:[2,7]}, {name:'target', value:9}].
 * A bare value without a name is accepted for single-argument problems.
 */
function parseArgs(input) {
  const text = String(input).trim();
  if (!text) return [];
  return splitTopLevel(text).map((part, idx) => {
    const m = /^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*([\s\S]+)$/.exec(part);
    if (m) return { name: m[1], value: parseValue(m[2]) };
    if (idx === 0) return { name: "arg0", value: parseValue(part) };
    throw new ParseError(`argument without a name: ${part}`);
  });
}

const LIST_PARAMS = new Set(["head", "l1", "l2", "list1", "list2", "headA", "headB", "list"]);
const TREE_PARAMS = new Set(["root", "p", "q", "root1", "root2", "subRoot", "t1", "t2", "original", "cloned"]);

/** Decide how each argument is converted for this problem (plain, linked list or tree). */
function argKinds(problem, args) {
  const tags = (problem.tags || []).map((t) => String(t).toLowerCase());
  const isList = tags.some((t) => t.includes("linked list"));
  const isTree = tags.some((t) => t.includes("tree"));
  return args.map((a) => {
    if (isList && LIST_PARAMS.has(a.name) && Array.isArray(a.value)) return "list";
    if (isTree && TREE_PARAMS.has(a.name) && Array.isArray(a.value)) return "tree";
    return "plain";
  });
}

module.exports = { parseValue, parseArgs, splitTopLevel, argKinds, ParseError };
