# v0.181 Road Material Opt-in QA Benchmark

Status: `PASS_V0181_ROAD_MATERIAL_OPT_IN_BENCHMARK`

v0.181 integrates the selected v0.180 Barrosan foothold road material into the Godot Salto normal review slice behind a new explicit opt-in launcher. It keeps the default launcher procedural, keeps all earlier launchers preserved, generates zero images, and leaves the character-slot phase frozen at five.

## Slot Contract

Selected road material:

- Slot: `barrosan_foothold_road_material_v0180`
- Approach: `ROAD_MATERIAL_LOCAL_1024`
- Source: `artifacts/desktop-spikes/godot-salto/v0180/local-road-material-slot/barrosan_foothold_road_material_v0180_1024.png`
- SHA-256: `a64959ef2fd7a509fcaaa969fca3e095d590d563a4f0c578a5e96d1fb04c0e10`
- Dimensions: `1024x1024`
- UV scale: `0.80`
- Filtering: linear with mipmaps

The material is applied only to:

- `v0173_main_road_wide_readable_bed`
- `v0173_barracks_side_path_wide_bed`
- `v0173_ruins_side_path_wide_bed`

Ground material remains the existing opt-in `barrosan_foothold_ground_material_v0175` slot with SHA `818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8`.

## Visual QA

Reviewed evidence:

- `artifacts/desktop-spikes/godot-salto/v0181/capture/e2-ground-road-material-opt-in/screenshots/03_ground_material_normal_rts.png`
- `artifacts/desktop-spikes/godot-salto/v0181/capture/e2-ground-road-material-opt-in/screenshots/05_road_river_bridge_hierarchy.png`
- `artifacts/desktop-spikes/godot-salto/v0181/capture/e2-ground-road-material-opt-in/screenshots/11_camera_max_zoom.png`
- Windows-side Computer Use review of title, briefing, battle start, and a safe Aster move-order input smoke.

Findings:

- Road material is visibly distinct from the darker terrain material and reads as the traversable main lane.
- River and bridge remain separate from the road-material surface.
- Road fallback preserves the procedural road while ground and character slots remain loaded.
- Live input smoke advanced from title to briefing to battle, then accepted a safe Aster move order.

## Benchmark

Scorecard:

- Status: `PASS_V0181_ROAD_MATERIAL_OPT_IN_BENCHMARK`
- Ground-only baseline average FPS: `75.09`
- Ground + road opt-in average FPS: `75.10`
- FPS ratio: `1.0001`
- Ground-only p95 frame time: `13.01 ms`
- Ground + road p95 frame time: `12.86 ms`
- p95 worsening: `-1.15%`

Fallbacks:

- Missing road source: `missing source file`, average FPS `75.02`, p95 `12.83 ms`
- Road hash mismatch: `metadata hash mismatch`, average FPS `75.18`, p95 `13.14 ms`

Commands run:

- `node --check tools/godot/saltoGroundRoadMaterialOptInTool.mjs`
- `npm run godot:validate:salto-ground-road-material-opt-in`

## Gate Status

Passed:

- `PASS_V0181_ROAD_MATERIAL_OPT_IN_VALIDATION`
- `PASS_V0181_ROAD_MATERIAL_OPT_IN_CAPTURE`
- `PASS_V0181_ROAD_MATERIAL_OPT_IN_BENCHMARK`
- `PASS_V0181_ROAD_MATERIAL_OPT_IN_BOUNDARY`
- `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`
