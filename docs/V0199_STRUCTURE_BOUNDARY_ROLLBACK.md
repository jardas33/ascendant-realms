# v0.199 Structure Hierarchy Boundary And Rollback

Status: `PASS_V0199_STRUCTURE_BOUNDARY_ROLLBACK`

Date: 2026-06-10

## Boundary

Authorized scope was limited to visual-only procedural structure hierarchy hardening inside the isolated Salto shell-v2 mesh-compositor review path:

- Preserve v0.198 wet-granite bridge-riverbank material binding.
- Add explicit v0.199 structure-hierarchy launcher, review, validate, capture, and benchmark tooling.
- Add procedural-only structure massing for the command hall, mine, Barracks restoration, restored Barracks, and compact site structures.
- Export the compact v0.199 manual-review PNG pack.
- Benchmark the structure-hardened shell against the v0.198 wet-granite mesh-compositor comparator.

Forbidden scope remained untouched:

- No generated images.
- No new imported art slots.
- No character-slot expansion.
- No environment-material slot expansion.
- No browser runtime wiring.
- No default launcher change.
- No normal Salto player-slice default-art enablement.
- No gameplay, pathing, collision, objective, AI, save, stable-ID, balance, production-manifest, or prior-launcher mutation.
- No broad wet-granite binding to terrain, water, roads, long banks, structures, minimap, HUD, legacy shell, or browser runtime.
- No v0.200 work inside this checkpoint.

## Added Review Path

- `GODOT_REVIEW_SALTO_SHELL_V2_STRUCTURE_HIERARCHY_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_SHELL_V2_STRUCTURE_HIERARCHY_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_SHELL_V2_STRUCTURE_HIERARCHY_WINDOWS.bat`
- `GODOT_BENCHMARK_SALTO_SHELL_V2_STRUCTURE_HIERARCHY_WINDOWS.bat`
- `tools/godot/launchGodotSaltoShellV2StructureHierarchyWindows.ps1`
- `tools/godot/reviewGodotSaltoShellV2StructureHierarchyWindows.ps1`
- `tools/godot/validateGodotSaltoShellV2StructureHierarchyWindows.ps1`
- `tools/godot/captureGodotSaltoShellV2StructureHierarchyWindows.ps1`
- `tools/godot/runGodotSaltoShellV2StructureHierarchyBenchmarkWindows.ps1`
- `tools/godot/saltoShellV2StructureHierarchyTool.mjs`

The path remains explicit opt-in only through the v0.193 presentation shell posture, `--salto-shell-v2-mesh-compositor`, `--bridge-riverbank-material-opt-in`, and `--salto-shell-v2-structure-hierarchy`. Default procedural launchers and all prior opt-in launchers remain available.

## Boundary Evidence

- `artifacts/desktop-spikes/godot-salto/v0199/boundary/structure-hierarchy-boundary-scan.json`
- `artifacts/desktop-spikes/godot-salto/v0199/validation/structure-hierarchy-validation-report.json`
- `artifacts/desktop-spikes/godot-salto/v0199/capture/structure-hierarchy-capture-report.json`
- `artifacts/desktop-spikes/godot-salto/v0199/artifact-retention-post-cleanup/salto-experimental-artifact-retention-report.json`

Confirmed boundary facts:

- Generated images: `false`
- New character art slots: `0`
- New environment material slots: `0`
- New imported textures: `0`
- Structure hierarchy enabled only in the explicit v0.199 review path: `true`
- Default launcher changed: `false`
- Browser runtime changed: `false`
- Gameplay/pathing/collision files changed: `false`
- Legacy shell comparator preserved: `true`
- v0.198 wet-granite mesh comparator preserved: `true`

The boundary scanner allows only the required v0.199 manual-review PNG pack under `artifacts/manual-review/v0199-structure-hierarchy/`. Other image changes remain blocked.

## Rollback

To stop using the v0.199 structure-hierarchy path for review, launch any older preserved route:

- Default procedural player slice: existing default launcher.
- Legacy riverbank/bridge approach: `GODOT_REVIEW_SALTO_RIVERBANK_BRIDGE_APPROACH_WINDOWS.bat`.
- Original shell-v2 comparator: `GODOT_REVIEW_SALTO_PRESENTATION_SHELL_V2_WINDOWS.bat`.
- v0.194 topology-repair comparator: `GODOT_REVIEW_SALTO_SHELL_V2_TOPOLOGY_REPAIR_WINDOWS.bat`.
- v0.195 scoped-material comparator: `GODOT_REVIEW_SALTO_SHELL_V2_SCOPED_MATERIAL_RECOVERY_WINDOWS.bat`.
- v0.196 mesh-compositor baseline: `GODOT_REVIEW_SALTO_SHELL_V2_MESH_COMPOSITOR_WINDOWS.bat`.
- v0.197 mesh-compositor QA path: `GODOT_REVIEW_SALTO_SHELL_V2_MESH_QA_WINDOWS.bat`.
- v0.198 wet-granite mesh path: `GODOT_REVIEW_SALTO_SHELL_V2_MESH_WET_GRANITE_WINDOWS.bat`.

Code rollback is narrow if required: revert the v0.199 additions in `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`, `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`, `package.json`, the v0.199 wrappers/tool listed above, and the v0.199 docs. No selected local art derivative, tracked fallback, metadata file, manual-review evidence, or historical evidence needs to be deleted for rollback.

Next boundary: continue to v0.200 only if the queued prompt sequence is explicitly active, the repository is clean/synced/pushed, and the remote gate is green.
