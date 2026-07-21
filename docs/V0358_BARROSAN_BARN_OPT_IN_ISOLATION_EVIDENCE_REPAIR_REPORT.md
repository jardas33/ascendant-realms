# v0.358 Barrosan Barn Opt-In Isolation, Fail-Closed Evidence, Rollback and Real Performance Repair

## Readiness and scope

`READY FOR HUMAN V0358 BARROSAN BARN OPT-IN ISOLATION AND EVIDENCE-REPAIR REVIEW.`

v0.358 repairs the evidence defects identified when v0.357 was rejected for integration closeout. The Barrosan Barn visual gold itself remains approved and frozen. This checkpoint changes only the isolated Godot review fixture, capture/pack tooling, validator, and documentation. It does not authorize production integration, default enablement, gameplay building registration, collision, navigation, animation, props, or another slot.

## Base and frozen authority

- Branch: `codex/v0215-v0226-recovery`.
- Base HEAD: `28703b89a7b8bfed4d3198d87d4c26752e27ebb9`.
- v0.357 exact-SHA CI: run `29796245153`, success.
- Human authority: `V0.354 HUMAN-APPROVED — BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN`.
- Authorized slot: `barrosan_barn_gold_v0355`.
- Canonical scene: `desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn`.
- Required source hash: `13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3`.
- Frozen roof hash: `0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9`.

The canonical scene, raw source, manifest, acceptance ledger, Blender source, GLB, meshes, materials, textures, UVs, geometry, transforms, roof and shutters remain byte-for-byte unchanged.

## v0.357 rejection and root cause

The v0.357 default/opt-in board was not a valid single-slot differential. Its `_load_v0357_assets()` method instantiated House02 and Barn together, while the off path never loaded House02. Therefore the board compared a House02-free baseline with an opt-in scene containing House02 plus Barn. The defect was fixture orchestration, not Barn art.

v0.358 fixes the cause structurally: House02 is now loaded once into `V0358_House02_Shared_Baseline_Unmodified` before the off/on split. The baseline scene, workers, terrain, river, bridge, road, camera, viewport, lighting and transforms are created identically for both states. The opt-in branch adds only the canonical Barn root and its canonical children.

Board 02 is labelled as a comparison fixture and is not presented as the true default PLAYER runtime. The real default launcher remains untouched and Barn loading remains off by default.

## Exact single-slot differential

The v0.358 fixture is `desktop-spikes/godot-salto/scenes/review/V0358BarrosanBarnOptInIsolationEvidenceRepair.tscn`. The loader records baseline, opt-in and rollback node signatures, added/removed node paths, changed non-Barn nodes, duplicate instances and retained Barn nodes.

Required result:

- `addedNodePaths`: only `V0358_Barrosan_Barn_Gold_OptIn_Single_Instance` and its canonical children.
- `removedNodePaths`: empty.
- `changedNonBarnNodeCount`: `0`.
- `validOptInLoadedOnce`: `true`.
- `duplicateInstanceCount`: `0`.

No canonical child is counted as a separate authorized slot.

## Default runtime preservation

The actual `GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat` and `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat` paths remain unchanged. v0.358 changes no browser source, save source, stable IDs, gameplay code, default launcher, production launcher, economy, resources, collision, navigation or pathfinding. The comparison fixture is explicit and isolated; it is not substituted for the default-launcher proof.

## Fail-closed evidence

Four independently executed scenarios are captured with the same shared baseline and camera:

- F1 missing canonical scene simulation — `FAIL_CLOSED_MISSING_SCENE`.
- F2 source-hash mismatch simulation — `FAIL_CLOSED_HASH_MISMATCH`.
- F3 invalid manifest/acceptance authority simulation — `FAIL_CLOSED_INVALID_AUTHORITY`.
- F4 unknown slot ID — `FAIL_CLOSED_UNKNOWN_SLOT_REJECTED`.

Every failure records `loadSucceeded=false`, `barnInstanceCount=0`, `fallbackAssetUsed=false`, `runtimeContinued=true`, the exact failure code/message, and the requested slot. The board shows the four failure panels only; it does not use a successfully loaded Barn as the failure image.

## Rollback equivalence

R0 is the shared baseline with Barn off, R1 is the same state with one Barn, and R2 removes the Barn. The fixture records signatures and retained-node counts; the capture wrapper compares baseline and rollback image hashes. The required state result is `baselineRollbackStateMatch=true`, `rollbackBarnInstanceCount=0`, `retainedBarnNodeCount=0`, and `duplicateInstanceCount=0`. Pixel equality is reported honestly; state-signature equality is authoritative when a rendering backend introduces nondeterministic pixels.

## Real performance protocol

The v0.357 startup sample (`1 FPS`, `1000 ms`) is rejected as invalid evidence. v0.358 uses a non-headless continuous-rendering run with no screenshots during sampling:

- warm-up: 300 frames per mode;
- measurement: 3 passes × 600 rendered frames per mode;
- raw frame deltas, draw calls and primitive counts retained;
- loading frames excluded from steady-state statistics;
- default and opt-in use the same shared scene and camera.

The manifest records median FPS, 1% low FPS, median/p95/p99 frame time, >50 ms spikes, maximum frame time, draw calls, primitives, loaded resources, total nodes, Barn nodes, scene-load milliseconds, raw sample arrays, and rollback node state. Validity requires at least 1800 samples per mode, FPS above 5, and p95 frame time below 200 ms. The desired comparison is reported as `medianFpsRatio` and `p95FrameTimeRatio`; it is not treated as production approval.

## UTF-8 repair

Authority text is generated with the Unicode em dash and written as UTF-8. The v0.358 README, compact summary, report and retained v0.357 pack derivative are checked for common mojibake sequences. The authorized slot is written exactly as `barrosan_barn_gold_v0355` with no `$` prefix.

## Capture and review pack

Capture command:

`npm run godot:capture:salto-v0358-barrosan-barn-opt-in-isolation-evidence-repair`

Pack command:

`npm run godot:pack:salto-v0358-barrosan-barn-opt-in-isolation-evidence-repair`

Validator command:

`npm run godot:validate:salto-v0358-barrosan-barn-opt-in-evidence-repair`

Review pack: `artifacts/manual-review/v0358-barrosan-barn-opt-in-isolation-evidence-repair/UPLOAD_TO_CHAT/`. It contains exactly ten files: eight genuine wide PNG boards, one README, and `compact-evidence-summary.json`; no video is present.

## Deferred work

No production-ready, gameplay-ready, default-runtime-approved, collision-approved, navigation-approved, animation-approved, or additional-slot conclusion is made. Human review must decide whether this evidence repair is acceptable before any later checkpoint.

## Validation and final state

The closeout runs the dedicated v0.358 validator, retained v0.357/v0.356/v0.355/v0.354 validators, `npm test`, `npm run build`, content/art/runtime/artifact-retention validation, `npm run godot:all`, and `git diff --check`. Exact pushed SHA and GitHub Actions success are recorded in the final handoff. Final repository state is clean and synced at 0 ahead / 0 behind.
