# GradeGlow Life — rendering/engine decision

**Decision:** keep the existing Flutter + Firebase stack and render the world with a pure-Dart
isometric 2.5D `CustomPainter` engine (`lib/life_sim/ui/painters`). Game rules live in a
UI-independent, deterministic Dart core (`lib/life_sim/game`, `economy`, `employment`, `workplace`).

| Option | Verdict |
|---|---|
| **CustomPainter isometric (chosen)** | No new dependencies, works on every Flutter target (mobile/web/desktop), ships inside the current app and Firebase auth/profile, fully unit-testable logic, small bundle. Limits: no free camera, no skeletal 3D. |
| Flame (2D engine) | Good sprite/tilemap tooling, but adds a dependency and a second game loop/input stack for a world that is mostly menu-driven interactions; art pipeline needed. A reasonable future swap since the renderer only consumes `LifeGame` state. |
| flutter_scene / Impeller 3D | True 3D, but still experimental, needs glTF assets and baked pipeline, weak web support. Revisit when stable. |
| Unity / Unreal embed | Best visuals, but a separate runtime, build and asset pipeline; Firebase/AI integration and app-size/CI cost outweigh the benefit now. |

**Boundaries that keep the renderer swappable:** painters take only positions, look, action,
emotion and time; `LifeGame` knows nothing about Flutter widgets; `ActionType` → screen mapping lives
in `ui/screens/interactions.dart`.

**AI vs rules:** money, time, inventory, ranks, pay and pass/fail are deterministic
(`StableRandom`). AI (OpenAI via `AppConfig`) only writes NPC dialogue, interviewer questions
and feedback, bounded to ±2 points / ±0.15 around deterministic scores, with offline fallbacks.

**Persistence:** `users/{uid}/life_sim/save` in Firestore plus a local mirror (newest wins).

**Disclaimers:** medical/legal content is an educational simulation in the fictional jurisdiction
"Glowland"; it is not medical or legal advice.

## Update (Oct 2026): 3D on web
Students found the isometric painter did not feel like a real game. The web build now renders the same
world in real-time 3D with three.js (`web/life_world/`, vendored three r170, ~0.7 MB, no CDN), inside an
iframe, following the existing anatomy-viewer pattern. Because painters were already isolated from
`LifeGame`, no rules moved: the 3D page is a renderer plus input. Native apps keep the painter until a
WebView or native 3D path is chosen (adding `webview_flutter` would let them reuse the same page).
