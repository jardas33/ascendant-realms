# v0.427 Resident-Worker Primary-Garment Value Hierarchy

## Scope and baseline

v0.427 is a single opt-in, material-only readability calibration for the existing `V0389_Resident_Worker`. It starts from final v0.426 commit `a3c89a9677437ca39c613d946fb0bc0610b46b49` on `codex/v0215-v0226-recovery`. The pre-existing untracked artifact backlog is intentionally preserved.

Only visible imported surfaces whose authored material name is exactly `LightBlue` are admitted as `RESIDENT_WORKER_PRIMARY_GARMENT`. The worker remains the authored `res://assets/third_party/quaternius/v0370/men/Farmer.gltf`; the source `.gltf`, skeleton, skin binding, pose, scale `0.90`, vertical correction `-0.03`, X/Z placement and all other characters remain unchanged.

## Original inventory and bounded candidate

The runtime inventory records every descendant mesh, surface index, material name, mesh/surface/UV counts, transform and AABB. It records the complete excluded material inventory (`Skin`, `Brown`, `Beige`, `Brown2`, `Eyebrows`, `Red`, `Eye`) and excludes `V0389_Crossing_Guard` and `V0389_Traveller_Porter`.

The candidate is an instance-local duplicate named `V0427_Resident_Worker_Primary_Garment`. It changes only the admitted surface override to muted slate-blue `#4f6770`, roughness `0.96`, specular `0.08`, metallic `0.00`, preserving alpha, transparency, blending, culling, shading, vertex-colour behavior and authored textures from the original material. The imported source material is never edited.

If the live surface boundary cannot be proven, v0.427 fails closed with `ASSET_MATERIAL_LIMITATION_RESIDENT_WORKER_PRIMARY_GARMENT` rather than broadening the material scope.

## Preservation

This is not a character-model, animation, transform, lighting, shadow, camera, gameplay, selection, movement, AI or layout change. Geometry, topology, vertices, indices, normals, tangents, surfaces, UVs, skeleton, skin binding, pose, scale, grounding, other characters, buildings, barn, bridge, route, river, terrain, props, default runtime, fallback renderer and debug renderer remain unchanged. No outline, emission, billboard, decal, badge, duplicate mesh or new `MeshInstance3D` is added.

## Real visual evidence

The required real Godot evidence is stored in `artifacts/manual-review/v0427-resident-worker-primary-garment-value-hierarchy/`:

- `01_PRIMARY_RTS_COLOUR.png`
- `02_RESIDENT_WORKER_GARMENT_CLOSE_COLOUR.png`
- `03_THREE_CHARACTER_CONTEXT_COLOUR.png`
- `04_RESIDENT_WORKER_GARMENT_CLOSE_GRAYSCALE.png`
- `05_TEMPORARY_RESIDENT_WORKER_GARMENT_NODE_ID.png`
- `06_V0426_V0427_WIDE_COMPARISON.png`
- `07_V0426_V0427_WORKER_CLOSE_COMPARISON.png`
- `v0427-preservation-audit.json`

The wide frame uses the accepted RTS camera. The close frame includes the complete worker silhouette, face, hands, feet, contact and settlement context. The three-character frame keeps worker, guard and traveller together. The temporary diagnostic uses non-black material highlighting and is absent from player-facing captures. Black, blank, cropped or title-card-only evidence is rejected.

## Commands

- `npm run godot:play:v0427-resident-worker-garment`
- `npm run godot:smoke:v0427-resident-worker-garment`
- `npm run godot:capture:v0427-resident-worker-garment`
- `npm run godot:validate:v0427-resident-worker-garment`

The dedicated validator checks the exact worker/material boundary, source identity, instance-local override, excluded inventory, candidate bounds, preservation audit, real capture dimensions and opt-in package/router wiring. The retained v0.426-v0.400 ladder is run before closeout.

## Validation and closeout

The live Godot inventory admitted exactly two visible `LightBlue` slots under the worker: `Farmer_Body` surface `1` and `Farmer_Pants` surface `0`. Ten other worker surface slots were excluded. The worker contains four mesh descendants. The audit records `sourceAssetChanged: false`, `geometryChanged: false`, `skeletonChanged: false`, `poseChanged: false`, `groundingChanged: false`, `otherCharactersChanged: false`, `lightingChanged: false`, `newMeshInstances: 0`, and `candidateRetained: true`.

Human inspection passed. `01_PRIMARY_RTS_COLOUR.png` is a real wide RTS frame; `02_RESIDENT_WORKER_GARMENT_CLOSE_COLOUR.png` shows the complete worker, face, hands, feet and settlement context; `03_THREE_CHARACTER_CONTEXT_COLOUR.png` shows worker, guard and traveller together; `04_*GRAYSCALE.png` remains non-black; `05_*NODE_ID.png` is a temporary non-black diagnostic with the worker highlighted and the excluded materials named; and both matched comparison frames are real rendered v0.426/v0.427 views. The slate-blue garment is restrained, cloth-like and environmentally separated without a faction-marker glow, saturation spike or change to the other characters. No black, blank, cropped, title-card-only or diagnostic-only player-facing frame was accepted.

The dedicated validator passed:

`PASS_V0427_RESIDENT_WORKER_PRIMARY_GARMENT_VALUE_HIERARCHY_VALIDATOR (instance-local LightBlue surface candidate; source, pose, grounding, geometry and other characters preserved; 7 real captures)`

The retained validator ladder passed for every available command from v0.426 through v0.400: v0.426, v0.425, v0.424, v0.423, v0.422, v0.421, v0.420, v0.419, v0.418, v0.417, v0.416, v0.415, v0.414, v0.413, v0.412, v0.411, v0.410, v0.409, v0.408, v0.407, v0.406, v0.401 and v0.400. The repository contains no v0.402-v0.405 validator scripts or package commands; those absent checkpoints were not silently represented as passes.

The full local validation passed:

- `npm run godot:smoke:v0427-resident-worker-garment`
- `npm run godot:capture:v0427-resident-worker-garment`
- `npm run godot:validate:v0427-resident-worker-garment`
- retained v0.426-v0.400 ladder above
- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run validate:runtime-art-slots`
- `npm run validate:artifact-retention`
- `npm run godot:all`
- `git diff --check`

The implementation is limited to the opt-in router, package commands, v0.427 scene/script/wrappers, validator, report and generated v0.427 evidence. Commit and exact-SHA Actions evidence are appended after the explicit-file commit and push.

Record the final dedicated validator output, retained ladder, full local validation, exact commit, exact-SHA GitHub Actions result, report/review-pack paths, and final clean synchronized state here before closeout.
