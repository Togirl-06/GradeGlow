# Integration guide

- Entry: Labs hub → "Enter GradeGlow Life" → `LifeGameLauncher` (loads save or shows character creator, wraps in `lifeTheme()`).
- Auth/identity: `LifeSaveService` uses the current `FirebaseAuth` user; signed-out play falls back to local save only.
- AI: `AppConfig.hasOpenAi` toggles live AI; otherwise scripted/heuristic fallbacks run.
- Return to Flutter: back arrow in the HUD saves, then pops.
- Web/mobile/desktop: single Flutter codebase; no Unity-as-a-Library, WebGL host or platform channels required.
- Adding content: new career → `careers/career_catalog.dart`, `workplace/content/<career>_tasks.dart`, station ids in `world/interiors.dart`, degree in `education/university.dart`.
