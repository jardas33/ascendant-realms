# v0.253 Barrosan First Worker Repair Bridge

Verdict: `PARTIAL`

## Exact facts

- Resolved base commit: `c6acf6a01b23d66403f3e8b7ebe3a486fb33f71c`.
- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27921864487.
- Implementation commit: `PENDING_PUBLICATION`.
- Final repository HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: PENDING_PUBLICATION.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB).
- Files changed: opt-in runtime subclass, capture dispatch, v0.253 evidence/validator/report tooling, package scripts and this report.
- Runtime systems touched: one Worker-selected repair command, one authoritative Field Barracks target, deterministic repair ticks, repair HUD and restrained repair marker.
- Default systems untouched: browser/default Godot runtime, global repair, AI, waves, destruction, economy, saves, pathfinding and assets.

## Damage and repair contract

- Construction cost: -180 Crowns / -120 Stone. Field Barracks starts 200/200.
- Missed-window damage: 200 -> 175 -> 150 -> 125; damage then stops and the building survives.
- Repair preconditions: opt-in v0.253, Worker selected and alive, authoritative Field Barracks exists at less than 200 HP after bounded pressure, repair not already active or complete.
- Repair cost: -30 Crowns / -30 Stone / 0 Iron / 0 Aether, charged exactly once.
- Repair resources: 240/40/90/38 -> 210/10/90/38.
- Repair HP: 125 -> 150 -> 175 -> 200.
- Repair final HP: 200/200; stopped: true; overheal: false; repeated charge rejected: true; available at full HP: false.
- Resources unchanged after completion: true.

## Defended regression

- Exactly one Militia and one Raider; explicit Attack remains required during the warning window.
- Combat remains 100/60 -> 90/40 -> 80/20 -> 70/0.
- Field Barracks final HP: 200/200; Repair available: false.

## Preservation and validation

- Aster / Worker HP: 100/100 and 80/80.
- Minimap Worker / Field Barracks readable during repair: true / true.
- Existing Barracks / Keep / Mine preserved: true / true / true.
- Shells remain non-producing: true.
- Default runtime proof: opt-in skin disabled; no repair state, repair command, repair marker, repair spend or v0.253 copy.
- Pathing honesty: review-grade explicit Worker selection and deterministic repair ticks.
- Repair honesty: scripted single-target bridge only; no global repair system, queue, passive regeneration or broad building model.
- v0.253 capture and dedicated validator: pass.
- Full local validation: pass. Exact-SHA GitHub Actions: pending publication.

## Honest assessment

The first Worker repair loop is explicit, bounded and readable, but remains scripted to one authoritative Field Barracks with review-grade movement. Verdict remains PARTIAL.
Recommendation for v0.254: improve the Worker-to-target interaction and repair feedback cadence without adding global repair, destruction, waves or broad AI.

Stop after v0.253. Do not begin v0.254.
