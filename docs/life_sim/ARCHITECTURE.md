# GradeGlow Life — Architecture

GradeGlow Life lives inside the existing Flutter app (`lib/life_sim/`) and is launched from the
University Labs hub (`lib/vu_v2/labs/vu_v2_labs_hub.dart` → `LifeGameLauncher`).
**It is not a Unity game.** See `../life_sim_engine_decision.md` for why; this file records how it
deviates from the original Unity/Cursor master spec.

## Layers (dependencies point downward)
| Layer | Path | Notes |
|---|---|---|
| UI / rendering | `ui/` | Isometric `CustomPainter` city + interiors, screens, phone, HUD. |
| Services | `services/` | `LifeSaveService` (Firestore + SharedPreferences), `life_ai_service.dart` (OpenAI adapters). |
| Game controller | `game/life_game.dart` | `LifeGame`: the only mutator of player state; returns `ActionResult`. |
| Domain engines | `core/ economy/ education/ careers/ employment/ interview/ workplace/ business/ social/ world/` | Pure Dart, deterministic (`StableRandom`), JSON-serializable, unit-testable without Flutter. |

## Rules vs AI
Money, time, needs, grades, GPA, hiring decisions, salaries, promotions: deterministic code.
AI (`gpt-4o-mini` via `AppConfig`) only writes NPC dialogue, interviewer wording, résumé tips and work
feedback; it can nudge scores by at most ±2 (interview) / ±0.15 (work text) and always has an offline fallback.

## Flutter ↔ game
Same process, same widget tree: no bridge. `LifeSession` (ChangeNotifier) wraps `LifeGame`, shows toasts,
plays activity animations and debounces auto-save (3 s).

## Known deviations from the spec
Unity, WebGL hosting, 3D assets/animation rigs, Cloud Functions-based server authority and
streaming are **not** implemented. See `IMPLEMENTATION_PROGRESS.md`.
