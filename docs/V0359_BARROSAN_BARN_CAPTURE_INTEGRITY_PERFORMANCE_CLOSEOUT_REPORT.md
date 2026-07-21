# v0.359 Barrosan Barn Capture-Integrity, Human-Legible Fail-Closed and Uncapped Performance Closeout

## Decision

READY FOR HUMAN V0359 BARROSAN BARN CAPTURE-INTEGRITY AND PERFORMANCE-CLOSEOUT REVIEW.

This checkpoint repairs evidence integrity only. It is not a production approval, gameplay integration, default-runtime change, collision/navigation change, animation/props pass, or authorization of another visual slot.

## Base and authority

- Branch: `codex/v0215-v0226-recovery`
- Base HEAD: `fbb92489c5bc5d563981718d781ba46a31edce0c` (v0.358 exact-SHA CI green before this work)
- Canonical scene: `desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn`
- Canonical scene SHA-256: `ffaf4c4eeb7c0dabc3a483b0137ad2d92d2b2f6dd496b84b86584ae4a7e86a4a`
- Accepted raw source: `artifacts/runtime/v0355/screenshots/04_canonical_barn_square_256.png`
- Accepted raw-source SHA-256: `13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3`
- Frozen roof-repair hash: `0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9`
- Authorized slot retained: `barrosan_barn_gold_v0355`
- Human authority retained verbatim: `V0.354 HUMAN-APPROVED — BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN`

## Why v0.359 exists

v0.358’s loader/isolation work was technically valid, but its visual closeout was rejected. The v0.358 capture wrapper passed `--v0358-view=front`, `--v0358-view=rear`, `--v0358-view=roof`, and related arguments. The inherited v0.357 camera parser reads only `--v0357-view=`, so each requested view fell through to the inherited default camera. The board builder then reused those identical raw files in multiple comparison boards. The failure was therefore both a raw-capture sequencing/source-mapping defect and a board-composition defect.

## What changed

The new isolated v0.359 review layer contains:

- `desktop-spikes/godot-salto/scenes/review/V0359BarrosanBarnCaptureIntegrityPerformanceCloseout.tscn`
- `desktop-spikes/godot-salto/scripts/v0359_barrosan_barn_capture_integrity_performance_closeout.gd`
- launch, capture, and pack wrappers under `tools/godot/`
- a dedicated validator: `tools/godot/saltoV0359BarrosanBarnCaptureIntegrityPerformanceCloseoutTool.mjs`
- explicit v0.359 package commands for launch, capture, pack, and validation
- `artifacts/runtime/v0359/capture-manifest.json`
- `artifacts/performance/v0359-barrosan-barn/v0359-performance.json`
- the exact-ten-file upload pack at `artifacts/manual-review/v0359-barrosan-barn-capture-integrity-performance-closeout/UPLOAD_TO_CHAT/`

The v0.359 camera path parses its own view argument, applies the transform, waits eight rendered process frames, and records the camera, viewport, settle count, scene signature, Barn count, and raw SHA-256 beside every panel. The board builder uses those corrected raw sources and has a deterministic two-column layout for all four fail-closed panels.

## Evidence result

The corrected raw panel ledger proves:

- wide and close-scale hashes differ;
- RTS-distance and terrain-contact hashes differ;
- front, rear, and roof hashes are all distinct;
- all four fail-closed raw panels have distinct diagnostics;
- rollback R0 and R2 hashes match while R1 differs;
- every raw capture is a genuine non-headless PNG at the recorded viewport size.

The final board 06 was visually inspected after correcting a layout bug that placed F4 below the board. All F1–F4 labels and lower diagnostic blocks are now visible inside the 1600×900 board. Boards 03, 04, 05, 06, and 08 were manually inspected as rendered evidence; the quality boards contain real captured Barn/House02 images rather than title cards.

## Fail-closed readability

Each failure scenario reports a large readable `FAIL-CLOSED` panel with requested slot, load-attempted state, load-succeeded state, Barn instance count, fallback usage, runtime continuation, and exact failure code. The four states are:

