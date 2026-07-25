# v0.380 Corrected Highland Infrastructure

READY FOR HUMAN V0380 CORRECTED HIGHLAND INFRASTRUCTURE REVIEW

This is a human visual-review pack, not a production-acceptance claim. The six PNGs are real 1920x1080 Godot renders from iteration 3 of the isolated, opt-in v0.380 route, using the supplied GLB without geometry or material replacement.

## Review order

1. `01_PRIMARY_RTS_VIEW.png` — primary orthographic-oblique RTS framing.
2. `02_ROAD_AND_TERRAIN_DETAIL.png` — road, relief, and river-edge relationship.
3. `03_CONTINUOUS_RIVER_CROSSING.png` — continuous water through the bridge crossing.
4. `04_BRIDGE_AND_LANDINGS.png` — bridge deck, rails, beams, supports, and landings.
5. `05_ELEVATED_TOPOLOGY_AUDIT.png` — elevated spacing and topology read.
6. `06_GRAYSCALE_PRIMARY.png` — value and shadow audit.

## Scope

This checkpoint imports and presents the corrected authored highland infrastructure source only: continuous terrain, embedded road, recessed river/wet banks, timber bridge, granite landings, and sparse dressing. No buildings, units, HUD, gameplay, or production migration are included.

Prototype launch: `npm run godot:play:v0380-highland-infrastructure`

Focused capture: `npm run godot:capture:v0380-highland-infrastructure`

Focused validator: `npm run godot:validate:v0380-highland-infrastructure`

The accepted runtime and true default route remain unchanged. Human review must decide whether this corrected source is suitable for the next art-direction step.
