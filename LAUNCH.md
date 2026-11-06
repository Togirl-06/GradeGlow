# Launch checklist (GradeGlow)

## Done in code
- [x] In-app Privacy Policy + Terms (Settings)
- [x] Fake Premium unlock removed (billing waitlist / coming soon)
- [x] Package ID → `com.gradeglow.app` (Android / iOS / macOS)
- [x] Stub VU degrees locked as Coming soon
- [x] Discussion / PDF download placeholders removed from lesson hub
- [x] Certificates labeled as beta learning achievements
- [x] Firestore + Storage rules tightened
- [x] Crashlytics wired (release builds)
- [x] OpenAI key prefers `--dart-define` over bundled secrets
- [x] Career simulator on `main` (PR #5 + follow-ups: 198 labs, Find, simulated pay, CAD, 3D anatomy)
- [x] Web build does **not** bake `OPENAI_API_KEY` into client JS (uses `/api/openai` proxy)
- [x] Live hosting deployed: https://gradeglow-virtualuni.web.app
- [x] Firestore rules + Storage rules deployed (`ai-studybuddy-1fad1`)
- [x] Cloud Functions deployed: `openaiProxy`, `createStripeCheckout`, `confirmStripeCheckout`, `stripeWebhook`
- [x] Env keys present locally in `.env` and `functions/.env` (gitignored): `OPENAI_API_KEY`, `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`

## Soft-launch smoke (2026-11-06)
- [x] Live site loads (HTTP 200, GradeGlow landing)
- [x] Live JS includes Career / Find / My Earnings / Practical Labs / CAD
- [x] `openaiProxy` responds (OPTIONS 204)
- [ ] Sign-in → Career → Find → pass one lab (balance up) — needs a real account in the browser
- [ ] 3D anatomy lab on a phone/desktop after sign-in
- [ ] CAD drawing lab after sign-in
- [ ] AI Professor / interview coach after sign-in

## You must do before store submit
1. **Keep Android package `com.example.ai_study_buddy` until** you register **`com.gradeglow.app`** in Firebase Console and download a fresh `google-services.json` (renaming the package without that breaks Google Sign-In — error 10 / SHA-1 banner).
2. Add your **SHA-1 / SHA-256** (run `.\scripts\get_sha1.ps1`) under Firebase → Project Settings → Android app.
3. ~~Deploy rules: `firebase deploy --only firestore:rules,storage`~~ **Done**
4. Create a **release keystore** and replace debug signing in `android/app/build.gradle.kts`.
5. Host privacy/terms on the web and set URLs in `lib/config/legal_urls.dart` (still `null` → in-app text only).
6. Connect **App Store / Play Billing** ( `SubscriptionService.billingLive` is already `true` — confirm store products exist before marketing paid Premium).
7. ~~Move OpenAI behind a Cloud Function proxy~~ **Done** (`openaiProxy` + Hosting `/api/openai`). Do not put the key in the web build.
8. Smoke-test with a signed-in account: Career Find → one lab → anatomy → CAD → AI; also notes→quiz, assignment submit, account delete.
9. **Code runner (optional):** set a real Piston URL via `firebase functions:secrets:set CODE_RUNNER_URL` / `CODE_RUNNER_KEY`, then deploy `codeJudge` (placeholders are set so other functions can deploy; sandboxed grading is not live yet). See `docs/sim_rebuild/CODE_RUNNER_SETUP.md`.

## Soft-launch positioning
Ship as **GradeGlow — AI study assistant** with selected Virtual University degrees and the Career simulator.
Do not market stub degrees or paid Premium until store billing products are live and verified.
