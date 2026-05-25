# v0.21.3 Cursor Affordance Future UI Note

Date: 2026-05-24
Status: future UI/VFX note, no runtime art added

## Context

Emmanuel's v0.21.3 Worker attack retest kept the cursor affordance request open:

- crossed swords for attack
- hammer for repair, build, and finish construction

## Current v0.21.3 Decision

Do not add new runtime art assets in this pass. v0.21.3 focuses on making explicit Worker attack damage provable and making Burn/status markers read clearly without adding cursor art.

The current cursor behavior remains based on existing browser/CSS behavior. A later UI polish pass should make attack and Worker-work intent more obvious before the player clicks.

## Future Implementation Notes

- Attack: use a crossed-swords cursor/icon when the hovered target is a valid enemy attack target for the current selection.
- Repair/build/construction: use a hammer cursor/icon when a selected Worker can repair a damaged friendly completed building, place a building, or continue construction on an incomplete friendly site.
- Disabled states should stay explicit:
  - enemy buildings are not repair targets
  - full-health completed buildings do not need repair
  - incomplete buildings are construction targets, not repair targets
  - Workers can only attack buildings through explicit attack intent, not idle proximity
- Prefer CSS/native cursor or already-approved UI icon assets first.
- Any new bitmap/vector art should go through the existing asset-intake/review process before runtime use.
