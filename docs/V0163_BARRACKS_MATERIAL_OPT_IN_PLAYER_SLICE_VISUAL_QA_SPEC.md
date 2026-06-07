# v0.163 Barracks Material Opt-In Player-Slice Visual QA Spec

Status: `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_HUMAN_REVIEW_READY`.

v0.163 is a bounded QA-hardening pass for the existing combined Worker + Barracks-material opt-in player-slice path. It does not integrate a new art slot, generate images, alter the default stabilized launcher, alter the Worker-only launcher, or wire any browser runtime path.

## Review Postures

- M0 default procedural: `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat`.
- M1 Worker-only opt-in: `GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat`.
- M2 Worker + Barracks opt-in: `GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat`.
- M3 Barracks missing-art fallback: `GODOT_REVIEW_SALTO_WORKER_BARRACKS_ART_OPT_IN_WINDOWS.bat -Posture barracks-missing-art-fallback`.
- M3 Barracks hash-mismatch fallback: `GODOT_REVIEW_SALTO_WORKER_BARRACKS_ART_OPT_IN_WINDOWS.bat -Posture barracks-hash-mismatch-fallback`.

## Acceptance Checks

- Default remains fully procedural.
- Worker-only mode still loads exactly `worker_billboard_static_v0147` / `HYBRID_WORKER_TRIMMED_1024`.
- Combined mode loads exactly `barrosan_barracks_material_v0149` / `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND` as the second slot.
- Missing-art and hash-mismatch fallbacks keep Worker art active while returning only the Barracks to procedural material.
- Real-input smoke covers Worker selection, mine assignment, Barracks restoration, Militia continuation, recoverable mistakes, restart, and replay.
- The benchmark compares default procedural, Worker-only, and combined modes with the same executable and same run shape.
- Browser runtime, save, stable-ID, gameplay, objective, balance, AI, pathing, and package-boundary files remain untouched.

## v0.163 Result

- Validation: `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_QA_VALIDATION`.
- Capture: `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_CAPTURE`.
- Benchmark: `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_BENCHMARK`.
- Real-input: `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_REAL_INPUT`.
- Computer Use gate: `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_COMPUTER_USE_GATE`.
- Boundary: `PASS_V0163_PLAYER_SLICE_TWO_SLOT_BOUNDARY`.
- Final scorecard: `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_HUMAN_REVIEW_READY`.
