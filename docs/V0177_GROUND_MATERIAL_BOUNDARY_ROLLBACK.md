# v0.177 Ground Material Boundary And Rollback

Status: `PASS_V0177_GROUND_MATERIAL_OPT_IN_BOUNDARY`

v0.177 adds one explicit opt-in environment-material slot for the Godot Salto review path. It does not enable art by default and does not broaden character integration.

## Boundaries Proved

Boundary report: `artifacts/desktop-spikes/godot-salto/v0177/boundary/ground-material-opt-in-boundary-report.json`

- AI images generated: `0`.
- Runtime character slots added: `0`.
- Environment material slots added: `1`.
- Default launcher procedural: `true`.
- Prior launchers preserved: `true`.
- Browser runtime changed: `false`.
- Save writes allowed: `false`.
- Stable IDs changed: `false`.
- Gameplay/pathing changed: `false`.
- Navigation semantics changed: `false`.
- Selected hash: `818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8`.

## Fallbacks

Both fallback modes keep the five frozen character/material slots active and fall back only the ground material:

- Missing source fallback: `ground-missing-art-fallback`, reason `missing source file`.
- Hash mismatch fallback: `ground-hash-mismatch-fallback`, reason `metadata hash mismatch`.

Fallback modes do not import the selected source and do not apply material surfaces.

## Rollback

Rollback removes only v0.177 additions:

- `GODOT_REVIEW_SALTO_GROUND_MATERIAL_OPT_IN_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_GROUND_MATERIAL_OPT_IN_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_GROUND_MATERIAL_OPT_IN_WINDOWS.bat`
- `tools/godot/launchGodotSaltoGroundMaterialOptInWindows.ps1`
- `tools/godot/reviewGodotSaltoGroundMaterialOptInWindows.ps1`
- `tools/godot/validateGodotSaltoGroundMaterialOptInWindows.ps1`
- `tools/godot/captureGodotSaltoGroundMaterialOptInWindows.ps1`
- `tools/godot/saltoGroundMaterialOptInTool.mjs`
- The v0.177 ground-material opt-in code path in `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`.
- The v0.177 ground-material material loader/binding in `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`.
- The four v0.177 npm script entries.

Rollback must not delete selected local art, metadata, tracked fallbacks, v0.175 source evidence, or historical QA evidence.

## Cleanup

Cleanup dry-run report: `artifacts/desktop-spikes/godot-salto/v0177/cleanup-dry-run/salto-experimental-cleanup-report.json`

Result:

- Status: `PASS_V0166_EXPERIMENTAL_ARTIFACT_CLEANUP_DRY_RUN`.
- Unknown files: none.
- Deletion attempted: `false`.
- Safe candidates are known Godot-generated transient sidecars only.

Retention report: `artifacts/desktop-spikes/godot-salto/v0177/artifact-retention/salto-experimental-artifact-retention-report.json`

Result:

- Status: `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`.
- Selected active derivatives, metadata, tracked fallbacks, selected ground material, and latest required evidence are retained.

## Stop Line

v0.177 stops after this first ground-material opt-in integration checkpoint. v0.178 is not part of this commit.
