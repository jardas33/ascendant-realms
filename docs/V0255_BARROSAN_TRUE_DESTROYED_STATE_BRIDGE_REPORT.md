# v0.255 Barrosan True Destroyed State Bridge

Verdict: `PARTIAL`

## Exact facts

- Resolved base commit: `a0c682d94795a2bb81c62faeb9a1629d6fe4bd82`.
- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27943772442.
- Implementation commit: `6c67d0fc2dd0b16ee65846aff83459eed85c5506`.
- Final repository HEAD: `documentation closeout commit (see final response)`.
- Exact-SHA GitHub Actions run: https://github.com/jardas33/ascendant-realms/actions/runs/27949064432.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB).
- Files changed: opt-in runtime subclass, capture dispatch, v0.255 capture/validator/report tooling, package scripts and this report.
- Runtime systems touched: explicit bounded second pressure, true HP-zero destroyed state, destroyed HUD/marker and exercised production gate.
- Default systems untouched: browser/default Godot runtime, global destruction, AI, waves, reconstruction, saves, pathfinding and assets.

## Damage, production and destruction proof

- Construction: 420/160/90/38 -> 240/40/90/38 (-180 Crowns / -120 Stone); Field Barracks starts 200/200.
- First pressure: 200 -> 175 -> 150 -> 125. Warning precedes damage; first pressure stops at 125.
- No passive collapse: true; HP after wait: 125/200; accepted hidden ticks: 0.
- At 125/200 selectable: true; functional: true; Train Militia available: true.
- Train from damaged: 240/40/90/38 -> 180/40/70/38; exactly one Militia; Barracks remains 125/200.
- Explicit second pressure: 125 -> 100 -> 75 -> 50 -> 25 -> 0. A second warning occurs first and applies no warning-window damage.
- Production available at 25: true. Destroyed at 0: true. Production unavailable at 0: true.
- Train unavailable at 0: true. Repair unavailable at 0: true. No refund: true. Automatic rebuild: false.

## Preserved branches

- Repair remains optional: 240/40/90/38 -> 210/10/90/38; HP 125 -> 150 -> 175 -> 200; charged once; unavailable at full HP.
- Second pressure intercepted by damaged-Barracks Militia: PASS; Barracks final HP 125/200; combat 100/60 -> 90/40 -> 80/20 -> 70/0.
- Defended first-pressure regression: PASS; Barracks final HP 200/200; combat 100/60 -> 90/40 -> 80/20 -> 70/0.
- Raider counts: first missed 1, second destroyed 1, second intercepted 1, defended first 1. Militia counts: damaged training 1, second intercepted 1, defended first 1.
- Aster / Worker HP: 100/100 and 80/80.
- Minimap preserved: true. Existing Barracks / Keep / Mine preserved: true / true / true. Shells non-producing: true.
- Default runtime changed: false. Pathing honesty: review-grade deterministic explicit pressure lane and combat intercept.

## Validation and honest assessment

- Dedicated v0.255 capture and validator: pass.
- Full local validation: pass. Exact-SHA GitHub Actions: pass.
- Honest assessment: this exercises a true destroyed state only for the authoritative opt-in Field Barracks. Global destruction, rubble replacement and rebuilding remain intentionally absent, so the verdict is PARTIAL.
- Recommendation for v0.256: define a separately authorized reconstruction/rebuild contract or broaden destruction only after this local threshold bridge is accepted.

Stop after v0.255. Do not begin v0.256.
