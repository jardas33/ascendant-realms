# v0.221 Implementation Report

Status: PASS

v0.221 adds an isolated composition, lighting, camera and selection-scale pass to the Godot Salto presentation-reboot review path. It generates zero images, downloads zero assets, adds zero art slots and leaves the default stabilized launcher procedural.

## Files Created

- `tools/godot/captureGodotSaltoCompositionLightingSelectionWindows.ps1`
- `tools/godot/validateGodotSaltoCompositionLightingSelectionWindows.ps1`
- `tools/godot/runGodotSaltoCompositionLightingSelectionBenchmarkWindows.ps1`
- `tools/godot/saltoCompositionLightingSelectionTool.mjs`
- `docs/V0221_BATTLEFIELD_COMPOSITION_REPORT.md`
- `docs/V0221_SELECTION_INDICATOR_REPORT.md`
- `docs/V0221_IMPLEMENTATION_REPORT.md`

Ignored/generated evidence:

- `artifacts/desktop-spikes/godot-salto/v0221/`
- `artifacts/manual-review/v0221-composition-lighting-selection/`

## Files Updated

- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
- `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`
- `tools/godot/launchGodotSaltoPresentationRebootWindows.ps1`
- `tools/godot/captureGodotSaltoEnvironmentDressingWindows.ps1`
- `tools/godot/validateGodotSaltoEnvironmentDressingWindows.ps1`
- `tools/godot/runGodotSaltoEnvironmentDressingBenchmarkWindows.ps1`
- `tools/godot/saltoPresentationRebootTool.mjs`
- `package.json`
- `CHANGELOG.md`
- `DEVELOPMENT_CHECKPOINT.md`
- `LLM_GAME_HANDOFF.md`
- `ROADMAP.md`

## Implementation Notes

- Added the `salto_composition_lighting_selection_enabled` review-path flag and status report.
- Added v0.221 camera, lighting, value, route, bridge, river, structure-contact and unit-grounding refinements as visual-only nodes.
- Reduced selection/focus ring scale and alpha only when the v0.221 composition pass is active.
- Added `--salto-composition-lighting-selection-disabled` to v0.220 wrappers so the v0.220 comparator path remains stable.
- Updated the v0.215 boundary checker to recognize later milestone-owned v0.220/v0.221 validation helpers without allowing tracked PNGs, browser source edits or broad path drift.

## Validation Results

| Check | Result |
| --- | --- |
| Composition capture | PASS_V0221_COMPOSITION_LIGHTING_SELECTION_CAPTURE_READY |
| Composition review pack | PASS_V0221_COMPOSITION_LIGHTING_SELECTION_REVIEW_PACK |
| Composition validation | PASS_V0221_COMPOSITION_LIGHTING_SELECTION_VALIDATION |
| Composition boundary gate | PASS_V0221_COMPOSITION_LIGHTING_SELECTION_BOUNDARY |
| Composition benchmark | PASS_V0221_COMPOSITION_LIGHTING_SELECTION_BENCHMARK |
| v0.220 environment dressing validation | PASS_V0220_ENVIRONMENT_DRESSING_VALIDATION |
| v0.215 presentation reboot validation | PASS_V0215_PRESENTATION_REBOOT_VALIDATION |
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
| v0.220 before composition | 74.85 | 13.28 |
| selected composition lighting selection | 75.04 | 13.41 |

Selected p95 frame-time ratio versus the v0.220 comparator: `1.010`.

## Boundary Notes

- Generated images: zero.
- Downloaded assets: zero.
- New art slots: zero.
- New production runtime art slots: zero.
- Browser runtime changes: none.
- Default launcher changes: none.
- Prior launcher removal: none.
- Gameplay, pathing, collisions, objectives, AI, economy, saves, stable IDs and balance changes: none.

## Decision

PASS. v0.221 is ready for commit, push and CI verification before any v0.222 work.
