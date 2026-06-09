# v0.189 Private Comparator Boundary Rollback

Status: `PASS_V0189_BRIDGE_RIVERBANK_MATERIAL_BOUNDARY`

v0.189 is private-comparator-only. It generated one wet-granite bridge-riverbank source and tested deterministic derivatives without importing the source, derivative, or fallback into the normal Salto player slice.

## Boundary

Confirmed:

- Default launcher remains procedural.
- Browser runtime remains untouched.
- Character-slot integrations remain frozen.
- No player-facing bridge/riverbank material slot was added.
- No normal-slice bridge/riverbank opt-in launcher was added.
- Generated source and derivatives remain ignored local evidence.
- Tracked fallback exists only under `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/`.
- Gameplay, pathing, collisions, objectives, AI, saves, stable IDs, production manifests, and browser runtime were not changed.

Tracked comparator-only additions:

- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/bridge_riverbank_material_single_slot_comparator.gd`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_wet_granite_bridge_riverbank_material_v0189_fallback.png`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_wet_granite_bridge_riverbank_material_v0189_fallback.contract.json`
- `tools/godot/bridgeRiverbankMaterialSingleSlotTool.mjs`
- `tools/godot/runGodotBridgeRiverbankMaterial*.ps1`
- `tools/godot/captureGodotBridgeRiverbankMaterialWindows.ps1`

## Rollback

To return to the pre-v0.189 code posture, revert only the v0.189 checkpoint commit. The local ignored source and derivative evidence may remain preserved by the artifact index; do not delete it as part of rollback unless a human explicitly authorizes cleanup.

Rollback removes:

- v0.189 bridge-riverbank material comparator dispatch.
- v0.189 bridge-riverbank material comparator script.
- v0.189 tracked diagnostic fallback and contract.
- v0.189 bridge-riverbank material npm scripts and PowerShell wrappers.
- v0.189 docs/index updates.

Rollback does not affect:

- Existing default procedural launcher.
- Existing Worker/Barracks/Militia/Aster/Ashen opt-in launchers.
- Existing ground-material and road-material opt-in launchers.
- Existing v0.184-v0.188 procedural shell review paths.
- Browser runtime.

## Cleanup Dry Run

Required cleanup remains dry-run only until human approval. Preserve:

- `artifacts/desktop-spikes/godot-salto/v0189/local-bridge-riverbank-material-slot/`
- `artifacts/desktop-spikes/godot-salto/v0189/evidence/`
- `artifacts/desktop-spikes/godot-salto/v0189/cleanup-dry-run/`
- Tracked fallback `.png` and `.contract.json` files for v0.189.
- Unknown files.

The refreshed v0.189 cleanup dry run reported `PASS_V0166_EXPERIMENTAL_ARTIFACT_CLEANUP_DRY_RUN`, `29` tracked comparator-scope files, `0` unknowns, `0` safe-delete candidates, and `0` deletions.
