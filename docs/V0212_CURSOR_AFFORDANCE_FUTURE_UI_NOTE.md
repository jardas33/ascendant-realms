# v0.21.2 Cursor Affordance Future UI Note

Date: 2026-05-24
Status: future UI note, no runtime art added

## Context

Emmanuel's v0.21.1 Worker repair retest confirmed the repair behavior is mostly passing, but the command cursor vocabulary needs clearer future affordances:

- crossed swords for attack
- hammer for repair, build, and construction

## Current v0.21.2 Decision

Do not add new runtime art assets in this pass. v0.21.2 keeps the implementation focused on explicit Worker repair/construction intent, Worker attack clarity, and the healthbar/status marker polish.

The current attack cursor remains based on existing browser/CSS behavior. A future UI pass should replace or augment that with a clear crossed-swords affordance when a selected unit can attack a hovered enemy target.

## Future Implementation Notes

- Attack: use a crossed-swords cursor/icon when the hovered target is a valid enemy attack target for the current selection.
- Repair/build/construction: use a hammer cursor/icon when a selected Worker can repair a damaged friendly completed building, place a building, or continue construction.
- Disabled states should stay explicit:
  - enemy buildings are not repair targets
  - full-health completed buildings do not need repair
  - incomplete buildings stay construction targets, not repair targets
- Prefer CSS/native cursor or already-approved UI icon assets first.
- Any new bitmap/vector art should go through the existing asset-intake/review process before runtime use.
