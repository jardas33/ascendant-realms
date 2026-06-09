# v0.175 Implementation Report

Status: `PASS_V0175_GROUND_MATERIAL_SELECTION_GATE`

v0.175 executed the Barrosan foothold terrain-material single-slot private comparator intake and stopped before v0.176. It generated exactly one original source image, produced deterministic derivatives, selected one private-comparator candidate, and left the normal Salto player slice untouched.

## Implementation

Added:

- Private Godot comparator dispatch: `--barrosan-ground-material-single-slot`.
- Private comparator scene script: `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/ground_material_single_slot_comparator.gd`.
- Deterministic fallback, derivative, validation, audit, benchmark, and capture tooling.
- Tracked diagnostic fallback plus contract for the ground-material comparator.
- Focused desktop-spike regression coverage for v0.175 boundary and documentation strings.
- Cleanup/retention classifier protection for the new v0.175 comparator/fallback files.

Generated exactly one image:

- `barrosan_foothold_ground_material_v0175_source.png`
- SHA-256: `0a05fa455af72c20f18a9f412949d3b2b3cd1d7bcf61cea9bc297b1a131c0c7e`

Selected candidate:

Selected derivative: `GROUND_MATERIAL_LOCAL_1024`

- `GROUND_MATERIAL_LOCAL_1024`
- SHA-256: `818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8`

Rejected comparison:

Rejected comparison: `GROUND_MATERIAL_1024_WRAPSAFE_OFFSET_BLEND`

- `GROUND_MATERIAL_1024_WRAPSAFE_OFFSET_BLEND`
- SHA-256: `8ecd8e4e9f8e71b8a1f626b04d8d022dc2f9669a580796bcc24c5778345444a9`

## Verification

Completed gates:

- `node --check tools/godot/groundMaterialSingleSlotTool.mjs`
- `npm run godot:ground-material:fallback:reproduce`
- `npm run godot:ground-material:derivatives:reproduce`
- `npm run godot:ground-material:validate`
- `npm run godot:ground-material:benchmark:headed`
- `npm run godot:ground-material:capture`
- `npm run godot:ground-material:audit`
- `npm run godot:cleanup:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0175/cleanup-dry-run`

Final selection gate:

- Status: `PASS_V0175_GROUND_MATERIAL_SELECTION_GATE`.
- Seam mean opposing-edge delta: `11.29`.
- Tier L FPS ratio versus fallback: `1.015`.
- Tier L p95 worsening: `-1.32%`.
- Screenshot count: `26`.
- Benchmark count: `35`.

## Boundary Confirmation

No player-slice integration

No browser runtime wiring

No further character slots

Default launcher remains procedural, all prior opt-in launchers remain preserved, and v0.176 was not started inside this checkpoint.