1. `FAIL_CLOSED_MISSING_SCENE`
2. `FAIL_CLOSED_HASH_MISMATCH`
3. `FAIL_CLOSED_INVALID_AUTHORITY`
4. `FAIL_CLOSED_UNKNOWN_SLOT_REJECTED`

All four continue the runtime without instantiating the Barn or a fallback asset. The diagnostics are evidence-only and do not change gameplay or the default launcher.

## Rollback identity

The rollback capture records R0 baseline, R1 one canonical Barn load, and R2 removal. R0 and R2 have identical raw pixel hashes and matching state signatures. The retained Barn count after rollback is zero, duplicate roots are zero, and the changed non-Barn node count is zero.

## Temporary uncapped benchmark

The benchmark is a dedicated subprocess, not a production-performance certification:

- VSync disabled: `true`
- `Engine.max_fps`: `0`
- detected frame cap: `false`
- uncapped protocol valid: `true`
- warm-up: `600` frames per mode
- measurements: `3` passes × `1200` frames per mode = `3600` raw samples per mode
- deliberate sleep: `false`
- screenshot during sampling: `false`
- adapter: NVIDIA GeForce GTX 1070
- monitor refresh observed: approximately 74.97 Hz
- default median: approximately 1461.99 FPS; opt-in median: approximately 1451.38 FPS
- default/opt-in median ratio: approximately `0.993`
- default/opt-in p95 frame-time ratio: approximately `1.061`
- default draw calls/resources/nodes: `74 / 53 / 61`
- opt-in draw calls/resources/nodes: `116 / 73 / 82`
- opt-in deltas: `+42` draw calls, `+20` loaded resources, `+21` nodes, and `+4720` primitives
- Barn nodes after rollback: `0`

These values are a local uncapped fixture measurement only. They do not authorize production integration or claim a shipping performance budget.

## What did not change

The v0.358 loader, canonical scene, canonical GLB/material/texture/UV/geometry/roof/shutter data, frozen source and roof hashes, gold manifest, acceptance ledger, stable IDs, saves, browser runtime, production launchers, default runtime, gameplay semantics, collision/navigation, animation, props, and authorized slot were not modified. No new slot was added. No movement, pathfinding, route following, combat, damage, HP, AI, waves, economy, resources, or production mutation was introduced.

The v0.358 technical isolation and rollback contract remains the retained fallback/proof layer. v0.359 adds only capture integrity, readable diagnostics, review-pack composition, and temporary benchmark evidence around it.

## Review pack

`artifacts/manual-review/v0359-barrosan-barn-capture-integrity-performance-closeout/UPLOAD_TO_CHAT/`

The upload pack contains exactly ten files: eight genuine rendered PNG boards, `00_READ_ME_FIRST.md`, and `compact-evidence-summary.json`. Raw captures, capture manifest, and full benchmark arrays remain in their runtime/performance artifact paths for validator audit and are intentionally not duplicated into the upload pack.

## Commands

- Capture: `npm run godot:capture:salto-v0359-barrosan-barn-capture-integrity-performance-closeout`
- Pack: `npm run godot:pack:salto-v0359-barrosan-barn-capture-integrity-performance-closeout`
- Dedicated validator: `npm run godot:validate:salto-v0359-barrosan-barn-capture-integrity-performance-closeout`

## Validation evidence

The dedicated validator checks the frozen canonical hashes and authority, v0.359 source/scene/wrappers, raw panel ledger, genuine PNG dimensions, corrected distinct-view hashes, readable fail-closed summary, rollback identity, uncapped raw sample arrays, exact upload-pack inventory, UTF-8/human-decision integrity, forbidden gameplay symbols, and the v0.359 scope boundary. Retained v0.358 validation remains a separate required command and is not weakened by this checkpoint.

The full closeout validation sequence is:

- dedicated v0.359 validator;
- retained v0.358 through v0.354 validators;
- `npm test`;
- `npm run build`;
- content, art-intake, runtime-art-slot, and artifact-retention validation;
- `npm run godot:all`;
- `git diff --check`;
- exact pushed-SHA GitHub Actions success.

Final status is intentionally a human-review stop. This report does not say the Barn is production-ready, default-enabled, gameplay-integrated, collision/navigation-enabled, animated, prop-complete, or approved for another slot.
