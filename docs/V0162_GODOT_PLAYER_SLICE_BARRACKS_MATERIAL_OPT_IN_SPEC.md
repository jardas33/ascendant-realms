# v0.162 Godot Player-Slice Barracks Material Opt-In Spec

Status: `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_HUMAN_REVIEW_READY`.

Scope:
- Add only `barrosan_barracks_material_v0149` as the second normal-slice opt-in art slot.
- Use only `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND`.
- Preserve the existing Worker slot `worker_billboard_static_v0147` / `HYBRID_WORKER_TRIMMED_1024`.
- Preserve `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat` as the unchanged procedural default launcher.
- Preserve `GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat` as the unchanged Worker-only launcher.

New player-facing opt-in launcher:
- `GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat`
- The launcher passes explicit Worker and Barracks source, metadata, and expected SHA-256 flags.
- The Barracks material opt-in is disabled unless `--barracks-material-opt-in` is present.

Barracks source:
- Slot: `barrosan_barracks_material_v0149`
- Approach: `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND`
- SHA-256: `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f`
- Dimensions: `768 x 768`
- Source path: `artifacts/desktop-spikes/godot-salto/v0150/local-barracks-material-seam-repair/barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png`

Acceptance posture:
- Default mode remains procedural.
- Worker-only mode remains one-slot Worker-only.
- Combined mode requests exactly two normal-slice opt-in art slots.
- Barracks missing-art fallback keeps Worker art active and returns only the Barracks shell to procedural.
- Barracks hash-mismatch fallback keeps Worker art active and returns only the Barracks shell to procedural.
- No Aster, Militia, Ashen Raider, browser-runtime, save, stable-ID, production manifest, or third-slot work is included.

Validated evidence:
- `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_VALIDATION`
- `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_CAPTURE`
- `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_BENCHMARK`
- `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_REAL_INPUT`
- `PASS_V0162_PLAYER_SLICE_TWO_SLOT_BOUNDARY`
