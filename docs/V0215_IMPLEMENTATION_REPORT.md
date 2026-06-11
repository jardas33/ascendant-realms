# v0.215 Implementation Report

Status: PASS

v0.215 adds a new isolated Godot Salto presentation-reboot review path and compact HUD posture. It keeps the v0.214 full-HUD path as a comparator and leaves the default launcher procedural.

## Files Created

- `GODOT_LAUNCH_SALTO_PRESENTATION_REBOOT_EXPERIMENT_WINDOWS.bat`
- `tools/godot/launchGodotSaltoPresentationRebootWindows.ps1`
- `tools/godot/captureGodotSaltoPresentationRebootWindows.ps1`
- `tools/godot/validateGodotSaltoPresentationRebootWindows.ps1`
- `tools/godot/runGodotSaltoPresentationRebootBenchmarkWindows.ps1`
- `tools/godot/saltoPresentationRebootTool.mjs`
- `docs/V0215_PRESENTATION_REBOOT_BASELINE.md`
- `docs/V0215_UI_DECLUTTER_REPORT.md`
- `docs/V0215_IMPLEMENTATION_REPORT.md`

## Files Updated

- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
- `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`
- `package.json`
- `LLM_GAME_HANDOFF.md`
- `ROADMAP.md`
- `CHANGELOG.md`
- `DEVELOPMENT_CHECKPOINT.md`

## Implementation Notes

- Added `--salto-presentation-reboot` and a launcher-specific compact HUD branch.
- Added deterministic capture, validation and benchmark tooling for the reboot path.
- Added occupancy-budget reporting for top strip, minimap, selected context, production drawer, objective summary, event posture and tooltip docking.
- Reduced selection and target marker visual weight only when the presentation-reboot path is active.
- Preserved fallback/comparator coverage for the prior full-HUD path.

## Validation Results

| Check | Result |
| --- | --- |
| Presentation reboot capture | PASS_V0215_PRESENTATION_REBOOT_CAPTURE_READY |
| Presentation reboot validation | PASS_V0215_PRESENTATION_REBOOT_VALIDATION_READY |
| Presentation reboot boundary gate | PASS_V0215_PRESENTATION_REBOOT_BOUNDARY |
| Artifact retention validation | PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION |
| Presentation reboot benchmark | PASS_V0215_PRESENTATION_REBOOT_BENCHMARK_READY |
| Runtime-art slot validation | PASS, 52 slots validated |
| Content validation | PASS |
| Art-intake validation | PASS |
| Focused Godot scaffold tests | PASS, 53 Vitest checks |
| Production build | PASS with existing large chunk warning |
| Git diff check | PASS |

Benchmark summary:

| Scenario | Average FPS | p95 frame ms |
| --- | ---: | ---: |
| full-ui-comparator | 72.67 | 8.57 |
| presentation-reboot | 75.48 | 13.31 |
| procedural-fallback | 75.18 | 13.17 |

The reboot path measured an average FPS ratio of `1.039` and a p95 frame-time ratio of `1.553` versus the full-HUD comparator in the final local benchmark sample. The benchmark tool still reported `PASS_V0215_PRESENTATION_REBOOT_BENCHMARK`; treat the p95 ratio as noisy local review evidence rather than a production performance certification.

## Boundary Notes

- Generated images: zero.
- Downloaded assets: zero.
- Runtime art slots added: zero.
- Browser runtime changes: none.
- Default launcher changes: none.
- Prior launcher changes: none.
- Gameplay, pathing, collision, objective, AI, economy, save, stable-ID and balance changes: none.

## Decision

PASS. v0.215 is ready to commit, push, and continue to v0.216 only after CI success and clean sync confirmation.
