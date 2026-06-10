# v0.196 Shell V2 Mesh Compositor QA And Benchmark

Status: `PASS_V0196_SHELL_V2_MESH_COMPOSITOR_QA_BENCHMARK`

Date: 2026-06-10

Scope: visual-only replacement of the isolated Salto shell-v2 pad-and-line presentation with a bounded procedural-mesh compositor. No images were generated, no art slots were added, the v0.189 wet-granite bridge-riverbank material remained unintegrated, the legacy shell and v0.195 scoped-material shell were preserved as comparators/fallbacks, the default launcher stayed procedural, and gameplay, pathing, collisions, objectives, AI, saves, stable IDs, browser runtime, production manifests, and prior launchers were left unchanged.

## Visual QA

The v0.196 shell-v2 path now builds one contiguous foothold terrain mesh with connected route ribbons, a continuous river channel, framed banks, bridge deck/abutment/landing masses, and route-to-bridge continuity. A follow-up repair in the same bounded scope widened and darkened the river cut, added bank channel shadows, and kept the bridge crossing above the water path.

Human-review note: this is still a restrained procedural presentation prototype, not final terrain art. Existing selection rings, objective discs, Lume indicators, HUD panels, and current character art are intentionally preserved outside the v0.196 mesh-compositor scope.

Computer Use note: the native Computer Use pipe was unavailable during this pass because the helper reported an already-active request. The fallback evidence is the deterministic packaged Godot Windows capture harness plus direct PNG inspection of the manual-review pack.

## Topology And Material Metrics

| Metric | v0.195 comparator | v0.196 mesh compositor |
| --- | ---: | ---: |
| Terrain base surfaces | 4 | 1 |
| Detached terrain islands | 0 | 0 |
| Floating diagonal road fragments | 0 | 0 |
| Road ribbons | 14 | 7 |
| River surfaces | 1 | 1 |
| Bank edge segments | 26 | 4 |
| Bridge visual nodes | 25 | 13 |
| Mesh vertices | n/a | 231 |
| Mesh indices | n/a | 747 |
| Ground material bind targets | 6 | 1 |
| Road material bind targets | 10 | 7 |

Final v0.196 bound material targets:

- Ground: `v0196_mesh_contiguous_foothold_terrain_base`
- Road: `v0196_mesh_main_road_west_surface`, `v0196_mesh_main_road_bridge_feed_surface`, `v0196_mesh_bridge_deck_route_surface`, `v0196_mesh_main_road_east_surface`, `v0196_mesh_barracks_side_route_surface`, `v0196_mesh_mine_spur_surface`, `v0196_mesh_stage_spur_surface`
- Wet granite: none

## Benchmark

Authoritative comparator: retained v0.195 shell-v2 scoped-material recovery path.

| Scenario | Average FPS | p95 frame time |
| --- | ---: | ---: |
| v0.195 P1 comparator | 75.72 | 13.44 ms |
| v0.196 M1 mesh compositor | 75.30 | 13.53 ms |

Result: FPS ratio `0.9945`; p95 worsening ratio `0.0067`; threshold was FPS ratio >= `0.85` and p95 worsening <= `0.20`.

## Evidence

- `artifacts/desktop-spikes/godot-salto/v0196/validation/shell-v2-mesh-compositor-validation-report.json`
- `artifacts/desktop-spikes/godot-salto/v0196/benchmark/shell-v2-mesh-compositor-benchmark-report.json`
- `artifacts/desktop-spikes/godot-salto/v0196/capture/shell-v2-mesh-compositor-capture-report.json`
- `artifacts/desktop-spikes/godot-salto/v0196/capture/m1-shell-v2-mesh-compositor/screenshots/`
- `artifacts/desktop-spikes/godot-salto/v0196/boundary/shell-v2-mesh-compositor-boundary-scan.json`
- `artifacts/desktop-spikes/godot-salto/v0196/cleanup-dry-run/salto-experimental-cleanup-report.json`
- `artifacts/desktop-spikes/godot-salto/v0196/artifact-retention-post-cleanup/salto-experimental-artifact-retention-report.json`
- `artifacts/manual-review/v0196-shell-v2-mesh-compositor/`

Manual-review PNG pack:

- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0196-shell-v2-mesh-compositor\01_legacy_overview.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0196-shell-v2-mesh-compositor\02_mesh_compositor_overview.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0196-shell-v2-mesh-compositor\03_terrain_roads_normal.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0196-shell-v2-mesh-compositor\04_road_to_bridge.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0196-shell-v2-mesh-compositor\05_river_banks_bridge.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0196-shell-v2-mesh-compositor\06_structures_and_units.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0196-shell-v2-mesh-compositor\07_pan_zoom.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0196-shell-v2-mesh-compositor\08_minimap_full_frame.png`

Recommended review screenshots:

- `02_mesh_compositor_overview.png`
- `04_road_to_bridge.png`
- `05_river_banks_bridge.png`
- `06_structures_and_units.png`

PASS gates:

- `PASS_V0196_SHELL_V2_MESH_COMPOSITOR_VALIDATION`
- `PASS_V0196_SHELL_V2_MESH_COMPOSITOR_BENCHMARK`
- `PASS_V0196_SHELL_V2_MESH_COMPOSITOR_BOUNDARY_SCAN`
- `PASS_V0196_SHELL_V2_MESH_COMPOSITOR_CAPTURE_PACKET`
- `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`
- `PASS_V0196_SALTO_SHELL_V2_MESH_COMPOSITOR_VALIDATION_READY`
