# v0.200 Implementation Report

Status: `PASS_V0200_IMPLEMENTATION_REPORT`

Date: 2026-06-10

## Summary

v0.200 hardens the isolated Salto shell-v2 mesh-compositor structure-hierarchy path with restrained procedural grounding, overcast lighting balance, contact shadows, and sparse deterministic props. It preserves the v0.199 structure hierarchy comparator and the v0.198 wet-granite bridge/bank context, exports the required manual-review PNG pack, benchmarks green against the structure shell, and preserves all default, gameplay, browser, character-slot, legacy-shell, and prior-launcher boundaries.

## Implementation

Runtime changes:

- Added an explicit `--salto-shell-v2-grounding-lighting` flag and status reporting.
- Added opt-in-only procedural grounding-lighting visual node tracking.
- Added restrained ground value patches, bank/contact accents, rock clusters, moss/grass accents, timber and stone edge props, and warm hearth cues.
- Added v0.200-only visual framing and lighting posture for the explicit review path.
- Kept the default procedural launcher, legacy shell, v0.196 mesh-compositor baseline, v0.197 mesh QA path, v0.198 wet-granite mesh path, and v0.199 structure-hierarchy path available as comparators/fallbacks.
- Preserved five frozen character slots, selected ground material, selected road material, selected wet-granite bridge-riverbank material, default procedural launcher, prior launchers, browser runtime, gameplay, pathing, collisions, objectives, AI, saves, stable IDs, and production manifests.

Tooling changes:

- Added v0.200 launch, review, capture, validate, and benchmark Windows wrappers.
- Added `tools/godot/saltoShellV2GroundingLightingTool.mjs` for validation, manual-review pack export, benchmark, boundary scan, cleanup dry-run/safe-only, and retention evidence.
- Added npm scripts for `godot:launch/review/capture/validate/benchmark:salto-shell-v2-grounding-lighting`.

Docs added:

- `docs/V0200_ENVIRONMENT_GROUNDING_QA_BENCHMARK.md`
- `docs/V0200_GROUNDING_BOUNDARY_ROLLBACK.md`
- `docs/V0200_IMPLEMENTATION_REPORT.md`

## Validation

Final v0.200 gates:

- `node --check tools/godot/saltoShellV2GroundingLightingTool.mjs`
- `npm run godot:validate:salto-shell-v2-grounding-lighting`
- `npm run godot:capture:salto-shell-v2-grounding-lighting`
- `npm run godot:benchmark:salto-shell-v2-grounding-lighting`

Latest gate results:

- `PASS_V0200_GROUNDING_LIGHTING_VALIDATION`
- `PASS_V0200_GROUNDING_LIGHTING_BENCHMARK`
- `PASS_V0200_GROUNDING_LIGHTING_BOUNDARY_SCAN`
- `PASS_V0200_GROUNDING_LIGHTING_CAPTURE_PACKET`
- `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`
- `PASS_V0200_GROUNDING_LIGHTING_VALIDATION_READY`

Benchmark result: v0.200 G1 average FPS `75.01` versus v0.199 S1 average FPS `75.11`; G1 p95 `13.36` ms versus S1 p95 `13.21` ms. FPS ratio is `0.9987`; p95 worsening ratio is `0.0114`.

## Human Review

Manual-review screenshots are available under:

- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0200-grounding-lighting`

Recommended review screenshots:

- `01_overview.png`
- `02_ground_roads.png`
- `03_river_bridge.png`
- `08_contact_sheet.png`

Review note: v0.200 makes the scene less empty with sparse grounding details and improved value balance, but intentionally does not redesign character art, selection rings, yellow site markers, terrain material slots, route logic, water behavior, UI, minimap, combat logic, or objective flow. Any larger art-direction change remains future-scope and must be explicitly authorized.

## Stop Condition

The checkpoint stops here for human review unless the queued prompt sequence is still explicitly active and v0.200 has been committed, pushed, clean, synced, and remote-green.
