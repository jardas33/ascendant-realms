# v0.185 Environment Shell Boundary And Rollback

Status: `PASS_BOUNDARY`

## Boundaries

v0.185 is visual-only, opt-in-only, and review-only.

Preserved:

- Default procedural launcher remains unchanged.
- All prior opt-in launchers remain available.
- Browser runtime remains untouched.
- Character-slot integration remains frozen at five selected opt-in slots.
- Ground and road materials remain opt-in only.
- No image generation occurred.
- No runtime-art slot, character slot, environment-material slot, bridge material slot, riverbank material slot, structure material slot, HUD slot, lighting slot, or animation slot was added.
- Gameplay, pathing, collisions, objectives, AI, saves, stable IDs, campaign data, selected art, metadata, tracked fallbacks, and required evidence were not changed.

New review path only:

- `GODOT_REVIEW_SALTO_ENVIRONMENT_SHELL_LIVE_QA_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_ENVIRONMENT_SHELL_LIVE_QA_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_ENVIRONMENT_SHELL_LIVE_QA_WINDOWS.bat`

## Rollback

To remove v0.185 without affecting earlier opt-in launchers:

1. Remove the three v0.185 batch files.
2. Remove `tools/godot/launchGodotSaltoEnvironmentShellLiveQaWindows.ps1`.
3. Remove `tools/godot/reviewGodotSaltoEnvironmentShellLiveQaWindows.ps1`.
4. Remove `tools/godot/validateGodotSaltoEnvironmentShellLiveQaWindows.ps1`.
5. Remove `tools/godot/captureGodotSaltoEnvironmentShellLiveQaWindows.ps1`.
6. Remove `tools/godot/saltoEnvironmentShellLiveQaTool.mjs`.
7. Revert only the v0.185 additions in `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`, `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`, and `package.json`.

Do not remove selected art, selected derivatives, metadata, tracked fallbacks, historical evidence, latest evidence, or unknown files.

## Boundary Proof

The v0.185 boundary tool confirmed:

- `defaultLauncherProcedural: true`
- `priorLaunchersPreserved: true`
- `aiImagesGenerated: 0`
- `characterSlotsAdded: 0`
- `environmentMaterialSlotsAdded: 0`
- `browserRuntimeChanged: false`
- `gameplayPathingChanged: false`
- `collisionGeometryChanged: false`
- `objectivesChanged: false`
- `aiChanged: false`
- `saveWritesAllowed: false`
- `stableIdsChanged: false`

Cleanup proof:

- Dry-run: `artifacts/desktop-spikes/godot-salto/v0185/final-cleanup-dry-run/salto-experimental-cleanup-report.json`.
- Safe-only cleanup: `artifacts/desktop-spikes/godot-salto/v0185/final-cleanup-safe-only/salto-experimental-cleanup-report.json`.
- Retention: `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`.

