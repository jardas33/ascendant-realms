# v0.197 Implementation Report

Status: `PASS_V0197_IMPLEMENTATION_REPORT`

Date: 2026-06-10

## Summary

v0.197 performs a Windows-side QA repair pass on the isolated Salto shell-v2 mesh-compositor review path. It keeps the v0.196 terrain topology intact while reducing shell-only marker dominance, validating live Windows presentation, exporting the required manual-review PNG pack, and preserving all default, gameplay, browser, art-slot, and wet-granite boundaries.

## Implementation

Runtime changes:

- Added a v0.197 checkpoint/capture branch for the mesh-compositor QA path.
- Kept the one-terrain-base, seven-road-ribbon, one-river-channel, four-bank-edge, and thirteen-bridge-node topology from v0.196.
- Reduced mesh-compositor-only future anchor and selection marker dominance so the road/bridge/river composition reads more clearly.
- Preserved selected Worker, Barracks, Militia, Aster, Ashen, ground, and road opt-in context only through explicit review launchers.
- Preserved all gameplay, pathing, collisions, objectives, AI, saves, stable IDs, default launchers, prior launchers, and browser runtime behavior.

Tooling changes:

- Added v0.197 launch, review, capture, validate, and benchmark Windows wrappers.
- Added `tools/godot/saltoShellV2MeshQaTool.mjs` for validation, manual-review pack export, benchmark, boundary scan, cleanup dry-run/safe-only, and retention evidence.
- Added npm scripts for `godot:launch/review/capture/validate/benchmark:salto-shell-v2-mesh-qa`.

Docs added:

- `docs/V0197_MESH_COMPOSITOR_WINDOWS_QA_BENCHMARK.md`
- `docs/V0197_MESH_COMPOSITOR_BOUNDARY_ROLLBACK.md`
- `docs/V0197_IMPLEMENTATION_REPORT.md`

## Validation

Final v0.197 gates:

- `npm run godot:validate:salto-shell-v2-mesh-qa`
- `npm run godot:capture:salto-shell-v2-mesh-qa`

Latest gate results:

- `PASS_V0197_SHELL_V2_MESH_QA_VALIDATION`
- `PASS_V0197_SHELL_V2_MESH_QA_BENCHMARK`
- `PASS_V0197_SHELL_V2_MESH_QA_BOUNDARY_SCAN`
- `PASS_V0197_SHELL_V2_MESH_QA_CAPTURE_PACKET`
- `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`
- `PASS_V0197_SALTO_SHELL_V2_MESH_QA_VALIDATION_READY`

Benchmark result: v0.197 M2 average FPS `75.28` versus v0.196 M1 average FPS `75.30`; v0.197 p95 `13.40` ms versus v0.196 p95 `13.53` ms.

## Human Review

Manual-review screenshots are available under:

- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0197-shell-v2-mesh-qa`

Recommended review screenshots:

- `01_overview.png`
- `03_bridge_approaches.png`
- `04_river_banks.png`
- `05_units_structures.png`

The current v0.197 shell-v2 path is a stronger Windows-reviewed mesh-compositor presentation than v0.196 while still being a procedural review prototype. It is not approval to integrate wet-granite material, add art slots, change gameplay, or enable art by default.

## Stop Condition

The checkpoint stops here for human review unless the queued prompt sequence is still explicitly active and v0.197 has been committed, pushed, clean, synced, and remote-green.
