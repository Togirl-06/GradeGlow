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

## You must do before store submit
1. **Keep Android package `com.example.ai_study_buddy` until** you register **`com.gradeglow.app`** in Firebase Console and download a fresh `google-services.json` (renaming the package without that breaks Google Sign-In — error 10 / SHA-1 banner).
2. Add your **SHA-1 / SHA-256** (run `.\scripts\get_sha1.ps1`) under Firebase → Project Settings → Android app.
3. Deploy rules: `firebase deploy --only firestore:rules,storage`
4. Create a **release keystore** and replace debug signing in `android/app/build.gradle.kts`.
5. Host privacy/terms on the web and set URLs in `lib/config/legal_urls.dart`.
6. Connect **App Store / Play Billing** and set `SubscriptionService.billingLive = true`.
7. Move OpenAI behind a **Cloud Function proxy**; stop shipping client keys in production.
8. Smoke-test: sign-in, notes→quiz, AI Professor, assignment submit, account delete.

## Soft-launch positioning
Ship as **GradeGlow — AI study assistant** with selected Virtual University degrees.
Do not market stub degrees or paid Premium until billing is live.
