# v0.416 Main-House Chimney Material Hierarchy

## Scope

v0.416 is an opt-in, material-only calibration of existing visible main-house chimney body and separately isolatable cap/crown surfaces. It begins from closed v0.415 and does not reopen the foundation/step gate.

## Baseline and implementation

- Base commit: `73bbc22d0137a11b4a2cd0f377dbe9157e6f2c7c`
- Branch: `codex/v0215-v0226-recovery`
- Scene: `desktop-spikes/godot-salto/scenes/v0416_main_house_chimney_material_hierarchy.tscn`
- Capture command: `npm run godot:capture:v0416-main-house-chimney`
- Smoke command: `npm run godot:smoke:v0416-main-house-chimney`
- Dedicated validator: `npm run godot:validate:v0416-main-house-chimney`
- Review pack: `artifacts/manual-review/v0416-main-house-chimney-material-hierarchy/`

The runtime dynamically inventories visible existing MeshInstance3D nodes under the accepted main-house root and classifies only `CHIMNEY_BODY` and, when separately isolatable, `CHIMNEY_CAP_OR_CROWN`. Roof, ridge, eaves, walls, openings, timber trim, foundation, threshold, barn, bridge, terrain, props, and hidden/empty meshes remain excluded.

## Material treatment and evidence

The live inventory found no semantically isolatable visible chimney body or cap MeshInstance3D surface under the accepted main-house root. The rendered chimney is therefore not a permitted material-only target in this asset representation. The checkpoint remains fail-closed as `ASSET_MATERIAL_LIMITATION_MAIN_HOUSE_CHIMNEY`; no candidate material was retained. Seven real colour/grayscale/diagnostic/comparison captures and the complete preservation audit are retained without overstating a visual candidate. No UV-dependent treatment, geometry, replacement cap, smoke, overlay, decal, camera, lighting, layout, gameplay, or state change was introduced.

## Preservation

The audit records affected and excluded inventories, functional classification, original/final material parameters, UV counts, mesh snapshots, hashes, transforms, AABBs, counts, nested v0.415 evidence, and material-only preservation flags. v0.409, v0.410, v0.415, accepted masonry/roof/openings/trim/foundation/step work, terrain, route, bridge, barn, characters, props, camera, lighting, gameplay, default runtime, fallback renderer, and debug renderer remain authoritative.

## Validation and closeout

The dedicated validator accepts the exact fail-closed limitation and checks that the v0.415 nested audit, material-only preservation flags, complete inventory fields, and no-new-mesh contract remain present. The review pack contains seven nonblank real captures plus `v0416-preservation-audit.json`. Retained v0.415 through v0.400 validators are green, including the v0.409, v0.410, and v0.415 fail-closed gates. Full tests/build/content/art/runtime/artifact validation, `npm run godot:all`, and `git diff --check` are green locally. Exact commit and Actions evidence are added during closeout.

## Final evidence

- Implementation commit: `abcf228532ae4773a5b129beb674a85e2145f3ef`
- Exact-SHA GitHub Actions: run `30392928292` (`CI Release Matrix Dry Run`) - success
- Final branch: `codex/v0215-v0226-recovery`
- Final tracked repository state: clean and synchronized with origin (`0 ahead / 0 behind`)
- Unrelated pre-existing untracked artifacts were preserved and were not included in the checkpoint commit.
