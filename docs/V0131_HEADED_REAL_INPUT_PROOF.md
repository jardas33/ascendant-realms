# v0.131 Headed Real Input Proof

Status: `PASS_HEADED_REAL_INPUT_SMOKE`

Latest local packaged proof generated:

- `artifacts/desktop-spikes/godot-salto/v0131/headed-playability-smoke.json`
- `artifacts/desktop-spikes/godot-salto/v0131/real-input-trace.json`
- `artifacts/desktop-spikes/godot-salto/v0131/real-input-trace.md`
- `artifacts/desktop-spikes/godot-salto/v0131/selection-proof.json`
- `artifacts/desktop-spikes/godot-salto/v0131/movement-proof.json`
- `artifacts/desktop-spikes/godot-salto/v0131/screenshot-manifest.json`
- `artifacts/desktop-spikes/godot-salto/v0131/screenshots/`

## Proven Real-Input Path

The headed smoke uses normal packaged-build mouse events:

1. Launch player slice.
2. Click `Start Salto Review`.
3. Click `Start Battle`.
4. Hover Aster.
5. Click Aster.
6. Confirm HUD card update.
7. Right-click near the quarry.
8. Confirm move marker.
9. Confirm Aster movement displacement.
10. Confirm objective advancement after movement.
11. Hover and select Worker.
12. Drag box-select across friendly soldiers.

## Required Screenshots

The v0.131 manifest records 12 captures:

1. Battle initial camera focus.
2. Aster pulsing.
3. Cursor hover Aster.
4. Aster selected.
5. HUD card updated.
6. Move destination pulse.
7. Move marker.
8. Aster displaced.
9. Objective advanced.
10. Worker hover.
11. Worker selected.
12. Squad box selected.

## Negative Proof

- `privateHarnessShortcutUsed`: false.
- `debugShortcutUsed`: false.
- `stateInjectionUsed`: false.
- `saveWritesAllowed`: false.
- `stableIdsChanged`: false.
- `browserRuntimeChanged`: false.
- `linkedWardDamageTakenMultiplier`: 0.92.

## Manual Packaged-Window Confirmation

After the repair, a Computer Use pass was performed inside the packaged `AscendantRealmsGodotSalto.exe` player-slice window only. The manual pass launched the player-facing path, clicked through title and briefing, selected visible Aster, right-clicked near the quarry, observed the visible move marker, observed Aster move and the objective advance after movement, selected the Worker normally, and then box-selected the squad with visible selection rings and HUD feedback.
