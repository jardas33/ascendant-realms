# v0.186 Implementation Report

Status: `PASS`

## Summary

v0.186 adds an explicit Godot Salto review path for procedural structure-shell hierarchy hardening after v0.185. It keeps the v0.185 shell-live-QA foundation, selected five character opt-ins, selected Barrosan foothold ground material, and selected road material, then improves only the opt-in visual structure shells for the Command Hall, mine, Barracks restoration shell, site structures, and restrained defensive props.

## Added

- `GODOT_REVIEW_SALTO_STRUCTURE_SHELL_HARDENING_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_STRUCTURE_SHELL_HARDENING_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_STRUCTURE_SHELL_HARDENING_WINDOWS.bat`
- `tools/godot/launchGodotSaltoStructureShellHardeningWindows.ps1`
- `tools/godot/reviewGodotSaltoStructureShellHardeningWindows.ps1`
- `tools/godot/validateGodotSaltoStructureShellHardeningWindows.ps1`
- `tools/godot/captureGodotSaltoStructureShellHardeningWindows.ps1`
- `tools/godot/saltoStructureShellHardeningTool.mjs`
- `docs/V0186_STRUCTURE_SHELL_HIERARCHY_QA_BENCHMARK.md`
- `docs/V0186_STRUCTURE_SHELL_BOUNDARY_ROLLBACK.md`
- `docs/V0186_IMPLEMENTATION_REPORT.md`

## Changed

- `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`
  - Added v0.186 opt-in structure-shell hardening status and audit reporting.
  - Added `configure_environment_structure_shell_hardening` and S1 review framing.
  - Kept v0.185 shell-live-QA active as the foundation for S1.
  - Added wet-granite foundations, timber frames, restrained roof/trim accents, scaffolding, contact shadows, and practical structure silhouettes only when v0.186 is enabled.
  - Added a dedicated structure-shell focus helper so Command Hall, mine, and Barracks normal/close captures stay focused.
- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
  - Added the `--salto-structure-shell-hardening` flag to accepted argument prefixes.
  - Added v0.186 validation/capture/benchmark status fields and capture routing.
  - Added v0.186-specific capture actions for Command Hall, mine, Barracks restoration, restored Barracks, Worker/Barracks relation, road/bridge relation, combat posture, pan/zoom, minimap, and Results.
  - Preserved default procedural and all prior opt-in launcher paths.
- `package.json`
  - Added launch, review, validate, and capture scripts for v0.186.

## Verification

Passed:

- `node --check tools/godot/saltoStructureShellHardeningTool.mjs`
- PowerShell parser checks for the new v0.186 wrappers.
- Windows-side Computer Use live review: title, briefing, battle, Aster selection, objective advancement toward the West Stone Cut Mine, camera movement, and zoom.
- `npm run godot:validate:salto-structure-shell-hardening`
- `PASS_V0186_SALTO_STRUCTURE_SHELL_HARDENING_AUTOMATION_READY`
- `PASS_V0186_STRUCTURE_SHELL_HARDENING_VALIDATION`
- `PASS_V0186_STRUCTURE_SHELL_HARDENING_CAPTURE`
- `PASS_V0186_STRUCTURE_SHELL_HARDENING_BENCHMARK`
- `PASS_V0186_STRUCTURE_SHELL_HARDENING_BOUNDARY`

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
- `node scripts/cleanupSaltoExperimentalArtifacts.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0186/final-cleanup-dry-run`
- `node scripts/validateSaltoExperimentalArtifactRetention.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0186/final-retention`
- `node tools/godot/saltoStructureShellHardeningTool.mjs boundary --artifact-root=artifacts/desktop-spikes/godot-salto/v0186/final-boundary`

Safe-only cleanup was not run because the v0.186 prompt required dry-run plus retention only. The dry-run reported `0` blocked unknown files and `18` already-classified safe Godot-generated sidecar candidates.

## Benchmark

S1 structure-shell hardening versus E4 refined shell live QA baseline:

- FPS ratio: `1.0039`
- p95 worsening: `-4.05%`

Result: `PASS_V0186_STRUCTURE_SHELL_HARDENING_BENCHMARK`.

## Zero-Image And Zero-Slot Confirmation

No image was generated. No slot was added. v0.186 imports no new texture, integrates no bridge/riverbank/structure material, and does not enable art by default.

## Remaining Procedural Limitations

The v0.186 scene is more grounded and readable, but it remains a procedural primitive shell. Bridge/riverbank material intake, structure materials, broad model production, animation, and default-art enablement remain out of scope.
