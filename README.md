# GradeGlow

GradeGlow is a virtual university and AI study assistant for people who cannot afford traditional tuition.

**Mission:** Give every person access to a world-class university education, regardless of income.

AI Professors teach like real faculty, with full lectures, speech-synced visuals, professional labs, and campus tools. GradeGlow also turns notes, PDFs, and recordings into summaries, flashcards, quizzes, and personalized tutoring so students can stay organized and improve.

## Setup

1. Copy `.env.example` to `.env` and add your API keys (never commit `.env`), **or** pass `--dart-define=OPENAI_API_KEY=...`.
2. Run `flutter pub get`
3. Confirm Firebase apps use package ID **`com.gradeglow.app`** (see [LAUNCH.md](LAUNCH.md)).
4. **Deploy Firestore + Storage rules**:
   - Firebase Console → Rules, or `firebase deploy --only firestore:rules,storage`
5. Run `flutter run` (phone) or `flutter run -d edge` / `flutter run -d chrome` (website)

## Host the website

The web app is ready for Firebase Hosting:

```powershell
.\scripts\deploy_web.ps1
```

That builds `build/web` and deploys it. After `firebase login`, the site is at https://ai-studybuddy-1fad1.web.app.

See [LAUNCH.md](LAUNCH.md) for store-ready checklist.

## Account deletion

Settings → **Delete account** schedules permanent removal after a **30-day recovery window**. Users must type `DELETE` to confirm. During the grace period they can sign in and tap **Restore my account**. After 30 days, all Firestore data, Storage files, and the Firebase Auth account are wiped automatically on next sign-in.
