# v0.209 Implementation Report

## Changes

- Added `GODOT_LAUNCH_SALTO_UI_SHELL_EXPERIMENT_WINDOWS.bat`.
- Added `--salto-ui-shell-experiment` and `--salto-ui-shell-force-fallback`.
- Added a live root-level Godot UI shell overlay for the battle screen only.
- Added a scene-side switch that hides the previous procedural HUD only while the opt-in overlay is active.
- Hardened the new capture and validation wrappers so packaged Windows Godot runs are gated by PASS manifests instead of GUI-process timing.
- Added capture and validation wrappers:
  - `godot:capture:salto-ui-shell-opt-in`
  - `godot:validate:salto-ui-shell-opt-in`

## Evidence Paths

- Runtime artifacts: `artifacts/desktop-spikes/godot-salto/v0209/`
- Manual review pack: `artifacts/manual-review/v0209-ui-shell-opt-in/`

## Validation Executed

Passed before checkpoint:

```powershell
npm run godot:capture:salto-ui-shell-opt-in
npm run godot:validate:salto-ui-shell-opt-in
npm run validate:runtime-art-slots
node scripts/cleanupSaltoExperimentalArtifacts.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0209/cleanup-dry-run
npm run godot:test
npm run validate:content
npm run validate:art-intake
npm run build
git diff --check
npm test
```

`npm run build` completed with the existing large chunk warning only. `npm test` passed 122 files and 887 tests.

## Boundary Notes

v0.209 stops before v0.210. The default Godot launcher remains procedural, all prior launchers are preserved, and no browser runtime files are changed.
