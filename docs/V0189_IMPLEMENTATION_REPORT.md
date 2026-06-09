# v0.189 Implementation Report

Status: `PASS_V0189_BRIDGE_RIVERBANK_MATERIAL_SELECTION_GATE`

v0.189 executed the Barrosan wet-granite bridge-riverbank material single-source private comparator intake and stopped before v0.190. It generated exactly one original source image, created deterministic derivatives and a tracked diagnostic fallback, selected one candidate, validated and benchmarked the private comparator, and left the normal Salto player slice untouched.

## Implementation

Added:

- Private Godot comparator dispatch: `--barrosan-bridge-riverbank-material-single-slot`.
- Private comparator scene: `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/bridge_riverbank_material_single_slot_comparator.gd`.
- Deterministic fallback, derivative, validation, audit, benchmark, and capture tooling.
- Tracked diagnostic fallback plus contract for clean-checkout comparator reproducibility.
- NPM scripts for the v0.189 private comparator gates.
- Retention-index protection for the selected bridge-riverbank source derivative, metadata, fallback, and evidence.

Generated exactly one project-local source image:

- `barrosan_wet_granite_bridge_riverbank_material_v0189_source.png`
- SHA-256: `342d058f4749e115569a82bf971bb409ccd63825f93b7428d346150ebd9d003a`

Selected candidate:

- `BRIDGE_RIVERBANK_MATERIAL_LOCAL_1024`
- SHA-256: `638ce153d7a3d39db729dfa13ba05f3fb05c437c2802ab91b5cd248bd2036753`

Diagnostic fallback:

- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_wet_granite_bridge_riverbank_material_v0189_fallback.png`
- SHA-256: `0a2e9bb0b94f544b183f49cf7a5f2a213768a5bca9a2c76192db9bb982b36ef2`

## Verification

Completed gates:

- `node --check tools/godot/bridgeRiverbankMaterialSingleSlotTool.mjs`
- `npm run godot:bridge-riverbank-material:fallback:reproduce`
- `npm run godot:bridge-riverbank-material:derivatives:reproduce`
- `npm run godot:bridge-riverbank-material:validate`
- `npm run godot:bridge-riverbank-material:benchmark:headed`
- `npm run godot:cleanup:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0189/cleanup-dry-run`
- `npm run godot:validate:salto-experimental-artifact-retention`

Final selection gate:

- Status: `PASS_V0189_BRIDGE_RIVERBANK_MATERIAL_SELECTION_GATE`
- Seam mean opposing-edge delta: `11.94`
- Tier L FPS ratio versus fallback: `1.0726`
- Tier L p95 worsening: `-1.57%`
- Screenshot count: `26`
- Benchmark count: `35`

## Boundary Confirmation

No player-slice integration.

No browser runtime wiring.

No character-slot expansion.

No new normal-slice environment-material slot.

Default launcher remains procedural, all prior opt-in launchers remain preserved, and v0.190 was not started inside this checkpoint.
