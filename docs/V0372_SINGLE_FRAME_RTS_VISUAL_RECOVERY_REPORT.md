# v0.372 - Single-Frame RTS Visual Recovery and Human Composition Gate

## Status

READY FOR HUMAN V0372 RTS VISUAL COMPOSITION REVIEW

This checkpoint is a human visual gate, not an acceptance claim. It creates one
isolated world-only composition so the settlement, resource site, river,
bridge, roads, and hostile camp can be judged as one compact RTS battlefield.

## Scope and preservation

Base HEAD: `0ee91d8046ead34ade746a838808fe13be4abc3b`
Branch: `codex/v0215-v0226-recovery`

The new scene is
`desktop-spikes/godot-salto/scenes/v0372_quaternius_rts_visual_recovery.tscn`.
It is reached only through the explicit v0.372 route flags and contains no
gameplay loop, HUD, labels, selection state, navigation, combat, economy,
construction, persistence, or production integration. The true default runtime,
v0.370 proof scene, and v0.371 playable scene remain unchanged.

## Composition treatment

The fixed orthographic three-quarter camera frames the player settlement on the
left, the bridge at the visual centre, the resource route beside the settlement,
and the hostile camp on the opposite lower-right bank. The river is one
continuous recessed variable-width surface with irregular banks; roads are three
softened authored ribbons with stone transitions; the bridge is one simple timber
deck with consistent railings, stairs, and bank-contact stones.

The settlement uses the accepted Quaternius house family, a deliberately small
future Barracks clearing, cart/supply dressing, and two human scale figures. The
resource site uses rocks, worked ground, tools, crate, wagon, and a connecting
path. The hostile camp uses darker worn ground, a rough enclosure, wagon,
supplies, focal tool prop, and two Adventurer figures. Lighting is muted at scene
level: warm readable daylight, cool fill, softened terrain values, and consistent
contact shadows.

## Human review evidence

Review pack:
`artifacts/manual-review/v0372-quaternius-rts-visual-recovery/`

It contains exactly six files: README, four real 1920x1080 rendered PNGs, and a
compact validation JSON. The primary frame has no HUD, F3 text, objective,
status panel, action button, selection ring, labels, or evidence annotations.

Launch: `npm run godot:play:quaternius-visual-recovery`
Capture: `npm run godot:capture:quaternius-visual-recovery`
Validator: `npm run godot:validate:quaternius-visual-recovery`

## Validation and limitations

Focused v0.372 validation checks the isolated route, retained v0.370/v0.371
files, Quaternius asset resolution, 1920x1080 nontrivial captures, no HUD route,
exact six-file pack, no primitive unit fallback, and smoke status. Repository
checks include tests, build, content/art/runtime validation, Godot matrix, and
`git diff --check`.

Remaining limitation: this is a static composition gate only. The brighter
Quaternius palette remains a source-family baseline, not final Barrosan
weathering, and the human reviewer must approve the primary frame before any
further gameplay or production integration is considered.
