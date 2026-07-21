# v0.357 Barrosan Barn First Opt-In Player-Slice Visual Integration

## Human-review stop

READY FOR HUMAN V0357 BARROSAN BARN FIRST OPT-IN INTEGRATION REVIEW.

This checkpoint is an isolated visual experiment, not production approval. It stops for human review and does not continue into gameplay registration, collision/navigation, animation, props, vegetation, default integration, or another visual slot.

## Authority and frozen source

- Base branch: `codex/v0215-v0226-recovery`.
- Base HEAD: `07bf2e2cfe3bc0214f3497070ae2ab7148befc16`.
- Human authority: `V0.354 HUMAN-APPROVED — BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN`.
- Gold manifest: `docs/gold/V0355_BARROSAN_BARN_GOLD_MANIFEST.json`.
- Acceptance ledger: `docs/gold/V0355_BARROSAN_BARN_ACCEPTANCE_LEDGER.md`.
- Authorized slot: `barrosan_barn_gold_v0355`.
- Canonical scene: `desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn`.
- Required accepted source hash: `13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3`.
- Frozen roof hash: `0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9`.

The canonical scene remains passive and unchanged. v0.357 instances it once only after the manifest, ledger, source hash, roof hash, canonical path, and exact human decision pass.

## Scope and paths

The integration is Godot-only and opt-in. The fixture is `desktop-spikes/godot-salto/scenes/review/V0357BarrosanBarnFirstOptInIntegration.tscn`, launched by `npm run godot:launch:salto-v0357-barrosan-barn-opt-in`. Capture uses `npm run godot:capture:salto-v0357-barrosan-barn-opt-in`; the pack uses `npm run godot:pack:salto-v0357-barrosan-barn-opt-in`; the validator is `npm run godot:validate:salto-v0357-barrosan-barn-opt-in`.

M0 is off by default: no Barn is loaded. M1 accepts the exact slot and loads exactly one passive Barn visual in the player-facing fixture. M2 diagnostics are visible only with the explicit `--v0357-debug-review` flag. Missing scene, hash mismatch, invalid authority, unknown slot, and rollback all fail closed.

## Visual placement and evidence

The fixture reuses the accepted House02, the immutable BarnGold scene, the accepted complete-worker visual context, and a small visual-only sector: recessed river, weathered road, bridge deck/pier/rail geometry, natural ground, and restrained lighting. The Barn remains on visual terrain contact only; no gameplay building registration, collider, navigation, worker assignment, or production logic is present.

The review pack is `artifacts/manual-review/v0357-barrosan-barn-first-opt-in-integration/UPLOAD_TO_CHAT/`. It contains exactly ten files: eight PNG boards, a README, and `compact-evidence-summary.json`. The boards are genuine non-headless Godot renders covering default-off, opt-in front/RTS/contact/rear/roof views, DEBUG_REVIEW authority evidence, and rollback. No video is included.

## Performance and mutation evidence

The capture manifest records the measured default-off and opt-in FPS/P95 frame-time samples. The compact summary records their ratios and the validator enforces the retained opt-in thresholds. Runtime mutation counts are zero for gameplay, default runtime, canonical asset, geometry, material, texture, and transform. Resources, economy, stable IDs, saves, browser runtime, collision, navigation, pathfinding, and animation remain untouched.

## What changed

- Added exactly one reversible Godot-only opt-in player-slice visual slot.
- Reused the immutable canonical BarnGold scene exactly once after authority validation.
- Added isolated river/road/bridge/terrain context for placement judgment.
- Added deterministic launch, capture, pack, fail-closed scenario, rollback, and validator tooling.
- Added the ten-file human-review pack and this report.

## What did not change

The true default runtime and its launcher are unchanged. No gameplay state, building registration, worker logic, collision, navigation, pathfinding, movement, animation, destruction, damage, economy, resources, browser runtime, save format, stable IDs, or accepted v0.347–v0.356 gold lineage changed. No production integration or default approval is claimed.

## Deferred work and verdict

Human review must decide whether this single visual slot is suitable for a later, separately authorized integration checkpoint. Production-wide conversion, gameplay semantics, collision/navigation, animation, props/vegetation, and additional slots are explicitly deferred. Automated validation does not approve the art.

## Validation and final state

Local validation completed before commit:

- `npm run godot:validate:salto-v0357-barrosan-barn-opt-in` — `PASS_V0357_BARROSAN_BARN_FIRST_OPT_IN_VALIDATION`.
- `npm run godot:validate:salto-v0356-barrosan-barn-gold-record-closeout` — `PASS_V0356_BARROSAN_BARN_GOLD_RECORD_CLOSEOUT`.
- `npm run godot:validate:salto-v0355-barrosan-barn-human-gold-lock` — `PASS_V0355_BARROSAN_BARN_HUMAN_GOLD_LOCK_VALIDATION`.
- `npm run godot:validate:salto-v0354-barn-final-evidence` — `PASS_V0354_BARN_FINAL_EVIDENCE_VALIDATION`.
- `npm test` — 887 tests passed across 122 files.
- `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run validate:runtime-art-slots`, and `npm run validate:artifact-retention` — passed.
- `npm run godot:all` — passed, including Godot 4.6.3 readiness, headless runtime, export, and package checks.
- `git diff --check` — passed.

The v0.357 capture manifest records 12 non-headless scenarios: default-off, five valid opt-in views, DEBUG_REVIEW, rollback, and four fail-closed/rejected cases. The valid opt-in path loads exactly one Barn; missing-scene, hash-mismatch, invalid-authority, and unknown-slot cases are rejected; rollback is clean. Capture FPS values are startup-warmup measurements (`defaultMedianFps=1`, `optInMedianFps=1`, ratio `1.0`) and are reported as ratios only, not as a production performance certification.

The exact pushed commit and GitHub Actions success are recorded in the final handoff after remote verification. Final state is clean and synced at 0 ahead / 0 behind.
