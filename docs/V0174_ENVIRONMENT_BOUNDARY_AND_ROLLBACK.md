# v0.174 Environment Boundary And Rollback

Status: `PASS_V0174_ENVIRONMENT_BOUNDARY_AND_ROLLBACK`

## Boundary

- Default launcher remains procedural.
- Prior opt-in launchers are preserved.
- v0.173 environment-foundation launcher is preserved and does not enable v0.174 readability hardening.
- Browser runtime remains untouched.
- Saves, stable IDs, gameplay rules, navigation, pathing, objectives, and balance remain unchanged.
- No character slots are added.
- Zero AI images.
- No terrain material import.
- No player-facing terrain-material slot.

Boundary report: `artifacts/desktop-spikes/godot-salto/v0174/boundary/environment-readability-boundary-report.json`

Boundary status: `PASS_V0174_ENVIRONMENT_READABILITY_BOUNDARY`

Additional verified boundaries:

- E2 loads exactly the existing five selected opt-in character/material slots.
- E2 reports `environmentReadabilityArtSlotCount=0`.
- E2 reports `terrainMaterialSourceImported=false` and `terrainMaterialRuntimeSlotAdded=false`.
- No tracked or untracked image change was detected by the v0.174 boundary report.
- The default procedural launcher and all earlier opt-in launchers do not enable `--salto-environment-readability-hardening`.

## Rollback

Revert the v0.174 commit to remove the E2 readability hardening path.

Manual rollback scope:

- Remove `GODOT_REVIEW_SALTO_ENVIRONMENT_READABILITY_WINDOWS.bat`, `GODOT_CAPTURE_SALTO_ENVIRONMENT_READABILITY_WINDOWS.bat`, and `GODOT_VALIDATE_SALTO_ENVIRONMENT_READABILITY_WINDOWS.bat`.
- Remove v0.174 Godot PowerShell wrappers and `tools/godot/saltoEnvironmentReadabilityTool.mjs`.
- Remove `--salto-environment-readability-hardening` handling.
- Remove the `environment_readability_hardening_enabled` procedural layers and status fields.
- Remove the v0.174 package scripts.

No selected local art, derivatives, metadata, tracked fallbacks, v0.173 evidence, or older required evidence should be deleted during rollback.

`PASS_V0174_ENVIRONMENT_BOUNDARY_AND_ROLLBACK`
