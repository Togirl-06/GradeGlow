"use strict";
// Sandbox runners. Production uses a Piston-compatible execution service
// (https://github.com/engineer-man/piston), self-hosted on Cloud Run or a VM,
// which runs each submission in an isolated container with CPU, memory,
// process and network limits. The URL is a secret: CODE_RUNNER_URL.
//
// `localRunner` exists ONLY for automated tests of the harness. It runs code
// directly with python3/node and is not isolated, so `index` never uses it.

const LIMITS = {
  runTimeoutMs: 6000,
  compileTimeoutMs: 10000,
  memoryBytes: 256 * 1024 * 1024,
  maxCodeBytes: 64 * 1024,
  maxStdoutBytes: 256 * 1024,
};

/** @returns {(job:{language,fileName,source,stdin}) => Promise<{stdout,stderr,code,signal,timedOut,memoryBytes,cpuMs}>} */
function pistonRunner(baseUrl, { fetchImpl = globalThis.fetch, apiKey } = {}) {
  const url = baseUrl.replace(/\/+$/, "") + "/api/v2/execute";
  return async (job) => {
    const res = await fetchImpl(url, {
      method: "POST",
      headers: Object.assign({ "content-type": "application/json" }, apiKey ? { authorization: apiKey } : {}),
      body: JSON.stringify({
        language: job.language,
        version: "*",
        files: [{ name: job.fileName, content: job.source }],
        stdin: job.stdin,
        run_timeout: LIMITS.runTimeoutMs,
        compile_timeout: LIMITS.compileTimeoutMs,
        run_memory_limit: LIMITS.memoryBytes,
      }),
    });
    if (!res.ok) {
      const text = await res.text().catch(() => "");
      const err = new Error(`Code runner returned ${res.status}: ${text.slice(0, 200)}`);
      err.runnerUnavailable = true;
      throw err;
    }
    const body = await res.json();
    const run = body.run || {};
    const signal = run.signal || null;
    return {
      stdout: String(run.stdout || "").slice(0, LIMITS.maxStdoutBytes),
      stderr: String(run.stderr || "").slice(0, 8000) + (body.compile && body.compile.code ? String(body.compile.stderr || "") : ""),
      code: run.code,
      signal,
      timedOut: signal === "SIGKILL" && (run.status === "TO" || /time/i.test(run.message || "")) || run.status === "TO",
      memoryBytes: typeof run.memory === "number" ? run.memory : null,
      cpuMs: typeof run.cpu_time === "number" ? run.cpu_time : null,
      outOfMemory: run.status === "OOM" || /memory/i.test(run.message || ""),
    };
  };
}

/** TEST ONLY: unisolated local execution. */
function localRunner() {
  const { spawnSync } = require("node:child_process");
  const fs = require("node:fs"); const os = require("node:os"); const path = require("node:path");
  return async (job) => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), "gg-judge-"));
    const file = path.join(dir, job.fileName);
    fs.writeFileSync(file, job.source);
    const cmd = job.language === "python" ? "python3" : process.execPath;
    const r = spawnSync(cmd, [file], { input: job.stdin, timeout: LIMITS.runTimeoutMs, maxBuffer: LIMITS.maxStdoutBytes * 4, encoding: "utf8", cwd: dir });
    fs.rmSync(dir, { recursive: true, force: true });
    return {
      stdout: r.stdout || "", stderr: r.stderr || "", code: r.status, signal: r.signal,
      timedOut: r.error && r.error.code === "ETIMEDOUT" || r.signal === "SIGTERM", memoryBytes: null, cpuMs: null, outOfMemory: false,
    };
  };
}

module.exports = { pistonRunner, localRunner, LIMITS };
