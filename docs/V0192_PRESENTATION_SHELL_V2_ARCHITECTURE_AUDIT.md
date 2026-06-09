# v0.192 Presentation Shell V2 Architecture Audit

Status: `PASS_V0192_PRESENTATION_SHELL_V2_ARCHITECTURE_AUDIT`

Scope: documentation-only human-review override after v0.191. No images were generated, no art slots were added, no runtime implementation was started, no launcher was changed, and no browser, gameplay, pathing, collision, objective, AI, save, stable-ID, production-manifest, or default-launcher path was mutated.

## Human Review Override

The prepared bridge-riverbank material integration prompt is superseded for this checkpoint. The selected v0.189 wet-granite derivative remains preserved as private-comparator evidence only:

- Selected file: `artifacts/desktop-spikes/godot-salto/v0189/local-bridge-riverbank-material-slot/barrosan_wet_granite_bridge_riverbank_material_v0189_1024.png`
- Selected SHA-256: `638ce153d7a3d39db729dfa13ba05f3fb05c437c2802ab91b5cd248bd2036753`
- Posture: comparator-only, not player-facing, not integrated.

Human review correctly identifies that adding a stone material now would decorate weak geometry instead of fixing the presentation architecture. The current bottleneck is still the environment-shell composition.

## Baseline And Read Scope

Baseline verified before edits:

- Required starting commit: `18ea52c7ad4c8d9981d4b03c2bd954ccf3993e81`.
- Branch state: `main...origin/main`.
- Upstream parity: `HEAD...@{u} = 0 0`.
- Working tree: clean before v0.192 edits.

Read/audited:

