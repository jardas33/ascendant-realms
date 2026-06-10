# v0.196 Shell V2 Mesh Compositor Boundary And Rollback

Status: `PASS_V0196_SHELL_V2_MESH_COMPOSITOR_BOUNDARY_ROLLBACK`

Date: 2026-06-10

## Boundary

Authorized scope was limited to a visual-only procedural-mesh compositor replacement for the isolated shell-v2 review path:

- Replace the pad-and-line shell-v2 presentation with one coherent terrain mesh and bounded visual surfaces.
- Preserve the legacy riverbank/bridge approach shell and the v0.195 scoped-material shell as comparators/fallbacks.
- Keep selected Worker, Barracks, Militia, Aster, Ashen, ground, and road opt-in context available only through explicit review launchers.
- Keep the v0.189 wet-granite bridge-riverbank material unintegrated.
- Export a compact manual-review PNG pack as required evidence.

Forbidden scope remained untouched:

- No generated images.
- No imported art slots.
- No wet-granite bridge-riverbank integration.
- No default launcher change.
- No legacy-shell removal.
- No browser runtime wiring.
- No gameplay, pathing, collision, objective, AI, save, stable-ID, balance, or production-manifest mutation.
- No v0.197 work inside this checkpoint.

## Added Review Path

- `GODOT_REVIEW_SALTO_SHELL_V2_MESH_COMPOSITOR_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_SHELL_V2_MESH_COMPOSITOR_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_SHELL_V2_MESH_COMPOSITOR_WINDOWS.bat`
- `GODOT_BENCHMARK_SALTO_SHELL_V2_MESH_COMPOSITOR_WINDOWS.bat`
- `tools/godot/launchGodotSaltoShellV2MeshCompositorWindows.ps1`
- `tools/godot/reviewGodotSaltoShellV2MeshCompositorWindows.ps1`
- `tools/godot/validateGodotSaltoShellV2MeshCompositorWindows.ps1`
- `tools/godot/captureGodotSaltoShellV2MeshCompositorWindows.ps1`
- `tools/godot/runGodotSaltoShellV2MeshCompositorBenchmarkWindows.ps1`
- `tools/godot/saltoShellV2MeshCompositorTool.mjs`

The path remains explicit opt-in only through `--salto-presentation-shell-v2` plus `--salto-shell-v2-mesh-compositor`. Default procedural launchers and all prior opt-in launchers remain available.

## Boundary Evidence

- `artifacts/desktop-spikes/godot-salto/v0196/boundary/shell-v2-mesh-compositor-boundary-scan.json`
- `artifacts/desktop-spikes/godot-salto/v0196/validation/shell-v2-mesh-compositor-validation-report.json`
- `artifacts/desktop-spikes/godot-salto/v0196/capture/shell-v2-mesh-compositor-capture-report.json`
- `artifacts/desktop-spikes/godot-salto/v0196/artifact-retention-post-cleanup/salto-experimental-artifact-retention-report.json`

Confirmed boundary facts:

- `generatedImagesChanged`: `false`
- `newArtSlotsAdded`: `false`
- `wetGraniteIntegrated`: `false`
- `defaultLauncherChanged`: `false`
- `browserRuntimeChanged`: `false`
- `gameplayPathingCollisionFilesChanged`: `false`
- `detachedTerrainIslandCount`: `0`
- `floatingDiagonalRoadFragmentCount`: `0`
- `riverSurfaceCount`: `1`

The boundary scanner explicitly allows only the required `artifacts/manual-review/v0196-shell-v2-mesh-compositor/NN_*.png` evidence pack. Other image changes remain blocked.

## Rollback

To stop using v0.196 mesh compositor for review, launch any older preserved route:

- Default procedural player slice: existing default launcher.
- Legacy riverbank/bridge approach: `GODOT_REVIEW_SALTO_RIVERBANK_BRIDGE_APPROACH_WINDOWS.bat`.
- Original shell-v2 comparator: `GODOT_REVIEW_SALTO_PRESENTATION_SHELL_V2_WINDOWS.bat`.
- v0.194 topology-repair comparator: `GODOT_REVIEW_SALTO_SHELL_V2_TOPOLOGY_REPAIR_WINDOWS.bat`.
- v0.195 scoped-material comparator: `GODOT_REVIEW_SALTO_SHELL_V2_SCOPED_MATERIAL_RECOVERY_WINDOWS.bat`.

Code rollback is narrow if required: revert the v0.196 additions in `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`, `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`, `package.json`, the v0.196 wrappers/tool listed above, and the v0.196 docs. No selected local art derivative, tracked fallback, metadata file, or historical evidence needs to be deleted for rollback.

Next boundary: continue to v0.197 only if the queued prompt sequence is explicitly active, the repository is clean/synced/pushed, and the remote gate is green.
