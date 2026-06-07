# v0.164 Implementation Report

Status: `PASS_V0164_MILITIA_OPT_IN_HUMAN_REVIEW_READY`; human review still required.

Implemented:

- Added a Militia billboard opt-in loader to the Godot Salto 2.5D scene.
- Added exact source, metadata, slot ID, derivative, hash, dimension, decode, texture, material, and mesh validation for the selected v0.155 Militia derivative.
- Applied the Militia billboard only to friendly recruited Militia defenders when explicitly opted in.
- Preserved the default procedural launcher unchanged.
- Preserved the Worker-only launcher unchanged.
- Preserved the Worker + Barracks launcher unchanged.
- Added `GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat`.
- Added validation, capture, benchmark, real-input, Computer Use, boundary, and summary tooling for v0.164.

Not implemented:

- No fourth player-facing art slot.
- No new images.
- No browser runtime wiring.
- No production manifest mutation.
- No save or stable-ID mutation.
- No gameplay, objective, AI, map, input, balance, or campaign mutation.
- No final runtime-art approval, final Militia art approval, final Godot choice, full port, or v0.165 work.

Final scorecard:

- `PASS_V0164_MILITIA_OPT_IN_HUMAN_REVIEW_READY`
- Validation: `PASS_V0164_MILITIA_OPT_IN_VALIDATION`
- Functional: `PASS_V0164_MILITIA_OPT_IN_FUNCTIONAL`
- Capture: `PASS_V0164_MILITIA_OPT_IN_CAPTURE`
- Benchmark: `PASS_V0164_MILITIA_OPT_IN_BENCHMARK`
- Real-input: `PASS_V0164_MILITIA_OPT_IN_REAL_INPUT`
- Computer Use: `PASS_V0164_MILITIA_OPT_IN_COMPUTER_USE_GATE`
- Boundary: `PASS_V0164_PLAYER_SLICE_THREE_SLOT_BOUNDARY`

Benchmark ratios:

- M3 FPS ratio versus M0: `1.0003`
- M3 P95 frame-time ratio versus M0: `0.9442`
- M3 FPS ratio versus M2: `1.0001`
- M3 P95 frame-time ratio versus M2: `0.9478`

Human-review stop:

- The next step is Emmanuel manual review of the new Worker + Barracks + Militia launcher and v0.164 evidence packet.
- Do not begin v0.165 without explicit authorization.
