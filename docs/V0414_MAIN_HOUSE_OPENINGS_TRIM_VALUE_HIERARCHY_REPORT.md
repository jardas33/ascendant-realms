# v0.414 Main-House Openings and Timber-Trim Value Hierarchy

## Scope

v0.414 is an opt-in material-only calibration of existing visible main-house doors, windows, and exterior timber trim. It starts from accepted v0.413 and leaves masonry, roof, geometry, gameplay, state, default runtime, fallback renderer, and debug renderer unchanged.

## Baseline and live inventory

- Base commit: `77b2b2289f76754cbc0644727f6c2e05ba216b69`
- Branch: `codex/v0215-v0226-recovery`
- Runtime scene: `desktop-spikes/godot-salto/scenes/v0414_main_house_openings_trim_value_hierarchy.tscn`
- Capture command: `npm run godot:capture:v0414-main-house-openings-trim`
- Smoke command: `npm run godot:smoke:v0414-main-house-openings-trim`
- Review pack: `artifacts/manual-review/v0414-main-house-openings-trim-value-hierarchy/`

The dynamic runtime inventory classifies visible `LOD*_Interior_Recess` as `DOOR`, `LOD*_Recessed_Window` as `WINDOW`, and `LOD*_Weathered_Timber` as `TIMBER_TRIM`. Masonry, roof, ridge/eave, chimney, foundation/stairs, iron, collision, barn, bridge, and props remain excluded. The retained candidate contains nine visible nodes: three nodes in each category.

## Material treatment and evidence

The retained materials are restrained flat materials: door `#514139`, window frame `#62655f`, and timber trim `#584437`, with roughness/specular tuned for readable but non-glossy openings. The wide/close color and grayscale captures, per-node diagnostic, and v0.413 comparison frames are stored in the review pack. The diagnostic is temporary and absent from final player-facing renders. Independent inspection confirmed that doors and windows are locatable, no black voids or overbright accents appear, and the roof remains the strongest architectural accent.

## Preservation

The audit records complete affected and excluded inventories, role classification, original/final materials and parameters, UV counts, inherited vertex-colour state, mesh snapshots, hashes, transforms, AABBs, mesh counts, and preservation flags. No geometry, topology, indices, vertices, surfaces, UV arrays, transforms, AABBs, overlays, decals, duplicate meshes, new MeshInstance3D nodes, lighting, camera, layout, gameplay, or state behavior changed. v0.413 masonry and v0.408 slate roof remain authoritative.

## Validation and closeout

Dedicated validator: `npm run godot:validate:v0414-main-house-openings-trim` — PASS (`RENDERED_CANDIDATE`, 9 dynamic opening/trim nodes, 7 real captures). The retained v0.413 through v0.400 ladder is green, including the accepted fail-closed v0.409 and v0.410 validators. Repository validation is green: 887 tests across 122 files, production build, content validation, art-intake validation, runtime-art-slot validation, artifact-retention validation, `npm run godot:all`, and `git diff --check`.

The implementation commit, exact GitHub Actions result, and final clean/synced repository evidence are added after the bounded v0.414 files are committed and pushed.
