# v0.173 Environment Shell Boundary And Rollback

Status: `PASS_V0173_ENVIRONMENT_SHELL_BOUNDARY_AND_ROLLBACK`

## Boundary

- Default launcher remains procedural.
- Prior opt-in launchers are preserved and do not include `--salto-environment-foundation-review`.
- New review launcher: `GODOT_REVIEW_SALTO_ENVIRONMENT_FOUNDATION_WINDOWS.bat`.
- Browser runtime remains untouched.
- Saves, stable IDs, gameplay rules, pathing, and objective semantics are unchanged.
- No sixth character slot.
- Zero AI images.
- No terrain material import.
- No player-facing terrain-material slot.
- Existing five selected slots remain the only opt-in art/material slots in this path.

Boundary report: `artifacts/desktop-spikes/godot-salto/v0173/boundary/environment-foundation-boundary-report.json`

## Launcher Posture

The new launcher enables:

- `--player-slice`
- `--salto-five-slot-review-framing`
- `--salto-environment-foundation-review`
- Worker, Barracks, Militia, Aster, and Ashen selected opt-in sources

The launcher does not enable terrain-material integration and does not mutate any default launcher.

## Rollback

Revert the v0.173 commit to remove the environment-foundation review path.

Manual rollback scope:

- Remove `GODOT_REVIEW_SALTO_ENVIRONMENT_FOUNDATION_WINDOWS.bat`, `GODOT_CAPTURE_SALTO_ENVIRONMENT_FOUNDATION_WINDOWS.bat`, and `GODOT_VALIDATE_SALTO_ENVIRONMENT_FOUNDATION_WINDOWS.bat`.
- Remove the v0.173 Godot PowerShell wrappers and `tools/godot/saltoEnvironmentFoundationTool.mjs`.
- Remove the `--salto-environment-foundation-review` root argument handling.
- Remove the `environment_foundation_review_enabled` procedural layers and status fields.
- Remove the v0.173 package scripts.

No selected local art, derivatives, metadata, tracked fallbacks, or older required evidence should be deleted during rollback.

`PASS_V0173_ENVIRONMENT_SHELL_BOUNDARY_AND_ROLLBACK`
