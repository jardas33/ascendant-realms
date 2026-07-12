# v0.305 Route C Representative-Sector Visual Prototype Bake-Off

## Executive verdict

Route C is feasible, but should be revised once before any full Salto conversion. The real rendered prototype is substantially stronger than the rejected v0.303 procedural PLAYER board: buildings have volume, the bridge visibly spans a recessed river, roads sit in the land mass, and the oblique RTS camera reads tactically. The remaining visual gap is concentrated in the uniform water treatment and the inherited static billboard silhouettes.

Route C score: **79/100**. Visual verdict: **revise once**.

## Base HEAD and branch

- Base HEAD: `97961a78f282c990b2e11907a9a0df430135522c`
- Branch: `codex/v0215-v0226-recovery`
- Scope: isolated, opt-in visual prototype only.

## v0.304 recommendation carried forward

v0.304 recommended Route C: low-poly 3D terrain and buildings with billboard or sprite units. The strongest recovered reference is v0.141 R1, `v0141-env-r1-gameplay-first-barrosan`, retained here as reference-only. It is not imported into runtime.

## Prototype scope

The prototype is one representative East bridge / Field Barracks / river-crossing sector. It contains one recessed river, one authored bridge, connected road sections, two land masses, one imported Field Barracks module, one authored support building, three static billboard units, sparse rocks/trees/crates, directional lighting, and an isolated clean capture HUD.

Prototype scene: `desktop-spikes/godot-salto/scenes/salto_v0305_route_c_representative_sector.tscn`

Launch/capture command:

```text
npm run godot:capture:salto-route-c-representative-sector
```

The command starts the scene explicitly with Godot's `--scene` option and writes only to `artifacts/desktop-spikes/godot-salto/v0305/route-c-prototype/` before building the manual-review pack.

## Historical target used

`artifacts/manual-review/v0305-route-c-representative-sector-visual-prototype-bakeoff/historical-target/v0141-env-r1-gameplay-first-barrosan.png` is the v0.141 R1 reference recovered by v0.304. It is used for visual comparison only. Its wet granite, river/ford, bridge, quarry, ruins, and Barrosan highland composition remain the target quality bar, not runtime content.

## Current v0.303 comparison

The current v0.303 PLAYER capture is preserved at `current-v0303/v0303_player_overview_actual.png`. It remains the technical fallback/debug/proof renderer. The bake-off shows why it is not the intended final player-facing art direction: it is a flat procedural board with square pads, token-like units, broad overlays, and weaker terrain/building hierarchy.

## Route C implementation

### Camera/projection

The prototype uses one controlled orthographic oblique gameplay camera, a second oblique comparison angle, and one direct top-down frame. The primary view exposes building side faces and roofs while retaining tactical river, road, and bridge readability. There is no free camera, zoom redesign, or perspective distortion.

### Terrain

The land is two extruded low-poly terrain masses with visible side faces and a deliberate gap for the river. This prevents the first attempted full-land cutout from occluding the water. Building yards and bridge landings use small grounded patches rather than translucent debug pads.

### River and banks

The river is a segmented ribbon below the land plane with darker depth, bank earth, wet edge, and a restrained highlight layer. The manifest records `riverWaterY = -0.42` and `landTopY = 0.0`.

### Road integration

Roads are three-layer embedded ribbons: bed, surface, and central wear. West and east road sections terminate at the bridge landings, with a short Barracks approach. They are part of the sector surface language rather than floating panels.

### Bridge construction

The bridge is authored from a deck, individual planks, rails, posts, and two stone piers. It spans the river gap and creates readable depth under the deck. No gameplay bridge or pathing semantics are connected.

### Building geometry

The Field Barracks reuses the repository-authored v0.236 Barrosan GLB module, including pitched roof, eaves, timber, stone, base, and side-face depth. The smaller support building is authored from low-poly walls, a raised base, timber trim, door, two sloped roof planes, and a ridge.

### Unit billboard/sprite treatment

Aster, Defender, and Reserve Support use existing repository static billboard fallback PNGs on camera-facing `QuadMesh` nodes. Each has a restrained contact shadow; Aster has a small selection treatment. No locomotion, animation, targeting, or gameplay entity integration was added.

### Unit scale and grounding

Billboard heights are scaled relative to the Field Barracks and support building. Feet are placed above the land plane with a small, consistent contact shadow. The evidence shows the current silhouettes are readable but less authored than the buildings; this is the main candidate for the v0.306 refinement.

### Selection treatment

Aster's selection treatment is a muted, compact ground disc. It is subordinate to the unit silhouette and does not overlap the isolated selected-card panel.

### Lighting and shadows

One warm directional key and one cool ambient fill establish a consistent highland daylight direction. Shadows remain soft enough to preserve units and bridge details; no fake shadow rectangles or gameplay-zone shapes are used.

### Materials and Barrosan identity

The palette is weathered timber, warm stone, earth/road ochre, moss grass, and cool recessed water. The imported v0.236 module preserves the Barrosan roof and wall language. No lava, sci-fi crystal infrastructure, glossy mobile-game shading, or third-party game asset was introduced.

## HUD overlap status

The Route C capture path is **isolated-clean**: it renders a small prototype header and selected-card panel without the global `Select Aster.` prompt. The shared v0.303 runtime overlap diagnosed by v0.304 remains documented and intentionally unmodified in this visual-feasibility checkpoint. This avoids silently changing the accepted playable runtime while proving the prototype presentation can keep global instructions out of selected-card space.

