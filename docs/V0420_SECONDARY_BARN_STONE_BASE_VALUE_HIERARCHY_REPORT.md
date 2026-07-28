# v0.420 Secondary-Barn Stone-Base Value Hierarchy

## Scope and baseline

This is one opt-in, material-only calibration of the existing visible secondary-barn stone base/plinth. It starts from `50d8879dd12e1800bbd0835421483194f6103f1c` on `codex/v0215-v0226-recovery`. The accepted v0.409-v0.419 chain and pre-existing untracked artifact backlog are preserved.

The exact target is `V0399_Barn_Stone_Base`, classified `BARN_STONE_BASE`. The separate `V0399_Barn_Contact_Shadow` remains excluded and unchanged.

## Inventory gate and candidate

The opt-in script dynamically verifies exactly one visible material-addressable base surface, the exact target node, no additional visible base/foundation/footing/plinth/sill surface, and a separate visible contact-shadow node. The initial candidate is `V0420_Secondary_Barn_Stone_Base` with albedo `#514c45`, roughness `0.98`, specular `0.06`, and inherited vertex-colour albedo disabled. It is intended to be darker/cooler than the v0.417 wall, lighter than v0.418 openings, distinct from the contact shadow and terrain, and subordinate to the barn walls.

If the boundary cannot be proven, the checkpoint fails closed with `ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_STONE_BASE` and retains no candidate.

## Preservation

Only the existing target material override is changed. The barn geometry, silhouette, position, scale, transform, grounding and contact shadow remain unchanged. v0.417 walls, v0.418 openings, v0.419 gable, roof, ridge, eaves, frame, terrain, route, bridge, landings, main house, characters, props, camera, lighting, gameplay, state behavior, true default runtime, fallback renderer and debug renderer remain unchanged. The audit records zero new meshes and false geometry/topology/index/vertex/surface/UV/transform/AABB/overlay/decals/duplicate-mesh flags.

## Evidence

The capture path writes colour and grayscale wide/close views, a non-black diagnostic identifying the base and separately naming the excluded contact shadow, and matched v0.419/v0.420 comparisons. The real rendered evidence shows four restrained groups - wall, base, terrain and contact shadow - without a dark stripe, bright pedestal, floating slab, black/plastic/plaster read or route-coloured contamination.

## Commands and validation

- `npm run godot:smoke:v0420-secondary-barn-stone-base`
- `npm run godot:capture:v0420-secondary-barn-stone-base`
- `npm run godot:validate:v0420-secondary-barn-stone-base`

The closeout ran the retained v0.419-v0.400 ladder including fail-closed gates, full tests/build/content/art/runtime/artifact validation, `npm run godot:all`, and `git diff --check`. The review pack is `artifacts/manual-review/v0420-secondary-barn-stone-base-value-hierarchy/` and contains seven real rendered captures plus `v0420-preservation-audit.json`.

## Closeout

The real colour, grayscale, diagnostic and comparison captures were inspected before acceptance. The candidate is retained as a one-node material-only change.

## Final closeout

- Implementation commit: `808267fdaf80fcfa589258c765b523670a76d325`
- Implementation exact GitHub Actions run: `30406607767` - `CI Release Matrix Dry Run` - success
- Final documentation-closeout commit: `939103ce0fd262e02f58805cc2730de070d4acba`
- Final documentation-closeout exact GitHub Actions run: `30407290805` - `CI Release Matrix Dry Run` - success
- Branch: `codex/v0215-v0226-recovery`
- Review pack: `artifacts/manual-review/v0420-secondary-barn-stone-base-value-hierarchy/`
- Final repository state: clean tracked tree and synchronized branch after the documentation closeout push.
