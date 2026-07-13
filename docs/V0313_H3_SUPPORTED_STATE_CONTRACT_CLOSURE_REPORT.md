# v0.313 H3 Supported-State Contract Closure

## Executive decision

**ACCEPT H3 RUNTIME INTEGRATION METHOD FOR CURRENT SUPPORTED STATES**

This is an engineering-method decision for the states that actually exist in the opt-in Barrosan runtime. It does not approve current character artwork as final player-facing art.

H3 ENGINEERING METHOD: ACCEPTED FOR CURRENT SUPPORTED STATES
CURRENT CHARACTER ART: NOT APPROVED AS FINAL PLAYER-FACING ART
DEFAULT-RUNTIME INTEGRATION: NOT APPROVED

## Historical correction chain

Base branch: `codex/v0215-v0226-recovery`
Base HEAD: `9d6adf7952819b0f4767cb8a01a0c39e7aeeab41`

- v0.311: `EVIDENCE INVALID — H3 RUNTIME METHOD REMAINS UNPROVEN`.
- v0.312: recovered distinct runtime evidence and preserved the corrected v0.311 status.
- v0.313: closes the method decision against supported states without inventing Militia gameplay.

The accepted v0.311 implementation history, failed evidence history, v0.312 pack, fallback/debug renderer, H3 opt-in boundary, stable IDs, saves, and true default are retained unchanged.

## What v0.312 proved

v0.312 proved Worker and Militia movement, bridge progression, depth/occlusion samples, camera pan/zoom, selection and box selection, real opt-in save/write/load, presentation-only H3/fallback/H3 rollback, and Worker runtime work state. Its one unresolved item was a distinct Militia ready/hold state.

## Why Militia ready remained unresolved

The actual runtime unit contract contains `position`, `destination`, `hasDestination`, `commandState`, `activityState`, `facing`, `health`, and `readyState`. Militia starts with `commandState=idle`, `activityState=idle`, and `readyState=unsupported`. Move sets `commandState=move_ordered` and `activityState=travelling`; arrival sets `commandState=stopped`, `activityState=idle`, and clears `hasDestination`.

The visible Hold control is present in the HUD, but its callback is `_on_live_ui_shell_move_pressed`, which calls the existing `issue_move_order`. It is therefore a generic Hold label over an existing move-order path, not an authoritative ready/hold gameplay state.

**MILITIA READY VISUAL STATE: NOT APPLICABLE — NO AUTHORITATIVE GAMEPLAY STATE EXISTS**

This is a gameplay-contract limitation and is not an H3 adapter defect. No Militia gameplay state was added.

## Militia command-path audit

| UI command | Callback | Runtime method | Before | After | Classification |
|---|---|---|---|---|---|
| Hold | `_on_live_ui_shell_move_pressed` | `issue_move_order` | selected idle/stopped | move_ordered/travelling, then stopped | not applicable to distinct ready visual |
| subsequent valid command | existing move command | `issue_move_order` | post-Hold alias state | new destination/facing | supported movement |

The focused PLAYER and DEBUG_REVIEW capture manifests record the exact before/after snapshots, selected IDs, last order, position, destination, facing, command state, activity state, and H3/fallback flags.

## Militia authoritative-state audit

Supported states are idle, selected, unselected, move-ordered/moving, and stopped. Save/load reconstructs the same authoritative unit. H3/fallback switching reconstructs presentation from that same state. No combat-ready or attack-ready Militia state is exposed by this slice beyond the existing commands and fields.

## Hold command result

- UI command present: yes.
- UI callback reached: yes.
- Authoritative method reached: yes, `issue_move_order`.
- Authoritative state changed: yes, as a move order; not as a Hold/Ready state.
- Distinct ready state exists: no.
- H3 adapter defect: no.
- Classification: not applicable.

## Supported versus unsupported versus not-applicable states

Worker supported states: idle, selected, unselected, moving, stopped, working, save/load reconstruction, fallback rollback, and H3 reconstruction.
Militia supported states: idle, selected, unselected, moving, stopped, save/load reconstruction, fallback rollback, and H3 reconstruction.
Militia ready/hold visual state: not applicable because no authoritative gameplay state exists.

## Worker supported-state adapter matrix

`worker_00` remains the authoritative Worker ID. Every captured state reads position, facing, command/activity state, selection, and proxy status from `runtime.units`. The H3 proxy, fallback proxy, shadow, and selection treatment reconstruct from that same state without duplicate or orphan proxies.

| State | Runtime source | H3 response | Fallback response | Result |
|---|---|---|---|---|
| idle/selected/unselected | `runtime.units`, `selected_ids` | bound proxy | existing fallback | pass |
| moving/stopped | `issue_move_order`, `_advance_movement` | follows authoritative position/facing | same state source | pass |
| working | `assign_worker_to_mine`, `activityState=working` | state-bound presentation | existing fallback | pass |
| save/load | capture save adapter | reconstructed proxy | reconstructed fallback | pass |
| rollback | presentation toggle only | H3 off/on | fallback | pass |

## Militia supported-state adapter matrix

`friendly_00` remains the authoritative Militia ID. Its supported state transitions bind correctly in both presentation layers. Hold is documented as a UI alias to Move and is not promoted to a distinct visual state.

