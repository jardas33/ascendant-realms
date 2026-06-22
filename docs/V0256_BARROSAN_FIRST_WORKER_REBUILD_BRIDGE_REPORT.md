# v0.256 Barrosan First Worker Rebuild Bridge

Verdict: `PARTIAL`

## Exact facts

- Resolved base commit: `b3043402cb1219468ed09a8e0c3e1345a59f407e`.
- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27949696015.
- Implementation commit: `902c36606a1e02e1b6b91dd667c11ed1bb6e1c57`.
- Final repository HEAD: `documentation closeout commit (see final response)`.
- Exact-SHA GitHub Actions run: https://github.com/jardas33/ascendant-realms/actions/runs/27988129066.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB).
- Files changed: opt-in runtime subclass, capture dispatch, v0.256 capture/validator/report tooling, package scripts and this report.
- Runtime systems touched: destroyed Field Barracks state, Worker work-command routing, deterministic rebuild progress, production gating and review evidence.
- Default systems untouched: browser/default Godot runtime, Command Keep, Lume Mine, shell production, global destruction/rebuild, AI, waves, saves, pathfinding and assets.

## Construction, destruction and rebuild proof

- Construction: 420/160/90/38 -> 240/40/90/38 (-180 Crowns / -120 Stone); Field Barracks starts 200/200.
- Training cost remains -60 Crowns / -20 Iron. Repair cost remains -30 Crowns / -30 Stone. Rebuild cost is -90 Crowns / -40 Stone.
- First pressure: 200 -> 175 -> 150 -> 125. Waiting at 125 causes no passive collapse.
- Second explicit pressure: 125 -> 100 -> 75 -> 50 -> 25 -> 0. Production remains available above zero and stops at zero.
- Destroyed at 0: true. Production unavailable: true. Train unavailable: true. Repair unavailable: true.
- Worker Rebuild available at zero: true. Explicit order accepted: true. Spend count: 1.
- Rebuild resources: 240/40/90/38 -> 150/0/90/38. No refund and no second charge.
- Rebuild HP: 0 -> 25 -> 50 -> 75 -> 100. Production remains unavailable during progress.
- Completion HP: 100/200. Damaged but functional: true.
- Train from rebuilt Barracks: 150/0/90/38 -> 90/0/70/38; exactly one Militia; Barracks remains 100/200.

## Separation and preservation

- Repair available at damaged nonzero HP with resources: true. Rebuild unavailable above zero: true.
- At rebuilt 100/200, repair is structurally eligible but blocked by 0 Stone; Rebuild is unavailable because the target is standing.
- Repair remains unavailable at full HP. Rebuild remains unavailable when no destroyed Field Barracks exists.
- Defended first-pressure regression: PASS; combat 100/60 -> 90/40 -> 80/20 -> 70/0; Barracks 200/200.
- Aster / Worker HP: 100/100 and 80/80.
- Minimap preserved: true. Existing Barracks / Keep / Mine preserved: true / true / true. Shells non-producing: true.
- Default runtime changed: false.

## Validation and honest assessment

- Dedicated v0.256 capture and validator: pass.
- Full local validation: pass. Exact-SHA GitHub Actions: pass.
- Honest assessment: this is a first explicit Worker rebuild bridge for one authoritative opt-in Field Barracks. It restores only to 100/200 and uses placeholder progress/overlay presentation. Global building reconstruction remains intentionally absent, so the verdict is PARTIAL.
- Recommendation for v0.257: only if separately authorized, broaden reconstruction UX or add another bounded structure contract; do not infer a global rebuild system from this slice.

Stop after v0.256. Do not begin v0.257.
