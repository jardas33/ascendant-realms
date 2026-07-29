# v0.311 H3 Hybrid Runtime Integration Report

## Executive verdict

**ACCEPT H3 RUNTIME INTEGRATION METHOD**

This checkpoint accepts the H3 integration method for a bounded, opt-in Worker/Militia runtime pilot. It does not claim that the current art is production-ready eight-direction locomotion content. Each role still has one authored 3/4 source pose; derived and mirrored directions are labelled, and no locomotion animation library is present.

## Scope and base

- Base HEAD: `96f5ece4a99432bc18a85e12df70cf5b7985ea3d`
- Branch: `codex/v0215-v0226-recovery`
- Prototype flag: `--salto-barrosan-h3-runtime-pilot`
- Existing runtime flag retained: `--salto-barrosan-playable-runtime-skin`
- Review pack: `artifacts/manual-review/v0311-h3-hybrid-runtime-integration/`
- Dedicated validator: `npm run godot:validate:salto-h3-hybrid-runtime-integration`
- Capture command: `npm run godot:capture:salto-h3-hybrid-runtime-integration`

## Why this pilot exists

The v0.310 bake-off established that H3 is the most credible runtime integration method, while also showing that the recovered single-pose art should not be presented as a finished directional animation library. v0.311 therefore tests the method at the real gameplay seam, with the smallest reversible scope: Worker and Militia only.

## Implementation

`barrosan_h3_runtime_presentation_adapter_v0311.gd` is a presentation adapter attached to the accepted Barrosan playable runtime. It reads `runtime.units`, `runtime.selected_ids`, authoritative positions, and authoritative destinations from the host scene. It creates only visual children for Worker/Militia, hides the corresponding procedural fallback visual while enabled, and never writes gameplay state, destinations, selection, resources, pressure, stable IDs, or saves.

The adapter is created lazily after the host visual root exists, making repeated configuration idempotent. Removing the flag immediately restores the procedural fallback. The runtime manifest records `authoritativeState: true`, `separateSimulation: false`, `gameplayProxy: false`, 12 bound Worker/Militia units, and repeated sync counts.

## Real runtime evidence

The capture harness runs the normal Godot gameplay runtime rather than the isolated v0.310 tableau. It records real runtime actions and views for selection, box selection, move order, authoritative position sync, bridge/road framing, Worker context, Militia ready context, camera framing, selection cards, and rollback/default proof. Both PLAYER and DEBUG_REVIEW runs contain 43 rendered frames.

The runtime fixture is read-only for persistence: save writes remain disabled by the existing fixture contract. The evidence therefore records save/reload as a read-only preservation contract and rollback as disabling the adapter and returning to the retained fallback, rather than claiming a new save system.

## Direction and animation honesty

- Worker: one authored 3/4 source pose from the retained v0.147 lineage.
- Militia: one authored 3/4 source pose from the retained v0.154 lineage.
- H3: eight deterministic directional cards are derived in memory; mirror use is explicit in metadata.
- Locomotion library: absent.
- Movement: still authoritative runtime movement; visual direction is derived from the authoritative destination delta when present.
- No false claim of eight authored animation sets or walk-cycle coverage.

## Visual and technical scorecard

Scores are deliberately separated between the method and the present assets:

| Area | Score | Evidence-based reading |
|---|---:|---|
| Runtime integration method | 82/100 | Clean adapter seam, authoritative sync, reversible fallback |
| Worker/Militia tactical readability | 74/100 | Stronger silhouette than procedural primitives; still single-pose |
| Grounding and selection | 78/100 | Contact shadow and restrained ring follow runtime selection |
| Bridge/road/occlusion readability | 71/100 | Real gameplay framing retained; broad procedural terrain remains |
| Directional coverage | 56/100 | Eight derived cards, one authored pose per role |
| Animation readiness | 38/100 | No locomotion animation library |
| Performance risk at 12 units | 84/100 | Small visual child count and cached materials |
| Performance risk at 24 units | 76/100 | Requires a future measured stress run |
| Maintainability | 83/100 | Central adapter with explicit provenance and rollback |
| Current asset production readiness | 55/100 | Not an art-complete roster |
| Full Salto suitability today | 62/100 | Method is suitable; asset completion is not yet |

## What changed

- Added the opt-in H3 runtime presentation adapter.
- Integrated only Worker and Militia into the real runtime visual sync path.
- Added explicit H3 flag, capture command, validator command, runtime manifest evidence, and review pack.
- Added real rendered PLAYER and DEBUG_REVIEW evidence plus contact sheets.
- Added explicit direction/animation limitation and exact final method decision.

## What did not change

- No new gameplay state, action, button, AI, combat, attack, damage, HP, projectile, death, wave, fog, economy, resource, pressure, movement, pathfinding, route following, stable-ID, or save semantics.
- No default-runtime mutation.
- No replacement of the accepted v0.303 fallback/debug renderer.
- No protected-game assets or large unapproved import.

## Preserved chain and fallback

The accepted v0.287-v0.310 chain remains retained, including route preview, deployed support, integration, pressure stabilization, and v0.310 H3 prototype provenance. The v0.303 procedural renderer remains the fallback/debug layer. DEBUG_REVIEW remains available for proof labels and retained evidence.

## Review pack and validation

The review pack contains 43 PLAYER runtime frames, 43 DEBUG_REVIEW runtime frames, runtime evidence, direction honesty, rollback/default notes, black-frame rejection, player/debug/mode-comparison contact sheets, and validation output. PNGs are signature-checked and size-checked; the wide gameplay frames are real rendered runtime images.

Required local validation is recorded by the dedicated v0.311 validator, retained v0.310-v0.303 validators, tests/build/content/art/runtime/artifact-retention checks, `npm run godot:all`, and `git diff --check`.

## Recommended v0.312

**v0.312 — H3 authored directional asset completion and locomotion feasibility slice**: add only a small measured Worker/Militia directional/animation asset subset, with explicit provenance, 12/24/50/100 performance measurements, no new gameplay, and no production-wide conversion until the asset evidence passes.

## CI and final state

The first v0.311 implementation commit `c34ed111e37e0b20d7356f05161aa6710a275ea1` was pushed to `codex/v0215-v0226-recovery`. GitHub Actions run `29211534108` (`CI Release Matrix Dry Run`, run 445) completed successfully for that exact SHA. The final documentation-only closeout commit records this evidence; its exact-SHA CI result is recorded in the repository handoff after the follow-up push.

Final closeout requires the branch to be clean and synced with origin at 0 ahead / 0 behind.
