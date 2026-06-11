# v0.216 Implementation Report

Status: PASS

v0.216 adds exactly one original Barrosan foothold terrain-material source, deterministic derivatives and an isolated presentation-reboot terrain binding. The selected material is opt-in-only, hash-gated and reversible.

## Files Created

- `tools/godot/captureGodotSaltoTerrainMaterialProductionWindows.ps1`
- `tools/godot/validateGodotSaltoTerrainMaterialProductionWindows.ps1`
- `tools/godot/runGodotSaltoTerrainMaterialProductionBenchmarkWindows.ps1`
- `tools/godot/saltoTerrainMaterialProductionTool.mjs`
- `docs/V0216_TERRAIN_MATERIAL_INTAKE_REPORT.md`
- `docs/V0216_TERRAIN_COMPOSITOR_REPORT.md`
- `docs/V0216_IMPLEMENTATION_REPORT.md`

Ignored/generated evidence:

- `artifacts/desktop-spikes/godot-salto/v0216/`
- `artifacts/manual-review/v0216-terrain-material-production/`

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

- Added v0.216 capture steps for terrain overview, normal RTS distance, zoomed-out view, pan/zoom framing and fallback comparison.
- Extended the presentation-reboot launcher to select the v0.216 terrain material by default, while preserving previous-material, missing-art and hash-mismatch scenarios.
- Added v0.216 terrain-material status fields to the Godot runtime manifest.
- Rebuilt deterministic derivatives from the same single generated source with an RTS-distance softening pass after visual review found the first derivative too speckled.
- Selected the 1024 softened derivative with SHA `8049b692b5d89d9abf5da39a79a31d8609ceb944dcb5695af8efc8553cd1eea3`.
- Tuned the reboot-only terrain material to UV scale `0.48` and alpha `0.24`.

## Validation Results

| Check | Result |
| --- | --- |
| Terrain material capture | PASS_V0216_TERRAIN_MATERIAL_CAPTURE_READY |
| Terrain material review pack | PASS_V0216_TERRAIN_MATERIAL_REVIEW_PACK |
| Terrain material validation | PASS_V0216_TERRAIN_MATERIAL_VALIDATION |
| Terrain material benchmark | PASS_V0216_TERRAIN_MATERIAL_BENCHMARK |
| Terrain material boundary gate | PASS_V0216_TERRAIN_MATERIAL_BOUNDARY |
| Artifact retention validation | PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION |
| Runtime-art slot validation | PASS, 52 slots validated |
| Content validation | PASS |
| Art-intake validation | PASS |
| Focused Godot scaffold tests | PASS, 53 Vitest checks |
| Production build | PASS with existing large chunk warning |
| Git diff check | PASS with line-ending warnings only |

Benchmark summary:

| Scenario | Average FPS | p95 frame ms |
| --- | ---: | ---: |
| selected-terrain | 75.17 | 13.15 |
| previous-ground-material | 75.60 | 13.34 |
| procedural-fallback | 75.73 | 13.35 |

Selected terrain measured an average FPS ratio of `0.994` and p95 frame-time ratio of `0.986` versus the previous ground material comparator. It measured an average FPS ratio of `0.993` and p95 frame-time ratio of `0.985` versus the procedural fallback.

## Boundary Notes

- Generated images: exactly one source image.
- Downloaded assets: zero.
- New production runtime art slots: zero.
- Browser runtime changes: none.
- Default launcher changes: none.
- Prior launcher removal: none.
- Gameplay, pathing, collision, objectives, AI, economy, saves, stable IDs and balance changes: none.

## Decision

PASS. v0.216 is ready to commit, push, verify CI and then continue to v0.217 only from a clean synced state.
