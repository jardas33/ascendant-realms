# v0.135 RTS Input Contract

Status: `PASS_V0135_RTS_INPUT_CONTRACT` after `npm run godot:headed:rts-ergonomics-smoke`.

This checkpoint makes the player-facing Godot Salto slice follow conventional RTS input without broadening gameplay.

## Supported Inputs

- Left-click a friendly unit to select it.
- Left-click empty terrain to deselect.
- Drag a box around friendly defenders to select the squad.
- Right-click terrain to move selected units.
- Right-click an Ashen enemy to attack.
- Right-click a valid objective target for the current selected unit to perform the context action.
- Mouse wheel changes camera zoom inside safe bounds.
- WASD and arrow keys pan the camera inside safe bounds.
- Space focuses Aster.
- Escape closes the compact help overlay, clears selection when appropriate, or toggles pause posture.
- F1 and the Help button open the compact controls overlay.

## Proof Boundary

The contract is proven only through the packaged player-facing Godot slice. Private harness actions, debug shortcuts, state injection, fixture-only helpers, scripted objective skipping, and screenshot-only evidence do not count.

No save fields, stable IDs, browser runtime code, generated/imported art, runtime art integration, broad systems, final engine choice, or full port work changed. `linked_ward` remains exactly `0.92`.
