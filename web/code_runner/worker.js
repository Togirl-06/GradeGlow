/*
 * Web Worker for the GradeGlow code labs (Flutter web).
 * Messages in:  JSON string {id, op, ...} (see runner_core.js `handle`).
 * Messages out: JSON string {id, phase:"running"} when student code starts
 *               (the app starts its time limit then), and {id, ok, result} or
 *               {id, ok:false, error}. The app terminates this worker when a
 *               run exceeds its time limit.
 */
/* global importScripts, loadPyodide, initSqlJs, GGRunner, GGJudge */
importScripts("gg_judge.js", "runner_core.js", "sql-wasm.js");

const PYODIDE_URL = "https://cdn.jsdelivr.net/pyodide/v0.27.7/full/";
let current = null;
let runner = null;

function post(obj) { self.postMessage(JSON.stringify(obj)); }

function getRunner(cfg) {
  if (runner) return runner;
  const pyUrl = (cfg && cfg.pyodideUrl) || PYODIDE_URL;
  runner = GGRunner.createRunner({
    judgeLib: GGJudge,
    loadPyodide: async function () {
      importScripts(pyUrl + "pyodide.js");
      return loadPyodide({ indexURL: pyUrl });
    },
    initSqlJs: function () { return initSqlJs({ locateFile: function (f) { return f; } }); },
    onRunning: function () { if (current !== null) post({ id: current, phase: "running" }); },
  });
  return runner;
}

let queue = Promise.resolve();
self.onmessage = function (ev) {
  let msg;
  try { msg = typeof ev.data === "string" ? JSON.parse(ev.data) : ev.data; } catch (e) { return; }
  queue = queue.then(async function () {
    current = msg.id;
    try {
      const result = await GGRunner.handle(getRunner(msg.cfg), msg);
      post({ id: msg.id, ok: true, result: result });
    } catch (e) {
      post({ id: msg.id, ok: false, error: (e && e.message) || String(e) });
    } finally {
      current = null;
    }
  });
};
