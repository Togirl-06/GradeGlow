# GradeGlow Life — Architecture

GradeGlow Life lives inside the existing Flutter app (`lib/life_sim/`) and is launched from the
University Labs hub (`lib/vu_v2/labs/vu_v2_labs_hub.dart` → `LifeGameLauncher`).
**It is not a Unity game.** See `../life_sim_engine_decision.md` for why; this file records how it
deviates from the original Unity/Cursor master spec.

## Layers (dependencies point downward)
| Layer | Path | Notes |
|---|---|---|
| UI / rendering | `ui/` + `web/life_world/` | **Web:** real-time 3D city and cut-away rooms (three.js, `web/life_world/`) shown in an iframe via `ui/world3d/`. **Mobile/desktop apps:** isometric `CustomPainter` city + interiors. Screens, phone and HUD are Flutter on every platform. |
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

## 3D world (web)
`web/life_world/index.html` renders the open city and building interiors in 3D: procedural Sims-style
characters (built from the player's avatar profile, with work uniforms), a distinct model for every
building, day/night lighting, traffic, pedestrians, cut-away walls and furniture for every interactable.
It contains **no game rules**. `LifeGameScreen` (`ui/screens/life_game_screen.dart`) streams JSON over
`postMessage`:

| Direction | Message | Purpose |
|---|---|---|
| Dart → page | `gg-scene` (`mode: city / interior`) | City grid + buildings, or the room's items and NPCs, plus the player's look. Sent when the scene changes or the page reports ready. |
| Dart → page | `gg-frame` (every tick) | Player position, action, emotion, time/daylight, nearby item/NPC, NPC positions, closed buildings. |
| page → Dart | `gg-tap` | Tap resolved to a tile, building, item, NPC or the exit; handled exactly like a painter tap. |
| page → Dart | `gg-move` / `gg-key` | Camera-relative WASD steps; E (use), P (phone), M (map). |
| page → Dart | `gg-ready` / `gg-error` | Page loaded (resend scene) / no WebGL (fall back to the 2D painter). |

Players can switch between the 3D world and the classic map from the ⋯ menu. Open
`/life_world/index.html?demo=1` for a standalone preview (data generated from Dart by
`tool/gen_life_world_demo.py`; useful params: `scene=<buildingId>`, `time=HH:MM`, `near=<buildingId>`).

## Known deviations from the spec
Unity, licensed 3D assets/animation rigs, native 3D on the mobile apps, Cloud Functions-based server
authority and streaming are **not** implemented (the web 3D view uses procedural low-poly models). See `IMPLEMENTATION_PROGRESS.md`.
