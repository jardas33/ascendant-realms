# v0.205 Grounding Lighting Props Report

Status: `PASS_V0205_GROUNDING_LIGHTING_PROPS_REPORT`

v0.205 adds restrained sparse environmental props, lighting/value tuning, and contact-grounding polish only to the isolated Salto shell-v2 review path. The default procedural launcher, prior launchers, browser runtime, gameplay systems, route topology, structure locations, character slots, and production art slots remain unchanged.

## Visual Result

The shell-v2 review scene reads less empty and less diagrammatic while preserving tactical clarity. Roads, terrain, river, bridge, structures, friendly units, hostile units, rings, markers, minimap correlation, pan, and zoom remain readable at the normal RTS review distance.

The pass adds deterministic low-cost visual details:

- 6 roadside stones
- 5 timber posts
- 6 restrained bank rocks
- 6 tiny scrub clumps
- 9 bridge and landing grounding details
- 6 structure contact details
- 5 representative unit contact details

Manual review PNG pack:

`D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0205-grounding-lighting-props\`

Required files:

- `01_before_after_overview.png`
- `02_final_overview.png`
- `03_ground_roads_props.png`
- `04_river_bridge_grounding.png`
- `05_structures_grounding.png`
- `06_units_grounding.png`
- `07_ashen_combat_readability.png`
- `08_minimap_pan_zoom.png`

## Evidence

- Validation report: `D:\Code for projects\WB game like\ascendant-realms\artifacts\desktop-spikes\godot-salto\v0205\validation\grounding-lighting-props-validation-report.json`
- Capture report: `D:\Code for projects\WB game like\ascendant-realms\artifacts\desktop-spikes\godot-salto\v0205\capture\grounding-lighting-props-capture-report.json`
- Benchmark report: `D:\Code for projects\WB game like\ascendant-realms\artifacts\desktop-spikes\godot-salto\v0205\benchmark\grounding-lighting-props-benchmark-report.json`
- Boundary scan: `D:\Code for projects\WB game like\ascendant-realms\artifacts\desktop-spikes\godot-salto\v0205\boundary\grounding-lighting-props-boundary-scan.json`
- Cleanup dry run: `D:\Code for projects\WB game like\ascendant-realms\artifacts\desktop-spikes\godot-salto\v0205\cleanup-dry-run\salto-experimental-cleanup-report.json`
- Artifact retention report: `D:\Code for projects\WB game like\ascendant-realms\artifacts\desktop-spikes\godot-salto\v0205\artifact-retention\salto-experimental-artifact-retention-report.json`

## Benchmark

- Baseline v0.204 shell-v2 structure-material path: 75.54 average FPS, 14.47 ms p95 frame time.
- v0.205 grounding props path: 75.61 average FPS, 9.63 ms p95 frame time.
- FPS ratio: 1.0009 against a 0.90 minimum threshold.
- p95 worsening ratio: -0.3345 against a 0.15 maximum threshold.

## Boundary Result

- Zero generated images.
- Zero downloaded assets.
- Zero new art slots.
- No browser runtime wiring.
- No default launcher change.
- No gameplay, pathing, collision, objective, AI, economy, save, stable-ID, or balance changes.
- No route topology or structure location changes.
- No production runtime-art slot leakage.
