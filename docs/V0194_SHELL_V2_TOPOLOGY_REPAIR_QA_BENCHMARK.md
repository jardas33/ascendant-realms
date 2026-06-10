# v0.194 Shell V2 Topology Repair QA And Benchmark

Status: `PASS_V0194_SHELL_V2_TOPOLOGY_REPAIR_QA_BENCHMARK`

Date: 2026-06-09

Scope: visual-only topology repair for the isolated Salto presentation shell v2 path. No images were generated, no art slots were added, the v0.189 wet-granite bridge-riverbank material remained unintegrated, the legacy shell remained available as comparator/fallback, the default launcher stayed procedural, and gameplay, pathing, collisions, objectives, AI, saves, stable IDs, browser runtime, production manifests, and prior launchers were left unchanged.

## Visual QA

Windows-side Computer Use review was performed before repair, after the first repair, and after the final right-side turnout cleanup.

Observed v0.193/v2 issues before repair:

- Terrain read as separated scoped rectangles rather than one battlefield base.
- Right-side diagonal road pieces and scoped material islands read as disconnected.
- Road-to-bridge transition was visually thin.
- River, banks, and bridge were aligned enough to prove architecture but still felt diagrammatic.

Repairs completed in v0.194:

- Consolidated the shell-v2 terrain into one coherent base plus three connected material overlays.
- Replaced disconnected road fragments with a connected road network using road material spans and procedural connector collars.
- Shortened the right-side turnout after live review so it no longer reads as a detached diagonal strip.
- Collapsed the river to one continuous channel and aligned banks/bridge seats/deck/abutments/rails to the same crossing.
- Preserved the old v0.193 shell-v2 evidence under `artifacts/desktop-spikes/godot-salto/v0194/before-v0193-authoritative/`.

## Topology Metrics

| Metric | v0.193 before | v0.194 after |
| --- | ---: | ---: |
| Terrain base surfaces | 8 | 4 |
| Detached terrain islands | 5 | 0 |
| Floating diagonal road fragments | 1 | 0 |
| Road strips | 6 | 10 |
| River segments | 3 | 1 |
| Bridge nodes | 7 | 9 |

Final v0.194 bound material targets:

- Ground: `v0194_west_contiguous_ground_material`, `v0194_central_bridge_contiguous_ground_material`, `v0194_east_route_ground_material_apron`.
- Road: `v0194_main_road_friendly_to_junction`, `v0194_main_road_junction_to_west_ramp`, `v0194_main_road_east_ramp_to_hostile`, `v0194_barracks_side_route_connected`, `v0194_mine_spur_route_connected`, `v0194_east_bank_turnout_connected`.

## Benchmark

Authoritative comparator: retained v0.193 shell-v2 path.

| Scenario | Average FPS | p95 frame time |
| --- | ---: | ---: |
| v0.193 before | 73.7 | 15.08 ms |
| v0.194 after | 75.21 | 13.23 ms |

Result: FPS ratio `1.0205`; p95 worsening ratio `-0.1227`; threshold was FPS ratio >= `0.90` and p95 worsening <= `0.15`.

## Evidence

- `artifacts/desktop-spikes/godot-salto/v0194/validation/shell-v2-topology-repair-validation-report.json`
- `artifacts/desktop-spikes/godot-salto/v0194/benchmark/shell-v2-topology-repair-benchmark-report.json`
- `artifacts/desktop-spikes/godot-salto/v0194/capture/shell-v2-topology-repair-capture-report.json`
- `artifacts/desktop-spikes/godot-salto/v0194/capture/shell-v2-topology-repair/screenshots/`

PASS gates:

- `PASS_V0194_SHELL_V2_TOPOLOGY_VALIDATION`
- `PASS_V0194_SHELL_V2_TOPOLOGY_BENCHMARK`
- `PASS_V0194_SHELL_V2_TOPOLOGY_CAPTURE_PACKET`
- `PASS_V0194_SHELL_V2_TOPOLOGY_BOUNDARY_SCAN`
- `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`

Human-review note: v0.194 improves shell-v2 topology coherence but remains a blockout/prototype presentation shell. It is now ready for human review, not for automatic wet-granite integration.
