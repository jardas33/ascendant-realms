# v0.195 Shell V2 Scoped Material Boundary And Rollback

Status: `PASS_V0195_SHELL_V2_SCOPED_MATERIAL_BOUNDARY_ROLLBACK`

Date: 2026-06-09

## Boundary

Authorized scope was limited to visual-only scoped material recovery for the isolated shell-v2 review path:

- Preserve v0.194 clean topology.
- Restore restrained terrain-material hierarchy.
- Strengthen connected road readability at review distance.
- Repair route-to-bridge and intersection readability without broad masks.
- Keep wet-granite bridge-riverbank material unintegrated.

Forbidden scope remained untouched:

- No generated images.
- No new art slots.
- No wet-granite bridge-riverbank integration.
- No default launcher change.
- No legacy-shell removal.
- No browser runtime wiring.
- No gameplay, pathing, collision, objective, AI, save, stable-ID, balance, or production-manifest mutation.
- No v0.196 work.

## Added Review Path

- `GODOT_REVIEW_SALTO_SHELL_V2_SCOPED_MATERIAL_RECOVERY_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_SHELL_V2_SCOPED_MATERIAL_RECOVERY_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_SHELL_V2_SCOPED_MATERIAL_RECOVERY_WINDOWS.bat`
- `tools/godot/launchGodotSaltoShellV2ScopedMaterialRecoveryWindows.ps1`
- `tools/godot/reviewGodotSaltoShellV2ScopedMaterialRecoveryWindows.ps1`
- `tools/godot/validateGodotSaltoShellV2ScopedMaterialRecoveryWindows.ps1`
- `tools/godot/captureGodotSaltoShellV2ScopedMaterialRecoveryWindows.ps1`
- `tools/godot/saltoShellV2ScopedMaterialRecoveryTool.mjs`

The path remains explicit opt-in only through `--salto-presentation-shell-v2` plus the v0.195 scoped-material-recovery review wrapper. Default procedural launchers and all prior opt-in launchers remain available.

## Boundary Evidence

- `artifacts/desktop-spikes/godot-salto/v0195/boundary/shell-v2-scoped-material-boundary-scan.json`
- `artifacts/desktop-spikes/godot-salto/v0195/validation/shell-v2-scoped-material-recovery-validation-report.json`
- `artifacts/desktop-spikes/godot-salto/v0195/cleanup-safe-only/salto-experimental-cleanup-report.json`
- `artifacts/desktop-spikes/godot-salto/v0195/artifact-retention-post-cleanup/salto-experimental-artifact-retention-report.json`

Confirmed boundary facts:

- `generatedImagesChanged`: `false`
- `newArtSlotsAdded`: `false`
- `wetGraniteIntegrated`: `false`
- `defaultLauncherChanged`: `false`
- `browserRuntimeChanged`: `false`
- `gameplayPathingCollisionFilesChanged`: `false`
- `broadMaterialMasksReintroduced`: `false`
- `detachedTerrainIslandCount`: `0`
- `floatingDiagonalRoadFragmentCount`: `0`
- Safe-only cleanup deleted `20` positively classified Godot-generated sidecars and found no unknown blockers.

## Rollback

To stop using v0.195 scoped material recovery for review, launch any older preserved route:

- Default procedural player slice: existing default launcher.
- Legacy riverbank/bridge approach: `GODOT_REVIEW_SALTO_RIVERBANK_BRIDGE_APPROACH_WINDOWS.bat`.
- Original shell-v2 comparator: `GODOT_REVIEW_SALTO_PRESENTATION_SHELL_V2_WINDOWS.bat`.
- v0.194 topology-repair comparator: `GODOT_REVIEW_SALTO_SHELL_V2_TOPOLOGY_REPAIR_WINDOWS.bat`.

Code rollback is narrow if required: revert the v0.195 additions in `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`, `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`, `package.json`, the v0.195 wrappers/tool listed above, and the v0.195 docs. No selected local art derivative, tracked fallback, or metadata file needs to be deleted for rollback.

Next boundary: stop for human review. Do not begin v0.196.
