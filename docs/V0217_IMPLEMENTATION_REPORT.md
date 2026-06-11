# v0.217 Implementation Report

Status: PASS

v0.217 adds exactly one original road, riverbank, water and wet-edge material atlas, deterministic local derivatives and an isolated presentation-reboot material binding. The selected bundle is opt-in-only, hash-gated and reversible.

## Files Created

- `tools/godot/captureGodotSaltoRoadRiverbankWaterWindows.ps1`
- `tools/godot/validateGodotSaltoRoadRiverbankWaterWindows.ps1`
- `tools/godot/runGodotSaltoRoadRiverbankWaterBenchmarkWindows.ps1`
- `tools/godot/saltoRoadRiverbankWaterTool.mjs`
- `docs/V0217_ROAD_RIVERBANK_WATER_INTAKE_REPORT.md`
- `docs/V0217_ROAD_RIVERBANK_WATER_COMPOSITOR_REPORT.md`
- `docs/V0217_IMPLEMENTATION_REPORT.md`

Ignored/generated evidence:

- `artifacts/desktop-spikes/godot-salto/v0217/`
- `artifacts/manual-review/v0217-road-riverbank-water/`

## Files Updated

- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
- `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`
- `tools/godot/launchGodotSaltoPresentationRebootWindows.ps1`
- `package.json`
- `CHANGELOG.md`
- `DEVELOPMENT_CHECKPOINT.md`
- `LLM_GAME_HANDOFF.md`
- `ROADMAP.md`

## Implementation Notes

- Added v0.217 capture steps for road overview, road junction, river/banks, bridge approaches, normal RTS distance and fallback comparison.
- Extended the presentation-reboot launcher with selected, missing-art and hash-mismatch road/riverbank/water material modes.
- Added runtime status reporting for source atlas SHA, loaded regions, surface counts, texture creation and image decode counts.
- Bound road, riverbank, water and wet-edge materials into the shell-v2 mesh compositor while preserving the procedural fallback path.
- Tuned water, wet-edge and riverbank tinting after visual review to avoid a flat cyan strip and keep units/markers readable.

## Validation Results

| Check | Result |
| --- | --- |
| Road riverbank water capture | PASS_V0217_ROAD_RIVERBANK_WATER_CAPTURE_READY |
| Road riverbank water review pack | PASS_V0217_ROAD_RIVERBANK_WATER_REVIEW_PACK |
| Road riverbank water validation | PASS_V0217_ROAD_RIVERBANK_WATER_VALIDATION |
| Road riverbank water benchmark | PASS_V0217_ROAD_RIVERBANK_WATER_BENCHMARK |
| Road riverbank water boundary gate | PASS_V0217_ROAD_RIVERBANK_WATER_BOUNDARY |
| Artifact retention validation | PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION |
| Runtime-art slot validation | PASS, 52 slots validated |
| Content validation | PASS |
| Art-intake validation | PASS |
| Vitest suite | PASS, 887 tests |
| Godot scaffold tests | PASS_GODOT_HEADLESS_TESTS |
| Production build | PASS with existing large chunk warning |
| Git diff check | PASS with line-ending warnings only |

Benchmark summary:

| Scenario | Average FPS | p95 frame ms |
| --- | ---: | ---: |
| selected-road-riverbank-water | 75.54 | 13.34 |
| procedural-road-riverbank-water-fallback | 75.52 | 12.51 |

Selected p95 frame-time ratio versus procedural fallback: `1.066`.

## Boundary Notes

- Generated images: exactly one source atlas.
- Downloaded assets: zero.
- New production runtime art slots: zero.
- Browser runtime changes: none.
- Default launcher changes: none.
- Prior launcher removal: none.
- Gameplay, pathing, collision, objectives, AI, economy, saves, stable IDs and balance changes: none.

## Decision

PASS. v0.217 is ready to commit, push, verify CI and then continue to v0.218 only from a clean synced state.
