# v0.397 Terrain and Route Integration

## Verdict target

This is the narrow follow-up to the independently accepted v0.396 route. It keeps the v0.396 route, camera, settlement composition, bridge, buildings, characters, props, and gameplay intact while testing a softer ground relationship.

## Scope

The opt-in Salto visual spike adds only two presentation treatments: a low-opacity grass/compacted-earth bedding ribbon beneath the accepted route and small irregular contact-grounding patches beneath the house, barn, yard functions, and bridge landings. The route remains the same v0.396 mesh and elevation; no objects are moved and no gameplay systems are touched.

## Implementation

- Scene: `desktop-spikes/godot-salto/scenes/v0397_terrain_route_integration.tscn`
- Script: `desktop-spikes/godot-salto/scripts/v0397_terrain_route_integration.gd`
- Capture: `npm run godot:capture:v0397-terrain-route`
- Smoke: `npm run godot:smoke:v0397-terrain-route`
- Validator: `npm run godot:validate:v0397-terrain-route`
- Review pack: `artifacts/manual-review/v0397-terrain-route-integration/`

## Visual treatment

The accepted warm-earth route remains traceable in colour and grayscale. A broader, very low-opacity warm grass bedding layer reduces the hard painted-ribbon edge without changing route topology. Irregular, low-opacity grounding patches provide restrained contact around the main house, barn, cart, workbench, and bridge landings. They are visual-only and are not gameplay zones.

The camera, lighting, bridge, terrain, building geometry, unit positions, props, and scale remain v0.396. No fence or new settlement object is introduced.

## Preservation and validation

The v0.396 material-unification pass remains the parent implementation. The true default runtime remains untouched; this checkpoint is selected only by the explicit v0.397 capture/smoke flags. No movement, pathfinding, combat, economy, resource, or state mutation is present. The primary, close, grayscale, diagnostic, and v0.396/v0.397 comparison images are real Godot captures; blank/title-only frames are rejected by the validator.

Independent visual review is required before treating this experiment as accepted. If the bedding or contact patches read as flat decals or obscure the route, the narrow next action is to reduce their alpha or remove only the offending overlay; do not change geometry or layout.
