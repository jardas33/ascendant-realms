# v0.196 Implementation Report

Status: `PASS_V0196_IMPLEMENTATION_REPORT`

Date: 2026-06-10

## Summary

v0.196 replaces the isolated Salto shell-v2 pad-and-line presentation with a bounded procedural-mesh compositor. It preserves the legacy shell and v0.195 scoped-material shell as comparators/fallbacks, keeps the v0.189 wet-granite bridge-riverbank source unintegrated, exports the required manual-review PNG pack, and stops at the v0.196 checkpoint boundary.

## Implementation

Runtime changes:

- Added the explicit `--salto-shell-v2-mesh-compositor` opt-in path behind the existing shell-v2 review posture.
- Added one coherent terrain mesh, seven connected road ribbons, one continuous river channel, four bank/shadow edges, bridge deck/abutment/landing/rail/plank masses, and scoped material bind telemetry.
- Added mesh-compositor status reporting for vertex/index counts, topology gates, material targets, UV scales, and boundary assertions.
- Added v0.196-specific capture focus actions for mesh overview, terrain/roads, road-to-bridge, river/banks/bridge, structures/units, pan/zoom, minimap, and results.
- Preserved all gameplay, pathing, collisions, objectives, AI, saves, stable IDs, default launchers, prior launchers, and browser runtime behavior.

Tooling changes:

- Added v0.196 launch, review, capture, validate, and benchmark Windows wrappers.
- Added `tools/godot/saltoShellV2MeshCompositorTool.mjs` for validation, manual-review pack export, benchmark, boundary scan, and retention evidence.
- Added npm scripts for `godot:launch/review/capture/validate/benchmark:salto-shell-v2-mesh-compositor`.

Docs added:

- `docs/V0196_SHELL_V2_MESH_COMPOSITOR_QA_BENCHMARK.md`
- `docs/V0196_SHELL_V2_MESH_COMPOSITOR_BOUNDARY_ROLLBACK.md`
- `docs/V0196_IMPLEMENTATION_REPORT.md`

## Validation

Final v0.196 gates:

- `npm run godot:validate:salto-shell-v2-mesh-compositor`
- `npm run godot:capture:salto-shell-v2-mesh-compositor`

Latest gate results:

- `PASS_V0196_SHELL_V2_MESH_COMPOSITOR_VALIDATION`
- `PASS_V0196_SHELL_V2_MESH_COMPOSITOR_BENCHMARK`
- `PASS_V0196_SHELL_V2_MESH_COMPOSITOR_BOUNDARY_SCAN`
- `PASS_V0196_SHELL_V2_MESH_COMPOSITOR_CAPTURE_PACKET`
- `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`
- `PASS_V0196_SALTO_SHELL_V2_MESH_COMPOSITOR_VALIDATION_READY`

Benchmark result: v0.196 M1 average FPS `75.30` versus v0.195 P1 average FPS `75.72`; v0.196 p95 `13.53` ms versus v0.195 p95 `13.44` ms.

## Human Review

Manual-review screenshots are available under:

- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0196-shell-v2-mesh-compositor`

Recommended review screenshots:

- `02_mesh_compositor_overview.png`
- `04_road_to_bridge.png`
- `05_river_banks_bridge.png`
- `06_structures_and_units.png`

The current v0.196 shell-v2 path is more coherent than the v0.195 pad-and-line surface stack, while still being a procedural review prototype. It is not approval to integrate wet-granite material, add art slots, change gameplay, or enable art by default.

## Stop Condition

The checkpoint stops here for human review unless the queued prompt sequence is still explicitly active and v0.196 has been committed, pushed, clean, synced, and remote-green.
