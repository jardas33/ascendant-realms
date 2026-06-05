# v0.132 Mine Conversion Guidance Spec

Status: `PLAYER_FACING_REPAIR_IMPLEMENTED`

## Required Interaction

1. Select Aster.
2. Right-click the highlighted `West Stone Cut Mine`.
3. Watch Aster enter the visible capture ring.
4. Observe the conversion bar fill.
5. Observe the mine switch to controlled state.

## Visual Requirements

- Battlefield label: `West Stone Cut Mine`.
- Objective ring around the mine.
- Capture-radius ring while uncontrolled.
- Conversion progress bar above the target.
- Controlled banner after conversion.
- HUD status copy showing conversion percentage while converting.

## Proof

The automated and manual proof cannot use private harness calls, state injection, objective skipping, screenshot-only assertions, save writes, or editor work. The accepted proof is the packaged player slice responding to normal mouse input.
