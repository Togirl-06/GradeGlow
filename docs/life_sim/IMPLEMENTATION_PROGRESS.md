# Implementation progress

## Done (verified by headless tests + analyzer)
Deterministic core, seven career loops (software engineer, nurse, pharmacist, doctor, lawyer, accountant,
business manager), university with GPA, honours, graduation ceremony/certificates, and AI-professor lectures
with synchronized body-diagram highlighting (scripted anatomy series + lectures generated from every course's
exam bank, offline fallback); job hunting + interviews with offer / reject / waitlist / **second interview** /
**information requested** outcomes; economy/bills/shop/bank; needs incl. hygiene & stress; NPC relationships;
**NPC schedules inside buildings** (working / break / resting, time-derived and deterministic); company
ownership; cloud+local save; AI adapters with fallbacks; isometric city and interiors; phone; status panel;
calendar; map; character creator; Labs hub entry.

Server-side plausibility guard (`functions/life_sim.js`, `functions/life_sim/validate.js`): Firestore trigger
that checkpoints each save, rolls back implausible jumps (cash/wealth, skills, degrees) and writes audit
events. Node tests: 15 passing.

**3D world on web (`web/life_world/`)**: open 3D city (24 distinct buildings, streets, traffic,
pedestrians, day/night, see-through occluders), Sims-style procedural characters with animations and
work uniforms, cut-away 3D rooms with furniture for every interactable, third-person camera (drag/pinch/
scroll, WASD relative to camera), Dart ↔ page bridge in `ui/world3d/`. Verified in headless Chromium
(all 23 interiors render, no console errors; protocol checked with a mock parent page).

## Done but not device-verified
All Flutter UI/painters, Firebase and OpenAI adapters (analyzed against stubs; the app was never run).
The Cloud Function and the new Firestore rules are **not deployed and not emulator-tested**.

The Dart side of the 3D bridge (`ui/world3d/*`, `LifeGameScreen` changes) was written without a Flutter
SDK available and has not been compiled or run yet: run `flutter analyze` and `flutter run -d chrome`.

## Not done
- Unity/3D, WebGL, asset pipeline (decision: Flutter CustomPainter).
- ~40 further courses/schools beyond the seven degree programmes; code-execution sandbox for the coding arena.
- City pedestrians; minimap; animated interviewer rooms; group interviews.
- Speech input; audio; accessibility pass; performance profiling.
- True server-authoritative economy (callable functions); the guard only bounds cheating.

## Known issues
Painter visuals unreviewed on real screens; fast-travel for trips > 40 tiles uses a simple rule.
