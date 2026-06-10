# v0.195 Shell V2 Scoped Material Recovery QA And Benchmark

Status: `PASS_V0195_SHELL_V2_SCOPED_MATERIAL_RECOVERY_QA_BENCHMARK`

Date: 2026-06-09

Scope: visual-only scoped material recovery for the isolated Salto presentation shell v2 path. No images were generated, no art slots were added, the v0.189 wet-granite bridge-riverbank material remained unintegrated, the legacy shell remained available as comparator/fallback, the default launcher stayed procedural, and gameplay, pathing, collisions, objectives, AI, saves, stable IDs, browser runtime, production manifests, and prior launchers were left unchanged.

## Visual QA

The v0.194 shell-v2 topology repair solved the detached-island and floating-road problems, but the human-review scene read over-pruned: the ground material was too subdued at review distance and the road hierarchy was not strong enough to guide the eye from friendly area to bridge and hostile side.

Repairs completed in v0.195:

- Restored restrained ground-material hierarchy on six contiguous scoped surfaces without reintroducing giant translucent pads or detached islands.
- Bound the selected Barrosan foothold road material to ten connected route surfaces, including road collars and bridge ramps.
- Added narrow procedural road crowns, route cores, shoulder shadows, and readability ticks so roads follow routes and feed the bridge.
- Added v0.195-specific capture focus actions for road network, road intersections, road-to-bridge, and bridge-close review.
- Preserved the clean v0.194 topology as the before comparator under `artifacts/desktop-spikes/godot-salto/v0195/before-v0194-authoritative/`.

Human-review note: the final road treatment is intentionally more readable and a little more schematic than v0.194. It avoids the old broad masks and detached rectangles, but should still be reviewed by a human before any wet-granite or additional material integration.

## Topology And Material Metrics

| Metric | v0.194 before | v0.195 after |
| --- | ---: | ---: |
| Terrain base surfaces | 4 | 4 |
| Detached terrain islands | 0 | 0 |
| Floating diagonal road fragments | 0 | 0 |
| Road strips | 10 | 14 |
| River segments | 1 | 1 |
| Bridge nodes | 9 | 9 |
| Ground material bind targets | 3 | 6 |
| Road material bind targets | 6 | 10 |

Final v0.195 bound material targets:

- Ground: `v0195_west_contiguous_ground_material`, `v0195_central_bridge_contiguous_ground_material`, `v0195_east_route_ground_material_apron`, `v0195_command_yard_ground_material`, `v0195_mine_yard_ground_material`, `v0195_bridge_approach_ground_material`.
- Road: `v0195_main_road_friendly_to_junction`, `v0195_main_road_junction_to_west_ramp`, `v0195_main_road_east_ramp_to_hostile`, `v0195_barracks_side_route_connected`, `v0195_mine_spur_route_connected`, `v0195_east_bank_turnout_connected`, `v0195_west_road_intersection_material_collar`, `v0195_central_road_intersection_material_collar`, `v0195_bridge_west_road_ramp_material`, `v0195_bridge_east_road_ramp_material`.

## Benchmark

Authoritative comparator: retained v0.194 shell-v2 topology repair path.

| Scenario | Average FPS | p95 frame time |
| --- | ---: | ---: |
| v0.194 before | 75.17 | 13.30 ms |
| v0.195 after | 75.28 | 13.34 ms |

Result: FPS ratio `1.0015`; p95 worsening ratio `0.0030`; threshold was FPS ratio >= `0.90` and p95 worsening <= `0.15`.

## Evidence

- `artifacts/desktop-spikes/godot-salto/v0195/validation/shell-v2-scoped-material-recovery-validation-report.json`
- `artifacts/desktop-spikes/godot-salto/v0195/benchmark/shell-v2-scoped-material-recovery-benchmark-report.json`
- `artifacts/desktop-spikes/godot-salto/v0195/capture/shell-v2-scoped-material-recovery-capture-report.json`
- `artifacts/desktop-spikes/godot-salto/v0195/capture/shell-v2-scoped-material-recovery/screenshots/`
- `artifacts/desktop-spikes/godot-salto/v0195/boundary/shell-v2-scoped-material-boundary-scan.json`
- `artifacts/desktop-spikes/godot-salto/v0195/cleanup-dry-run/salto-experimental-cleanup-report.json`
- `artifacts/desktop-spikes/godot-salto/v0195/cleanup-safe-only/salto-experimental-cleanup-report.json`
- `artifacts/desktop-spikes/godot-salto/v0195/artifact-retention-post-cleanup/salto-experimental-artifact-retention-report.json`

Recommended review screenshots:

- `08_connected_road_network.png`
- `09_road_intersection.png`
- `10_road_to_bridge_transition.png`
- `12_bridge_close_view.png`

PASS gates:

- `PASS_V0195_SHELL_V2_SCOPED_MATERIAL_VALIDATION`
- `PASS_V0195_SHELL_V2_SCOPED_MATERIAL_BENCHMARK`
- `PASS_V0195_SHELL_V2_SCOPED_MATERIAL_BOUNDARY_SCAN`
- `PASS_V0195_SHELL_V2_SCOPED_MATERIAL_CAPTURE_PACKET`
- `PASS_V0166_EXPERIMENTAL_ARTIFACT_CLEANUP_DRY_RUN`
- `PASS_V0166_EXPERIMENTAL_ARTIFACT_SAFE_ONLY_CLEANUP`
- `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`
- `PASS_V0195_SALTO_SHELL_V2_SCOPED_MATERIAL_RECOVERY_VALIDATION_READY`
