# v0.232 Implementation Report

Status: `PRODUCTION_DIRECTION_PROVEN_NOT_PRODUCTION_ART`

## Outcome

The isolated v0.232 production-target scene is substantially better than v0.231. It reads as a small fantasy RTS diorama rather than a flat editor/debug board because it changes the representation: orthographic 3D depth, terrain elevation, recessed water, continuous route geometry, authored landmark massing, lighting and cast shadows.

It is not production art. The structures, terrain and units are still low-detail code-built primitives. Their purpose is to prove the camera, scale, hierarchy, lighting and asset-pipeline direction before investing in authored assets.

## Pipeline Decision

- Keep Godot.
- Stop extending the v0.231 battlefield compositor as a production-art path.
- Retain the old path for comparator, deterministic fallback and debug evidence.
- Build future environment art as a Blender-authored modular kit imported through GLTF.
- Reuse gameplay data, stable IDs, command/selection semantics, minimap data, HUD information architecture and capture/validation infrastructure.

## Isolation and Safety

- New scene: `res://scenes/salto_production_target_spike.tscn`.
- New private flag: `--salto-production-target-spike`.
- Non-playable visual proof only.
- Generated external images: zero.
- Downloaded assets: zero.
- New runtime-art slots: zero.
- Gameplay, saves, pathing, collision, AI, objectives, economy, production logic, browser runtime and default launcher: unchanged.

## Verification

- Exact seven-file review pack: present.
- Isolated contract: `PASS_V0232_PRODUCTION_TARGET_SPIKE`.
- Review validation: `PASS_V0232_VISUAL_PIPELINE_RESET_VALIDATION_READY`.
- Godot suite: `PASS_GODOT_HEADLESS_TESTS`.
- Application suite: 122 files and 887 tests passed.
- Production build: passed; existing large-chunk warning only.
- Content, art-intake and 52-slot runtime-art validators: passed.
- Experimental artifact retention and cleanup dry run: passed.
- `git diff --check`: passed; line-ending conversion warning only.
