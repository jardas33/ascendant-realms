# v0.418 Secondary-Barn Openings Value Hierarchy

## Scope

This opt-in checkpoint calibrates only the three existing visible secondary-barn opening surfaces: the entrance door and the two front-window recesses. It does not reopen v0.409-v0.417 and does not change geometry, UVs, gameplay, camera, lighting, layout, or the true default runtime.

## Baseline and inventory gate

- Base commit: `02edf9d0e469bf11ea9d3597a5768f62c422e757`
- Branch: `codex/v0215-v0226-recovery`
- Accepted wall body: v0.417 preserved
- Required live roles: `BARN_ENTRANCE` and two `BARN_WINDOW_RECESS` surfaces
- Expected nodes: `V0399_Barn_Entrance_Door`, `V0399_Barn_Front_Window_-2_25`, `V0399_Barn_Front_Window_2_25`
- Fail-closed status: `ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_OPENINGS`

The runtime inventory is authoritative. A candidate is retained only when exactly the three expected visible MeshInstance3D surfaces are present and no additional visible door/window surface is discovered.

## Material treatment

The entrance uses the bounded existing-surface material `#4a3b32`, roughness `0.97`, specular `0.08`. Both windows use the identical material `#454946`, roughness `0.93`, specular `0.12`. Vertex-colour influence is disabled. No texture or UV-dependent treatment is used.

The intended hierarchy is a slightly warmer entrance, matched cool-grey window recesses, and an unchanged v0.417 wall body and surrounding timber frame. The openings remain subordinate details, not black holes, bright inserts, emissive planes, transparency, overlays, decals, replacement geometry, or duplicate meshes.

## Preservation

The audit records the complete opening inventory, excluded adjacent components, original/final materials, mesh snapshots, counts, transforms, AABBs, UV counts, hashes, and inherited v0.417 audit. Material-only flags are explicit: geometry/topology/vertices/indices/surfaces/transforms/AABB/UV arrays unchanged, zero new MeshInstance3D nodes, no gameplay/state/default/fallback/debug renderer mutation.

## Evidence and commands

- Runtime evidence: `desktop-spikes/godot-salto/artifacts/runtime/v0418/`
- Review pack: `artifacts/manual-review/v0418-secondary-barn-openings-value-hierarchy/`
- Launch: `npm run godot:play:v0418-secondary-barn-openings`
- Smoke: `npm run godot:smoke:v0418-secondary-barn-openings`
- Capture: `npm run godot:capture:v0418-secondary-barn-openings`
- Validator: `npm run godot:validate:v0418-secondary-barn-openings`

The pack contains real wide and close colour captures, grayscale captures, an explicit temporary node-ID diagnostic, matched v0.417/v0.418 comparisons, and the preservation audit. The diagnostic is temporary and is not used in player-facing captures.

Retained validation covers v0.417 through v0.400, including accepted fail-closed gates, followed by tests, build, content/art/runtime/artifact validation, `npm run godot:all`, and `git diff --check`.

## Rendered observation

The real v0.418 wide capture is nonblank and preserves the accepted Salto bridge, river, road, main house, secondary barn, props, and characters. The close capture shows the entrance and both front windows as readable dark inset details within the existing wall and timber frame; the entrance remains warmer than the matched windows, and none reads as an emissive or transparent insert. The grayscale and matched v0.417/v0.418 comparisons remain restrained, with no visible geometry or layout drift. The diagnostic names all three affected nodes and is retained only as audit evidence.

## Local validation record

- `npm run godot:smoke:v0418-secondary-barn-openings` — passed
- `npm run godot:capture:v0418-secondary-barn-openings` — passed; seven real PNG captures plus audit
- `npm run godot:validate:v0418-secondary-barn-openings` — passed; three exact opening nodes
- Retained validators: v0.417, v0.416, v0.415, v0.414, v0.413, v0.412, v0.411, v0.410, v0.409, v0.408, v0.407, v0.406, v0.401, v0.400 — passed
- `npm test` — 122 files / 887 tests passed
- `npm run build` — passed
- `npm run validate:content` — passed
- `npm run validate:art-intake` — passed
- `npm run validate:runtime-art-slots` — passed
- `npm run validate:artifact-retention` — passed
- `npm run godot:all` — passed
- `git diff --check` — passed

The repository-provided package has no v0.402-v0.405 dedicated validator commands; the retained ladder therefore covers every available command in the v0.400-v0.417 range.

## Closeout evidence

Commit and exact GitHub Actions evidence are recorded at push closeout. The intended final state is the tracked tree clean and synchronized with `origin/codex/v0215-v0226-recovery`; the unrelated pre-existing untracked artifact backlog remains untouched.

## Decision

The candidate is retained only if the rendered evidence confirms that the entrance and both windows are immediately locatable, matched where required, distinct from the wall and frame, and still subordinate to the main house. Otherwise the checkpoint closes honestly with `ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_OPENINGS` and no workaround geometry.