| State | Runtime source | H3 response | Fallback response | Result |
|---|---|---|---|---|
| idle/selected/unselected | `runtime.units`, `selected_ids` | bound proxy | existing fallback | pass |
| moving/stopped | `issue_move_order`, `_advance_movement` | follows authoritative position/facing | same state source | pass |
| Hold label | existing UI callback | no distinct ready proxy expected | no distinct ready proxy expected | not applicable |
| save/load | capture save adapter | reconstructed proxy | reconstructed fallback | pass |
| rollback | presentation toggle only | H3 off/on | fallback | pass |

## Evidence-count reconciliation

The v0.312 totals are preserved and mathematically reconciled, not regenerated or rewritten:

| Total | Count |
|---|---:|
| physical PNG files | 154 |
| PLAYER files | 77 |
| DEBUG_REVIEW files | 77 |
| PLAYER/DEBUG paired moments | 77 |
| exact unique SHA-256 images | 127 |
| perceptually unique images | 48 |
| accepted semantic records | 128 |
| accepted semantic gameplay events | 62 |
| rejected exact-duplicate records | 26 |
| rejected near-duplicate records | 0 |
| rejected mislabeled frames | 0 |
| informational/non-gameplay records | 4 |

The 128 accepted records are 64 accepted paired moments × two presentation views. Two accepted paired moments are informational preflight/final-overview records, leaving 62 accepted gameplay events. The 26 rejected records are 13 paired duplicate moments; every rejected hash is already represented by accepted evidence. One accepted exact SHA is reused by the PLAYER `scale_comparison_74` and PLAYER `clean_gameplay_77` records; their paired DEBUG_REVIEW records and metadata remain distinct, so neither event relies solely on that one screenshot. The reuse is explicitly classified and is not counted as a second image identity. No two distinct semantic events rely solely on the same screenshot.

The focused v0.313 capture set contains 34 physical PNGs, 17 paired moments, and 17 semantic events, with separate PLAYER and DEBUG_REVIEW sidecars.

## Physical files versus unique images

Physical-file, SHA-256, and perceptual registers are in the review pack. A physical file is counted once on disk; a unique image is counted once by exact SHA; a perceptual hash is a review similarity grouping and does not replace exact identity.

## Records versus semantic gameplay events

Each v0.312 PLAYER/DEBUG pair has two records but one `pairedMomentId`. The validator rejects any attempt to count the pair as two events. v0.313 sidecars use `semanticEventId` and `pairedViewId` and apply the same rule.

## Player/debug pairing

PLAYER is the clean player-facing view. DEBUG_REVIEW retains evidence metadata and proof presentation. Both are captured from the same runtime contract and paired explicitly; switching presentation does not change state, positions, resources, selection, or pressure.

## Save/load result

The focused harness writes a real `user://v0313-h3-supported-state-save.json`, records its checksum, resets the opt-in runtime, reloads the written state, and verifies the Militia ID, position, command/activity data, and selection reconstruction. This does not alter the default save architecture.

## Rollback result

The focused harness captures H3 enabled, fallback enabled, and H3 reconstructed from the same authoritative runtime. This is presentation-only rollback. No gameplay state, unit position, resource, or stable ID changes.

## Presentation-scale lock

**H3 PRESENTATION SCALE LOCK: CURRENT**

The current scale was selected after re-evaluating current, 12%-smaller, and 24%-smaller treatments at ordinary/minimum/maximum zoom, beside Aster, a doorway, bridge railing, and mixed formations. It preserves selection and shadow alignment and avoids changing source cards. The lock applies only to opt-in H3.

## Runtime integration method assessment

The H3 method is accepted for current supported Worker and Militia states. The adapter consumes authoritative `runtime.units` and `runtime.selected_ids`; it does not own gameplay state. Only Worker and Militia are integrated, and H3 remains opt-in.

## Current art-quality assessment

Current character art is not final player-facing art. Known limitations remain: one authored pose per role, mirrored/derived directions, no complete idle/walk/work/combat atlas, repeated formation silhouettes, fallback environment mismatch, and no broader faction integration. No protected or external assets were imported.

## Default-runtime status

`UNCHANGED — H3 REMAINS OPT-IN`. The true default launcher, gameplay commands, stats, terrain, buildings, water, HUD layout, saves, economy, and accepted state chain remain unchanged.

## Remaining limitations

The generic Hold label does not map to a distinct Hold gameplay state. This is not an adapter defect. Current authored cards remain a prototype and are not approved for broad rollout.

## Final decision

**ACCEPT H3 RUNTIME INTEGRATION METHOD FOR CURRENT SUPPORTED STATES**

## Exact v0.314

**v0.314 — H3 Barrosan Worker and Militia Supported-State Directional Animation Micro-Pilot**

Scope: one bounded Worker atlas proof, one bounded Militia atlas proof, idle and locomotion for both, Worker work only where the genuine work state exists, repository-authored assets, opt-in swap-ready atlas pipeline, no broad faction rollout, no default integration, and no environment mutation.

## Validation

Required validation includes the dedicated v0.313 validator, v0.312 validator, retained v0.311–v0.303 validators, npm tests/build/content/art/runtime checks, artifact retention, `npm run godot:all`, and `git diff --check`. Exact CI evidence is recorded in the final handoff after push.

## Final repository state

Final closeout will record the pushed commit, exact GitHub Actions run, and clean/synced `0 ahead / 0 behind` state.
