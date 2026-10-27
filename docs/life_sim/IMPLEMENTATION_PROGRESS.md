# Implementation progress

## Done (verified by headless tests + analyzer)
Deterministic core, six career loops, university with GPA and graduation ceremony/certificates,
job hunting + interviews + offers/negotiation, economy/bills/shop/bank, needs incl. hygiene & stress,
NPC relationships, company ownership, cloud+local save, AI adapters with fallbacks, isometric city and
interiors, phone, status panel, calendar, map, character creator, Labs hub entry.

## Done but not device-verified
All Flutter UI/painters, Firebase and OpenAI adapters (analyzed against stubs; the app was never run).

## Not done
- Unity/3D, WebGL, asset pipeline (decision: Flutter CustomPainter).
- Server-authoritative Cloud Functions + locked-down rules.
- ~50 further courses/schools; AI professor lectures with live highlighting; code-execution sandbox for the coding arena.
- NPC schedules/movement through the city; minimap; animated interviewer rooms; group/second interviews.
- Speech input; audio; accessibility pass; performance profiling.

## Known issues
Painter visuals unreviewed on real screens; fast-travel for trips > 40 tiles uses a simple rule.
