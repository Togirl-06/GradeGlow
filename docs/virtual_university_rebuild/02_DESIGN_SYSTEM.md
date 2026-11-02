# 02 — Design System  
## GradeGlow Virtual University V2

**Prototype freeze:** Do not restyle old widgets in place. Build `package:gradeglow_vu_ds` (or `lib/vu_v2/design/`) as a new design system used only by V2 routes.

---

## 1. Brand foundation

| Token | Value | Usage |
|-------|-------|-------|
| Brand name | GradeGlow | App-wide |
| Product | Virtual University | Campus product line |
| Tagline | Learn by doing — not just memorizing | Onboarding, campus |
| Logo | `assets/images/gradeglow_logo.png` | Nav, splash |
| Navy | `#0F172A` | Dark surfaces |
| Glow Orange | `#F97316` | Primary CTA / brand pulse |
| Glow Yellow | `#FBBF24` | Highlights, XP |
| Glow Deep | `#EA580C` | Pressed / emphasis |
| Ink | `#F8FAFC` | Primary text on dark |
| Mute | `#94A3B8` | Secondary text |
| Success | `#22C55E` | Correct / complete |
| Warning | `#F59E0B` | Due soon |
| Danger | `#EF4444` | Errors / fail |
| Info | `#38BDF8` | Tips |

**Faculty secondary accents** (never replace brand orange as primary CTA):
- Biology `#10B981` · Chemistry `#06B6D4` · Physics `#6366F1` · Math `#A78BFA`  
- CS `#22D3EE` · Engineering `#F472B6` · Law `#FBBF24` · Business `#34D399`  
- Medicine `#F43F5E` · Nursing `#14B8A6` · Psychology `#C084FC` · English `#60A5FA`

**Anti-patterns:** purple-on-white generic AI look; cream+terracotta cliché; flat single-color pages; dashboard card grids in heroes.

---

## 2. Typography

| Role | Spec |
|------|------|
| Display | 32/38, weight 800, tracking -0.5 |
| Title | 22/28, weight 800 |
| Headline | 18/24, weight 700 |
| Body | 15/22, weight 500 |
| Label | 12/16, weight 700, tracking 0.2 |
| Caption | 11/14, weight 600 |

Prefer expressive fonts already in app if licensed; else **Plus Jakarta Sans** (UI) + **Source Serif 4** (long reading). Avoid Inter/Roboto/Arial as brand voice.

---

## 3. Grid & layout

- Mobile base: 16px page gutter, 8px rhythm  
- Max content width web: 1120px  
- Campus first viewport: **one composition** (brand/campus signal + one CTA + one dominant visual)  
- Course pages: sticky professor strip optional; body scrolls  
- Never put stats strips + announcements + tools all in first viewport  

---

## 4. Components

### Buttons
- `VuPrimaryButton` — orange fill, 48–52h, radius 14  
- `VuSecondaryButton` — outline  
- `VuGhostButton` — text  
- `VuDangerButton` — destructive  
States: default / pressed / disabled / loading  

### Cards
Default: **no decorative cards**. Cards only when they contain an interaction (continue lesson, submit assignment). If border/shadow/radius can be removed without hurting understanding, remove them.

### Forms
Labeled fields, 48h inputs, clear error text under field, never toast-only validation.

### Modals & sheets
Modals for blocking decisions (upgrade, submit). Sheets for AI Tutor, filters, quick notes.

### Navigation
- Student: bottom `NavigationBar` (5 tabs)  
- Web: left rail + top context bar  
- Course: nested top tabs (Home / Modules / Discuss / Grades)  

### FAB
Single global **Ask AI Tutor** FAB on Learn/Lesson surfaces; hide on paywall/camera.

### Progress
Linear (module), circular (course mastery), step (onboarding). Always show label + %.

### Charts
Sparkline grade trend; radar skills; bar time-on-task. Use brand orange + mute grid.

### Tables
Assessments & admin only; mobile becomes stacked rows.

### Empty / Loading / Error
Every list requires:
- Skeleton shimmer (not infinite spinner alone)  
- Empty illustration + one CTA  
- Error with retry + support link  

---

## 5. Glassmorphism

Allowed only for:
- Campus map overlays  
- AI Professor stage chrome  

Rules: blur ≤16, opacity ≥0.55, always solid fallback when reduce-transparency / low GPU.

---

## 6. Iconography & illustration

- Icons: rounded Material Symbols or custom set; consistent 24dp  
- Illustrations: subject-world scenes (lab bench, courtroom, clinic)  
- AI Professor: illustrated avatar per faculty + optional short loop animation  

---

## 7. Motion guidelines

| Motion | Duration | Easing | Use |
|--------|----------|--------|-----|
| Micro | 120–180ms | standard | presses |
| Transition | 280–350ms | emphasized | page |
| Campus enter | 450ms | decelerate | building |
| Progress fill | 400ms | standard | bars |

Ship ≥2 intentional motions per visually led screen. Respect `VuReduceMotion` / system setting — replace with crossfade/opacity.

---

## 8. Voice & tone

- Speak like a great TA: clear, encouraging, specific  
- Prefer “Let’s try this example” over “As an AI language model…”  
- Errors: human, actionable steps  
- Premium: respectful, never dark-pattern spam  

---

## 9. Component library checklist (build order)

1. Color + type + spacing tokens  
2. Buttons, inputs, progress  
3. App scaffold + nav  
4. Professor stage  
5. Module list + lesson blocks  
6. Simulation chrome  
7. Notes editor toolbar  
8. Paywall sheet  
9. Empty/error/skeleton  
10. Charts  

---

## 10. Screen specification template

Every V2 screen doc must include:
- Purpose (1 sentence)  
- Entry points / exits  
- Layout regions  
- Components used  
- States (loading/empty/error/success)  
- Analytics events  
- Acceptance criteria  
- A11y notes  
