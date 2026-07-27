# v0.411 Bridge Rail and Post Value-Hierarchy Calibration

## Scope

v0.411 is a narrow, opt-in material-only calibration for the existing four bridge rails and twelve visible vertical support posts. It changes only their albedo/value, roughness, specular response, and inherited vertex-colour influence. Bridge deck, geometry, topology, transforms, AABBs, footings, abutments, underbeams, edge courses, route, landings, buildings, barn, characters, props, camera, lighting, gameplay, fallback renderer, debug renderer, and true default runtime remain unchanged.

## Base and commands

- Base commit: `b1f9c717f4ba0bdd7f5bd93d3d72c8001ee4240f`
- Branch: `codex/v0215-v0226-recovery`
- Scene: `desktop-spikes/godot-salto/scenes/v0411_bridge_rail_post_value_hierarchy.tscn`
- Capture: `npm run godot:capture:v0411-bridge-rail-post`
- Smoke: `npm run godot:smoke:v0411-bridge-rail-post`
- Validator: `npm run godot:validate:v0411-bridge-rail-post`

## Visual treatment and evidence

The affected existing nodes are `Bridge_Rail_+1_High`, `Bridge_Rail_+1_Low`, `Bridge_Rail_-1_High`, `Bridge_Rail_-1_Low`, and `Bridge_Post_+1/-1_00` through `_05`. The calibrated family is restrained weathered timber: darker than the deck, lighter than near-black, distinct from warm-earth landings, and subordinate to the settlement. No authored UVs are required for this value-only treatment.

The review pack contains wide and close colour, wide and close grayscale, a temporary material-ID diagnostic naming every affected node, matched accepted-baseline comparisons, and preservation JSON. The diagnostic is temporary and is not present in final player-facing frames.

## Preservation and fail-closed rule

The audit records original/final materials, counts, transforms, AABBs, affected node names, bridge hashes, camera state, and unchanged runtime contracts. If the rails/posts become black, glossy, washed out, patchy, brighter than the settlement, indistinguishable from the deck, or inconsistent between sides, the result is `ASSET_MATERIAL_LIMITATION_BRIDGE_RAIL_POSTS` with no retained candidate. v0.409 and v0.410 fail-closed evidence remains preserved; neither the barn roof nor bridge-deck material work is reopened.

## Validation and closeout

The retained ladder is the v0.410 fail-closed validator, v0.409 fail-closed validator, and v0.408 through v0.400 accepted validators, followed by repository tests/build/content/art/runtime/artifact/Godot checks and `git diff --check`. Exact local and CI results are recorded at closeout after manual inspection of the real colour and grayscale renders.
