# v0.413 Main-House Masonry Value Hierarchy

## Scope

v0.413 is an opt-in, material-only calibration of the live main-house exterior masonry wall nodes. It starts from accepted v0.412 and changes only the albedo/value, roughness, specular response, and vertex-colour influence of the dynamically identified visible masonry wall inventory.

## Baseline and branch

- Base commit: `5a064c8df089336f71324b0c477d5b48578f560b`
- Branch: `codex/v0215-v0226-recovery`
- Runtime scene: `desktop-spikes/godot-salto/scenes/v0413_main_house_masonry_value_hierarchy.tscn`
- Capture command: `npm run godot:capture:v0413-main-house-masonry`
- Smoke command: `npm run godot:smoke:v0413-main-house-masonry`

## Why this pass exists

The accepted slate roof now supplies the primary house silhouette and surface detail, but the imported wall body still reads too uniformly pale in the settlement view. The narrow correction gives the masonry a subordinate, coherent value family so the roof, openings, timber, foundation, terrain, and bridge remain legible without adding geometry, texture noise, or a new asset.

## Live inventory and candidate

The runtime audit dynamically identified three visible masonry nodes: `LOD0_Granite`, `LOD1_Granite`, and `LOD2_Granite`. Nearby roof, ridge, eave, chimney, interior recess, door/window, timber, iron, foundation, stair, ground, and collision roles were inventoried and excluded. The retained material is `V0413_Main_House_Restrained_Masonry` with albedo `#81786d`, roughness `0.96`, specular `0.10`, and vertex-colour albedo disabled.

## Visual evidence

- Wide colour: main house reads as coherent masonry beneath the accepted slate roof; bridge, landings, river, road, and barn remain unchanged.
- House close colour: wall planes separate from roof, timber framing, openings, chimney, and foundation without texture seams or overlay surfaces.
- Wide and close grayscale: masonry, slate, timber, openings, road, water, and bridge retain distinct value bands.
- Temporary diagnostic: each affected live wall node is identified one at a time; the diagnostic is absent from final player-facing captures.
- Comparisons: v0.412 baseline is paired directly with v0.413 at wide and house-close framing.

Review pack: `artifacts/manual-review/v0413-main-house-masonry-value-hierarchy/`

## Preservation

The audit records original/final materials, every affected mesh UV count, vertex/index/triangle/surface counts, transforms, AABBs, house hashes, excluded nearby nodes, and mesh-instance counts. `materialOnly=true`; geometry, topology, indices, vertices, surfaces, transforms, AABBs, UV arrays, inherited vertex colour, overlays, decals, duplicate meshes, and new mesh instances remain unchanged. v0.412 bridge calibration, v0.408 house roof, v0.409 barn roof, route, landings, characters, props, camera, lighting, gameplay, state behaviour, default runtime, fallback renderer, and debug renderer are preserved.

## Validation

Dedicated validator: `npm run godot:validate:v0413-main-house-masonry` (`tools/godot/saltoV0413MainHouseMasonryValueHierarchyTool.mjs`). The retained v0.412/v0.411/v0.410/v0.409/v0.408/v0.407/v0.406/v0.401/v0.400 validators, full local validation, and CI evidence are recorded here after closeout.

Local validation passed:

- v0.413 dedicated validator: material-only candidate; 3 dynamic wall nodes; 7 real captures.
- v0.412 and v0.411 dedicated validators: material-only bridge candidates retained.
- v0.410 and v0.409 dedicated validators: accepted fail-closed limitations retained.
- v0.408, v0.407, v0.406, v0.401, and v0.400 dedicated validators.
- `npm test`: 887 tests across 122 files.
- `npm run build`.
- `npm run validate:content`.
- `npm run validate:art-intake`.
- `npm run validate:runtime-art-slots`.
- artifact-retention validator.
- `npm run godot:all`.
- `git diff --check`.

## Closeout

- Implementation commit: `91cc16f14a76a0493fd93f4ea5c2a96030f1d95b`.
- Implementation GitHub Actions: run `30378457274` — success for the exact implementation SHA.
- Documentation closeout commit: `7b66de94f093f6fa8f3017e35e3c86c64ce5665a`.
- Documentation closeout GitHub Actions: run `30379410552` — success for the exact documentation SHA.
- Final repository state after the documentation closeout push: tracked working tree clean and branch synchronized with origin at `0` ahead / `0` behind. The repository retains the pre-existing untracked artifact backlog outside this checkpoint; no unrelated files were staged or deleted.
