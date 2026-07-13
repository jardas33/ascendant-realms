# v0.315 H3 Animation Runtime-Proof Recovery and Evidence-Integrity Report

## Executive decision

**ACCEPT H3 DIRECTIONAL ANIMATION METHOD FOR VERIFIED WORKER AND MILITIA STATES**.

This is a bounded, opt-in presentation decision based on live runtime evidence. It does not approve default-runtime adoption, new gameplay, or final player-facing character art.

## Base and scope

- Base HEAD: `54e5c8f6de21c2d821048109f6189250a797290b`
- Branch: `codex/v0215-v0226-recovery`
- Scope: recover honest runtime proof for the existing v0.314 H3 directional animation adapter, correct v0.314’s historical evidence classification, and preserve the accepted static/runtime contracts.
- Prototype boundary: Worker and friendly Militia only; presentation proxies remain driven by `runtime.units` and never own gameplay state.

## Historical v0.314 classification and root cause

v0.313 accepted the H3 runtime integration method for current supported static states. v0.314’s earlier adoption wording is corrected here to: **EVIDENCE INVALID — H3 DIRECTIONAL ANIMATION PIPELINE REMAINS UNPROVEN**.

**V0.314 CAPTURE ROOT CAUSE:** The v0.314 runner configured H3 during `load_mode`, then `_reset_runtime()` called `set_workload_tier("M")`. The playable-skin tier hook called `_refresh_visual_foundation()`, whose `_rebuild_visuals()` removes and frees every child under `visual_root`. That deleted the newly-created v0314 adapter (and static rollback adapter) after configuration but before the first capture. The requested flag remained true, so status reported `requested=true` while the adapter reference was invalid and `enabled=false`. The final rollback/reconstruction toggle recreated the adapter, which is why only the last records showed `enabled=true`. This was a capture-scene initialization/lifecycle teardown defect, not an atlas or gameplay-state defect.

v0.315 repairs this by recreating and rebinding the static and directional presentation adapters after the known workload-tier visual rebuild. It does not change the authoritative workload runtime.

## Runtime enablement and method

- Opt-in flag: `--h3-directional-animation-runtime-proof-recovery`.
- Package command: `npm run godot:capture:salto-h3-animation-runtime-proof-recovery`.
- Dedicated validator: `node tools/godot/saltoV0315H3AnimationRuntimeProofRecoveryTool.mjs validate`.
- Animation method: `M3_AUTHORED_MULTI_FRAME_ATLAS`.
- Integrated roles: Worker and friendly Militia only.
- Worker states proven: idle, locomotion, work.
- Militia states proven: idle, locomotion.
- Militia ready/Hold state: 0; no unsupported state was invented.
- Controller status: Worker and Militia animation controllers active in enabled records.
- Runtime evidence: 25 PLAYER records and 25 DEBUG_REVIEW records; 46 records enabled, with static/fallback rollback records intentionally disabled.
- Changing runtime animation snapshots: 15 distinct ID/frame/phase combinations.

The adapter records atlas identifier, direction family, atlas cell, frame index, phase, frame duration, cycle duration, elapsed time, presentation scale, authoritative position, and grounding anchor. The screenshots are saved directly from Godot’s viewport and retain the live runtime UI plus a `V0.315 LIVE RUNTIME | H3 M3` watermark.

## Save/load and rollback proof

The runner writes a real capture-only JSON save, hashes it, resets the scene, reads the file, and restores the existing `capture_save_state` schema. This proves file-backed reconstruction without changing production save behavior. The rollback sequence is animated H3 -> static v0.311 adapter -> fallback renderer -> animated reconstruction. Stable IDs, authoritative positions, selected IDs, and gameplay semantics remain runtime-owned.

## Hold contract

Hold remains `HIDDEN_WHEN_UNSUPPORTED`. No H shortcut, Hold callback, ready state, or movement callback was added. The capture records before/after authoritative digests and proves they are unchanged.

## Scale evidence

The capture runner records CURRENT scale `1.00`, `-12%` scale `0.88`, and `-24%` scale `0.76`, then restores CURRENT. The adapter’s scale is presentation-only and does not change positions, state, or the default runtime. CURRENT remains the bounded presentation scale for this checkpoint.

## Visual assessment

The live runtime evidence is visually honest and suitable for this engineering checkpoint: Worker and Militia silhouettes visibly change phase in the same running scene, grounding/selection remains present, and the PLAYER/DEBUG_REVIEW modes remain directly comparable. The current game board is still a technical Salto presentation rather than final character art; this checkpoint proves the H3 runtime method, not an art-direction finish.

Scorecard:

| Category | Score |
|---|---:|
| Runtime proof integrity | 94 |
| Technical feasibility | 88 |
| Maintainability | 84 |
| Grounding | 79 |
| Worker readability | 78 |
| Militia readability | 76 |
| Attractiveness | 72 |

## Preserved contracts and hard boundaries

Preserved exactly: the accepted v0.287–v0.313 chain, v0.311 static rollback, v0.312 evidence-integrity boundary, v0.313 supported-state contract, stable IDs, authoritative positions, selected-card/HUD contracts, source-card lineage, true default runtime, fallback presentation, terrain/buildings/camera/minimap, and save schema.

No movement, pathfinding, collision, combat, attack, damage, HP loss, projectile, death/despawn, AI, waves, fog, pressure, economy, production, resource, default-runtime, or gameplay-state mutation was added. Animation proxies do not simulate, move, collide, or issue orders.

## Source lineage and default status

The retained Militia source is `desktop-spikes/godot-salto/assets/v0310/barrosan_militia_v0154_source.png`, SHA-256 `CE8CA60D20201874D679E9A00B6BF0F7C4B7F0A83C27CD83AE99E8E40FB6703E`, introduced by the v0.310 authored billboard pivot commit. The Worker/Militia atlas remains repository-authored; no protected-game asset was imported. H3 remains opt-in and the true default runtime remains unchanged.

## Review pack

`artifacts/manual-review/v0315-h3-animation-runtime-proof-recovery/`

The pack contains both mode captures, per-event sidecars, a 48-entry evidence ledger, live Worker/Militia runtime GIFs derived from actual Godot screenshots, contact sheets, save/load and rollback reports, source lineage, exact base proof, and black-frame rejection output. `UPLOAD_TO_CHAT/` contains exactly 14 compact files.

## Validation evidence

- Dedicated v0.315 validator: `PASS_V0315_H3_ANIMATION_RUNTIME_PROOF_VALIDATION`.
- Updated v0.314 validator: `PASS_V0314_H3_DIRECTIONAL_ANIMATION_VALIDATION`, now classifying v0.314 as invalid/unproven historical evidence.
- Retained v0.313 through v0.303 validators: required and run before closeout.
- Full local validation: `npm test`, `npm run build`, content validation, art-intake validation, runtime-art-slot validation, artifact retention, `npm run godot:all`, and `git diff --check`.
- CI evidence: exact pushed SHA workflow run recorded at closeout.

## Exact decision and next checkpoint

**ACCEPT H3 DIRECTIONAL ANIMATION METHOD FOR VERIFIED WORKER AND MILITIA STATES**.

Exact v0.316 proposal: **v0.316 — H3 Worker and Militia Animation Authoring Hardening and Bounded Variation**. It must remain opt-in and must not broaden the supported-state or gameplay boundary.

## Final repository state

The closeout target is a clean, pushed branch with exact-SHA GitHub Actions success and `0 ahead / 0 behind` against `origin/codex/v0215-v0226-recovery`.
