# v0.194 Shell V2 Topology Boundary And Rollback

Status: `PASS_V0194_SHELL_V2_TOPOLOGY_BOUNDARY_ROLLBACK`

Date: 2026-06-09

## Boundary

Authorized scope was limited to visual-only shell-v2 topology repair:

- Consolidate the terrain base.
- Remove detached rectangular islands.
- Connect the road network.
- Remove floating diagonal road fragments.
- Repair road-to-bridge transition.
- Align river, banks, and bridge.

Forbidden scope remained untouched:

- No generated images.
- No new art slots.
- No wet-granite bridge-riverbank integration.
- No default launcher change.
- No legacy-shell removal.
- No browser runtime wiring.
- No gameplay, pathing, collision, objective, AI, save, stable-ID, balance, or production-manifest mutation.

## Added Review Path

- `GODOT_REVIEW_SALTO_SHELL_V2_TOPOLOGY_REPAIR_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_SHELL_V2_TOPOLOGY_REPAIR_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_SHELL_V2_TOPOLOGY_REPAIR_WINDOWS.bat`
- `tools/godot/launchGodotSaltoShellV2TopologyRepairWindows.ps1`
- `tools/godot/reviewGodotSaltoShellV2TopologyRepairWindows.ps1`
- `tools/godot/validateGodotSaltoShellV2TopologyRepairWindows.ps1`
- `tools/godot/captureGodotSaltoShellV2TopologyRepairWindows.ps1`
- `tools/godot/saltoShellV2TopologyRepairTool.mjs`

The path remains explicit opt-in only through `--salto-presentation-shell-v2` plus the v0.194 topology-repair review wrapper. Default procedural launchers and prior opt-in launchers remain available.

## Boundary Evidence

- `artifacts/desktop-spikes/godot-salto/v0194/boundary/shell-v2-topology-repair-boundary-report.json`
- `artifacts/desktop-spikes/godot-salto/v0194/artifact-retention/retention-validation-report.json`
- `artifacts/desktop-spikes/godot-salto/v0194/validation/shell-v2-topology-repair-validation-report.json`

Confirmed boundary facts:

- `wetGraniteIntegrated`: `false`
- `defaultLauncherChanged`: `false`
- `browserRuntimeChanged`: `false`
- `gameplayCollisionPathingNodesModified`: `0`
- `legacyShellPreserved`: `true`
- `detachedTerrainIslandCount`: `0`
- `floatingDiagonalRoadFragmentCount`: `0`

## Rollback

To stop using v0.194 topology repair for review, launch any older preserved route:

- Default procedural player slice: existing default launcher.
- Legacy riverbank/bridge approach: `GODOT_REVIEW_SALTO_RIVERBANK_BRIDGE_APPROACH_WINDOWS.bat`.
- Original shell-v2 comparator: `GODOT_REVIEW_SALTO_PRESENTATION_SHELL_V2_WINDOWS.bat`.

Code rollback is narrow if required: revert the v0.194 additions in `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`, `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`, `package.json`, the v0.194 wrappers/tool listed above, and the v0.194 docs. No art derivative or tracked fallback needs to be deleted for rollback.

Next boundary: stop for human review. Do not begin v0.195.
