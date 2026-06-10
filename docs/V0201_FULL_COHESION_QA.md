# v0.201 Mesh-Compositor Full Cohesion QA

Status: `PASS_V0201_FULL_COHESION_QA`

v0.201 performs a freeze-gate review of the existing shell-v2 mesh-compositor player-facing review posture. It generates zero images, adds zero art slots, changes no runtime code, and keeps the default launcher procedural.

## Manual Review PNG Pack

Compact manual-review pack:

`D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0201-final-cohesion\`

Required files:

- `01_legacy_vs_final.png`
- `02_final_overview.png`
- `03_ground_roads.png`
- `04_river_bridge.png`
- `05_structures.png`
- `06_units_combat.png`
- `07_minimap_pan_zoom.png`
- `08_contact_sheet.png`

Visual finding: the final shell-v2 mesh-compositor path is materially stronger than the legacy pad-and-line shell. Roads follow coherent routes, the river reads as a continuous channel, the bridge reads as a crossing, structures read as authored masses, and the five selected opt-in character slots remain readable at review framing. The presentation is still procedural and marker-forward, but no v0.201-authorized blocker was found.

## Windows-Side QA Gates

Passed:

- `npm run godot:validate:salto-shell-v2-grounding-lighting`
- `npm run godot:validate:salto-ground-road-material-opt-in`
- `npm run godot:validate:salto-five-slot-art-experiment`
- `npm run godot:headed:post-mine-flow-smoke`
- `npm run godot:headed:triple-natural-playthrough`

Fallback reproducers passed for Worker, Barracks material, ground material, road material, bridge-riverbank material, Aster, Militia, and Ashen Raider opt-in paths.

## Performance Gate

Comparator: v0.195 post-pass scoped-material shell versus retained v0.200 final grounding-lighting performance smoke.

| Metric | v0.195 post-pass | Final retained v0.200 smoke | Gate |
| --- | ---: | ---: | --- |
| Average FPS | 75.30 | 75.00 | PASS, ratio `0.9960` >= `0.80` |
| p95 frame time | 13.01 ms | 13.37 ms | PASS, worsening `2.77%` <= `25%` |

The standalone v0.200 benchmark folder was not present in the ignored local artifacts during v0.201 closeout, so this packet uses the retained v0.200 validation performance-smoke artifact that is still present on disk.

## Boundary Check

Confirmed:

- Zero new images.
- Zero new art slots.
- Default launcher remains procedural.
- Prior launchers remain preserved.
- Browser runtime remains untouched.
- Gameplay, pathing, collisions, objectives, AI, saves, and stable IDs remain unchanged.
- Character-slot integrations remain frozen.

