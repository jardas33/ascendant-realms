# v0.197 Mesh Compositor Windows QA And Benchmark

Status: `PASS_V0197_SHELL_V2_MESH_QA_BENCHMARK`

Date: 2026-06-10

Scope: visual-only Windows QA and topology repair for the isolated Salto shell-v2 procedural-mesh compositor path. No images were generated, no art slots were added, the v0.189 wet-granite bridge-riverbank material remained unintegrated, the legacy shell and v0.195 scoped-material shell were preserved as comparators/fallbacks, the default launcher stayed procedural, and gameplay, pathing, collisions, objectives, AI, saves, stable IDs, browser runtime, production manifests, and prior launchers were left unchanged.

## Windows QA

v0.197 narrows the v0.196 mesh-compositor presentation by reducing shell-only diagnostic marker dominance, softening future-art anchors, and keeping the bridge/road/river/bank route readable at the packaged Windows review resolution.

Computer Use note: the live packaged Godot window was opened through the v0.197 wrapper and inspected with the Windows helper. The desktop capture matched the manual-review pack, though a Windows Update toast overlapped the lower-right of the live desktop snapshot; the clean review evidence is therefore the deterministic manual PNG pack exported by the Godot capture harness.

Remaining future-scope note: the structure masses are still intentionally procedural and somewhat block-like. That is not a v0.197 topology regression and is left for the later structure-hierarchy prompt, not repaired inside this boundary.

## Topology And Material Metrics

| Metric | v0.196 M1 baseline | v0.197 M2 QA repair |
| --- | ---: | ---: |
| Terrain base surfaces | 1 | 1 |
| Detached terrain islands | 0 | 0 |
| Floating diagonal road fragments | 0 | 0 |
| Road ribbons | 7 | 7 |
| River surfaces | 1 | 1 |
| Bank edge segments | 4 | 4 |
| Bridge visual nodes | 13 | 13 |
| Mesh vertices | 231 | 231 |
| Mesh indices | 747 | 747 |
| Ground material bind targets | 1 | 1 |
| Road material bind targets | 7 | 7 |

Final v0.197 bound material targets:

- Ground: `v0196_mesh_contiguous_foothold_terrain_base`
- Road: `v0196_mesh_main_road_west_surface`, `v0196_mesh_main_road_bridge_feed_surface`, `v0196_mesh_bridge_deck_route_surface`, `v0196_mesh_main_road_east_surface`, `v0196_mesh_barracks_side_route_surface`, `v0196_mesh_mine_spur_surface`, `v0196_mesh_stage_spur_surface`
- Wet granite: none

## Benchmark

Authoritative comparator: retained v0.196 M1 mesh-compositor benchmark.

| Scenario | Average FPS | p95 frame time |
| --- | ---: | ---: |
| v0.196 M1 baseline | 75.30 | 13.53 ms |
| v0.197 M2 QA repair | 75.28 | 13.40 ms |

Result: FPS ratio `0.9997`; p95 worsening ratio `-0.0096`; threshold was FPS ratio >= `0.90` and p95 worsening <= `0.15`.

## Evidence

- `artifacts/desktop-spikes/godot-salto/v0197/validation/shell-v2-mesh-qa-validation-report.json`
- `artifacts/desktop-spikes/godot-salto/v0197/benchmark/shell-v2-mesh-qa-benchmark-report.json`
- `artifacts/desktop-spikes/godot-salto/v0197/capture/shell-v2-mesh-qa-capture-report.json`
- `artifacts/desktop-spikes/godot-salto/v0197/capture/m2-shell-v2-mesh-qa/screenshots/`
- `artifacts/desktop-spikes/godot-salto/v0197/boundary/shell-v2-mesh-qa-boundary-scan.json`
- `artifacts/desktop-spikes/godot-salto/v0197/cleanup-dry-run/salto-experimental-cleanup-report.json`
- `artifacts/desktop-spikes/godot-salto/v0197/artifact-retention-post-cleanup/salto-experimental-artifact-retention-report.json`
- `artifacts/manual-review/v0197-shell-v2-mesh-qa/`

Manual-review PNG pack:

- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0197-shell-v2-mesh-qa\01_overview.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0197-shell-v2-mesh-qa\02_roads.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0197-shell-v2-mesh-qa\03_bridge_approaches.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0197-shell-v2-mesh-qa\04_river_banks.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0197-shell-v2-mesh-qa\05_units_structures.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0197-shell-v2-mesh-qa\06_pan_zoom.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0197-shell-v2-mesh-qa\07_minimap.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0197-shell-v2-mesh-qa\08_contact_sheet.png`

Recommended review screenshots:

- `01_overview.png`
- `03_bridge_approaches.png`
- `04_river_banks.png`
- `05_units_structures.png`

PASS gates:

- `PASS_V0197_SHELL_V2_MESH_QA_VALIDATION`
- `PASS_V0197_SHELL_V2_MESH_QA_BENCHMARK`
- `PASS_V0197_SHELL_V2_MESH_QA_BOUNDARY_SCAN`
- `PASS_V0197_SHELL_V2_MESH_QA_CAPTURE_PACKET`
- `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`
- `PASS_V0197_SALTO_SHELL_V2_MESH_QA_VALIDATION_READY`
