"use strict";
// Output comparison. Exact structural equality, with:
//  * float tolerance (1e-5 relative/absolute),
//  * optional unordered comparison for problems whose statement says the
//    answer may be returned "in any order".

function close(a, b) {
  if (Number.isInteger(a) && Number.isInteger(b)) return a === b;
  return Math.abs(a - b) <= 1e-5 * Math.max(1, Math.abs(a), Math.abs(b));
}

function equal(a, b) {
  if (typeof a === "number" && typeof b === "number") return close(a, b);
  if (a === null || b === null) return a === b;
  if (Array.isArray(a) || Array.isArray(b)) {
    if (!Array.isArray(a) || !Array.isArray(b) || a.length !== b.length) return false;
    return a.every((x, i) => equal(x, b[i]));
  }
  if (typeof a === "object" && typeof b === "object") {
    const ka = Object.keys(a).sort(), kb = Object.keys(b).sort();
    return equal(ka, kb) && ka.every((k) => equal(a[k], b[k]));
  }
  return a === b;
}

function canon(v) {
  if (Array.isArray(v)) return v.map(canon).map((x) => JSON.stringify(x)).sort().map((x) => JSON.parse(x));
  return v;
}

/** Unordered: outer list order and (for lists of lists) inner order ignored. */
function equalUnordered(a, b) {
  if (!Array.isArray(a) || !Array.isArray(b)) return equal(a, b);
  return equal(canon(a), canon(b));
}

function anyOrder(problem) {
  return /in any order|any order\b|return them in any order/i.test(problem.description || "");
}

module.exports = { equal, equalUnordered, anyOrder };
