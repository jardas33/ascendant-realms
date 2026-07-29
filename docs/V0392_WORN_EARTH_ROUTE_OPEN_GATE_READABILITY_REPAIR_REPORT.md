# v0.392 Worn-Earth Route and Open-Gate Readability Repair

## Scope and ancestry

This is a bounded, opt-in visual repair following the independent v0.391 `REJECT`. It targets only visible worn-earth route contrast, the open-gate boundary, local settlement contrast, and preserved building/character readability.

- Base commit: `ac4925c5` (v0.391 rejection record)
- Branch: `codex/v0215-v0226-recovery`
- v0.391 remains retained as the rejected reference.
- Accepted v0.380 GLB hash remains `746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb`.

## v0.392 repairs

- Added one flush, irregular, visibly contrasting worn-earth surface from the western bridge landing through the yard to the doorway.
- Added one smaller flush branch from the route toward the barn entrance.
- Replaced disconnected fence placement with a coherent fence-line arrangement and a named open gate gap aligned to the yard.
- Reduced the remaining bridge/landing value and lowered the broad homestead fill so local doorway, yard, and gate contrast can read.
- Preserved the house, barn, five functions, three characters, accepted infrastructure, and opt-in-only runtime path.

## Prior v0.391 independent rendered verdict

The linked ChatGPT visual review inspected seven real 1920x1080 Godot frames and returned `REJECT`. The workstation slab was gone, the barn had clear ground separation, and all three characters were unobstructed. The gate failed because the route was visually absent on the pale ground, the fence pieces did not form a coherent open gate, and bridge/landing value still competed with the settlement.

The narrow v0.392 repair is deliberately limited to an unmistakable flush route, coherent open-gate boundary, and local value correction. No new assets, buildings, characters, gameplay, HUD, animation, or default-runtime changes are authorized.

## Preservation

No gameplay, movement, navigation, pathfinding, combat, AI, economy, production, stable-ID, save, state-chain, pressure, resource, accepted geometry, or true-default runtime behavior was changed. v0.391 remains available as a rejected reference and the accepted v0.380-v0.391 lineage is retained.

## Evidence and validation

- Scene: `desktop-spikes/godot-salto/scenes/v0392_worn_earth_route_open_gate_readability_repair.tscn`
- Capture: `npm run godot:capture:v0392-worn-earth`
- Smoke: `npm run godot:smoke:v0392-worn-earth`
- Validator: `npm run godot:validate:v0392-worn-earth`
- Review pack: `artifacts/manual-review/v0392-worn-earth-route-open-gate-readability-repair/`
- Iteration records: `desktop-spikes/godot-salto/artifacts/work/v0392-iteration-01/` through `-03/`

## Independent v0.392 rendered verdict

`REJECT`.

The independent review inspected the seven real 1920x1080 Godot renders and found that the principal repair was not visible: no clearly contrasting worn-earth route could be followed from the western bridge landing to the house doorway, there was no readable yard widening or barn branch, and the fence still read as disconnected or intersecting rails rather than a coherent open gate aligned to the route. The house, barn, five yard functions, and three characters remained readable and unobstructed. The darker bridge was an improvement, but its scale still competed with the settlement.

## Next checkpoint

v0.393 — Explicit Route Silhouette and Front-Yard Gate Repair:

- replace the effectively invisible route with one flush irregular mesh or decal whose hue and grayscale value are visibly distinct at primary RTS distance;
- touch the western bridge landing, continue continuously through the yard, widen around the cart/workstation, terminate at the doorway, and branch to the barn entrance;
- remove hidden/protruding/disconnected rails and place two short coherent foreground fence runs separated by a wide open gateway with the route passing through it;
- preserve all buildings, characters, yard functions, bridge/river geometry, gameplay, and default runtime.

Acceptance requires the complete route and open gate to be identifiable immediately in both the primary RTS render and grayscale render without labels or validator prose.

The pack is now fail-closed as rejected. Structural validation remains separate from visual acceptance; black frames, title-card-only evidence, and validator-only claims are not acceptance evidence.
