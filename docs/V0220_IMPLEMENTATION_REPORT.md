# v0.220 Implementation Report

Status: PASS

v0.220 adds one private prop-atlas intake and sparse deterministic environment dressing to the isolated Godot Salto presentation-reboot path. It keeps the default stabilized launcher procedural, preserves all previous launchers and comparators, and does not add a production runtime art slot.

## Files Created

- `tools/godot/captureGodotSaltoEnvironmentDressingWindows.ps1`
- `tools/godot/validateGodotSaltoEnvironmentDressingWindows.ps1`
- `tools/godot/runGodotSaltoEnvironmentDressingBenchmarkWindows.ps1`
- `tools/godot/saltoEnvironmentDressingTool.mjs`
- `docs/V0220_ENVIRONMENT_PROP_ATLAS_INTAKE_REPORT.md`
- `docs/V0220_ENVIRONMENT_DRESSING_REPORT.md`
- `docs/V0220_IMPLEMENTATION_REPORT.md`

Ignored/generated evidence:

- `artifacts/desktop-spikes/godot-salto/v0220/`
- `artifacts/manual-review/v0220-environment-dressing/`

## Files Updated

- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
- `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`
- `tools/godot/launchGodotSaltoPresentationRebootWindows.ps1`
- `tools/godot/captureGodotSaltoStructureShellProductionWindows.ps1`
- `tools/godot/validateGodotSaltoStructureShellProductionWindows.ps1`
- `tools/godot/runGodotSaltoStructureShellProductionBenchmarkWindows.ps1`
- `package.json`
- `CHANGELOG.md`
- `DEVELOPMENT_CHECKPOINT.md`
- `LLM_GAME_HANDOFF.md`
- `ROADMAP.md`

## Implementation Notes

- Added `--environment-prop-atlas-opt-in`, prop-atlas source/metadata/hash/fallback arguments, and `--salto-environment-dressing`.
- Added one selected v0.220 prop atlas with SHA `fa59ddb29281b12b818c065302af632d7710fd05f419d14e838cc002fc9588df`.
- Added hash-gated loading for accepted extracted prop crops and fail-closed missing/hash-mismatch behavior.
- Added 12 deterministic, visual-only atlas sprites around road shoulders, riverbanks, structures, bridge approaches and field edges.
- Kept v0.219 structure-shell tools on their prior visual path by explicitly disabling v0.220 dressing in those wrappers.
- Added v0.220 capture, validation, benchmark and manual-review-pack tooling.

## Validation Results

| Check | Result |
| --- | --- |
| Environment dressing capture | PASS_V0220_ENVIRONMENT_DRESSING_CAPTURE_READY |
| Environment dressing review pack | PASS_V0220_ENVIRONMENT_DRESSING_REVIEW_PACK |
| Environment dressing validation | PASS_V0220_ENVIRONMENT_DRESSING_VALIDATION |
| Environment dressing benchmark | PASS_V0220_ENVIRONMENT_DRESSING_BENCHMARK |
| Environment dressing boundary gate | PASS_V0220_ENVIRONMENT_DRESSING_BOUNDARY |
| Artifact retention validation | PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION |
| Safe-only cleanup dry run | PASS |
| Runtime art slot validation | PASS |
| Content validation | PASS |
| Art intake validation | PASS |
| Vitest suite | PASS: 887 tests |
| Godot scaffold tests | PASS_GODOT_HEADLESS_TESTS |
| Build | PASS |
| Git diff check | PASS; line-ending warnings only |

Benchmark summary:

| Scenario | Average FPS | p95 frame ms |
| --- | ---: | ---: |
| v0.219 before structure shell | 74.48 | 11.45 |
| selected environment dressing | 73.32 | 12.31 |

Selected p95 frame-time ratio versus the v0.219 comparator: `1.075`.

## Boundary Notes

- Generated images: exactly one.
- Downloaded assets: zero.
- New art slots: zero.
- New production runtime art slots: zero.
- Browser runtime changes: none.
- Default launcher changes: none.
- Prior launcher removal: none.
- Gameplay, pathing, collisions, objectives, AI, economy, saves, stable IDs and balance changes: none.

## Decision

PASS. v0.220 is ready for commit, push, CI verification and then v0.221 only from a clean synced state.
