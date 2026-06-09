# v0.180 Private Comparator Boundary Rollback

Status: `PASS_V0180_ROAD_MATERIAL_BOUNDARY`

v0.180 is private-comparator-only. It generated one road-material source and tested derivatives without importing the source, derivative, or fallback into the normal Salto player slice.

## Boundary

Confirmed:

- Default launcher remains procedural.
- Browser runtime remains untouched.
- Character-slot integrations remain frozen.
- No player-facing road-material slot was added.
- No normal-slice road-material opt-in launcher was added.
- Generated source and derivatives remain ignored local evidence.
- Tracked fallback exists only under `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/`.

Tracked comparator-only additions:

- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/road_material_single_slot_comparator.gd`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_foothold_road_material_v0180_fallback.png`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_foothold_road_material_v0180_fallback.contract.json`
- `tools/godot/roadMaterialSingleSlotTool.mjs`
- `tools/godot/runGodotRoadMaterial*.ps1`
- `tools/godot/captureGodotRoadMaterialWindows.ps1`

## Rollback

To return to the pre-v0.180 code posture, revert only the v0.180 checkpoint commit. The local ignored source and derivative evidence may remain preserved by the artifact index; do not delete it as part of rollback unless a human explicitly authorizes cleanup.

Rollback removes:

- v0.180 road-material comparator dispatch.
- v0.180 road-material comparator script.
- v0.180 tracked diagnostic fallback and contract.
- v0.180 road-material npm scripts and PowerShell wrappers.
- v0.180 docs/index updates.

Rollback does not affect:

- Existing default procedural launcher.
- Existing Worker/Barracks/Militia/Aster/Ashen opt-in launchers.
- Existing v0.177/v0.178/v0.179 ground-material/environment opt-in posture.
- Browser runtime.

## Cleanup Dry Run

Required safe cleanup remains dry-run only until human approval. Preserve:

- `artifacts/desktop-spikes/godot-salto/v0180/local-road-material-slot/`
- `artifacts/desktop-spikes/godot-salto/v0180/evidence/`
- Tracked fallback `.png` and `.contract.json` files for v0.180.
- Unknown files.

Delete only positively identified safe transient residue through the existing safe-only cleanup path.
