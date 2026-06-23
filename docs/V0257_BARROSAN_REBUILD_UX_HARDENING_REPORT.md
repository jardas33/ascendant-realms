# v0.257 Barrosan Rebuild UX Hardening

Verdict: `PARTIAL`

## Exact facts

- Base commit: `3de91a5332022151b71ab3e3aa3d27270e1433f8`.
- Implementation commit: `a9798bc4433ec968ab838e1c458a2fbf60825b4d`.
- Final HEAD: `a9798bc4433ec968ab838e1c458a2fbf60825b4d`.
- Exact-SHA GitHub Actions run: https://github.com/jardas33/ascendant-realms/actions/runs/27992461613.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB).
- Files changed: opt-in runtime HUD/capture dispatch, v0.257 evidence tooling, package scripts, and this report.
- Text changed: destroyed, damaged-functional, rebuilding, rebuilt, Worker Rebuild, Worker Repair, and no-target messages.
- "Rebuild not yet implemented" removed from the v0.257 path: true.
- Mechanics remain unchanged from v0.256: yes.

## UX and mechanical proof

- Destroyed HUD: Authoritative Field Barracks | Destroyed | HP 0/200 | Production unavailable | Select Worker to rebuild.
- Worker at destroyed target: Rebuild available | Destroyed Field Barracks | Cost: 90 Crowns / 40 Stone | Ready. | Repair unavailable | Target destroyed.
- Damaged HUD: Operational | HP 125/200 | Train Militia available. HP 25 HUD: Operational | HP 25/200 | Train Militia available.
- Rebuilding HUD: Production unavailable until rebuild complete | HP 25/200. Rebuilt HUD: Operational | Rebuilt HP 100/200 | Train Militia available.
- Construction: 420/160/90/38 -> 240/40/90/38.
- First pressure: 200 -> 175 -> 150 -> 125; no passive collapse.
- Second pressure: 125 -> 100 -> 75 -> 50 -> 25 -> 0.
- Repair is available only at HP 1-199. Rebuild is available only at HP 0.
- Rebuild resources: 240/40/90/38 -> 150/0/90/38.
- Rebuild HP: 0 -> 25 -> 50 -> 75 -> 100; production unavailable during progress.
- Production returns at rebuilt 100/200.
- Train from rebuilt: 150/0/90/38 -> 90/0/70/38; exactly one Militia.
- Defended branch: PASS; combat 100/60 -> 90/40 -> 80/20 -> 70/0; Barracks 200/200.
- Default runtime changed: false. Minimap and structures preserved: true.

## Validation and honest assessment

- Dedicated v0.257 capture and validator: pass.
- Full local validation: pass. Exact-SHA GitHub Actions: pass.
- Honest assessment: this is bounded opt-in UX/text hardening for one Field Barracks rebuild bridge. It is not global reconstruction; placeholder-grade visuals remain. Verdict is PARTIAL.
- Recommendation for v0.258: if separately authorized, test the next bounded gameplay consequence or broaden rebuild UX to another explicitly scoped structure without inferring a global system.

Stop after v0.257. Do not begin v0.258.
