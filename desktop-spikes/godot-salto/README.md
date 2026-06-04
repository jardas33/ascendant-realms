# v0.119 Godot Salto Representative RTS Load Spike

This automated Godot desktop benchmark spike uses the engine-neutral Salto fixture to exercise representative RTS/RPG load tiers, placeholder navigation, bounded AI pressure, capture-site state, Lume state, and Results readiness. It remains a placeholder-only workflow spike, not a port and not a final engine choice.

## Boundaries

- No browser runtime deletion or replacement.
- No browser gameplay, balance, reward, save, stable-ID, localStorage, art-import, runtime asset path, multiplayer, PvP, co-op, or engine-choice change.
- Godot-only workload logic is bounded to deterministic S/M/L benchmarking and parity evidence.
- `linked_ward` must remain exactly `0.92`.
- Save fixtures are read-only translation evidence.
- Visuals are placeholders only: one 2D illustrated-placeholder mode and one modest 2.5D orthographic-placeholder mode.

## One-Click Workflow

From the repository root on Windows:

```text
GODOT_DOCTOR_WINDOWS.bat
GODOT_BOOTSTRAP_WINDOWS.bat
GODOT_RUN_ALL_WINDOWS.bat
```

The bootstrap wrapper is instruction-only by default. It prints exact official Godot 4.6.3 standard x86_64 editor and export-template URLs and does not download unless the PowerShell script is run with `-DownloadOfficial`.

Generated local evidence is written under `artifacts/desktop-spikes/godot-salto/latest/` and the v0.119 folder at `artifacts/desktop-spikes/godot-salto/v0119/`. If Godot or export templates are missing, runtime benchmark/export/package reports must say `BLOCKED_PENDING_LOCAL_GODOT_SETUP`.

## Scripted Surfaces

- `project.godot` and `.tscn` files are text-editable.
- `data/generated/` is populated from `artifacts/desktop-spike-fixture/latest/`.
- `scripts/fixture_importer.gd` validates selected stable IDs, unknown-ID rejection, read-only save posture, and `linked_ward` parity.
- `scripts/salto_spike_workload_runtime.gd` defines the deterministic S/M/L workload, navigation metrics, bounded AI pressure, capture-site state, Lume state, and benchmark reports for both placeholder modes.
- `tests/` contains Godot headless runner scripts for local runtime validation.
- `tools/godot/*.ps1` and root `.bat` wrappers provide simple commands for Emmanuel and Codex.
