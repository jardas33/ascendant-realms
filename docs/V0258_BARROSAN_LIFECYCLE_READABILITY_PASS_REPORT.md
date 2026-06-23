# v0.258 Barrosan Lifecycle Readability Pass

Verdict: `PARTIAL`

## Exact facts

- Base commit: `fca1f34ad0bf1304447e0a5d957afa702ae65973`.
- Implementation commit: `560f35f796a3182be56b0fbac41c0d78098243f2`.
- Final HEAD: `560f35f796a3182be56b0fbac41c0d78098243f2`.
- Exact-SHA GitHub Actions run: https://github.com/jardas33/ascendant-realms/actions/runs/27995663566.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB).
- Files changed: opt-in runtime lifecycle instructions/overlays, capture dispatch, v0.258 evidence tooling, package scripts, and this report.
- Instruction changes: Select Aster -> Select Worker -> Place/Click build -> pressure -> damaged/critical -> destroyed/rebuild -> rebuilt/train -> Militia defend.
- Visual changes: full trim, damaged planks, critical rubble, destroyed rubble/beam, rebuilding scaffold, and rebuilt patch overlays.
- "Rebuild not yet implemented" absent: true.
- "Select Aster" absent beyond initial phase: true.
- Mechanics remain unchanged from v0.257: yes.

## Lifecycle and mechanical proof

- Full resources: 420/160/90/38 -> 240/40/90/38 -> 150/0/90/38 -> 90/0/70/38.
- HP: 200 -> 175 -> 150 -> 125 -> 100 -> 75 -> 50 -> 25 -> 0; rebuild 0 -> 25 -> 50 -> 75 -> 100.
- Production remains available above HP 0, unavailable at HP 0 and during rebuild, and returns at rebuilt 100/200.
- Rebuild remains explicit at HP 0 only and costs exactly 90 Crowns / 40 Stone.
- Train after rebuild remains 60 Crowns / 20 Iron and produces exactly one Militia.
- Repair remains HP 1-199 only; Rebuild remains HP 0 only. No passive collapse, rebuild, repair, or refund.
- Defended branch: PASS; Militia/Raider 70/0; Barracks 200/200.
- Default runtime changed: false. Minimap and structures preserved: true.

## Validation and honest assessment

- Dedicated v0.258 capture and validator: pass.
- Full local validation: pass. Exact-SHA GitHub Actions: pass.
- Honest assessment: this is one bounded opt-in Field Barracks lifecycle readability pass using lightweight runtime overlays. It is not global reconstruction and remains placeholder-grade. Verdict is PARTIAL.
- Recommendation for v0.259: if separately authorized, improve one next bounded interaction or visual-feedback contract without broadening into global reconstruction, new waves, or economy gathering.

Stop after v0.258. Do not begin v0.259.
