# v0.119 Emmanuel Review Guide

v0.119 is a Codex/automation benchmark spike. Emmanuel does not need to assemble scenes in the Godot editor.

## One-Click Path

From the repository root on Windows:

```text
GODOT_RUN_ALL_WINDOWS.bat
```

Optional focused commands:

```text
GODOT_TEST_WINDOWS.bat
GODOT_BENCHMARK_WINDOWS.bat
GODOT_PACKAGE_WINDOWS.bat
```

## What To Review

- Confirm both 2D and 2.5D placeholder modes remain only placeholders.
- Confirm the workload now represents small, medium, and large RTS/RPG pressure.
- Compare whether 2D or 2.5D feels more promising for a modern original top-down RTS/RPG presentation.
- Keep the desired visual ambition in mind: strong faction silhouettes, atmospheric terrain, modern lighting/VFX, readable tactical action, and a central persistent hero.

## What Not To Do

- Do not open the Godot editor for routine scene assembly.
- Do not drag assets into the editor.
- Do not import art.
- Do not choose Godot finally from this spike.
- Do not start a full port or v0.120 without a new explicit goal.

## Evidence To Check

```text
artifacts/desktop-spikes/godot-salto/v0119/scalability-benchmark-2d.json
artifacts/desktop-spikes/godot-salto/v0119/scalability-benchmark-2_5d.json
artifacts/desktop-spikes/godot-salto/v0119/parity-report.json
artifacts/desktop-spikes/godot-salto/v0119/scorecard-update.json
artifacts/desktop-spikes/godot-salto/latest/AscendantRealmsGodotSalto-v0119-windows.zip
```
