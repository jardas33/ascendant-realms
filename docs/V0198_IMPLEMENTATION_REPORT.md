# v0.198 Implementation Report

Status: `PASS_V0198_IMPLEMENTATION_REPORT`

Date: 2026-06-10

## Summary

v0.198 integrates the selected v0.189 Barrosan wet-granite bridge-riverbank material as exactly one explicit opt-in environment-material slot for the isolated Salto shell-v2 mesh-compositor review path. It keeps the v0.197 mesh topology intact, scopes the material to six bridge/ridge-edge surfaces, proves missing-art and hash-mismatch fallback, exports the required manual-review PNG pack, benchmarks the opt-in path, and preserves all default, gameplay, browser, character-slot, legacy-shell, and prior-launcher boundaries.

## Implementation

Runtime changes:

- Added bridge-riverbank material opt-in state, configuration, status reporting, and loader/fallback handling to the Godot Salto spike scene.
- Added explicit root flags for bridge-riverbank material opt-in, source path, metadata path, expected SHA-256, fallback mode, and UV scale.
- Verified the selected material source by exact metadata SHA, actual image SHA, metadata/source dimensions, slot ID, and approach.
- Created the material and texture once with linear filtering and mipmaps, then reused them for scoped mesh-compositor binding.
- Preserved procedural fallback surfaces when the opt-in flag is absent, the source is missing, or metadata hash verification fails.
- Bound wet granite only to two short bridge-adjacent bank retaining edges plus four bridge abutment/landing apron masses.
- Kept long riverbank ribbons procedural after inspection showed broad material application read too dark and bar-like.
- Preserved five frozen character slots, ground material, road material, default procedural launcher, prior launchers, legacy shell comparators, browser runtime, gameplay, pathing, collisions, objectives, AI, saves, stable IDs, and production manifests.

Tooling changes:

- Added v0.198 launch, review, capture, validate, and benchmark Windows wrappers.
- Added `tools/godot/saltoShellV2MeshWetGraniteTool.mjs` for validation, manual-review pack export, benchmark, boundary scan, cleanup dry-run/safe-only, and retention evidence.
- Added npm scripts for `godot:launch/review/capture/validate/benchmark:salto-shell-v2-mesh-wet-granite`.

Docs added:

- `docs/V0198_WET_GRANITE_MESH_OPT_IN_QA_BENCHMARK.md`
- `docs/V0198_WET_GRANITE_BOUNDARY_ROLLBACK.md`
- `docs/V0198_IMPLEMENTATION_REPORT.md`

## Validation

Final v0.198 gates:

- `node --check tools/godot/saltoShellV2MeshWetGraniteTool.mjs`
- `npm run godot:validate:salto-shell-v2-mesh-wet-granite`
- `npm run godot:capture:salto-shell-v2-mesh-wet-granite`

Latest gate results:

- `PASS_V0198_WET_GRANITE_MESH_OPT_IN_VALIDATION`
- `PASS_V0198_WET_GRANITE_MESH_OPT_IN_BENCHMARK`
- `PASS_V0198_WET_GRANITE_MESH_OPT_IN_BOUNDARY_SCAN`
- `PASS_V0198_WET_GRANITE_MESH_OPT_IN_CAPTURE_PACKET`
- `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`
- `PASS_V0198_WET_GRANITE_MESH_OPT_IN_VALIDATION_READY`

Benchmark result: v0.198 W1 average FPS `75.12` versus v0.197 M2 average FPS `75.32`; W1 p95 `13.37` ms versus M2 p95 `13.21` ms. FPS ratio is `0.9973`; p95 worsening ratio is `0.0121`.

## Human Review

Manual-review screenshots are available under:

- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0198-wet-granite-mesh`

Recommended review screenshots:

- `02_wet_granite_bridge_banks.png`
- `03_bridge_close.png`
- `04_banks_close.png`
- `08_contact_sheet.png`

Review note: v0.198 is a first scoped material integration for the mesh-compositor bridge/bank crossing only. The material is darker than the surrounding procedural shell, but after repair it appears as localized stone accents instead of broad vertical bank bars. Do not use this checkpoint as approval to bind the material to terrain, water, roads, structures, legacy shell, minimap, or default launchers.

## Stop Condition

The checkpoint stops here for human review unless the queued prompt sequence is still explicitly active and v0.198 has been committed, pushed, clean, synced, and remote-green.
