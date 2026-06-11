# v0.219 Implementation Report

Status: PASS

v0.219 adds a reversible production-pass structure-shell layer to the isolated Godot Salto presentation-reboot shell-v2 path. It generates zero images, adds zero art slots, preserves the legacy structure comparator and keeps the default stabilized launcher procedural.

## Files Created

- `tools/godot/captureGodotSaltoStructureShellProductionWindows.ps1`
- `tools/godot/validateGodotSaltoStructureShellProductionWindows.ps1`
- `tools/godot/runGodotSaltoStructureShellProductionBenchmarkWindows.ps1`
- `tools/godot/saltoStructureShellProductionTool.mjs`
- `docs/V0219_STRUCTURE_SHELL_PRODUCTION_REPORT.md`
- `docs/V0219_IMPLEMENTATION_REPORT.md`

Ignored/generated evidence:

- `artifacts/desktop-spikes/godot-salto/v0219/`
- `artifacts/manual-review/v0219-structure-shells/`

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

- Added `--salto-structure-shell-production` and `--salto-structure-shell-legacy-comparator` handling for the isolated presentation-reboot path.
- Bound the selected v0.202 structure-finish material, SHA `94d4975f9e6f13453103439135da930b74d1d66b56d2b10e43219de408f508ef`, only to approved shell-v2 structure surfaces.
- Added v0.219 structure-focused capture steps for overview, Command Hall, Barracks damaged/restoring/restored, mine/site, Aether support, units beside structures and an old/new contact sheet.
- Replaced the selected path's old cuboid-heavy structure hierarchy for Command Hall, West Stone Cut, Barracks and Aether support with restrained wall, roof, timber, stone-base, entrance, scaffold and state-read geometry.
- Hardened the v0.219 review tool so capture, validation and benchmark reports validate nested runtime status payloads rather than wrapper manifests.

## Validation Results

| Check | Result |
| --- | --- |
| Structure shell capture | PASS_V0219_STRUCTURE_SHELL_CAPTURE_READY |
| Structure shell review pack | PASS_V0219_STRUCTURE_SHELL_REVIEW_PACK |
| Structure shell validation | PASS_V0219_STRUCTURE_SHELL_VALIDATION |
| Structure shell benchmark | PASS_V0219_STRUCTURE_SHELL_BENCHMARK |
| Structure shell boundary gate | PASS_V0219_STRUCTURE_SHELL_BOUNDARY |
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
| selected-structure-shell | 75.28 | 13.31 |
| legacy-structure-comparator | 75.02 | 13.40 |

Selected p95 frame-time ratio versus legacy structure comparator: `0.993`.

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

PASS. v0.219 is ready for commit, push, CI verification and then v0.220 only from a clean synced state.
