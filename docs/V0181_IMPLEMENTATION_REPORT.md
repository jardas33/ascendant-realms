# v0.181 Implementation Report

Status: `PASS_V0181_SALTO_GROUND_ROAD_MATERIAL_OPT_IN_AUTOMATION_READY`

v0.181 integrates the selected v0.180 Barrosan foothold road material into the Godot Salto normal review slice behind a new explicit combined ground + road opt-in launcher. The default launcher remains procedural and unchanged.

## Implementation

Added:

- Explicit road-material player-slice args: `--road-material-opt-in`, source, metadata, expected hash, fallback mode, and UV scale.
- Combined review launcher: `GODOT_REVIEW_SALTO_GROUND_ROAD_MATERIAL_OPT_IN_WINDOWS.bat`.
- Matching validate and capture wrappers.
- `tools/godot/saltoGroundRoadMaterialOptInTool.mjs`.
- Road-material validation, capture, benchmark, and boundary reports under `artifacts/desktop-spikes/godot-salto/v0181/`.

Changed:

- Added road-material load/status/fallback handling to the Godot Salto scene.
- Bound the selected material only to the main road and two side-path road beds.
- Kept procedural roads as fallback/underlay beneath the material overlay.
- Updated capture checkpoint handling so v0.181 uses the environment-material review screenshot set.

## Verification

Completed:

- `node --check tools/godot/saltoGroundRoadMaterialOptInTool.mjs`
- `npm run godot:validate:salto-ground-road-material-opt-in`
- Windows-side Computer Use review of the packaged opt-in app.

Result:

- Validation: `PASS_V0181_ROAD_MATERIAL_OPT_IN_VALIDATION`
- Capture: `PASS_V0181_ROAD_MATERIAL_OPT_IN_CAPTURE`
- Benchmark: `PASS_V0181_ROAD_MATERIAL_OPT_IN_BENCHMARK`
- Boundary: `PASS_V0181_ROAD_MATERIAL_OPT_IN_BOUNDARY`
- Retention: `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`

## Boundary Confirmation

Zero images generated.

Zero character slots added.

Exactly one environment-material opt-in slot added: the selected road material.

Browser runtime remains untouched.

Default launcher remains procedural.

v0.182 was not started inside this checkpoint.
