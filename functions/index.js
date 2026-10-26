const { onRequest } = require("firebase-functions/v2/https");

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

let adminReady = false;
function ensureAdmin() {
  if (adminReady) return;
  const { initializeApp, getApps } = require("firebase-admin/app");
  if (getApps().length === 0) initializeApp();
  adminReady = true;
}

function stripeSecret() {
  return (process.env.STRIPE_SECRET_KEY || "").trim();
}

function getStripe() {
  const secret = stripeSecret();
  if (!secret) return null;
  const Stripe = require("stripe");
  return new Stripe(secret);
}

const PLAN_PRICES = {
  monthly: {
    amount: 699,
    label: "GradeGlow Premium — Monthly",
    mode: "subscription",
    interval: "month",
    intervalCount: 1,
    trialDays: 30,
  },
  semester: {
    amount: 1999,
    label: "GradeGlow Premium — Semester (4 months)",
    mode: "payment",
    interval: null,
    intervalCount: null,
    trialDays: 0,
  },
  annual: {
    amount: 4999,
    label: "GradeGlow Premium — Annual",
    mode: "subscription",
    interval: "year",
    intervalCount: 1,
    trialDays: 30,
  },
};

async function unlockPremium(db, FieldValue, uid, session) {
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
}

function resolveUid(session) {
  return session.client_reference_id || session.metadata?.firebaseUid || "";
}

/**
 * Creates a Stripe Checkout Session with correct Premium prices.
 * Hosting rewrite: /api/stripe/create-checkout -> createStripeCheckout
 *
 * functions/.env: STRIPE_SECRET_KEY=sk_live_... (or sk_test_...)
 */
exports.createStripeCheckout = onRequest(
  {
    region: "us-central1",
    cors: true,
    timeoutSeconds: 60,
    memory: "256MiB",
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

    const stripe = getStripe();
    if (!stripe) {
      res.status(503).json({
        error:
          "Stripe is not configured. Add STRIPE_SECRET_KEY to functions/.env and redeploy.",
        code: "stripe_not_configured",
      });
      return;
    }

    const body = typeof req.body === "string" ? JSON.parse(req.body || "{}") : req.body || {};
    const uid = String(body.uid || "").trim();
    const email = String(body.email || "").trim();
    const interval = String(body.interval || "monthly").trim();
    const successUrl = String(body.successUrl || "").trim();
    const cancelUrl = String(body.cancelUrl || "").trim();

    if (!uid) {
      res.status(400).json({ error: "uid is required" });
      return;
    }
    if (!successUrl || !cancelUrl) {
      res.status(400).json({ error: "successUrl and cancelUrl are required" });
      return;
    }

    const plan = PLAN_PRICES[interval] || PLAN_PRICES.monthly;
    const successWithSession = successUrl.includes("{CHECKOUT_SESSION_ID}")
      ? successUrl
      : `${successUrl}${successUrl.includes("?") ? "&" : "?"}session_id={CHECKOUT_SESSION_ID}`;

    const lineItem = {
      quantity: 1,
      price_data: {
        currency: "usd",
        unit_amount: plan.amount,
        product_data: {
          name: plan.label,
          description:
            "Unlimited AI Tutor, study sets, flashcards, quizzes, uploads, and exam prep tools.",
        },
        ...(plan.mode === "subscription"
          ? {
              recurring: {
                interval: plan.interval,
                interval_count: plan.intervalCount,
              },
            }
          : {}),
      },
    };

    try {
      const sessionParams = {
        mode: plan.mode,
        line_items: [lineItem],
        success_url: successWithSession,
        cancel_url: cancelUrl,
        client_reference_id: uid,
        metadata: {
          firebaseUid: uid,
          billingInterval: interval,
        },
        allow_promotion_codes: false,
        billing_address_collection: "auto",
      };

      if (email) {
        sessionParams.customer_email = email;
      }

      if (plan.mode === "subscription") {
        sessionParams.subscription_data = {
          metadata: {
            firebaseUid: uid,
            billingInterval: interval,
          },
          ...(plan.trialDays > 0
            ? { trial_period_days: plan.trialDays }
            : {}),
        };
      } else {
        sessionParams.payment_intent_data = {
          metadata: {
            firebaseUid: uid,
            billingInterval: interval,
          },
        };
      }

      const session = await stripe.checkout.sessions.create(sessionParams);
      res.status(200).json({
        url: session.url,
        sessionId: session.id,
      });
    } catch (err) {
      console.error("createStripeCheckout error", err);
      res.status(502).json({
        error: "Could not create Stripe checkout session.",
        detail: String(err && err.message ? err.message : err),
      });
    }
  }
);

