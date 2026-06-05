# v0.131 Emmanuel Retest Guide

Status: `READY_FOR_RETEST_AFTER_CLOSEOUT`

Use the player-facing packaged Godot slice. Do not use the private harness for this retest.

## One-Click Paths

- Launch the review slice: `GODOT_LAUNCH_PLAYABILITY_REVIEW_WINDOWS.bat`
- Run the automated packaged real-input smoke: `GODOT_REAL_INPUT_SMOKE_WINDOWS.bat`
- NPM equivalent: `npm run godot:headed:real-input-smoke`

## Manual Retest Steps

1. Launch the player-facing slice.
2. Click `Start Salto Review`.
3. Click `Start Battle`.
4. Locate Aster using the pulse, label, minimap hero marker, and camera focus.
5. Hover Aster and confirm visible feedback.
6. Left-click Aster and confirm the selection ring and HUD card.
7. Right-click near the quarry and confirm a move marker.
8. Watch Aster visibly move.
9. Confirm the objective advances only after movement.
10. Hover and select the Worker.
11. Drag a box around a friendly squad and confirm squad selection feedback.

## Expected Result

The first objective should be playable with ordinary mouse input. If Aster cannot be found, selected, moved, or used to advance the objective, classify the retest as blocked and do not continue to later milestones.