## Three-way comparison

The directly comparable evidence is `contact-sheets/v0305_matching_framing_three_way_comparison.png`:

- A: v0.141 R1 historical target.
- B: actual v0.303 PLAYER runtime.
- C: actual v0.305 Route C render.

Route C wins over v0.303 on camera depth, bridge credibility, building volume, road integration, and tactical hierarchy. It remains below R1 on material richness, natural water/terrain variation, and unit-authored detail.

## Scorecard

| Category | Score |
| --- | ---: |
| Attractiveness | 78 |
| Closeness to strongest historical target | 70 |
| RTS readability | 87 |
| Terrain credibility | 82 |
| Bridge credibility | 88 |
| Building volume | 90 |
| Unit readability | 68 |
| Lighting/shadows | 82 |
| Barrosan identity | 78 |
| Technical feasibility | 86 |
| Maintainability | 85 |
| Performance risk | 82 |
| Asset burden | 90 |
| Animation burden | 92 |
| Suitability for full Salto conversion | 78 |

The overall score is 79/100. The recommendation is **proceed with Route C after one contained revision**, not a production-wide conversion.

## Technical isolation

The new scene inherits only safe visual helper conventions from the existing isolated Godot spike. It is not the project main scene, does not instantiate the accepted playable runtime skin, and writes to a v0.305 artifact root. The accepted v0.303 fallback/debug layer remains intact.

## What changed

- Added an isolated Route C representative-sector scene and script.
- Added genuine low-poly 3D land, recessed river, embedded roads, bridge construction, and support-building geometry.
- Reused the v0.236 authored Barrosan Field Barracks module without changing the source GLB.
- Added repository billboard units, contact shadows, selection treatment, lighting, and clean prototype HUD.
- Added deterministic capture tooling, scorecard, provenance, comparison sheets, black-frame rejection report, and validator.

## What did not change

- No accepted runtime scene, gameplay system, state chain, pressure behavior, resource/economy logic, stable ID, save, or default launcher changed.
- No movement, pathfinding, route following, combat, damage, HP, AI, waves, fog gameplay, or production logic changed.
- No full asset replacement, full renderer rewrite, or animation pipeline was started.

## Default-runtime preservation

The true default runtime remains `res://scenes/salto_spike_root.tscn`. The new scene is reachable only through the explicit v0.305 capture command. The manifest records `prototypeOptIn: true`, `prototypeOnly: true`, and all mutation flags false.

## Gameplay preservation

The prototype has no collision, input, navigation, commands, simulation tick, economy, pressure, or save integration. Units are visual nodes only. The v0.287–v0.304 accepted chain is untouched.

## Asset provenance

- v0.236 GLB: repository-authored Blender production-direction kit, reused as a visual module.
- Billboard PNGs: existing repository static fallback slots, used only in this prototype.
- Terrain, bridge, roads, support building, lighting, and HUD: authored in the v0.305 GDScript scene.
- Historical R1 and v0.303 images: copied into the review pack as reference/evidence only.
- Downloaded assets: 0. Generated AI assets: 0. Protected-game assets: 0.

## Performance observations

The sector is small, static, and uses one GLB module library plus simple meshes and three billboards. It is appropriate for a feasibility spike. The main future performance questions are full-map instance count, material batching, and billboard count; none are relevant to this isolated sector yet.

## Risks

The current water is visually uniform compared with R1. The inherited static billboard silhouettes are readable but still flatter and less distinctive than the building kit. The imported module library also needs an explicit production asset audit before any full Salto use.

## Recommendation

**Revise Route C once**, then re-score from rendered evidence. Do not migrate the accepted runtime yet. Route C is the strongest feasible direction because it solves the structural failure of v0.303 with a small, maintainable authored 3D layer while keeping units inexpensive.

## Exact v0.306 proposal

**v0.306 — Route C Water, Billboard Silhouette, and Material Cohesion Revision**

One more isolated bake-off pass only: improve river variation and bank transition, replace the three crude fallback silhouettes with one cohesive repository-authored Barrosan billboard treatment, and re-score the same sector/framing. No runtime migration, gameplay integration, or full Salto conversion.

## Review pack

`artifacts/manual-review/v0305-route-c-representative-sector-visual-prototype-bakeoff/`

The visual-quality sheet uses real rendered Route C frames. The technical sheet contains proof cards and retained fallback evidence. The pack includes the three-way comparison, scorecard, provenance, and black-frame rejection report.

## Validator

Dedicated command:

```text
npm run godot:validate:salto-route-c-representative-sector
```

Validator path: `tools/godot/saltoV0305RouteCRepresentativeSectorTool.mjs`.

## Validation evidence

Required local validation is run at closeout from this branch:

- dedicated v0.305 validator
- retained v0.304 and v0.303 validators
- `npm test`
- `npm run build`
- content, art-intake, and runtime-art-slot validation
- experimental artifact-retention validation
- `npm run godot:all`
- `git diff --check`

The final exact-SHA GitHub Actions run and final repository state are recorded in the closeout response after push.

## CI evidence

Pending the v0.305 commit SHA and exact pushed GitHub Actions run at initial report authoring; no CI claim is made before that run completes.

## Final repo state

Recorded after the final commit, push, exact-SHA CI verification, and clean-sync audit.
