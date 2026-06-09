# v0.177 Implementation Report

Status: `PASS_V0177_GROUND_MATERIAL_FIRST_OPT_IN_INTEGRATION`

v0.177 integrates only `barrosan_foothold_ground_material_v0175` as the first player-slice environment-material opt-in slot for the Godot Salto review path. It keeps the default launcher procedural, preserves all previous opt-in launchers, keeps character-slot expansion frozen at five, generates zero images, and leaves browser runtime untouched.

## Work Completed

Added:

- `GODOT_REVIEW_SALTO_GROUND_MATERIAL_OPT_IN_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_GROUND_MATERIAL_OPT_IN_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_GROUND_MATERIAL_OPT_IN_WINDOWS.bat`
- `tools/godot/launchGodotSaltoGroundMaterialOptInWindows.ps1`
- `tools/godot/reviewGodotSaltoGroundMaterialOptInWindows.ps1`
- `tools/godot/validateGodotSaltoGroundMaterialOptInWindows.ps1`
- `tools/godot/captureGodotSaltoGroundMaterialOptInWindows.ps1`
- `tools/godot/saltoGroundMaterialOptInTool.mjs`
- `docs/V0177_GROUND_MATERIAL_OPT_IN_QA_BENCHMARK.md`
- `docs/V0177_GROUND_MATERIAL_BOUNDARY_ROLLBACK.md`
- `docs/V0177_IMPLEMENTATION_REPORT.md`

Changed:

- Added explicit `--ground-material-opt-in` loader arguments and reporting in `salto_spike_root.gd`.
- Added exact hash/dimension validation, fallback, one-time texture/material cache reporting, and narrow terrain-surface binding in `salto_spike_scene_3d.gd`.
- Added v0.177 npm scripts for launch, review, capture, and validation.
- Updated artifact retention so the selected v0.175 ground derivative and metadata remain protected.
- Updated the standard handoff, roadmap, changelog, checkpoint, checklist, and artifact index docs.

## Launcher

Use:

```text
GODOT_REVIEW_SALTO_GROUND_MATERIAL_OPT_IN_WINDOWS.bat
```

Equivalent npm script:

```text
npm run godot:review:salto-ground-material-opt-in
```

The label reads:

```text
Experimental opt-in art: 5 slots + Barrosan foothold ground
```

## Validation

Command:

```text
npm run godot:validate:salto-ground-material-opt-in
```

Result:

```text
PASS_V0177_SALTO_GROUND_MATERIAL_OPT_IN_AUTOMATION_READY
```

Primary evidence:

- Validation: `artifacts/desktop-spikes/godot-salto/v0177/validation/ground-material-opt-in-validation-report.json`
- Capture: `artifacts/desktop-spikes/godot-salto/v0177/capture/ground-material-opt-in-capture-report.json`
- Contact sheet: `artifacts/desktop-spikes/godot-salto/v0177/capture/v0177-ground-material-opt-in-contact-sheet.svg`
- Benchmark: `artifacts/desktop-spikes/godot-salto/v0177/benchmark/ground-material-opt-in-benchmark-scorecard.json`
- Boundary: `artifacts/desktop-spikes/godot-salto/v0177/boundary/ground-material-opt-in-boundary-report.json`
- Cleanup dry-run: `artifacts/desktop-spikes/godot-salto/v0177/cleanup-dry-run/salto-experimental-cleanup-report.json`
- Retention: `artifacts/desktop-spikes/godot-salto/v0177/artifact-retention/salto-experimental-artifact-retention-report.json`

## Visual Decision

The selected material is still dark and high-frequency, but v0.177 keeps it behind the road, river, bridge, site-marker, minimap, unit, and HUD hierarchy. It passes as a first opt-in material integration, with v0.178 reserved for UV/noise hardening and further contrast review.

## Boundary

Zero images generated. One environment-material opt-in slot added. Zero character slots added. No default-art enablement. No browser wiring. No save, stable-ID, gameplay, objective, pathing, AI, balance, campaign, production manifest, or package-leak mutation.

v0.178 not started in this checkpoint.
