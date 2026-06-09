# v0.179 Environment Boundary And Rollback

Status: `PASS_V0179_ENVIRONMENT_CONTRAST_HARMONIZATION_BOUNDARY`

v0.179 is an opt-in environment contrast posture only. It does not generate images, does not import a new source texture, does not add a runtime art slot, does not add character slots, does not enable art by default, and does not touch browser runtime.

## Boundary

Allowed work completed:

- Added `--salto-environment-contrast-harmonization` as a separate opt-in flag.
- Added procedural contrast overlays for roads, riverbanks, bridge crossing, site marker, approach lanes, hostile lane, minimap correlation, and restrained lighting.
- Added v0.179 validation, capture, benchmark, boundary, review, and launch wrappers.
- Added v0.179 capture checkpoint detection and capture steps.

Forbidden work avoided:

- No gameplay/pathing/objective/AI/balance/save/stable-ID changes.
- No browser runtime wiring.
- No default launcher changes.
- No changes to earlier Worker-only, Worker+Barracks, Worker+Barracks+Militia, four-slot, five-slot, environment-foundation, environment-readability, or ground-material launchers.
- No generated images.
- No new environment-material slot beyond the existing selected Barrosan foothold ground material.

Boundary evidence:

- `artifacts/desktop-spikes/godot-salto/v0179/boundary/environment-contrast-harmonization-boundary-report.json`

## Rollback

Rollback v0.179 by removing:

- `--salto-environment-contrast-harmonization` handling in `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`.
- `environment_contrast_harmonization_enabled`, `configure_environment_contrast_harmonization`, `_environment_contrast_harmonization_status`, `apply_environment_contrast_harmonization_framing`, and `_add_environment_contrast_harmonization_layers` in `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`.
- v0.179 wrappers:
  - `GODOT_VALIDATE_SALTO_ENVIRONMENT_CONTRAST_WINDOWS.bat`
  - `GODOT_CAPTURE_SALTO_ENVIRONMENT_CONTRAST_WINDOWS.bat`
  - `GODOT_REVIEW_SALTO_ENVIRONMENT_CONTRAST_WINDOWS.bat`
  - `tools/godot/validateGodotSaltoEnvironmentContrastWindows.ps1`
  - `tools/godot/captureGodotSaltoEnvironmentContrastWindows.ps1`
  - `tools/godot/launchGodotSaltoEnvironmentContrastWindows.ps1`
  - `tools/godot/reviewGodotSaltoEnvironmentContrastWindows.ps1`
  - `tools/godot/saltoEnvironmentContrastHarmonizationTool.mjs`
- v0.179 npm script entries in `package.json`.
- v0.179 docs and artifact-index references.

After rollback, rerun:

```text
npm run godot:validate:salto-ground-material-opt-in
npm run godot:test
npm run validate:runtime-art-slots
npm run godot:validate:salto-experimental-artifact-retention
```
