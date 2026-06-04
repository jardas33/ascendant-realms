# v0.117 Godot Spike Scope

Status: v0.117 creates the first small Godot desktop benchmark spike and one-click Windows workflow. It is a repository-driven spike only.

## Start State

- Branch: `main`.
- Expected starting commit: `fd2004af1cc80be5929d9435d2f16c5cea896476`.
- Expected message: `Checkpoint v0.116 reviewed architecture direction desktop-engine spike preparation pack and engine-neutral Salto fixture`.
- Baseline status before edits: clean and synchronized with `origin/main`.
- Baseline fixture export and validation: PASS.

## Purpose

This checkpoint tests whether Godot can support an AI-first, editor-optional, repository-driven workflow for the representative Salto slice prepared in v0.116.

It does not make Godot the final engine. It does not begin a full port. It does not delete, replace, or demote the browser prototype.

## Created Project

Project path: `desktop-spikes/godot-salto/`.

The project is intentionally text-first:

- `project.godot` for the Godot project.
- `.tscn` text scenes under `scenes/`.
- `.gd` GDScript scripts under `scripts/` and `tests/`.
- Generated fixture JSON under `data/generated/`.
- No committed `.godot` cache.
- No manual drag-and-drop asset registration requirement.

## Authorized Outputs

Tracked repository outputs:

- Godot project scaffold under `desktop-spikes/godot-salto/`.
- One-click PowerShell and `.bat` scripts.
- Generated deterministic fixture JSON under `desktop-spikes/godot-salto/data/generated/`.
- v0.117 report docs.
- Focused tests for the scaffold.

Ignored local outputs:

- `.tools/godot/`.
- `desktop-spikes/godot-salto/.godot/`.
- `desktop-spikes/godot-salto/builds/*`.
- `desktop-spikes/godot-salto/reports/*`.
- `artifacts/desktop-spikes/godot-salto/latest/`.

## Explicit Non-Goals

- No full game port.
- No final engine choice.
- No browser runtime behavior change.
- No gameplay, balance, AI, pathing, save, stable-ID, reward, map, faction, multiplayer, PvP, or co-op change.
- No generated or imported artwork.
- No Unity, Unreal, or Electron project.
- No system PATH change.
- No administrator requirement.
- No manual Godot editor scene assembly.
- No v0.118 work.

`linked_ward` remains exactly `0.92`.
