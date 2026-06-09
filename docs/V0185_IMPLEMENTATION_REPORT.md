# v0.185 Implementation Report

Status: `PASS`

## Summary

v0.185 adds an explicit Godot Salto review path for environment-shell live QA residual-overlay pruning. It keeps the v0.184 geometry convergence foundation, selected five character opt-ins, selected Barrosan foothold ground material, and selected road material, then reduces diagnostic-looking overlay dominance inside the v0.185 opt-in review path only.

## Added

- `GODOT_REVIEW_SALTO_ENVIRONMENT_SHELL_LIVE_QA_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_ENVIRONMENT_SHELL_LIVE_QA_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_ENVIRONMENT_SHELL_LIVE_QA_WINDOWS.bat`
- `tools/godot/launchGodotSaltoEnvironmentShellLiveQaWindows.ps1`
- `tools/godot/reviewGodotSaltoEnvironmentShellLiveQaWindows.ps1`
- `tools/godot/validateGodotSaltoEnvironmentShellLiveQaWindows.ps1`
- `tools/godot/captureGodotSaltoEnvironmentShellLiveQaWindows.ps1`
- `tools/godot/saltoEnvironmentShellLiveQaTool.mjs`
- `docs/V0185_ENVIRONMENT_SHELL_LIVE_QA_AND_BENCHMARK.md`
- `docs/V0185_ENVIRONMENT_SHELL_BOUNDARY_ROLLBACK.md`
- `docs/V0185_IMPLEMENTATION_REPORT.md`

## Changed

- `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`
  - Added v0.185 opt-in shell-live-QA status and audit reporting.
  - Added `configure_environment_shell_live_qa` and v0.185 camera framing.
  - Kept v0.184 geometry convergence active as the foundation for E4.
  - Pruned residual diagnostic-like terrain/value/site/road overlays only when v0.185 live QA is enabled.
  - Reduced transparent layer competition around site markers, roads, terrain masks, bridge seats, and review pads.
- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
  - Added the `--salto-environment-shell-live-qa` flag to the accepted argument prefixes.
  - Added v0.185 validation/capture/benchmark status fields and capture routing.
  - Preserved default procedural and all prior opt-in launcher paths.
- `package.json`
  - Added launch, review, validate, and capture scripts for v0.185.

## Verification

Passed:

- `node --check tools/godot/saltoEnvironmentShellLiveQaTool.mjs`
- PowerShell parser checks for the new v0.185 wrappers.
- Windows-side Computer Use live review: title, briefing, battle, pan, zoom, mine, Worker assignment, Barracks restoration, Militia recruitment, Ashen posture, minimap, Results, and Restart Slice.
- `npm run godot:validate:salto-ground-road-material-opt-in`
- `npm run godot:validate:salto-environment-geometry-convergence`
- `npm run godot:validate:salto-environment-shell-live-qa`
- `npm run godot:headed:post-mine-flow-smoke`
- `npm run godot:headed:triple-natural-playthrough`
- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run validate:runtime-art-slots`
- `npm run godot:validate:salto-experimental-artifact-retention`
- `node tools/godot/saltoEnvironmentShellLiveQaTool.mjs boundary --artifact-root=artifacts/desktop-spikes/godot-salto/v0185/final-boundary`
- `node scripts/cleanupSaltoExperimentalArtifacts.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0185/final-cleanup-dry-run`
- `GODOT_CLEANUP_SALTO_EXPERIMENTAL_ARTIFACTS_SAFE_WINDOWS.bat --apply-safe-only --output-root=artifacts/desktop-spikes/godot-salto/v0185/final-cleanup-safe-only`
- `npm run godot:validate:salto-experimental-artifact-retention`

## Benchmark

E4 refined shell live QA versus E3 geometry-convergence baseline:

- FPS ratio: `1.0000`
- p95 worsening: `-2.92%`

Result: `PASS_V0185_ENVIRONMENT_SHELL_LIVE_QA_BENCHMARK`.

## Zero-Image And Zero-Slot Confirmation

No image was generated. No slot was added. v0.185 imports no new texture, integrates no bridge/riverbank/structure material, and does not enable art by default.

## Remaining Procedural Limitations

The v0.185 scene is cleaner and more reviewable, but it remains a procedural primitive shell. Structure massing, bridge hierarchy, riverbank shaping, z-order grounding, and broader shell cohesion remain appropriate future bounded work and were not broadened in this checkpoint.

