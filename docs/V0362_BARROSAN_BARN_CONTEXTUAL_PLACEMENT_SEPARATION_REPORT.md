# v0.362 Barrosan Barn Contextual Placement Separation

## Executive result

`v0.362` is a narrow, opt-in fixture transform repair for the Barrosan Barn contextual placement. The canonical Barn gold asset remains frozen. The repaired opt-in fixture translates only the Barn root from `(-1.800, 0.180, -1.000)` to `(4.000, 0.180, -1.000)`, preserving rotation and scale. The final measured structural gap is `2.480`, the roof/eave gap is `2.510`, and the required worker clearance is `1.875`.

The review pack is deliberately human-review gated:

`READY FOR HUMAN V0362 BARROSAN BARN CONTEXTUAL PLACEMENT SEPARATION REVIEW`

## Scope and boundaries

- Base HEAD: `0019238a4fc293315c433d7640001ff92964f3e9` (accepted v0.361)
- Branch: `codex/v0215-v0226-recovery`
- Authorized slot: `barrosan_barn_gold_v0355`
- Prototype scene: `res://scenes/review/V0362BarrosanBarnContextualPlacementSeparation.tscn`
- Runtime script: `desktop-spikes/godot-salto/scripts/v0362_barrosan_barn_contextual_placement_separation.gd`
- Capture command: `npm run godot:capture:salto-v0362-barrosan-barn-contextual-placement-separation`
- Pack command: `npm run godot:pack:salto-v0362-barrosan-barn-contextual-placement-separation`
- Validator command: `npm run godot:validate:salto-v0362-barrosan-barn-contextual-placement-separation`

The only authorized mutation is the opt-in Barn root translation. There is no canonical scene edit, geometry edit, material edit, texture edit, roof edit, shutter edit, House02 edit, worker gameplay edit, terrain edit, river/bridge/road edit, rotation edit, scale edit, default-runtime edit, collision edit, navigation edit, pathfinding edit, economy edit, combat edit, resource edit, save edit, browser edit or stable-ID edit.

## Why the repair is needed

The accepted v0.357/v0.359 opt-in fixture placed House02 and the Barn so their authored world-space bounds intersected. That made the contextual scene read as one fused mass and did not leave a credible ordinary RTS passage. The v0.362 repair keeps both gold assets unchanged and corrects only their fixture context.

## Placement and measurement method

The runtime computes world-space transformed mesh AABBs by transforming every endpoint of every MeshInstance3D local AABB through its global transform. It computes XZ interval overlap and closest separated distance for combined House02/Barn bounds. A second pass selects authored roof/eave meshes by name tokens (`roof`, `ridge`, `eave`, `slate`, `shutter`, `gable`) and repeats the relation for the roof subset. Worker clearance uses the retained worker width reference of `1.250`, multiplied by `1.5`, with a hard floor of `0.750`.

Final measured values:

- Structural AABB intersection: `false`
- Horizontal XZ overlap depth: `0.000`
- Structural closest horizontal clearance: `2.480`
- Roof/eave intersection: `false`
- Roof/eave overlap depth: `0.000`
- Closest roof/eave clearance: `2.510`
- Worker width reference: `1.250`
- Required worker clearance: `1.875`
- Worker-clearance gate: `true`
- Ordinary RTS gap visible: `true`
- House02 meshes / roof meshes: `24 / 4`
- Barn meshes / roof meshes: `16 / 15`

## Canonical asset and mutation ledger

- Canonical scene: `desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn`
- Canonical scene SHA256: `ffaf4c4eeb7c0dabc3a483b0137ad2d92d2b2f6dd496b84b86584ae4a7e86a4a`
- Canonical source SHA256: `13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3`
- Canonical roof SHA256: `0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9`
- Canonical asset / geometry / material / texture mutations: `0 / 0 / 0 / 0`
- Canonical transform mutation: `0`
- Fixture Barn root position mutation: `1`
- Fixture Barn root rotation / scale mutation: `0 / 0`
- Changed non-Barn node count: `0`
- Duplicate Barn root count: `0`

## Runtime isolation

The default scenario instantiates zero Barn instances. The valid opt-in scenario loads exactly one Barn instance. The rollback scenario removes the Barn and reports a clean baseline state. The capture manifest proves the retained R0/R2 pixel match. The four inherited fail-closed cases remain present: missing scene, hash mismatch, invalid authority and unknown slot.

The gap worker used in the close evidence is explicitly capture-only. It is an existing worker scene placed in the measured open corridor for scale evidence. It does not add collision, navigation, pathfinding, movement, AI or gameplay semantics.

## Review evidence

The upload pack contains exactly ten files: eight 1600x900 PNG boards, one strict UTF-8 README and one compact JSON summary. Every board contains actual non-headless Godot-rendered imagery. The boards cover the repaired decision, identical-camera before/after, transformed bounds and clearance, clean Player separation, worker scale, rear/roof separation, default/opt-in/rollback, and the hash/mutation ledger. Runtime manifests remain outside the upload pack for machine validation.

Review pack:

`artifacts/manual-review/v0362-barrosan-barn-contextual-placement-separation/UPLOAD_TO_CHAT/`

The rejected before image shows the original fused/intersecting placement. The repaired wide and gap images show two separate structures and an ordinary usable-looking passage. The measurement image is DEBUG_REVIEW evidence only; it does not alter the Player/default path.

## Accepted lineage preserved

v0.361 aggregate metric and UTF-8 truth closeout, v0.360 evidence-pack truth, v0.359 capture integrity, v0.358 single-slot isolation, v0.357 first opt-in integration, v0.356 gold-lock documentary closure, v0.355 canonical asset registration, and all earlier accepted Barn/Barrosan lineage remain preserved. No accepted gameplay or state contract is changed.

## Validation and CI evidence

The dedicated v0.362 validator checks canonical hashes, exact pack contents, strict UTF-8, genuine image dimensions/nonblank variance, final transform and measurement gates, default/opt-in/rollback counts, pixel rollback proof, four fail-closed states, mutation ledger, and negative fail-closed predicates. The retained v0.361 through v0.354 validators, full tests/build/content/art/runtime/artifact-retention checks, `npm run godot:all`, and `git diff --check` are required before commit. The exact pushed commit SHA and GitHub Actions run are recorded in the final closeout after the local gate is green.

## Machine-readable placement block

<!-- V0362_PLACEMENT_BEGIN -->
{"checkpoint":"v0.362","oldBarnX":-1.8,"newBarnX":4.0,"structuralAabbIntersection":false,"horizontalOverlapDepth":0,"closestHorizontalClearance":2.48,"roofEaveIntersection":false,"roofEaveOverlapDepth":0,"closestRoofEaveClearance":2.51,"workerWidthReference":1.25,"requiredWorkerClearance":1.875,"workerClearancePassed":true,"defaultBarnInstanceCount":0,"optInBarnInstanceCount":1,"fixtureBarnRootPositionMutationCount":1,"fixtureBarnRootRotationMutationCount":0,"fixtureBarnRootScaleMutationCount":0,"changedNonBarnNodeCount":0,"duplicateBarnRootCount":0,"rollbackClean":true,"baselineRollbackStateMatch":true,"rollbackR0R2PixelMatch":true}
<!-- V0362_PLACEMENT_END -->

## Final state

Final repository state is reported only after the v0.362 commit, push, exact-SHA Actions success, and clean/synced verification. This checkpoint stops at v0.362 and does not start v0.363.
