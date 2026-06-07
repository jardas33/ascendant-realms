# v0.163 Barracks Material Opt-In Computer Use Review

Status: `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_COMPUTER_USE_GATE`.

The Computer Use pass must inspect the packaged Godot app, not the browser runtime. It reviews the default procedural posture, Worker-only opt-in posture, combined Worker + Barracks posture, and Barracks fallback posture.

Required tracked evidence after review:

- Artifact report: `artifacts/desktop-spikes/godot-salto/v0163/computer-use/worker-barracks-art-opt-in-computer-use-review.json`.
- Gate report: `artifacts/desktop-spikes/godot-salto/v0163/computer-use/worker-barracks-art-opt-in-computer-use-gate.json`.

Required PASS gate:

- `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_COMPUTER_USE_GATE`.

Observed postures:

- M0 default procedural reached menu, briefing, and battle.
- M1 Worker-only reached battle with selected Worker billboard visible and no Barracks material posture.
- M2 Worker + Barracks reached battle with both opt-in slots readable.
- M3 missing-art fallback reached battle with Worker active and Barracks procedural.
- M3 hash-mismatch fallback reached battle with Worker active and Barracks procedural.

The review artifact records five postures and fifteen positive checks.

Review checklist:

- Default launcher is procedural.
- Worker-only launcher is preserved.
- Combined posture is readable with two slots only.
- Worker art remains readable against the map and selection ring.
- Barracks material reads as a Barracks shell and does not obscure click targets.
- Barracks fallback returns the Barracks only to procedural while Worker art remains active.
- No third player-facing art slot or browser-runtime path is observed.
