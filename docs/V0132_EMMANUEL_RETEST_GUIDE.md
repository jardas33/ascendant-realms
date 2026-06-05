# v0.132 Emmanuel Retest Guide

Status: `READY_FOR_RETEST_AFTER_CLOSEOUT`

Use the player-facing packaged Godot slice. Do not use the private harness for this retest.

## One-Click Paths

- Launch the review slice: `GODOT_LAUNCH_SITE_GUIDANCE_REVIEW_WINDOWS.bat`
- Run the automated packaged site-semantics smoke: `GODOT_SITE_SEMANTICS_SMOKE_WINDOWS.bat`
- NPM equivalent: `npm run godot:headed:site-semantics-smoke`

## Manual Retest Steps

1. Launch the player-facing slice.
2. Click `Start Salto Review`.
3. Click `Start Battle`.
4. Select Aster normally.
5. Locate the highlighted `West Stone Cut Mine`.
6. Right-click the mine.
7. Confirm Aster enters the capture ring.
8. Confirm the conversion bar fills.
9. Confirm the mine becomes controlled.
10. Confirm the objective does not regress.
11. Select the highlighted Worker.
12. Right-click the controlled `West Stone Cut Mine`.
13. Confirm Worker assignment and production-boost feedback.
14. Confirm the objective advances.

## Expected Result

The mine and Worker path should be understandable without guessing whether quarry and mine are the same object. If the mine cannot be identified, conversion progress cannot be observed, ownership is unclear, Worker assignment is unclear, or the objective regresses, classify the retest as blocked.
