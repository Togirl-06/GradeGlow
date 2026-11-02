# Health Simulation — rendering approach

## Decision

**Primary:** Photographic anatomy plates in `assets/anatomy/*_real.png`
(heart, respiratory, skeleton, organs, neuron). Shown in
`AnatomyViewerScreen` with orbit/zoom and organ strip selection.

**Optional (web only):** Three.js schematic at `web/health_3d/anatomy_viewer.html`
via `HtmlElementView`. Animated capsules for spatial layout — clearly labeled
as schematic, not real organs. Opt-in from the side panel.

**Why not Unity:** Hosting target is Flutter Web; Unity embed adds a second build
pipeline and binary size without enough gain for the current milestone.

**Licensed GLB meshes:** Registry entries remain for Phase+ procurement
(`assets/health_3d/models/*.glb`). When GLBs ship, load them with `GLTFLoader`
in the HTML shell as a photoreal 3D upgrade path.

## Asset registry

See `models/asset_registry.dart`.
