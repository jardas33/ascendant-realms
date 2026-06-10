# v0.197 Mesh Compositor Boundary And Rollback

Status: `PASS_V0197_SHELL_V2_MESH_QA_BOUNDARY_ROLLBACK`

Date: 2026-06-10

## Boundary

Authorized scope was limited to Windows-side QA and visual-only repair for the isolated shell-v2 procedural-mesh compositor review path:

- Inspect the packaged Godot review app with the existing selected Worker, Barracks, Militia, Aster, Ashen, ground, and road opt-in context.
- Repair only visual topology, route transition, UV/readability, layering, z-order, masking, and camera/framing issues proven inside the mesh-compositor path.
- Preserve the legacy riverbank/bridge approach shell, the v0.195 scoped-material shell, and the v0.196 M1 mesh-compositor baseline as comparators/fallbacks.
- Export the compact v0.197 manual-review PNG pack.

Forbidden scope remained untouched:

- No generated images.
- No imported art slots.
- No wet-granite bridge-riverbank integration.
- No default launcher change.
- No legacy-shell removal.
- No browser runtime wiring.
- No gameplay, pathing, collision, objective, AI, save, stable-ID, balance, or production-manifest mutation.
- No v0.198 work inside this checkpoint.

## Added Review Path

- `GODOT_REVIEW_SALTO_SHELL_V2_MESH_QA_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_SHELL_V2_MESH_QA_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_SHELL_V2_MESH_QA_WINDOWS.bat`
- `GODOT_BENCHMARK_SALTO_SHELL_V2_MESH_QA_WINDOWS.bat`
- `tools/godot/launchGodotSaltoShellV2MeshQaWindows.ps1`
- `tools/godot/reviewGodotSaltoShellV2MeshQaWindows.ps1`
- `tools/godot/validateGodotSaltoShellV2MeshQaWindows.ps1`
- `tools/godot/captureGodotSaltoShellV2MeshQaWindows.ps1`
- `tools/godot/runGodotSaltoShellV2MeshQaBenchmarkWindows.ps1`
- `tools/godot/saltoShellV2MeshQaTool.mjs`

The path remains explicit opt-in only through the v0.193 presentation shell posture plus `--salto-shell-v2-mesh-compositor`. Default procedural launchers and all prior opt-in launchers remain available.

## Boundary Evidence

- `artifacts/desktop-spikes/godot-salto/v0197/boundary/shell-v2-mesh-qa-boundary-scan.json`
- `artifacts/desktop-spikes/godot-salto/v0197/validation/shell-v2-mesh-qa-validation-report.json`
- `artifacts/desktop-spikes/godot-salto/v0197/capture/shell-v2-mesh-qa-capture-report.json`
- `artifacts/desktop-spikes/godot-salto/v0197/artifact-retention-post-cleanup/salto-experimental-artifact-retention-report.json`

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
- `routeContinuityPass`: `true`

The boundary scanner explicitly allows only the required `artifacts/manual-review/v0197-shell-v2-mesh-qa/NN_*.png` evidence pack. Other image changes remain blocked.

## Rollback

To stop using the v0.197 QA repair path for review, launch any older preserved route:

- Default procedural player slice: existing default launcher.
- Legacy riverbank/bridge approach: `GODOT_REVIEW_SALTO_RIVERBANK_BRIDGE_APPROACH_WINDOWS.bat`.
- Original shell-v2 comparator: `GODOT_REVIEW_SALTO_PRESENTATION_SHELL_V2_WINDOWS.bat`.
- v0.194 topology-repair comparator: `GODOT_REVIEW_SALTO_SHELL_V2_TOPOLOGY_REPAIR_WINDOWS.bat`.
- v0.195 scoped-material comparator: `GODOT_REVIEW_SALTO_SHELL_V2_SCOPED_MATERIAL_RECOVERY_WINDOWS.bat`.
- v0.196 mesh-compositor baseline: `GODOT_REVIEW_SALTO_SHELL_V2_MESH_COMPOSITOR_WINDOWS.bat`.

Code rollback is narrow if required: revert the v0.197 additions in `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`, `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`, `package.json`, the v0.197 wrappers/tool listed above, and the v0.197 docs. No selected local art derivative, tracked fallback, metadata file, or historical evidence needs to be deleted for rollback.

Next boundary: continue to v0.198 only if the queued prompt sequence is explicitly active, the repository is clean/synced/pushed, and the remote gate is green.
