/*
 * GradeGlow lab runner core. Runs student code on the student's own device:
 *   - Python 3 through Pyodide (CPython compiled to WebAssembly),
 *   - JavaScript in a dedicated worker,
 *   - SQL against an in-memory SQLite database (sql.js).
 * Grading uses GGJudge, the server judge's own harness and rules
 * (bundled by tool/build_code_runner.js), so results match the server.
 *
 * Works in a Web Worker (importScripts), a plain page (WebView) and Node
 * (functions/test/lab_runner.test.js). Time limits are enforced by the
 * caller, which terminates the worker / reloads the page.
 */
(function (root) {
  "use strict";

  function decoder() {
    return typeof TextDecoder !== "undefined" ? new TextDecoder("utf-8") : null;
  }

  function fmt(v) {
    if (typeof v === "string") return v;
    try { return JSON.stringify(v); } catch (e) { return String(v); }
  }

  /**
   * @param {{judgeLib:object, loadPyodide:()=>Promise<any>, initSqlJs:()=>Promise<any>, onRunning?:()=>void}} opts
   */
  function createRunner(opts) {
    let pyPromise = null;
    let sqlPromise = null;
    const onRunning = opts.onRunning || function () {};

    function py() {
      if (!pyPromise) pyPromise = Promise.resolve().then(opts.loadPyodide).catch(function (e) { pyPromise = null; throw e; });
      return pyPromise;
    }
    function sql() {
      if (!sqlPromise) sqlPromise = Promise.resolve().then(opts.initSqlJs).catch(function (e) { sqlPromise = null; throw e; });
      return sqlPromise;
    }

    function runJs(job) {
      let stdout = "";
      let stderr = "";
      const proc = {
        stdout: { write: function (s) { stdout += String(s); return true; } },
        stderr: { write: function (s) { stderr += String(s); return true; } },
        hrtime: { bigint: function () { return BigInt(Math.round((typeof performance !== "undefined" ? performance.now() : Date.now()) * 1e6)); } },
        argv: [], env: {}, exit: function () {},
      };
      const req = function (m) {
        if (m === "fs") return { readFileSync: function () { return job.stdin || ""; } };
        throw new Error("require('" + m + "') is not available in the lab runner");
      };
      const con = {
        log: function () { stdout += Array.prototype.map.call(arguments, fmt).join(" ") + "\n"; },
        info: function () { stdout += Array.prototype.map.call(arguments, fmt).join(" ") + "\n"; },
        warn: function () { stderr += Array.prototype.map.call(arguments, fmt).join(" ") + "\n"; },
        error: function () { stderr += Array.prototype.map.call(arguments, fmt).join(" ") + "\n"; },
      };
      let fn;
      try {
        fn = new Function("process", "require", "console", job.source);
      } catch (e) {
        return { stdout: stdout, stderr: (e && e.name ? e.name + ": " : "") + (e && e.message ? e.message : String(e)), code: 1 };
      }
      onRunning();
      try {
        fn(proc, req, con);
        return { stdout: stdout, stderr: stderr, code: 0 };
      } catch (e) {
        return { stdout: stdout, stderr: stderr + ((e && e.stack) || String(e)), code: 1 };
      }
    }

    async function runPython(job) {
      const pyodide = await py();
      const dec = decoder();
      let out = "";
      let err = "";
      const sink = function (append) {
        return {
          write: function (buf) { append(dec ? dec.decode(buf, { stream: true }) : String.fromCharCode.apply(null, buf)); return buf.length; },
        };
      };
      pyodide.setStdout(sink(function (s) { out += s; }));
      pyodide.setStderr(sink(function (s) { err += s; }));
      let consumed = false;
      pyodide.setStdin({ stdin: function () { if (consumed) return null; consumed = true; return job.stdin || ""; } });
      const ns = pyodide.globals.get("dict")();
      let code = 0;
      onRunning();
      try {
        pyodide.runPython(job.source, { globals: ns, filename: job.fileName || "main.py" });
        pyodide.runPython("import sys\nsys.stdout.flush()\nsys.stderr.flush()");
      } catch (e) {
        code = 1;
        err += (e && e.message) || String(e);
      } finally {
        ns.destroy();
      }
      return { stdout: out, stderr: err, code: code };
    }

    function run(job) {
      return job.language === "python" ? runPython(job) : Promise.resolve(runJs(job));
    }

    /** Grade against the problem's tests with the server's rules. */
    async function judge(sub) {
      return opts.judgeLib.judge(sub, run);
    }

    /** Run a whole program (no tests) and return what it printed. */
    async function runProgram(p) {
      const started = Date.now();
      const isPy = p.language === "python3" || p.language === "python";
      const r = await run({ language: isPy ? "python" : "javascript", fileName: isPy ? "main.py" : "main.js", source: String(p.code || ""), stdin: p.stdin || "" });
      return { stdout: r.stdout, stderr: r.stderr, ok: r.code === 0, ms: Date.now() - started };
    }

    function table(r) {
      return r ? { columns: r.columns, rows: r.values } : { columns: [], rows: [] };
    }

    /** Run SQL against a fresh in-memory database built from `setup`. */
    async function runSql(p) {
      const SQL = await sql();
      const db = new SQL.Database();
      try {
        try { db.exec(String(p.setup || "")); } catch (e) { return { ok: false, error: "Lab database could not be created: " + e.message }; }
        onRunning();
        let res;
        try { res = db.exec(String(p.statements || "")); } catch (e) { return { ok: false, error: e.message }; }
        const changes = db.getRowsModified();
        const out = { ok: true, result: table(res.length ? res[res.length - 1] : null), changes: changes };
        if (p.check) {
          try { const c = db.exec(String(p.check)); out.check = table(c.length ? c[c.length - 1] : null); } catch (e) { out.check = null; out.checkError = e.message; }
        }
        return out;
      } finally {
        db.close();
      }
    }

    return { judge: judge, runProgram: runProgram, runSql: runSql, warmPython: py, warmSql: sql };
  }

  /** Dispatches one request object {op, ...} to a runner. */
  async function handle(runner, msg) {
    switch (msg.op) {
      case "judge": return runner.judge({ problem: msg.problem, language: msg.language, code: msg.code, includeHidden: !!msg.includeHidden });
      case "program": return runner.runProgram(msg);
      case "sql": return runner.runSql(msg);
      case "warm": await (msg.language === "sql" ? runner.warmSql() : runner.warmPython()); return { ok: true };
      default: throw new Error("Unknown runner operation: " + msg.op);
    }
  }

  const api = { createRunner: createRunner, handle: handle };
  if (typeof module !== "undefined" && module.exports) module.exports = api;
  root.GGRunner = api;
})(typeof self !== "undefined" ? self : (typeof globalThis !== "undefined" ? globalThis : this));
