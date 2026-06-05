# v0.129 Implementation Report

v0.129 implements the bounded microloop through existing repository-driven Godot surfaces:

- `salto_spike_workload_runtime.gd` owns deterministic microloop state and actions.
- `salto_spike_scene_2d.gd` and `salto_spike_scene_3d.gd` expose the same runtime actions for both placeholder modes.
- `salto_spike_root.gd` drives v0.129 validation and screenshot capture actions from scripts.
- `godotSpikeTool.mjs` writes v0.129 validation, data-adapter, performance-smoke, screenshot-manifest, hash, contact-sheet, and microloop reports.
- `captureGodotPlayerSliceWindows.ps1` and `validateGodotPlayerSlice.ps1` target the v0.129 artifact folder.

No browser runtime, save model, stable-ID set, runtime art path, or Godot editor-created scene assembly changed.

Closeout command set remains the established matrix: player-slice validation, player-slice capture, Godot all, fresh-checkout validation, Windows package, full tests, whitespace check, commit, push, and remote Actions confirmation.
