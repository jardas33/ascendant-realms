# v0.187 Implementation Report

Status: `PASS`

## Summary

v0.187 adds an explicit Godot Salto review path for procedural riverbank, bridge-crossing, and approach-lane visual hardening after v0.186. It keeps the v0.186 structure-shell foundation, selected five character opt-ins, selected Barrosan foothold ground material, and selected road material, then improves only the opt-in procedural crossing presentation.

## Added

- `GODOT_REVIEW_SALTO_RIVERBANK_BRIDGE_APPROACH_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_RIVERBANK_BRIDGE_APPROACH_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_RIVERBANK_BRIDGE_APPROACH_WINDOWS.bat`
- `tools/godot/launchGodotSaltoRiverbankBridgeApproachWindows.ps1`
- `tools/godot/reviewGodotSaltoRiverbankBridgeApproachWindows.ps1`
- `tools/godot/validateGodotSaltoRiverbankBridgeApproachWindows.ps1`
- `tools/godot/captureGodotSaltoRiverbankBridgeApproachWindows.ps1`
- `tools/godot/saltoRiverbankBridgeApproachTool.mjs`
- `docs/V0187_RIVERBANK_BRIDGE_APPROACH_QA_BENCHMARK.md`
- `docs/V0187_RIVERBANK_BRIDGE_BOUNDARY_ROLLBACK.md`
- `docs/V0187_IMPLEMENTATION_REPORT.md`

## Changed

- `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`
  - Added v0.187 opt-in riverbank/bridge approach status and audit reporting.
  - Added `configure_environment_riverbank_bridge_approach` and R1 review framing.
  - Kept v0.186 structure-shell hardening active as the foundation for R1.
  - Added visual-only river channel, bank shelf, bridge deck, bridge rail, abutment, landing-shadow, approach-lane, site-marker, and minimap-correlation refinements only when v0.187 is enabled.
  - Added a dedicated riverbank/bridge focus helper so normal/close bridge, banks, approach, and crossing captures stay focused.
- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
  - Added the `--salto-riverbank-bridge-approach-hardening` flag to accepted argument prefixes.
  - Added v0.187 validation/capture/benchmark status fields and capture routing.
  - Added v0.187-specific capture actions for full overview, river overview, banks normal/close, bridge normal/close, road-to-bridge transition, friendly approach, hostile approach, combat crossing posture, pan, zoom, minimap, and Results.
  - Preserved default procedural and all prior opt-in launcher paths.
- `package.json`
  - Added launch, review, validate, and capture scripts for v0.187.

## Verification

Passed:

- `node --check tools/godot/saltoRiverbankBridgeApproachTool.mjs`
- PowerShell parser checks for the new v0.187 wrappers.
- Windows-side Computer Use live review: title, briefing, battle, Aster selection, Move command, right-click movement near the bridge approach, pan, and zoom.
- `npm run godot:validate:salto-riverbank-bridge-approach`
- `PASS_V0187_SALTO_RIVERBANK_BRIDGE_APPROACH_AUTOMATION_READY`
- `PASS_V0187_RIVERBANK_BRIDGE_APPROACH_VALIDATION`
- `PASS_V0187_RIVERBANK_BRIDGE_APPROACH_CAPTURE`
- `PASS_V0187_RIVERBANK_BRIDGE_APPROACH_BENCHMARK`
- `PASS_V0187_RIVERBANK_BRIDGE_APPROACH_BOUNDARY`

- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run validate:runtime-art-slots`
- `npm run godot:validate:salto-structure-shell-hardening`
- `npm run godot:headed:post-mine-flow-smoke`
- `npm run godot:headed:triple-natural-playthrough`
- `npm run godot:validate:salto-experimental-artifact-retention`
- `node scripts/cleanupSaltoExperimentalArtifacts.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0187/final-cleanup-dry-run`
- `node scripts/validateSaltoExperimentalArtifactRetention.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0187/final-artifact-retention`
- `node tools/godot/saltoRiverbankBridgeApproachTool.mjs boundary --artifact-root=artifacts/desktop-spikes/godot-salto/v0187/final-boundary`

Safe-only cleanup was not run because the v0.187 prompt required dry-run plus retention only. The dry-run reported `0` blocked unknown files and `18` already-classified safe Godot-generated sidecar candidates.

## Benchmark

R1 riverbank/bridge approach hardening versus S1 structure-shell hardening baseline:

- FPS ratio: `1.0024`
- p95 worsening: `0.3%`

Result: `PASS_V0187_RIVERBANK_BRIDGE_APPROACH_BENCHMARK`.

## Zero-Image And Zero-Slot Confirmation

No image was generated. No slot was added. v0.187 imports no bridge, riverbank, water, or structure material; adds no water shader pipeline; and does not enable art by default.

## Remaining Procedural Limitations

The v0.187 crossing is more coherent and readable, but it remains a procedural primitive shell. Bridge/riverbank material intake, model production, water shaders, animation, and default-art enablement remain out of scope.
