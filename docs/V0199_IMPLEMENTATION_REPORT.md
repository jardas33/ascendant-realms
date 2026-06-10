# v0.199 Implementation Report

Status: `PASS_V0199_IMPLEMENTATION_REPORT`

Date: 2026-06-10

## Summary

v0.199 hardens the isolated Salto shell-v2 mesh-compositor structure hierarchy with procedural-only visual massing. It preserves the v0.198 wet-granite bridge and bank context, improves the command hall, mine, Barracks restoration, restored Barracks, and compact site structures, exports the required manual-review PNG pack, benchmarks green against the wet-granite mesh comparator, and preserves all default, gameplay, browser, character-slot, legacy-shell, and prior-launcher boundaries.

## Implementation

Runtime changes:

- Added an explicit `--salto-shell-v2-structure-hierarchy` flag and status reporting.
- Added opt-in-only procedural structure-hierarchy visual node tracking.
- Added procedural structure boxes for wet-granite-colored foundations, timber frames, restrained metal braces, practical scaffolding, roof planes, warm functional accents, mine retaining cues, and compact site-marker props.
- Kept the default procedural launcher, legacy shell, v0.196 mesh-compositor baseline, v0.197 mesh QA path, and v0.198 wet-granite mesh path available as comparators/fallbacks.
- Preserved five frozen character slots, selected ground material, selected road material, selected wet-granite bridge-riverbank material, default procedural launcher, prior launchers, browser runtime, gameplay, pathing, collisions, objectives, AI, saves, stable IDs, and production manifests.

Tooling changes:

- Added v0.199 launch, review, capture, validate, and benchmark Windows wrappers.
- Added `tools/godot/saltoShellV2StructureHierarchyTool.mjs` for validation, manual-review pack export, benchmark, boundary scan, cleanup dry-run/safe-only, and retention evidence.
- Added npm scripts for `godot:launch/review/capture/validate/benchmark:salto-shell-v2-structure-hierarchy`.

Docs added:

- `docs/V0199_STRUCTURE_HIERARCHY_QA_BENCHMARK.md`
- `docs/V0199_STRUCTURE_BOUNDARY_ROLLBACK.md`
- `docs/V0199_IMPLEMENTATION_REPORT.md`

## Validation

Final v0.199 gates:

- `node --check tools/godot/saltoShellV2StructureHierarchyTool.mjs`
- `npm run godot:validate:salto-shell-v2-structure-hierarchy`
- `npm run godot:capture:salto-shell-v2-structure-hierarchy`
- `npm run godot:benchmark:salto-shell-v2-structure-hierarchy`

Latest gate results:

- `PASS_V0199_STRUCTURE_HIERARCHY_VALIDATION`
- `PASS_V0199_STRUCTURE_HIERARCHY_BENCHMARK`
- `PASS_V0199_STRUCTURE_HIERARCHY_BOUNDARY_SCAN`
- `PASS_V0199_STRUCTURE_HIERARCHY_CAPTURE_PACKET`
- `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`
- `PASS_V0199_STRUCTURE_HIERARCHY_VALIDATION_READY`

Benchmark result: v0.199 S1 average FPS `75.24` versus v0.198 W1 average FPS `75.22`; S1 p95 `13.25` ms versus W1 p95 `13.18` ms. FPS ratio is `1.0003`; p95 worsening ratio is `0.0053`.

## Human Review

Manual-review screenshots are available under:

- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0199-structure-hierarchy`

Recommended review screenshots:

- `01_overview.png`
- `02_command_hall.png`
- `04_barracks_restoring.png`
- `08_contact_sheet.png`

Review note: v0.199 improves procedural structure readability but intentionally does not redesign selection rings, yellow site markers, terrain material slots, route logic, water, UI, minimap, combat logic, or objective flow. The mine now has more structure cues but remains comparatively restrained; that is acceptable for this scoped pass and can be revisited only under a future prompt that explicitly authorizes structure finishing.

## Stop Condition

The checkpoint stops here for human review unless the queued prompt sequence is still explicitly active and v0.199 has been committed, pushed, clean, synced, and remote-green.
