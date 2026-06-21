# v0.251 Barrosan First Defense Consequence Bridge

Verdict: `PARTIAL`

## Exact facts

- Resolved base commit: `c260c2e49c6acad48340fbac5d818929b0e6bde2`.
- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27915230603.
- Implementation commit: `PENDING_PUBLICATION`.
- Final repository HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: PENDING_PUBLICATION.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB).
- Files changed: opt-in runtime subclass, capture dispatch, v0.251 evidence/validator/report tooling, package scripts and this report.
- Runtime systems touched: v0.251-only Field Barracks HP, bounded Raider building-pressure state, HUD feedback and defended/undefended proof snapshots.
- Default systems untouched: browser/default Godot runtime, global combat, AI, waves, economy, saves, pathfinding and assets.

## Defended branch

- Field Barracks construction: -180 Crowns / -120 Stone; starting HP 200/200.
- Militia production: -60 Crowns / -20 Iron; exactly one Militia.
- Raider: `v0247_ashen_raider_00`; count 1.
- Attack behavior: Attack arms targeting mode; next hostile click targets the only scripted Raider.
- Combat starts only after accepted order plus Militia and Raider within 115-unit intercept/contact radius.
- HP sequence: 100/60 -> 90/40 -> 80/20 -> 70/0.
- Field Barracks final HP: 200/200; Raider defeated: true; removed: true.

## Undefended branch

- Start condition: Field Barracks built, no Militia trained, no Attack order.
- Damage trigger: one Raider reaches the constructed Field Barracks within the bounded pressure radius; contact=true.
- Field Barracks HP: 200 -> 175 -> 150 -> 125.
- Survives: true; any building destroyed: false.
- Bounded stop after three ticks: true; resources unchanged: true; Aster/Worker unharmed: true.
- Raider minimap registered before pressure: true.

## Preservation and validation

- Existing Barracks / Keep / Mine preserved: true / true / true.
- Shells remain non-producing: true.
- Default runtime proof: opt-in skin disabled; no Raider, Field Barracks HP bridge, building damage, or v0.251 objective text.
- Pathing honesty: review-grade deterministic lane destination to one constructed Field Barracks.
- v0.251 capture and dedicated validator: pass.
- Full local validation and exact-SHA GitHub Actions: pending publication.

## Honest assessment

The first defense consequence is readable and deterministic, but the undefended Raider route targets only the constructed Field Barracks and stops after a scripted three-tick sequence. Verdict remains PARTIAL.
Recommendation for v0.252: improve natural player-facing consequence timing and feedback without adding waves, destruction, repair, or broad AI.

Stop after v0.251. Do not begin v0.252.
