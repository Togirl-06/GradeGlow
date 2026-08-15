# GradeGlow Virtual University — Rebuild Spec Package

**Status:** Ground-up rebuild PRD (current app = prototype only)  
**Product:** GradeGlow Virtual University  
**North star:** Become the #1 AI-powered educational app in the US  
**Rule:** Do **not** edit the existing Flutter UI to “patch toward” this vision. Implement V2 as a new product surface (new routes, new design system, new architecture). Reuse backend services, content catalogs, and AI prompts only where they accelerate V2.

---

## Package contents

| File | Purpose |
|------|---------|
| [01_PRD.md](./01_PRD.md) | Vision through roadmap (Sections 1–37) |
| [02_DESIGN_SYSTEM.md](./02_DESIGN_SYSTEM.md) | Brand, components, motion, accessibility |
| [03_TECHNICAL_SPEC.md](./03_TECHNICAL_SPEC.md) | IA, roles, DB, APIs, AI behavior, security |
| [04_CURSOR_IMPLEMENTATION_PROMPTS.md](./04_CURSOR_IMPLEMENTATION_PROMPTS.md) | Module-by-module Cursor build prompts |
| [05_ROADMAP_ACCEPTANCE.md](./05_ROADMAP_ACCEPTANCE.md) | Milestones, acceptance criteria, QA checklist |

---

## Non-negotiable build principles

1. **Prototype freeze** — Existing screens are reference only.
2. **Learning by doing** — Every lesson includes practice or simulation.
3. **AI Professor is the classroom** — Not a chat bolt-on.
4. **Faculty identity** — Each school has its own world, palette accents, and simulators.
5. **Premium must feel worth it** — Offline, unlimited AI, advanced sims, career tools.
6. **Ship in vertical slices** — Campus shell → one faculty end-to-end → expand.

---

## Recommended first vertical slice (MVP of V2)

1. New app shell + Virtual Campus home  
2. Onboarding (goals → major → placement → study plan)  
3. One faculty end-to-end (recommend **Computer Science** or **Biology**)  
4. Course Home → Modules → Lesson → AI Professor → Quiz → Progress  
5. Notes + AI Tutor FAB + Premium gate  

Only after that slice feels world-class: add remaining faculties, community, research center, admin.
