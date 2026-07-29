# v0.399 Barn Outbuilding Structural Readability

## Scope

This is the narrow visual checkpoint requested after independent acceptance of v0.398. It changes only the left subordinate outbuilding in the opt-in Salto crossing capture. The accepted route, bridge, camera, characters, props, settlement layout, and gameplay/default-runtime semantics remain unchanged.

## Implementation

- Scene: `desktop-spikes/godot-salto/scenes/v0399_barn_outbuilding_structural_readability.tscn`
- Script: `desktop-spikes/godot-salto/scripts/v0399_barn_outbuilding_structural_readability.gd`
- Capture: `npm run godot:capture:v0399-barn-structure`
- Smoke: `npm run godot:smoke:v0399-barn-structure`
- Validator: `npm run godot:validate:v0399-barn-structure`
- Review pack: `artifacts/manual-review/v0399-barn-outbuilding-structural-readability/`

## Visual change

The original approved barn instance remains retained at its accepted transform but its detached dark roof presentation is hidden in this opt-in visual correction. A repository-authored low-poly structural shell is added as its child at the same position and rotation: grounded base, weathered stone walls, front gable, eaves, ridge, slate roof planes, entrance door, timber framing, windows, and one integrated contact shadow. This keeps the outbuilding clearly secondary to the main house while making its architectural reading legible in colour and grayscale.

## Preservation

The v0.398 route and narrow edge bedding remain visible and unchanged. Bridge, river, camera, characters, props, layout, gameplay, state, resources, movement, pathfinding, combat, and true default runtime are untouched. The prototype is opt-in only and all evidence is real Godot rendering rather than title-card or validator-only proof.

## Evidence

The review pack contains a primary RTS view, barn close-up, grayscale primary, grayscale barn close-up, and a v0.398/v0.399 primary comparison. Independent visual review: ACCEPT. The linked ChatGPT review confirmed that the outbuilding reads as a complete secondary barn in colour and grayscale, with visible wall mass, roof thickness/eaves, an entrance-side face, and grounding contact shadow. The accepted route, bridge, camera, characters, props, and layout remain preserved.
