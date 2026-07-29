# v0.366 Barrosan House02 and Barn Forked Clean-Mesh Prototype

## Executive result

**READY FOR HUMAN V0366 BARROSAN HOUSE02 AND BARN FORKED CLEAN-MESH PROTOTYPE REVIEW.** This checkpoint is an isolated visual prototype only. It stops before any canonical asset replacement or production integration.

## Scope and lineage

- Base HEAD: `82a0dfb1f58bbb1651c29893b9414fa6b73a553a`
- Branch: `codex/v0215-v0226-recovery`
- Canonical House02: `desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb`
- Canonical Barn: `desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn`
- Prototype scene: `desktop-spikes/godot-salto/scenes/rework/barrosan/v0366/V0366BarrosanHouse02AndBarnForkedCleanMeshPrototype.tscn`

The v0.365 human-approved presence/state truth is retained. v0.366 addresses only the next authorized question: whether the three observed visual regions can be removed from isolated derived mesh forks without hiding their broad parent nodes.

## Derived mesh method

The prototype loads the canonical source scenes into a review-only fixture, duplicates the relevant scene instances, and replaces only the target `MeshInstance3D.mesh` on the duplicate with a newly built `ArrayMesh`. Each source surface is preserved with its existing material. Triangle-connected components are enumerated using quantized vertex connectivity and component AABBs; only the reviewed component envelopes are excluded. The canonical left comparison remains visible and unmodified.

- House02 A: front-ground stone projection, removed from `LOD0_Granite` across its matching material surfaces.
- House02 B: upper strange timber bracket/scaffold, removed from the upper timber component islands while doors, windows, frames, roof and walls remain.
- Barn C: front timber pen/trough/platform cluster, removed across its merged material surfaces while the barn shell, roof and stone walls remain.

This is actual triangle removal. It is not a parent visibility toggle, material alpha trick, terrain cover, or production scene edit.

### Derived-mesh ledger

The capture manifest at `artifacts/runtime/v0366/capture/v0366-manifest.json` records the following source-to-derived deltas. Surface counts and material identities are preserved while the reviewed connected components are removed from the derived forks.

| Fork | Source triangles | Derived triangles | Removed triangles | Source/derived surfaces |
| --- | ---: | ---: | ---: | ---: |
| House02 A | 7,024 | 6,836 | 188 | 4 / 4 |
| House02 B | 4,324 | 3,384 | 940 | 1 / 1 |
| Barn C | 3,252 | 2,504 | 748 | 6 / 6 |

All three records report `deltaIsGeometry=true`, distinct derived mesh signatures, and zero canonical, production, gameplay, placement, transform, stable-ID, save, and default-runtime mutations. No new performance benchmark is introduced by this checkpoint.

## Review fixture and evidence

Capture command:
`npm run godot:capture:salto-v0366-barrosan-house02-and-barn-forked-clean-mesh-prototype`

Pack command:
`npm run godot:pack:salto-v0366-barrosan-house02-and-barn-forked-clean-mesh-prototype`

Dedicated validator:
`npm run godot:validate:salto-v0366-barrosan-house02-and-barn-forked-clean-mesh-prototype`

Review pack:
`artifacts/manual-review/v0366-barrosan-house02-and-barn-forked-clean-mesh-prototype/UPLOAD_TO_CHAT/`

The eight PNGs are direct Godot viewport captures from the isolated fixture. They cover the decision scope, exact original/clean pair, House02 A and B removals, House02 preservation, Barn C removal, Barn preservation, and the derived-mesh/mutation ledger. The pack contains exactly ten upload files, including the README and compact JSON summary.

## Preservation and boundaries

Preserved: canonical assets, accepted production scenes, authority slots, gameplay state, terrain, roads, bridge, worker scale, stable IDs, saves, default runtime, and all v0.365 lineage. No movement, pathfinding, route following, combat, damage, AI, waves, fog, economy, resource, placement, transform, or gameplay mutation is introduced. The fixture uses matching source instances and paired transforms for comparison; it does not write derived assets into production paths.

Canonical source hashes at the v0.365 base remain: `BarrosanBarnGold.tscn` `ffaf4c4eeb7c0dabc3a483b0137ad2d92d2b2f6dd496b84b86584ae4a7e86a4a`, accepted Barn GLB `0b4944d8a15006664dad84cec5e8b41546497588d14194d5b2e49621071e209c`, and House02 GLB `ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89`.

## Human decision gate

The derived meshes are not approved production replacements. Human review must decide whether A, B, and C are the intended cleanup targets and whether the preserved architecture is sufficient. Do not integrate, register, replace, or begin a production cleanup pass from this checkpoint without explicit approval.

## Validation and closeout

The dedicated validator checks the exact base, source paths, canonical Barn hash, real derived triangle deltas, surface/material preservation, no parent-hide trick, no gameplay integration, zero mutation ledger, exact ten-file pack, readable UTF-8, nonblank PNG dimensions, and human-review stop. Retained v0.365 and earlier validators plus repository test/build/content/art/runtime/Godot gates are run before closeout. The implementation commit `2bb029de31988c08cc7d2be433c6b9973e0449a2` passed exact-SHA GitHub Actions run `29884265263` (`CI Release Matrix Dry Run`, run 535) with conclusion `success`; the final documentation-only closeout commit is separately verified by its own exact-SHA run and recorded in the closeout response.

Final state requirement: clean and synced with origin, `0 ahead / 0 behind`.
