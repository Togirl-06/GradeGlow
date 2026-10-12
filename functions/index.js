const { onRequest } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const Stripe = require("stripe");

initializeApp();

/**
 * Proxies OpenAI so the Flutter web app avoids CORS and keeps the key server-side.
 * Hosting rewrite: /api/openai/** -> openaiProxy
 *
 * Key source: functions/.env (OPENAI_API_KEY=...) copied by deploy_web.ps1
 */
exports.openaiProxy = onRequest(
  {
    region: "us-central1",
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

    const key = process.env.OPENAI_API_KEY || "";
    if (!key) {
      res.status(500).json({
        error:
          "OPENAI_API_KEY is missing. Put it in functions/.env and redeploy.",
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

/**
 * Stripe webhook — unlocks Premium on users/{uid}.plan after checkout.
 *
 * Setup:
 * 1. functions/.env: STRIPE_SECRET_KEY=sk_... and STRIPE_WEBHOOK_SECRET=whsec_...
 * 2. Stripe Dashboard → Developers → Webhooks → endpoint
 *    https://us-central1-<project>.cloudfunctions.net/stripeWebhook
 *    events: checkout.session.completed, customer.subscription.deleted
 * 3. Payment Links must pass client_reference_id (= Firebase uid)
 *    App opens: buy.stripe.com/...?client_reference_id=<uid>
 */
exports.stripeWebhook = onRequest(
  {
    region: "us-central1",
    cors: false,
    timeoutSeconds: 60,
    memory: "256MiB",
    invoker: "public",
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("POST only");
      return;
    }

    const secret = process.env.STRIPE_SECRET_KEY || "";
    const whSecret = process.env.STRIPE_WEBHOOK_SECRET || "";
    if (!secret || !whSecret) {
      console.error("Missing STRIPE_SECRET_KEY or STRIPE_WEBHOOK_SECRET");
      res.status(500).send("Stripe not configured");
      return;
    }

    const stripe = new Stripe(secret);
    let event;
    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        req.headers["stripe-signature"],
        whSecret
      );
    } catch (err) {
      console.error("Webhook signature failed", err.message);
      res.status(400).send(`Webhook Error: ${err.message}`);
      return;
    }

    const db = getFirestore();

    try {
      if (event.type === "checkout.session.completed") {
        const session = event.data.object;
        let uid = session.client_reference_id || "";
        const email = (session.customer_details && session.customer_details.email) ||
          session.customer_email ||
          "";

        if (!uid && email) {
          const snap = await db
            .collection("users")
            .where("email", "==", email)
            .limit(1)
            .get();
          if (!snap.empty) uid = snap.docs[0].id;
        }

        if (!uid) {
          console.error("checkout.session.completed missing uid/email", session.id);
          res.status(200).json({ received: true, unlocked: false });
          return;
        }

        await db.collection("users").doc(uid).set(
          {
            plan: "premium",
            planUpdatedAt: new Date().toISOString(),
            stripeCustomerId: session.customer || null,
            stripeCheckoutSessionId: session.id,
            planSource: "stripe",
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
        console.log("Unlocked premium for", uid);
      }

      if (event.type === "customer.subscription.deleted") {
        const sub = event.data.object;
        const customerId = sub.customer;
        if (customerId) {
          const snap = await db
            .collection("users")
            .where("stripeCustomerId", "==", customerId)
            .limit(1)
            .get();
          if (!snap.empty) {
            await snap.docs[0].ref.set(
              {
                plan: "free",
                planUpdatedAt: new Date().toISOString(),
                planSource: "stripe_canceled",
                updatedAt: FieldValue.serverTimestamp(),
              },
              { merge: true }
            );
            console.log("Reverted to free for", snap.docs[0].id);
          }
        }
      }

      res.status(200).json({ received: true });
    } catch (err) {
      console.error("stripeWebhook handler error", err);
      res.status(500).json({ error: String(err.message || err) });
    }
  }
);
