# Visual Labs Spec

**THE LABS MUST BE INTERACTIVE VISUAL SIMULATIONS, NOT TEXTBOOK PAGES.**

## Rule

Career Labs visual stations are hands-on UIs:

| Kind | Interaction |
|------|-------------|
| IDENTIFY | Tap the correct structure on a diagram |
| LABEL | Drag / type / annotate labels onto hotspots |
| ASSEMBLE | Drag parts into named slots |
| MEASURE | Dial a virtual instrument; enter the reading |
| OBSERVE | Move param sliders; watch simulation; record what changed |
| GRAPH | Tap to plot points; interpret the trend |
| INTERPRET | Read ECG / curves / imaging; pick the meaning |
| PRIORITIZE | Drag items into ranked Immediate→Low slots |
| PATHTRACE | Tap the next node in sequence |
| PRACTICAL EXAM | Chain 2–3 stations; supervisor score gate |

## Anti-patterns (forbidden)

- A single **Complete Lab** button with no interaction
- Long textbook paragraphs as the “lab”
- Multiple-choice only with no visual canvas (except as secondary check after observing)

## Engine entry

```dart
await runVisualLab(context, spec);
// or
await runVisualLabById(context, 'med_heart_label');
```

Catalog: `visual_lab_catalog.dart` — ≥2–3 labs + one `practical_exam_*` per career id.
