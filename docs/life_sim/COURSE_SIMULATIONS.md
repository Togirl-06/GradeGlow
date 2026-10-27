# Course simulations (as built)

Each career has its own workplace building, NPCs, stations and task bank (`workplace/content/*_tasks.dart`).
A task is a `WorkScenario` of stages (choice, ordering, fill-in, free text, etc.) with deterministic scoring.

| Career | Degree | Workplaces | Example tasks |
|---|---|---|---|
| Software Engineer | deg_cs | Pixelforge-type tech firms | tickets, bug fixes, code review |
| Nurse | deg_nursing | hospital | vitals, handover, medication-safety checks |
| Doctor | deg_medicine | hospital | history, tests, differential, plan |
| Lawyer | deg_law | law firms / courthouse | evidence, contracts, argument drafting |
| Accountant | deg_accounting | accounting firms | journal entries, reconciliations, audit flags |
| Business Manager | deg_business | corporate HQ | staffing, budgets, strategy |

Skills gained per task feed promotion requirements. Medical/legal scenarios are educational only.

## Not yet built (spec §9–§14)
The remaining ~50 courses (biology/chemistry labs, pharmacy, anatomy explorer with synchronised
highlighting, engineering, arts, etc.) and AI-professor lectures with live highlighting. The scenario
framework is data-driven, so new careers/courses are added as content files plus catalog entries.

## Pharmacy (PHA101–PHA203)
Pharmaceutical chemistry, pharmacology, dispensing calculations, clinical pharmacy, law & ethics (4 exam questions each).
Workplace scenarios: interaction screening, counselling, dispensing order, controlled-medicines register,
adverse reaction, stewardship, formulary budget, plus generated weight-based dose and reorder-point tasks.
Educational simulation only (fictional Glowland, fictional drugs).
