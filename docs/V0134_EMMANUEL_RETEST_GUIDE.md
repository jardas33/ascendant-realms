# v0.134 Emmanuel Retest Guide

One-click automated proof:

1. Run `GODOT_TRIPLE_NATURAL_PLAYTHROUGH_WINDOWS.bat`.
2. Wait for the Godot slice to finish the three packaged playthrough profiles.
3. Confirm `artifacts/desktop-spikes/godot-salto/v0134/triple-natural-playthrough-validation.json` reports `PASS_V0134_TRIPLE_NATURAL_PLAYTHROUGH_VALIDATION`.

Manual spot check:

1. Run `GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat`.
2. Click Start Salto Review.
3. Click Start Battle.
4. Complete the slice normally.
5. At Results, try Restart Slice once and verify the battle resets cleanly.
6. Complete again, click Return to Title, then start again and verify Aster/mine/Worker/Barracks/wave/Lume state starts fresh.

Expected behavior:

- Invalid early clicks give concise feedback and do not advance objectives.
- Conversion can recover after moving Aster away and back.
- A missed Worker click does not block assignment.
- Combat can recover from empty box-select and no-selection Attack.
- Results is reachable repeatedly without soft-locking.

Do not use the Godot editor, private harness, debug shortcuts, or manual state mutation for this retest.
