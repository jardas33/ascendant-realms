# v0.400 Main-House Roof Silhouette Cleanup

## Scope

Opt-in visual-only repair on the accepted v0.399 settlement slice. The correction targets only the primary homestead roof silhouette: one clear ridge, a single ridge roof mass with consistent eaves, and a readable chimney. Barn, route, bridge, camera, characters, props, layout, state, and gameplay remain inherited.

## Base and implementation

- Base checkpoint: v0.399 accepted (`2b180a07366657e77d4ebe17313a79ffa03eaab8`)
- Branch: `codex/v0215-v0226-recovery`
- Scene: `desktop-spikes/godot-salto/scenes/v0400_main_house_roof_silhouette_cleanup.tscn`
- Capture command: `npm run godot:capture:v0400-house-roof`
- Validator: `npm run godot:validate:v0400-house-roof`

## Defect and repair

The v0.399 primary view showed a dark front roof plane and a second light rear/right plane, so the house read as two overlapping roof masses. The opt-in v0.400 layer fail-closes all inherited slate roof render meshes and the imported `Collision_RoofVolume` visual, then adds two authored slate planes sharing one ridge beam and two consistent timber eaves. The inherited house mesh remains the authority for walls, openings, foundation, chimney, and footprint; the collision mesh is hidden only because it was incorrectly render-visible in the opt-in art slice.

## Evidence and preservation

The runtime pack contains real Godot renders in colour and grayscale, a v0.399/v0.400 comparison, and a machine-readable manifest. The close view is framed on the house roof and chimney; the overview verifies the barn, bridge, river, route, characters, and props remain present. Independent visual review is required for ACCEPT.

Preserved: v0.399 barn structural readability; v0.398 route-edge cleanup; accepted route and bridge; camera and layout; characters and props; no movement, pathfinding, route following, combat, damage, AI, economy, resource, save, stable-ID, or default-runtime mutation. The true default runtime remains unchanged. The chimney remains visible above the single clear ridge in both colour and grayscale captures.

## Review pack

`artifacts/manual-review/v0400-main-house-roof-silhouette-cleanup/`

Status is intentionally READY until the linked independent ChatGPT visual review returns ACCEPT, REVISE ONCE, or REJECT.
