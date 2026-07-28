# v0.415 Main-House Foundation and Entry-Step Grounding

## Scope

v0.415 is an opt-in, material-only calibration of the existing visible main-house foundation/plinth and entry-step/threshold nodes. It begins at accepted v0.414 and leaves masonry, slate roof, doors, windows, timber trim, terrain, route, bridge, gameplay, state, default runtime, fallback renderer, and debug renderer unchanged.

## Baseline and implementation

- Base commit: `25990fcc63513cacb08dc7b1310b418f58d92bf2`
- Branch: `codex/v0215-v0226-recovery`
- Scene: `desktop-spikes/godot-salto/scenes/v0415_main_house_foundation_step_grounding.tscn`
- Capture command: `npm run godot:capture:v0415-main-house-foundation-step`
- Smoke command: `npm run godot:smoke:v0415-main-house-foundation-step`
- Dedicated validator: `npm run godot:validate:v0415-main-house-foundation-step`
- Review pack: `artifacts/manual-review/v0415-main-house-foundation-step-grounding/`

The implementation dynamically inventories visible existing MeshInstance3D nodes across the loaded world, classifying only cleanly isolated `FOUNDATION_OR_PLINTH` and `ENTRY_STEP_OR_THRESHOLD` components. Masonry, accepted v0.414 openings/trim, roof, terrain, route, bridge, barn, characters, props, and collision remain excluded. No fixed count is assumed and the pass fails closed as `ASSET_MATERIAL_LIMITATION_MAIN_HOUSE_FOUNDATION_STEPS` when both roles cannot be isolated.

## Material treatment and visual evidence

The runtime inventory found three visible `LOD*_Damp_Foundation` nodes, but the visible `V0395_Door_Threshold_Stone` entry-threshold node has no mesh surface available for a material-only assignment. The pass therefore remains fail-closed as `ASSET_MATERIAL_LIMITATION_MAIN_HOUSE_FOUNDATION_STEPS`; no candidate material was retained. The diagnostic identifies the three foundation nodes and the real wide/close colour and grayscale captures plus v0.414 comparisons remain available for review. A future repair may revisit the missing step surface only with a separately authorized scope; v0.415 does not add replacement geometry.

## Preservation

The audit records complete affected and excluded inventories, classifications, original/final materials and parameters, UV counts, mesh snapshots, world vertex hashes, transforms, AABBs, mesh counts, and material-only preservation flags. No geometry, topology, indices, vertices, surfaces, UV arrays, transforms, AABBs, overlays, decals, duplicate meshes, new MeshInstance3D nodes, lighting, camera, layout, gameplay, or state behavior changes are permitted. v0.414 openings/trim and the earlier masonry/roof chain remain authoritative.

## Validation and closeout

The dedicated validator accepts the fail-closed limitation, including the recorded three-node foundation inventory and the absence of a falsely classified entry-step surface. Retained v0.414 through v0.400 validators are green; this includes the accepted v0.409/v0.410 fail-closed gates. The refreshed review pack contains seven nonblank real scene/diagnostic/comparison captures and the preservation audit. Full tests, production build, content/art/runtime/artifact validation, `npm run godot:all`, and `git diff --check` are green locally. No v0.415 candidate is retained: the exact result is `ASSET_MATERIAL_LIMITATION_MAIN_HOUSE_FOUNDATION_STEPS` because `V0395_Door_Threshold_Stone` exposes no mesh surface for a permitted material-only assignment. Exact commit and GitHub Actions evidence are added during closeout.

## Final evidence

- Implementation commit: `5d7e572bc3a15af026e077538ce9343464a19394`
- Exact-SHA GitHub Actions: run `30388869527` (`CI Release Matrix Dry Run`) — success
- Final branch: `codex/v0215-v0226-recovery`
- Final tracked repository state: clean and synchronized with origin (`0 ahead / 0 behind`)
- Unrelated pre-existing untracked artifacts were preserved and were not included in the checkpoint commit.
