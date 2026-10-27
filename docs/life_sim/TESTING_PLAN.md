# Testing plan

## Automated (headless Dart, `test/life_sim/`)
employment, interview, job/workplace, workplace content, university, world/pathing, movement, iso math,
spec-gap (needs, relationships, GPA, ceremony), and `playthrough_test` — a bot completing all six careers
end to end with a save/load round trip.
Run with `flutter test test/life_sim` (project environment) .

## Manual (not yet done — required before release)
- Run on Android, iOS, web, desktop: rendering correctness, tap hit-testing, frame rate on mid-range phones.
- Firebase: sign-in, cloud save/restore across devices, offline→online merge, rules review.
- AI: live OpenAI responses, rate-limit/failure fallbacks, content safety.
- Accessibility: contrast, text scaling, keyboard-only play.
- Security: client-tamper test of economy/grades (currently expected to fail — see FIREBASE_SCHEMA.md).
