# v0.317 H3 Target-Isolated Evidence Integrity and Final Adoption Closure

## Executive decision

**REJECT H3 DIRECTIONAL ANIMATION METHOD — PRESERVE STATIC H3 ADAPTER**

This is an evidence-gated rejection, not a runtime regression. The target-isolated capture is real and auditable, but the authored atlas does not meet the required state-family identity minimum: Worker work produced two distinct target-only identities where four are required. The player-session Militia idle evidence meets its three-identity minimum. No replacement animation art was added. H3 remains opt-in and the static adapter remains the safe fallback.

## Scope

v0.317 closes the H3 evidence-integrity question from the v0.316 visible-animation checkpoint. It adds target-isolated capture, normalized target masks, direction/scale/traversal/GIF/save/formation evidence, an independent validator, and a compact review pack. It does not add gameplay, animation art, default adoption, or state semantics.

Base HEAD: `59b4c7cfd8737d1878217d9c131a5d5144dc0db8`

Branch: `codex/v0215-v0226-recovery`

## Target-isolated method

Each Worker/Militia record is captured from a real windowed Godot session after `RenderingServer.force_draw(false)`. The target billboard is isolated through live visibility toggles: all visible, all hidden, target only, target plus neighbor, neighbor only, and target hidden. The measured alpha mask supplies the screen-space rectangle, bbox, pixel count, crop SHA, normalized mask, pHash, ground anchor, and toggle hashes. The target-only crop reports 100% target foreground; the broader all-visible overlap remains retained as `allVisibleNonTargetOverlapPixelCount` rather than being hidden.

Two sessions were captured: PLAYER and DEBUG_REVIEW, each with 79 records and zero capture-run errors. The top-level manifests were reconciled from their per-record sidecars after the writer defect was fixed, so every review claim maps to a source screenshot and measured mask.

## Normalized animation proof

Ground-anchor normalization removes world translation and excludes HUD, selection, shadow, and background from the target mask. Worker idle, locomotion, and work records and Militia idle and locomotion records are present. Exact target-only identities are independently counted by the validator. Locomotion and directional evidence is visibly present; the required Worker-work identity minimum is not met, while the player-session Militia-idle minimum is met.

## Direction, scale, and anchors

Both roles cover eight facing requests mapped to four runtime families, with measured facing-update latency. The scale capture holds unit, state, facing, frame, camera, environment, and selection constant while recording 1.00, 0.88, and 0.76 candidates. The runner records measured bbox and ground/selection/shadow anchors, reports no root motion, and retains the authoritative runtime position.

## Traversal, GIF, save, and formations

Bridge and road traversals use one fixed order and destination per path, record before/entry/centre-or-road-one/exit-or-road-two/arrival/arrived-idle zones, and end idle with no destination. The bridge proof destination is at least 40 authoritative units from origin. The Worker and Militia GIFs are generated from 40 ordered normalized target frames with debug identity/state/facing/family/frame/phase overlays. A real writable non-default Worker-working save is hashed and reconstructed after reset. Formation evidence is exactly 12 and 24 Worker/Militia stable IDs, with no unsupported roles or fully hidden units.

## Rejection reason and preservation

The static atlas supplies only two distinct target-only Worker-work identities in the player-session evidence, while the player-session Militia-idle evidence supplies three. The v0.317 rules require at least four Worker-work and three Militia-idle identities. Because this is a real evidence failure and the scope forbids new animation art, H3 is rejected for adoption. The accepted v0.315 lifecycle, v0.316 capture boundary, static adapter, H3 opt-in, authoritative runtime position/state/facing ownership, no-root-motion contract, fallback behavior, default runtime, and retained validators are preserved.

## Review pack

Full local pack: `artifacts/manual-review/v0317-h3-target-isolated-evidence-closure/`

Compact upload set: `UPLOAD_TO_CHAT/`, exactly 14 files, intentionally within the user’s 20-file transfer limit. It contains target isolation, normalized Worker/Militia strips, continuous runtime GIFs, direction families, scale ratios, bridge/road traversal, formations, anchors, save proof, final scorecard, and `compact-evidence-summary.json`. The full local pack retains both manifests, masks, sidecars, hash register, traversal zones, save audit, GIF source ledger, black-frame rejection report, and validator report.

## Validator and commands

Dedicated validator: `tools/godot/saltoV0317H3TargetIsolatedEvidenceClosureTool.mjs`

Capture command: `npm run godot:capture:salto-h3-target-isolated-evidence-closure`

Pack command: `python tools/godot/buildV0317H3TargetIsolatedEvidenceClosurePack.py`

Validation command: `npm run godot:validate:salto-h3-target-isolated-evidence-closure`

The validator independently hashes source screenshots and masks, counts target identities, checks target toggles, directions, scale candidates, traversal displacement/zones, GIF frame count and duration, save size/SHA/reconstruction, formations, default-runtime diff, and the preserved runtime seams. It returns `PASS_V0317_H3_TARGET_ISOLATED_EVIDENCE_CLOSURE_REJECTED` only when the rejection is exactly explained by the two measured identity minima; unrelated defects remain hard failures.

## What did not change

No movement system, pathfinding, route following, combat, attack, damage, HP, projectile, death/despawn, AI, waves, fog, economy, resource mutation, pressure behavior, save schema, terrain, buildings, camera, minimap, HUD contract, stable ID, or true-default runtime behavior changed. No new animation art or unsupported role was added.

## Validation evidence

The local v0.317 capture sessions, pack, and validator are the primary evidence. Retained v0.316 through v0.303 validators, the v0.285 through v0.269 Barrosan ladder, and the v0.259 UI invariant validator all pass; missing retained black-frame files for v0.259 and v0.269 through v0.284 were regenerated only through their existing capture commands. Tests (887), build, content, art-intake, runtime-art-slot, artifact-retention, `npm run godot:all`, and `git diff --check` also pass. CI evidence and the final pushed SHA are recorded here during closeout.

## Final adoption statement

H3 is **not adopted** for Worker/Militia animation states. Preserve the static H3 adapter and v0.316 capture boundary. A future checkpoint may address the atlas identity deficit only with a separately scoped authored-art task; it is outside v0.317.
