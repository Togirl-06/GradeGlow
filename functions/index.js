const { onRequest } = require("firebase-functions/v2/https");
const { defineString } = require("firebase-functions/params");
const { setGlobalOptions } = require("firebase-functions/v2");

setGlobalOptions({ region: "us-central1" });

// Set via functions/.env at deploy time (copied from project .env by deploy_web.ps1).
// Requires Blaze billing for Cloud Functions.
const openAiKey = defineString("OPENAI_API_KEY", { default: "" });

/**
 * Proxies OpenAI API calls so the Flutter web app avoids CORS and never
 * ships the API key to the browser.
 *
 * Hosting rewrite: /api/openai/** -> this function
 */
exports.openaiProxy = onRequest(
  {
    cors: true,
    timeoutSeconds: 300,
    memory: "512MiB",
    invoker: "public",
  },
  async (req, res) => {
    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }
    if (req.method !== "POST") {
      res.status(405).json({ error: "POST only" });
      return;
    }

    const key = openAiKey.value();
    if (!key) {
      res.status(500).json({
        error:
          "OPENAI_API_KEY is not configured for the proxy. Add it to functions/.env and redeploy.",
      });
      return;
    }

    const original = req.originalUrl || req.url || "";
    const marker = "/api/openai";
    const idx = original.indexOf(marker);
    let openAiPath =
      idx >= 0 ? original.slice(idx + marker.length) : original.split("?")[0];
    openAiPath = openAiPath.split("?")[0];
    if (!openAiPath.startsWith("/")) openAiPath = `/${openAiPath}`;
    if (openAiPath === "/" || openAiPath === "") {
      openAiPath = "/v1/chat/completions";
    }
    openAiPath = openAiPath.replace(/^\/openaiProxy/, "");
    if (!openAiPath.startsWith("/")) openAiPath = `/${openAiPath}`;
    if (!openAiPath.startsWith("/v1/")) {
      openAiPath = `/v1/${openAiPath.replace(/^\//, "")}`;
    }

    const target = `https://api.openai.com${openAiPath}`;
    const headers = { Authorization: `Bearer ${key}` };
    const contentType = req.get("content-type") || "";
    let body;
    if (contentType.includes("multipart/form-data")) {
      body = req.rawBody;
      headers["Content-Type"] = contentType;
    } else {
      headers["Content-Type"] = "application/json";
      body =
        typeof req.body === "string"
          ? req.body
          : JSON.stringify(req.body ?? {});
    }

    try {
      const upstream = await fetch(target, { method: "POST", headers, body });
      const responseType =
        upstream.headers.get("content-type") || "application/json";
      const buf = Buffer.from(await upstream.arrayBuffer());
      res.status(upstream.status).set("Content-Type", responseType).send(buf);
    } catch (error) {
      console.error("openaiProxy error", error);
      res.status(502).json({
        error: "Upstream OpenAI request failed.",
        detail: String(error && error.message ? error.message : error),
      });
    }
  }
);
