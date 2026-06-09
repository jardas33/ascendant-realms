# v0.184 Environment Geometry Boundary And Rollback

Status: `PASS_BOUNDARY`

## Boundaries

v0.184 is visual-only and opt-in-only.

Preserved:

- Default procedural launcher remains unchanged.
- Browser runtime remains untouched.
- Character integrations remain frozen at five selected opt-in slots.
- Ground and road materials remain opt-in only.
- No image generation occurred.
- No runtime-art slot was added.
- No bridge, riverbank, structure, HUD, lighting, animation, or material slot was added.
- Gameplay, pathing, collision, objective, AI, saves, stable IDs, and campaign data were not changed.

New review path only:

- `GODOT_REVIEW_SALTO_ENVIRONMENT_GEOMETRY_CONVERGENCE_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_ENVIRONMENT_GEOMETRY_CONVERGENCE_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_ENVIRONMENT_GEOMETRY_CONVERGENCE_WINDOWS.bat`

## Rollback

To remove v0.184 without affecting earlier opt-in launchers:

1. Remove the three v0.184 batch files.
2. Remove `tools/godot/launchGodotSaltoEnvironmentGeometryConvergenceWindows.ps1`.
3. Remove `tools/godot/reviewGodotSaltoEnvironmentGeometryConvergenceWindows.ps1`.
4. Remove `tools/godot/validateGodotSaltoEnvironmentGeometryConvergenceWindows.ps1`.
5. Remove `tools/godot/captureGodotSaltoEnvironmentGeometryConvergenceWindows.ps1`.
6. Remove `tools/godot/saltoEnvironmentGeometryConvergenceTool.mjs`.
7. Revert only the v0.184 additions in `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`, `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`, and `package.json`.

Do not remove selected art, selected derivatives, metadata, tracked fallbacks, historical evidence, or unknown files.

## Boundary Proof

The v0.184 boundary tool confirmed:

- Default launcher does not contain the v0.184 geometry flag.
- Existing Worker, Barracks, Militia, Aster, Ashen, ground, and ground+road launchers are preserved.
- Browser runtime files are not modified by this path.
- No generated image file appears in the tracked worktree.
- No sixth character slot or third environment-material slot is introduced.

Cleanup proof:

- Dry-run: `artifacts/desktop-spikes/godot-salto/v0184/cleanup-dry-run/salto-experimental-cleanup-report.json`.
- Safe-only cleanup: `artifacts/desktop-spikes/godot-salto/v0184/safe-only-cleanup/salto-experimental-cleanup-report.json`.
- Retention after cleanup: `artifacts/desktop-spikes/godot-salto/v0184/artifact-retention-after-cleanup/salto-experimental-artifact-retention-report.json`.

