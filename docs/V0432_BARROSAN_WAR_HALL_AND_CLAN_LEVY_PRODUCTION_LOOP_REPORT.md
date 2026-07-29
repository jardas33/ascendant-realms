# v0.432 — Barrosan War Hall and Clan Levy Production Loop

## Executive result

v0.432 adds the first bounded, replayable military-production loop to the actual production Godot game. The headed Forward Plus capture drove the existing worker build controls, real War Hall construction, selected-building production panel, one cancellation/refund, one successful Clan Levy queue, real training, real spawn, selection, rally movement, manual movement, fresh-scene replay, and one retained Clan Croft regression.

## Baseline and branch

- Base v0.431 SHA: `16fcf322316a626e0e32bf834020bafdce7d0647`
- Branch: `codex/v0432-war-hall-clan-levy-production-loop`
- Parent branch: `codex/v0431-gameplay-readability-construction-loop`
- Production project: `production/ascendant-realms-godot`
- Immutable original source: `D:/Code for projects/WB game like/WB_tesana`

## Authoritative data

War Hall is the existing `barrosan_war_hall` definition: 150 timber, 60 stone, 30-second base build time, 5.0 footprint, and `res://assets/environment/buildings/barrosan_war_hall.glb`. It exposes the existing tier-one Clan Levy, Stoneward Spears, and Crag Archer options, with higher-tier options disabled by the existing tier gate.

Clan Levy is the existing `barrosan_clan_levy` definition: 60 food, 10 timber, 14-second base training time, population 1, and the existing authored model path.

## Root causes and bounded repairs

The inventory found the build path, completion callback, production HUD, queue progress/cancel, spawn, rally, selection, and movement systems already functional. The concrete defects were:

1. `Building.queue_unit` did not enforce `can_produce`.
2. queued population was not reserved before spawn, allowing overcommit by rapid queueing.
3. cancellation did not release a queued population reservation.
4. production had no same-frame transaction guard.
5. spawn used one fixed point without a bounded footprint/resource search.
6. production buttons did not expose disabled tier/cost/housing states.

The repairs are centralized in the existing `Commander`, `Building`, and HUD paths. The driver does not grant resources, insert queue items, reduce timers, set completion, spawn units directly, or inject selected data.

## Evidence of the real loop

The headed capture pack contains 20 required frames. The key sequence is:

`01` initial state → `02` worker selected → `03` build menu → `04` invalid preview → `05` valid War Hall preview → `06` construction progress → `07` completed War Hall selected → `08` production panel/tier states → `09` queue → `10` cancellation/refund → `11` requeue → `12` training progress → `13` spawn → `14` selected Clan Levy → `15` rally movement → `16` manual movement → `17` fresh-scene second-loop spawn → `18` Clan Croft regression.

Manual inspection of the real PNGs confirms the frames are headed production gameplay, not title cards or browser captures. The War Hall is visible at gameplay scale, the production card shows enabled tier-one choices and disabled higher-tier choices, the queue/progress card is visible, and the spawned Clan Levy is present and selectable.

## Transaction results

- War Hall placement deducted exactly 150 timber and 60 stone once.
- Invalid preview and cancelled placement deducted zero.
- War Hall completed once and remained selectable.
- First Clan Levy queue deducted exactly 60 food and 10 timber.
- Cancellation returned the full current cost and released the reservation.
- Requeue succeeded after cancellation.
- Training used the existing 14-second unit definition value.
- Exactly one Clan Levy spawned in the first loop and one in the fresh second loop.
- Population reservation is visible in `v0432-population-reservation-audit.json`; reservation is zero after cancellation and after successful spawn conversion.
- Spawn search is bounded outside building/resource footprints.
- Rally and manual movement both use existing `Unit.command_move` paths.

## Review pack and commands

Review pack: `artifacts/manual-review/v0432-war-hall-clan-levy-production-loop/`

- Smoke: `npm run godot:smoke:v0432-war-hall-production`
- Capture: `npm run godot:capture:v0432-war-hall-production`
- Validator: `npm run godot:validate:v0432-war-hall-production`
- Contact sheet: `20_V0432_PRODUCTION_LOOP_CONTACT_SHEET.png`
- Root-cause audit: `v0432-production-root-cause-audit.json`
- Black-frame report: `v0432-black-frame-rejection.json`

## Preservation and scope

Preserved: v0.431 lighting and readability, title/Skirmish/Campaign paths, Clan Croft construction and exact cost, headed Forward Plus capture, original Tesana source, production assets, legacy/fallback project, campaign/hero/settings systems, stable IDs, saves, and accepted state semantics.

No enemy combat, attacks, damage, death, projectiles, AI, gathering, mines, technology, faction upgrades, age progression, hero abilities, story, dialogue, victory redesign, multiplayer, fog, audio overhaul, external assets, generated assets, or broad balance changes were added.

`TesanaWorldEditor` remains absent from the production autoload list. Network audit reports no unexpected listener or external asset dependency.

## Validation evidence

The dedicated v0.432 validator distinguishes `baseSha`, `captureSourceSha`, and `finalCommitSha`, verifies the authoritative definitions, exact transactions, reservation lifecycle, spawn/selection/movement traces, required PNGs, and black-frame/luminance evidence. The retained v0.431 validator and the full required local validation ladder are run before commit closeout.

## CI and final state

CI evidence and the final commit SHA are added after the explicit v0.432 validation ladder, commit, stacked draft PR, and exact-SHA GitHub Actions run complete. Historical untracked backlog in the workspace remains preserved and unstaged.