- `LLM_GAME_HANDOFF.md`.
- All v0.184 through v0.191 shell, cleanup, material-readiness, and implementation docs.
- `docs/art-prompts/V0192_01_RECOMMENDED_NEXT_PHASE.md` as the superseded material recommendation.
- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`.
- `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`.
- Current five-slot plus ground/road material opt-in wrapper pattern.
- Current riverbank/bridge/approach launcher and validation wrapper.
- Selected ground, road, and wet-granite material sources, metadata, derivatives, and hashes.
- Salto artifact retention index and cleanup tooling.
- v0.141/v0.142 reference-only environment lock docs.
- Browser/default-launcher boundary notes.

## Current Shell Weakness

The current R1 shell is technically bounded and opt-in, but visually it remains a stack of corrective layers. Earlier milestones tried to solve readability incrementally: v0.173 terrain foundation, v0.174 road/river/bridge/site readability, v0.179 contrast harmonization, v0.184 geometry convergence, v0.185 overlay pruning, v0.186 structure shell hardening, and v0.187 riverbank/bridge approach hardening. Those layers mostly preserve safety, but the composed result still reads like many thin translucent rectangles placed over broad rectangular grounds.

Specific visual weaknesses:

- Roads are still a collection of wide bands, centerlines, collars, and tick overlays rather than route-shaped surfaces.
- The river has continuity nodes, but the underlying read is still a narrow vertical stripe with bend joins and top layers.
- Banks frame the river with lip strips instead of forming coherent terrain edges.
- The bridge is better than the earlier crossing, but it is still made from stacked deck, shadow, abutment, rail, tick, and collar boxes.
- Structures gained useful hierarchy, yet they remain many box details around simple block masses.
- Characters are technically grounded by contact shadows and review rings, but the shell below them is busy enough that they can still feel detached.
- The orthographic camera and transparent z-order values make layer stacking visible; alpha sorting is doing presentation work that geometry should carry.

## Environment Visual-Node Classification

| Category | Current source | Classification | v0.192 decision |
| --- | --- | --- | --- |
| Gameplay truth | `salto_spike_workload_runtime.gd` state for units, structures, sites, Lume links, objectives, wave state, resources, and selections | Authoritative gameplay state | Preserve unchanged and read-only for v2. |
| Collision/pathing truth | Runtime fixture positions, click radii, site capture radii, bridge traversal smoke path, pathing/navigation adapters, and stable-ID adapters | Authoritative interaction truth | Preserve unchanged. Shell v2 must not add collision/pathing nodes. |
| Visual-only surfaces | Terrain root meshes from `_create_terrain`, environment layer helpers, structure shells, road/river/bank/bridge primitives | Presentation only | Legacy path remains comparator/fallback; v2 gets parallel compositor. |
| Debug markers | Validation status, runtime reports, artifact counts, benchmark metadata | Evidence only | Keep in artifacts/docs, not as player-facing visual clutter. |
| Review overlays | Rings, labels, contact shadows, road/bridge read ticks, minimap correlation, review labels | Human-review helpers | Keep minimal in v2; old overlays remain only in old comparator path. |
| Obsolete residue | No existing shell-v2 implementation or launcher found. No unknown v2 residue found. | None for v2 | Do not delete legacy evidence; preserve until explicit cleanup approval. |

## Counted Shell Evidence

Current v0.187 R1 runtime evidence reports:

| Metric | Count / value | Evidence |
| --- | ---: | --- |
| Total visual node count | `660` | `artifacts/desktop-spikes/godot-salto/v0187/validation/r1-riverbank-bridge-approach/player-slice-validation-runtime.json` |
| MeshInstance3D count | `657` | same |
| Visible marker/ring count | `15` | same |
| Large transparent diagnostic pads kept by earlier gate | `0` | same |
| Broad pads reframed as grounding cues | `8` | same |
| Ground material applied surfaces | `2` | `v0173_terrain_mid_value_field`, `v0173_friendly_staging_value_field` |
| Road material applied surfaces | `3` | `v0173_main_road_wide_readable_bed`, `v0173_barracks_side_path_wide_bed`, `v0173_ruins_side_path_wide_bed` |
| Barracks material applied surfaces | `11` | Barracks-only status |

Code-level inventory of the legacy opt-in shell helpers used by the current family of environment paths:

| Surface family | Counted calls / nodes | Notes |
| --- | ---: | --- |
| Broad pads / ground cues | `8` runtime-reframed broad cues; `35` pad/ground/ridge-named code records across audited legacy helper blocks | Earlier gates classify these as cues, but human review still sees rectangular layering. |
| Road strips / route cues | `43` road/lane/path/collar-named code records across audited blocks | Road readability is distributed across beds, crowns, lanes, collars, ticks, and transition overlays. |
| River strips / water cues | `21` river/water/ford-named code records | River continuity exists but remains strip-led. |
| Bank strips | `12` bank-named code records | Banks read as lip strips rather than shaped terrain. |
| Bridge nodes | `16` bridge/plank/abutment/rail-named code records in audited blocks, plus loop-expanded plank/tick repetition | Crossing is still layered from separate box components. |
| Structure blocks | `20` structure/mine/barracks/command/roof/wall/scaffold records in audited blocks, plus fixture-specific detail loops | Useful hierarchy but not yet coherent masses. |
| Marker nodes | `15` visible runtime marker/ring nodes; `14` marker/ring/site code records in audited blocks | Necessary for review and objectives, but v2 should keep overlays sparse. |
| Transparency layers | `89` transparent call sites in audited legacy blocks | This is the main presentation-architecture smell. |

These counts are not a failure of the earlier gates; they explain why passing benchmark/readability gates did not create a visually coherent battlefield shell.

## Material Binding Review

| Material/source | Current binding | Geometry quality | Decision |
| --- | --- | --- | --- |
| Barrosan foothold ground | Two opt-in broad field surfaces | Useful but still pad-like | Preserve opt-in; v2 should map it to fewer coherent terrain surfaces. |
| Barrosan foothold road | Three opt-in wide road beds | Promising texture, weak route geometry | Preserve opt-in; v2 should bind it to route-following road ribbons. |
| Barracks material | Eleven Barracks-only structure surfaces | Best scoped binding today | Preserve existing Barracks binding. |
| Wet-granite bridge-riverbank | Private comparator selected derivative only | Not player-facing | Preserve for later; do not integrate until v2 geometry is reviewed. |

## Z-Order And Camera Limits

The legacy shell uses explicit Y layering to keep surfaces readable, for example river core below bank lips, banks below bridge deck, bridge rails above the deck, and markers above all. This works for deterministic proof, but it makes the scene look assembled from semi-transparent plates. The fixed orthographic camera reinforces the issue: thin horizontal primitives and transparent pads are easy to inspect, but they do not create a natural world surface.

Shell v2 should keep explicit z-order, but the order should be encoded into a smaller set of opaque or lightly tinted coherent surfaces instead of many overlapping translucent boxes.

## Decision

Preserve the current R1 shell as comparator and fallback. Build one parallel opt-in `presentation shell v2` path in the next authorized milestone. The old path is valuable because it is validated, benchmarked, and safe. It should remain available for rollback and side-by-side review while v2 attempts a cleaner composition.

Gate result: v0.192 audit passed. v0.193 is prepared as a prompt only and not started inside this checkpoint.
