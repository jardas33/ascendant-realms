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

The v0.399 primary view showed a dark front roof plane and a second light rear/right plane, so the house read as two overlapping roof masses. The opt-in v0.400 layer fail-closes all inherited slate roof render meshes and the imported `Collision_RoofVolume` visual, then adds two authored slate planes sharing one ridge beam and two consistent timber eaves. A matching visual-closure surface is applied to each authored roof plane so the inherited granite gable region cannot pierce the replacement roof. The inherited house mesh remains the authority for walls, openings, foundation, chimney, and footprint; no gameplay collision or transform is changed.

## Evidence and preservation

The runtime pack contains real Godot renders in colour and grayscale, a v0.399/v0.400 comparison, and a machine-readable manifest. The close view is framed on the house roof and chimney; the overview verifies the barn, bridge, river, route, characters, and props remain present. Independent ChatGPT visual review returned `ACCEPT` after the one allowed revision: the granite intrusion is gone and the house reads as one coherent roof in colour and grayscale.

Preserved: v0.399 barn structural readability; v0.398 route-edge cleanup; accepted route and bridge; camera and layout; characters and props; no movement, pathfinding, route following, combat, damage, AI, economy, resource, save, stable-ID, or default-runtime mutation. The true default runtime remains unchanged. The chimney remains visible above the single clear ridge in both colour and grayscale captures.

## Review pack

`artifacts/manual-review/v0400-main-house-roof-silhouette-cleanup/`

Status: ACCEPTED by independent ChatGPT visual review after one narrow revision. The true default runtime remains unchanged.
