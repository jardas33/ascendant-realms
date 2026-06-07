# v0.162 Implementation Report

Status: `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_HUMAN_REVIEW_READY`; human review still required.

Implemented:
- Added a Barracks material opt-in loader to the Godot Salto 2.5D scene.
- Added exact metadata, hash, dimension, and approach validation for the selected v0.150 seam-repaired Barracks derivative.
- Applied the Barracks material only to friendly Barracks shell geometry when explicitly opted in.
- Preserved the Worker billboard opt-in path and default procedural path.
- Added `GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat`.
- Added validation, capture, benchmark, boundary, and summary tooling for v0.162.

Not implemented:
- No third slot.
- No Aster, Militia, or Ashen Raider player-facing slot.
- No browser runtime wiring.
- No save or stable-ID mutation.
- No production runtime-art manifest mutation.
- No final Godot engine decision.
- No v0.163 work.

Final scorecard:
- `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_HUMAN_REVIEW_READY`
- Benchmark ratios: Worker-only FPS `0.9975`, combined FPS `1.0028`, Worker-only P95 `1.0106`, combined P95 `1.0334`.
- Real-input smoke: `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_REAL_INPUT` using normal packaged Godot input, with `debugShortcutUsed=false` and `stateInjectionUsed=false`.
- Boundary: `PASS_V0162_PLAYER_SLICE_TWO_SLOT_BOUNDARY`.

Human-review stop:
- The next step is manual review of the combined Worker + Barracks launcher and v0.162 evidence packet.
