# v0.398 Route Edge Bedding Cleanup

## Scope and reason

This is the narrow correction requested by the independent v0.397 visual review (`REVISE ONCE`). The v0.396 route and all surrounding scene geometry remain authoritative. The broad v0.397 contact halos are disabled, and the broad bedding is replaced by a tight, irregular, lower-opacity edge bedding that only hugs the accepted route and barn branch.

## Implementation

- Scene: `desktop-spikes/godot-salto/scenes/v0398_route_edge_bedding_cleanup.tscn`
- Script: `desktop-spikes/godot-salto/scripts/v0398_route_edge_bedding_cleanup.gd`
- Capture: `npm run godot:capture:v0398-route-edge`
- Smoke: `npm run godot:smoke:v0398-route-edge`
- Validator: `npm run godot:validate:v0398-route-edge`
- Review pack: `artifacts/manual-review/v0398-route-edge-bedding-cleanup/`

## Visual change

`V0397_Contact_Grounding` remains in the scene tree but is hidden by the v0.398 opt-in correction, preserving the prior experiment without presenting large translucent halos. The only new visible treatment is narrow low-opacity route-edge bedding beneath the v0.396 warm-earth route. The route remains fully traceable in colour and grayscale; no route vertices, widths, elevation, camera, bridge, terrain, buildings, characters, props, or layout are changed.

## Independent visual verdict

The attached real Godot evidence was independently reviewed and **ACCEPTED**. The route remains continuously traceable from the bridge landing through the yard to the house and barn branch in colour and grayscale. The broad v0.397 halos are gone; the remaining edge treatment is tight to the route and does not read as a debug decal.

## Preservation

This is opt-in only and keeps the true default runtime unchanged. It contains no gameplay, movement, pathfinding, combat, economy, resource, or state mutation. The five captures are real Godot renders, and the validator rejects missing, blank, or wrong-aspect evidence. The corrected treatment is accepted for this checkpoint; no further visual change is included here.
