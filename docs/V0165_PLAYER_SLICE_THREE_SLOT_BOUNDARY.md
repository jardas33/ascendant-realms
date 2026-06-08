# v0.165 Player Slice Three-Slot Boundary

Status: `PASS_V0165_PLAYER_SLICE_THREE_SLOT_BOUNDARY`

## Boundary

v0.165 preserves:

- zero new images
- zero new art slots
- exactly three opt-in player-slice slots
- default stabilized launcher unchanged and procedural
- Worker-only launcher unchanged
- Worker + Barracks launcher unchanged
- Worker + Barracks + Militia launcher unchanged
- no Aster or Ashen normal-slice import
- no HUD or environment normal-slice import
- no browser wiring
- no package, manifest, or broad art-registry mutation
- no save, stable-ID, or gameplay mutation
- no final engine choice
- no full port
- no v0.166 work

## Launchers

Expected launcher hashes are checked by `tools/godot/saltoThreeSlotVisualHardeningTool.mjs boundary`:

- `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat`
- `GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat`
- `GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat`
- `GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat`

Evidence:

- `artifacts/desktop-spikes/godot-salto/v0165/boundary/v0165-player-slice-three-slot-boundary-scan.json`
