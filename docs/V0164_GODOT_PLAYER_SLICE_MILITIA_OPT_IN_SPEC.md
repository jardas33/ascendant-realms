# v0.164 Godot Salto Militia Third Opt-In Spec

Status: `PASS_V0164_MILITIA_OPT_IN_HUMAN_REVIEW_READY`; human review still required.

Scope:

- Add only the selected Militia billboard as the third normal-slice opt-in art slot.
- Keep the default stabilized launcher procedural.
- Preserve the Worker-only launcher and the Worker + Barracks launcher unchanged.
- Add a new Worker + Barracks + Militia launcher for bounded review.
- Prove Militia missing-art and hash-mismatch fallback without disturbing Worker or Barracks.
- Run equivalent validation, capture, benchmark, real-input, Computer Use, and boundary checks.

Selected slots:

- Worker: `worker_billboard_static_v0147` / `HYBRID_WORKER_TRIMMED_1024` / `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Barracks: `barrosan_barracks_material_v0149` / `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND` / `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f`.
- Militia: `militia_billboard_static_v0154` / `HYBRID_MILITIA_TRIMMED_1024` / `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb`.

New entry points:

- `GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat`
- `npm run godot:launch:salto-worker-barracks-militia-art-experiment`
- `npm run godot:validate:salto-worker-barracks-militia-art-experiment`
- `npm run godot:capture:salto-worker-barracks-militia-art-experiment`

Acceptance gates:

- `PASS_V0164_MILITIA_OPT_IN_VALIDATION`
- `PASS_V0164_MILITIA_OPT_IN_FUNCTIONAL`
- `PASS_V0164_MILITIA_OPT_IN_CAPTURE`
- `PASS_V0164_MILITIA_OPT_IN_BENCHMARK`
- `PASS_V0164_MILITIA_OPT_IN_REAL_INPUT`
- `PASS_V0164_MILITIA_OPT_IN_COMPUTER_USE_GATE`
- `PASS_V0164_PLAYER_SLICE_THREE_SLOT_BOUNDARY`
- `PASS_V0164_MILITIA_OPT_IN_HUMAN_REVIEW_READY`

Forbidden in this checkpoint:

- No fourth player-facing art slot.
- No new image generation.
- No browser runtime wiring.
- No production manifest mutation.
- No save or stable-ID mutation.
- No gameplay, AI, objective, map, input, balance, or campaign mutation.
- No final runtime-art approval, final Militia art approval, final Godot choice, full port, or v0.165 work.
