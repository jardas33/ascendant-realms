# v0.218 Implementation Report

Status: PASS

v0.218 adds a reversible procedural bridge-shell layer to the isolated Godot Salto presentation-reboot shell-v2 path. It generates zero images, adds zero art slots, preserves the legacy bridge comparator and keeps the default stabilized launcher procedural.

## Files Created

- `tools/godot/captureGodotSaltoBridgeShellWindows.ps1`
- `tools/godot/validateGodotSaltoBridgeShellWindows.ps1`
- `tools/godot/runGodotSaltoBridgeShellBenchmarkWindows.ps1`
- `tools/godot/saltoBridgeShellTool.mjs`
- `docs/V0218_BRIDGE_SHELL_REPORT.md`
- `docs/V0218_IMPLEMENTATION_REPORT.md`

Ignored/generated evidence:

- `artifacts/desktop-spikes/godot-salto/v0218/`
- `artifacts/manual-review/v0218-bridge-shell/`

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

- Added `--salto-bridge-shell-reboot` and `--salto-bridge-shell-legacy-comparator` handling for the isolated presentation-reboot path.
- Added selected and legacy bridge-shell status reporting to capture, validation, benchmark and spike status manifests.
- Added v0.218 bridge-focused capture steps for old bridge, normal RTS overview, close bridge, west/east approaches, riverbank seats, units crossing, fallback and contact sheet.
- Added a procedural bridge shell with stone abutments, bank seats, shoulders, deck, curbs, guard rails, posts, cross ties, landing shadows and center readability cues.
- Added validation and benchmark gates proving the selected bridge, the legacy comparator and default procedural fallback.

## Validation Results

| Check | Result |
| --- | --- |
| Bridge shell capture | PASS_V0218_BRIDGE_SHELL_CAPTURE_READY |
| Bridge shell review pack | PASS_V0218_BRIDGE_SHELL_REVIEW_PACK |
| Bridge shell validation | PASS_V0218_BRIDGE_SHELL_VALIDATION |
| Bridge shell benchmark | PASS_V0218_BRIDGE_SHELL_BENCHMARK |
| Bridge shell boundary gate | PASS_V0218_BRIDGE_SHELL_BOUNDARY |
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
| selected-bridge-shell | 75.57 | 13.35 |
| legacy-bridge-comparator | 75.65 | 13.72 |

Selected p95 frame-time ratio versus legacy bridge comparator: `0.973`.

## Boundary Notes

- Generated images: zero.
- Downloaded assets: zero.
- New art slots: zero.
- New production runtime art slots: zero.
- Browser runtime changes: none.
- Default launcher changes: none.
- Prior launcher removal: none.
- Gameplay, pathing, collision, objectives, AI, economy, saves, stable IDs and balance changes: none.

## Decision

PASS. v0.218 is ready to commit, push, verify CI and then continue to v0.219 only from a clean synced state.
