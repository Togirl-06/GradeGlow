# Science Labs Spec

**Biology ≠ Chemistry ≠ Physics.** Shared chrome; distinct experiments.

## Principle

Science Career Labs are **playable educational simulation games**, not quiz lists or textbook pages.

Loop: **Mission → Briefing → Investigate → Interact → Record → Solve → Feedback → Unlock**

## Visual assets

Prefer **real scientific photographs** (anatomy plates in `assets/anatomy/*_real.png`) with source/license metadata in `science_asset_catalog.dart`. Use accurate diagrams when photos are unavailable. Never invent fake medical photos.

Interactive image modes: **VIEW · LABEL · ANNOTATE · MEASURE · QUIZ · EXPLAIN** (`science_interactive_image.dart`).

## Shared package

`lib/vu_v2/career_labs/playable/science/shared/`

| File | Role |
|------|------|
| `science_lab_theme.dart` | Dark lab palette + accent presets |
| `science_notebook_store.dart` | SharedPreferences notebook + XP |
| `science_notebook_screen.dart` | Notes / Diagrams / Experiments |
| `science_drawing_canvas.dart` | Annotate over any diagram |
| `science_interactive_image.dart` | Work-the-image modes |
| `science_asset_catalog.dart` | Licensed asset registry |
| `science_career_ranks.dart` | Student → researcher ranks |
| `science_mission_briefing.dart` | AI Lab Instructor briefing |
| `science_hub_screen.dart` | Stations · hero · current mission |
| `science_badges.dart` | Badge ids |

## Anti-patterns (forbidden)

- Multiple-choice quiz dumps as the “lab”
- One **Complete Lab** button with no interaction
- Cartoon fake anatomy presented as real photos
- Instant “Reveal Answer”
- Copy-paste identical Biology/Chemistry/Physics flows

## Rule of thumb

**Experiments are the game.** Stations open tools. Students collect evidence in the notebook.
