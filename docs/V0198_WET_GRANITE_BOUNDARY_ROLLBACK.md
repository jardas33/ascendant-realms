# v0.198 Wet-Granite Mesh Boundary And Rollback

Status: `PASS_V0198_WET_GRANITE_BOUNDARY_ROLLBACK`

Date: 2026-06-10

## Boundary

Authorized scope was limited to adding one opt-in bridge-riverbank material slot to the isolated Salto shell-v2 mesh-compositor review path:

- Read the selected v0.189 wet-granite derivative and v0.190 readiness evidence.
- Add explicit loader flags, exact SHA/dimension validation, one-time load/reuse, scoped binding, UV/filter/mipmap handling, and procedural fallback.
- Bind only to mesh-compositor bridge abutments, bridge landing aprons, and riverbank retaining-edge visual surfaces.
- Export the compact v0.198 manual-review PNG pack.
- Benchmark the wet-granite opt-in against the procedural mesh bridge/bank comparator.

Forbidden scope remained untouched:

- No generated images.
- No character art slots.
- No second bridge-riverbank material slot.
- No binding to terrain, roads, water, structures, minimap, HUD, legacy shell, browser runtime, default launcher, or normal gameplay systems.
- No default launcher change.
- No browser runtime wiring.
- No gameplay, pathing, collision, objective, AI, save, stable-ID, balance, production-manifest, or prior-launcher mutation.
- No v0.199 work inside this checkpoint.

## Added Review Path

- `GODOT_REVIEW_SALTO_SHELL_V2_MESH_WET_GRANITE_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_SHELL_V2_MESH_WET_GRANITE_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_SHELL_V2_MESH_WET_GRANITE_WINDOWS.bat`
- `GODOT_BENCHMARK_SALTO_SHELL_V2_MESH_WET_GRANITE_WINDOWS.bat`
- `tools/godot/launchGodotSaltoShellV2MeshWetGraniteWindows.ps1`
- `tools/godot/reviewGodotSaltoShellV2MeshWetGraniteWindows.ps1`
- `tools/godot/validateGodotSaltoShellV2MeshWetGraniteWindows.ps1`
- `tools/godot/captureGodotSaltoShellV2MeshWetGraniteWindows.ps1`
- `tools/godot/runGodotSaltoShellV2MeshWetGraniteBenchmarkWindows.ps1`
- `tools/godot/saltoShellV2MeshWetGraniteTool.mjs`

The path remains explicit opt-in only through the v0.193 presentation shell posture, `--salto-shell-v2-mesh-compositor`, and `--bridge-riverbank-material-opt-in`. Default procedural launchers and all prior opt-in launchers remain available.

## Boundary Evidence

- `artifacts/desktop-spikes/godot-salto/v0198/boundary/wet-granite-mesh-opt-in-boundary-scan.json`
- `artifacts/desktop-spikes/godot-salto/v0198/validation/wet-granite-mesh-opt-in-validation-report.json`
- `artifacts/desktop-spikes/godot-salto/v0198/capture/wet-granite-mesh-opt-in-capture-report.json`
- `artifacts/desktop-spikes/godot-salto/v0198/artifact-retention-post-cleanup/salto-experimental-artifact-retention-report.json`

Confirmed boundary facts:

- Generated images: `false`
- New character art slots: `0`
- New environment material slot: exactly `1`
- Wet-granite applied surface count in opt-in scenario: `6`
- Missing-source fallback: `PASS_PLAYER_SLICE_VALIDATION`
- Hash-mismatch fallback: `PASS_PLAYER_SLICE_VALIDATION`
- Default launcher changed: `false`
- Browser runtime changed: `false`
- Gameplay/pathing/collision files changed: `false`
- Legacy shell comparator preserved: `true`
- v0.197 mesh QA comparator preserved: `true`

The boundary scanner allows only the required v0.198 manual-review PNG pack under `artifacts/manual-review/v0198-wet-granite-mesh/`. Other image changes remain blocked.

## Rollback

To stop using the v0.198 wet-granite mesh opt-in path for review, launch any older preserved route:

- Default procedural player slice: existing default launcher.
- Legacy riverbank/bridge approach: `GODOT_REVIEW_SALTO_RIVERBANK_BRIDGE_APPROACH_WINDOWS.bat`.
- Original shell-v2 comparator: `GODOT_REVIEW_SALTO_PRESENTATION_SHELL_V2_WINDOWS.bat`.
- v0.194 topology-repair comparator: `GODOT_REVIEW_SALTO_SHELL_V2_TOPOLOGY_REPAIR_WINDOWS.bat`.
- v0.195 scoped-material comparator: `GODOT_REVIEW_SALTO_SHELL_V2_SCOPED_MATERIAL_RECOVERY_WINDOWS.bat`.
- v0.196 mesh-compositor baseline: `GODOT_REVIEW_SALTO_SHELL_V2_MESH_COMPOSITOR_WINDOWS.bat`.
- v0.197 mesh-compositor QA path: `GODOT_REVIEW_SALTO_SHELL_V2_MESH_QA_WINDOWS.bat`.

Code rollback is narrow if required: revert the v0.198 additions in `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`, `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`, `package.json`, the v0.198 wrappers/tool listed above, and the v0.198 docs. No selected local art derivative, tracked fallback, metadata file, manual-review evidence, or historical evidence needs to be deleted for rollback.

Next boundary: continue to v0.199 only if the queued prompt sequence is explicitly active, the repository is clean/synced/pushed, and the remote gate is green.
