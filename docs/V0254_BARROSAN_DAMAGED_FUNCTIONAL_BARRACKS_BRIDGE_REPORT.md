# v0.254 Barrosan Damaged but Functional Field Barracks Bridge

Verdict: `PARTIAL`

## Exact facts

- Resolved base commit: `177fffcd545670cd2bfc346ae0cd460a50e5b152`.
- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27923998996.
- Implementation commit: `406878cdbb0163c1f8266199a31ccfe5d5839fd9`.
- Final repository HEAD: `406878cdbb0163c1f8266199a31ccfe5d5839fd9`.
- Exact-SHA GitHub Actions run: https://github.com/jardas33/ascendant-realms/actions/runs/27926809716.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB).
- Files changed: opt-in runtime subclass, capture dispatch, v0.254 capture/validator/report tooling, package scripts and this report.
- Runtime systems touched: authoritative Field Barracks HP-gated production, damaged-building HUD, deterministic no-passive-collapse proof, preserved Worker repair and defended combat branches.
- Default systems untouched: browser/default Godot runtime, global damage/destruction, AI, waves, rebuilding, saves, pathfinding and assets.

## Damaged but functional contract

- Construction: 420/160/90/38 -> 240/40/90/38 (-180 Crowns / -120 Stone); Field Barracks starts 200/200.
- Warning precedes damage and causes no damage. Missed-window damage remains 200 -> 175 -> 150 -> 125.
- At 125/200 the Barracks remains selectable: true; functional: true; Train Militia available: true.
- Train-from-damaged resources: 240/40/90/38 -> 180/40/70/38 (-60 Crowns / -20 Iron). Exactly one Militia is produced.
- HP after training and six wait attempts: 125/200 and 125/200; accepted extra damage ticks: 0.
- No passive collapse: true. No refund: true. No extra charge: true. Production is disabled only at HP 0: true.

## Optional repair and defended regression

- Repair remains optional and available at 125/200. Cost: -30 Crowns / -30 Stone, charged once.
- Repair resources: 240/40/90/38 -> 210/10/90/38. HP: 125 -> 150 -> 175 -> 200. No overheal; unavailable at full HP.
- Repaired Barracks final HP: 200/200; repair status: PASS.
- Defended branch remains one Militia versus one Raider: 100/60 -> 90/40 -> 80/20 -> 70/0.
- Defended Barracks: 200/200; Raider count: 1; Militia count: 1.

## Preservation and validation

- Aster / Worker HP: 100/100 and 80/80.
- Minimap preserved: true. Existing Barracks / Keep / Mine preserved: true / true / true.
- Shells remain non-producing: true. Default runtime changed: false.
- Pathing honesty: review-grade deterministic lane and existing rectangular destination nudge.
- Destruction honesty: HP 0 is a dormant production-disable rule only; v0.254 does not force or exercise destruction.
- v0.254 capture and dedicated validator: pass.
- Full local validation: pass. Exact-SHA GitHub Actions: pass.

## Honest assessment

The corrected bridge proves proper RTS-style damaged functionality for one authoritative opt-in Field Barracks. It remains deliberately scripted and local, so the honest verdict is PARTIAL.
Recommendation for v0.255: add an explicit future attack/damage route that can reach HP 0 and exercise the dormant disabled-state rule, without passive collapse, broad AI or rebuilding.

Stop after v0.254. Do not begin v0.255.
