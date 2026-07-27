# v0.410 Bridge Deck Timber Surface Readability

## Scope

v0.410 is a narrow, opt-in material-only readability study for the existing bridge walking deck. It may assign one repository-authored timber material and permitted material parameters to the existing 18 visible deck plank nodes. It does not edit mesh UVs, topology, vertices, indices, transforms, AABBs, bridge structure, route geometry, or gameplay.

## Base and branch

- Base commit: `1083ce84f90e983c66879ea095631203f200ebaa` (accepted v0.409 final)
- Branch: `codex/v0215-v0226-recovery`
- Scene: `desktop-spikes/godot-salto/scenes/v0410_bridge_deck_timber_surface_readability.tscn`
- Opt-in capture: `npm run godot:capture:v0410-bridge-deck-timber`
- Opt-in smoke: `npm run godot:smoke:v0410-bridge-deck-timber`

## Treatment

The study targets exactly `Bridge_Deck_Plank_00` through `Bridge_Deck_Plank_17`. The permitted treatment is the existing repository-authored v0338 timber albedo, restrained UV scale, roughness, and disabling inherited vertex tint only at the deck material boundary. Rails, posts, edge beams, understructure, supports, abutments, footings, landings, route, camera, lighting, characters, props, barn, gameplay, fallback renderer, debug renderer, and true default runtime remain unchanged.

## Evidence gate

The runtime capture emits wide colour, bridge-deck close colour, grayscale counterparts, a temporary non-black four-plank material-ID diagnostic, matched v0.409/v0.410 wide and close comparisons, and a preservation audit. The candidate is retained only when the deck reads as weathered timber without stretching, oversized grain, seams, dark blocks, wall-like texture, rail contamination, bleeding, or checker artifacts. If any existing plank lacks usable authored UV arrays, the checkpoint fails closed as `ASSET_UV_LIMITATION_BRIDGE_DECK`; no material candidate is retained and the diagnostic evidence remains available.

v0.409's `ASSET_UV_LIMITATION_SECONDARY_BARN_ROOF` result remains preserved. This checkpoint does not reopen the barn roof.

## Preservation and validation

The dedicated validator is `npm run godot:validate:v0410-bridge-deck-timber`. It verifies all 18 deck names, material-only contracts, UV/mesh preservation, bridge structural preservation, evidence dimensions, and the fail-closed or retained-candidate audit state. The review pack is `artifacts/manual-review/v0410-bridge-deck-timber-surface-readability/`.

The retained ladder passed: `npm run godot:validate:v0409-secondary-barn-roof`, `npm run godot:validate:v0408-main-house-roof`, `npm run godot:validate:v0407-eastern-landing`, `npm run godot:validate:v0406-western-footing`, `npm run godot:validate:v0401-character-grounding`, and `npm run godot:validate:v0400-house-roof`. The dedicated v0.410 validator and smoke/capture commands passed, with the audit in the fail-closed UV-limitation state. Full repository validation passed: `npm test` (887 tests / 122 files), `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run validate:runtime-art-slots`, `npm run validate:artifact-retention`, `npm run godot:all`, and `git diff --check`. The rendered wide, close, grayscale, diagnostic, and comparison frames were manually inspected; they are real non-blank captures, and no rejected material candidate was retained.

## Final review rule

This is a material feasibility checkpoint, not an automatic adoption. If the authored UV/material path produces a stretched or structurally contaminated deck, the truthful result is `ASSET_UV_LIMITATION_BRIDGE_DECK` and the accepted v0.409 baseline remains the player-facing result. No black or otherwise rejected candidate is packaged as a success.

## CI and final state

- Implementation commit: `c0e6cb1cca08f52d9608cc51ea35733fb23aeabe`
- Exact-SHA GitHub Actions: run `30244302470` — success
- The final documentation closeout commit and its exact-SHA CI run are recorded here after push.
- The intended tracked checkpoint files are committed; unrelated pre-existing untracked artifact backlog remains untouched.