/**
 * Confirms a completed Checkout Session and unlocks Premium.
 * Works even when the webhook is not yet wired — call after success redirect.
 * Hosting rewrite: /api/stripe/confirm-checkout -> confirmStripeCheckout
 */
exports.confirmStripeCheckout = onRequest(
  {
    region: "us-central1",
    cors: true,
    timeoutSeconds: 60,
    memory: "256MiB",
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

    const stripe = getStripe();
    if (!stripe) {
      res.status(503).json({
        error: "Stripe is not configured.",
        code: "stripe_not_configured",
      });
      return;
    }

    const body = typeof req.body === "string" ? JSON.parse(req.body || "{}") : req.body || {};
    const sessionId = String(body.sessionId || "").trim();
    const uidHint = String(body.uid || "").trim();

    if (!sessionId) {
      res.status(400).json({ error: "sessionId is required" });
      return;
    }

    try {
      const session = await stripe.checkout.sessions.retrieve(sessionId);
      const paid =
        session.payment_status === "paid" ||
        session.payment_status === "no_charge" ||
        session.status === "complete";

      if (!paid) {
        res.status(200).json({ unlocked: false, status: session.status, paymentStatus: session.payment_status });
        return;
      }

      let uid = resolveUid(session) || uidHint;
      const { getFirestore, FieldValue } = require("firebase-admin/firestore");
      ensureAdmin();
      const db = getFirestore();

      if (!uid) {
        const email =
          (session.customer_details && session.customer_details.email) ||
          session.customer_email ||
          "";
        if (email) {
          const snap = await db
            .collection("users")
            .where("email", "==", email)
            .limit(1)
            .get();
          if (!snap.empty) uid = snap.docs[0].id;
        }
      }

      if (!uid) {
        res.status(200).json({ unlocked: false, reason: "missing_uid" });
        return;
      }

      if (uidHint && uidHint !== uid) {
        res.status(403).json({ error: "Session does not match signed-in user." });
        return;
      }

      await unlockPremium(db, FieldValue, uid, session);
      res.status(200).json({ unlocked: true, uid, plan: "premium" });
    } catch (err) {
      console.error("confirmStripeCheckout error", err);
      res.status(502).json({
        error: "Could not confirm checkout.",
        detail: String(err && err.message ? err.message : err),
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
 * 3. Checkout Sessions pass client_reference_id (= Firebase uid)
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

    const secret = stripeSecret();
    const whSecret = (process.env.STRIPE_WEBHOOK_SECRET || "").trim();
    if (!secret || !whSecret) {
      console.error("Missing STRIPE_SECRET_KEY or STRIPE_WEBHOOK_SECRET");
      res.status(500).send("Stripe not configured");
      return;
    }

    const Stripe = require("stripe");
    const { getFirestore, FieldValue } = require("firebase-admin/firestore");
    ensureAdmin();

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
        let uid = resolveUid(session);
        const email =
          (session.customer_details && session.customer_details.email) ||
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
          console.error(
            "checkout.session.completed missing uid/email",
            session.id
          );
          res.status(200).json({ received: true, unlocked: false });
          return;
        }

        await unlockPremium(db, FieldValue, uid, session);
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
