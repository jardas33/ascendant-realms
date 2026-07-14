# v0.316 H3 Visible Animation and Directional Closure Report

## Scope

This checkpoint closes the v0.315 evidence-integrity gap for the opt-in H3 Worker/Militia presentation. It is a capture, measurement, and proof closure pass. It does not add gameplay, movement ownership, root motion, combat, economy, resources, AI, pressure, save semantics, or default-runtime mutation.

Base HEAD: `cc059f01fc1dd3ec65f4e478c061605cbf50a5c2`
Branch: `codex/v0215-v0226-recovery`

## Historical classification

- v0.313: `ACCEPT H3 RUNTIME INTEGRATION METHOD FOR CURRENT SUPPORTED STATIC STATES`
- v0.314: `EVIDENCE INVALID — H3 DIRECTIONAL ANIMATION PIPELINE REMAINED UNPROVEN`
- v0.315: `PARTIAL RUNTIME-ENABLEMENT RECOVERY CONFIRMED — VISIBLE DIRECTIONAL ANIMATION ADOPTION REMAINS UNPROVEN`
- v0.316: `ACCEPT H3 DIRECTIONAL ANIMATION METHOD FOR VISIBLY VERIFIED WORKER AND MILITIA STATES`

## Root cause repaired

The v0.315 runner advanced adapter metadata but captured the full viewport without a guaranteed rendered-frame boundary, did not crop the authoritative proxy, and reused physical screenshot identities across unrelated semantic claims. v0.316 uses the windowed Vulkan renderer, forces a render before capture, crops the live H3 billboard, records exact SHA-256 and perceptual hashes, records changed pixels and max channel difference, and builds the semantic ledger directly from the capture manifests.

The exact evidence note is in `artifacts/manual-review/v0316-h3-visible-animation-directional-closure/rendered-frame-root-cause.md`.

## Runtime evidence

Two real windowed Vulkan Godot sessions were captured: `PLAYER` and `DEBUG_REVIEW`, 80 records each. Each record has a physical runtime PNG, live watermark, authoritative stable ID/state/position/facing, adapter frame metadata, rendered crop, crop SHA, perceptual hash, pixel-diff metrics, bbox, and ground/selection/shadow anchors.

Worker evidence: 8 idle samples with 3 exact/perceptual identities, 8 locomotion samples with 8 exact/perceptual identities, and 8 work samples with 4+ exact/perceptual identities. Worker work records remain authoritative `activityState=working` and `commandState=work`.

Militia evidence: 8 idle samples with 3 exact/perceptual identities and 8 locomotion samples with 8 exact/perceptual identities. No Militia ready state was introduced.

The required eight runtime facings were exercised for both roles: north, north-east, east, south-east, south, south-west, west, and north-west. The adapter reports four directional families. The rendered crop evidence, not the configured direction array, is the proof source.

## Scale, traversal, formation, and persistence evidence

The scale comparison uses the same selected unit, state, frame, environment, camera, and selection at 1.00, 0.88, and 0.76. All three rendered crop hashes differ. Bridge and road waypoint records contain authoritative position, destination, movement, and facing data. Real 12-unit and 24-unit mixed formations were captured in two animation phases. A writable non-default Worker-working save was written under the v0.316 artifact root and reconstructed after a reset.

Rollback evidence covers `ANIMATED_H3`, `STATIC_H3_V0311`, `FALLBACK_RENDERER`, and `ANIMATED_H3_RECONSTRUCTED` from unchanged authoritative state. Hold remains `HIDDEN_WHEN_UNSUPPORTED`; the H input audit records no callback and no authoritative digest change.

## Decision and visual assessment

The rendered evidence passes the v0.316 minimum proof thresholds: no required visible sequence is byte-identical, all scale candidates are distinct, both roles have visible cycles, and all eight directions are represented. The resulting decision is:

`ACCEPT H3 DIRECTIONAL ANIMATION METHOD FOR VISIBLY VERIFIED WORKER AND MILITIA STATES`

The art remains a technical H3 proof layer rather than a final character-art adoption. The static adapter and fallback renderer remain available for rollback and comparison.

## Preservation and hard boundaries

The v0.315 lifecycle repair, supported role states, stable IDs, save path, accepted v0.287-v0.315 chain, true default runtime, pressure, resources, terrain, buildings, camera, minimap, and HUD contracts remain unchanged. Animation does not own movement or root motion. No movement/pathfinding/collision/combat/damage/HP/projectiles/death/despawn/AI/waves/fog/economy/resource mutation was added.

## Review pack and validator

Review pack: `artifacts/manual-review/v0316-h3-visible-animation-directional-closure/`
Compact upload set: `UPLOAD_TO_CHAT/` with exactly 14 files.
Dedicated capture: `npm run godot:capture:salto-h3-visible-animation-directional-closure`
Dedicated validator: `npm run godot:validate:salto-h3-visible-animation-directional-closure`
Capture script: `desktop-spikes/godot-salto/scripts/salto_v0316_h3_visible_animation_directional_closure_capture.gd`
Adapter seam: `desktop-spikes/godot-salto/scripts/barrosan_h3_directional_animation_adapter_v0314.gd`

## Validation evidence

The dedicated validator checks both manifests, live crop hashes, exact/perceptual uniqueness, four families/eight facings for both roles, Worker work authority, distinct scale candidates, real save presence, continuous GIFs, fallback/default preservation, and compact-pack count. It passed with 80 PLAYER records, 80 DEBUG_REVIEW records, four direction families, distinct scale candidates, real runtime evidence, continuous runtime GIF evidence, and `defaultRuntimeChanged=false` / `gameplayChanged=false`.

Local closeout gates passed:

- v0.315, v0.314, v0.313, v0.312, v0.311, v0.310, v0.309, v0.308, v0.307, v0.306, v0.305, v0.304, v0.303 dedicated validators
- `npm test` - 887 tests passed across 122 files
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run validate:runtime-art-slots`
- artifact-retention validator
- `npm run godot:all`
- `git diff --check`

The retained v0.304-v0.309 validators were given narrow continuation allowlist entries for v0.316 source/report/pack files and their own generated validation JSON; no gameplay or runtime source was weakened.

## CI and final state

Exact-SHA GitHub Actions evidence and the final commit SHA are recorded in the final closeout after push. The closeout is not considered complete until the branch is clean and synchronized at 0 ahead / 0 behind.
