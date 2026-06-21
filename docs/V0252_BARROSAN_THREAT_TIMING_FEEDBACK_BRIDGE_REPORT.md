# v0.252 Barrosan Threat Timing and Feedback Bridge

Verdict: `PARTIAL`

## Exact facts

- Resolved base commit: `06f179f4a40583e7f569dd0c0ebafd3411d7afeb`.
- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27916829778.
- Implementation commit: `PENDING_PUBLICATION`.
- Final repository HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: PENDING_PUBLICATION.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB).
- Files changed: opt-in runtime subclass, capture dispatch, v0.252 evidence/validator/report tooling, package scripts and this report.
- Runtime systems touched: v0.252-only three-step warning state, threat/damage-imminent markers, HUD copy, bounded damage feedback and branch proofs.
- Default systems untouched: browser/default Godot runtime, global combat, AI, waves, economy, saves, pathfinding and assets.

## Construction and warning contract

- Field Barracks construction: -180 Crowns / -120 Stone; starting HP 200/200.
- Militia production: -60 Crowns / -20 Iron; exactly one Militia in the defended branch.
- Raider: `v0247_ashen_raider_00`; count 1.
- Warning starts when one Raider reaches the constructed Field Barracks threat radius.
- Warning duration: 3 seconds / 3 deterministic steps.
- No warning damage: defended=true; missed=true; Barracks remains 200/200 at expiry.
- Minimap readable during warning: true.

## Defended in window

- Attack behavior: Attack arms targeting mode; next hostile click targets the only scripted Raider.
- Combat starts only after accepted order plus Militia and Raider within 115-unit Barracks threat/contact radius.
- HP sequence: 100/60 -> 90/40 -> 80/20 -> 70/0.
- Field Barracks final HP: 200/200; Raider defeated: true; removed: true.

## Missed window

- Damage trigger: warning expires at step 3 with no valid Militia intercept.
- Field Barracks HP: 200 -> 175 -> 150 -> 125.
- Damage stopped: true; Raider bounded: true; building survives: true; destroyed: false.
- Resources unchanged: true; Aster HP: 100/100; Worker HP: 80/80.

## Preservation and validation

- Existing Barracks / Keep / Mine preserved: true / true / true.
- Shells remain non-producing: true.
- Default runtime proof: opt-in skin disabled; no Raider, warning window, Field Barracks HP bridge, building damage, attack-order pressure bridge or v0.252 copy.
- Pathing honesty: review-grade deterministic lane destination and three-step threat window.
- v0.252 capture and dedicated validator: pass.
- Full local validation: pass. Exact-SHA GitHub Actions: pending publication.

## Honest assessment

The warning is fair, readable and deterministic, but it remains a scripted three-step window on a review-grade Raider route to one constructed Field Barracks. Verdict remains PARTIAL.
Recommendation for v0.253: improve player-controlled timing feel and damage feedback cadence without adding waves, destruction, repair, broad AI or free pathfinding.

Stop after v0.252. Do not begin v0.253.
