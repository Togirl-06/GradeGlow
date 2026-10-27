# Firebase schema (as built)

| Path | Content |
|---|---|
| `users/{uid}/life_sim/save` | One JSON document: `LifeGame.toJson()` (`version`, avatar, clock, needs, economy, skills, resume, inbox, applications, job, university, company, relationships, certificates, position…) plus `savedAt`. |

Local mirror: SharedPreferences key `gradeglow_life_sim_save_v1`. On load the newer of cloud and local wins.
Existing rules already allow the owner to read/write `users/{uid}/**`.

## Security gap (important)
The save is client-authoritative: a modified client can write any balance, grade or salary to its own
document. The spec requires server-authoritative transactions. **Not implemented.** Plan:
1. Split `economy`, `university.grades`, `job` into server-owned documents (`users/{uid}/life_server/*`), writable only by Cloud Functions; deny client writes in `firestore.rules`.
2. Callable Functions: `lifePayday`, `lifePurchase`, `lifeSubmitExam`, `lifeApplicationOutcome` re-running the same pure-Dart/ported rules.
3. Client keeps cosmetic state (avatar, position, apartment layout).
Leaderboards or anything shared must not trust the current save.

## Server guard (`lifeSimGuard`)
Trigger on `users/{uid}/life_sim/save`. Compares the incoming save with `users/{uid}/life_server/checkpoint`
using `functions/life_sim/validate.js` limits (start cash 600; wealth ≤ 3000/day + 1500 slack; skills ≤ 25/day
+ 15 slack; ≤ 8 courses/day; degrees need passed courses). Accept → new checkpoint; implausible → save is
rolled back to the checkpoint and an event is written to `users/{uid}/life_server/events/*`. A first save is never
deleted. `life_server` is read-only for the owner in `firestore.rules`. Not deployed / not emulator-tested.
