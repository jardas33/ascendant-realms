# v0.122 Godot Salto Content Adapter Parity Spike

This automated Godot desktop spike uses the engine-neutral Salto fixture and generated portable JSON to prove a bounded content-subset adapter, stable-ID validation, read-only save-fixture posture, and fixed-seed rules-parity harness. It remains a placeholder-only workflow spike, not a port, not a content migration, and not a final engine choice.

## Boundaries

- No browser runtime deletion or replacement.
- No browser gameplay, balance, reward, save, stable-ID, localStorage, art-import, runtime asset path, multiplayer, PvP, co-op, or engine-choice change.
- Godot-only workload logic is bounded to deterministic S/M/L benchmarking, procedural placeholder visual evidence, and v0.122 adapter/parity evidence.
- `linked_ward` must remain exactly `0.92`.
- Save fixtures are read-only translation evidence.
- Stable IDs are consumed from generated fixture data; unknown, duplicate, and missing IDs must be rejected.
- Visuals are placeholders only: one 2D illustrated-placeholder mode and one modest 2.5D orthographic-placeholder mode.

## One-Click Workflow

From the repository root on Windows:

```text
GODOT_DOCTOR_WINDOWS.bat
GODOT_BOOTSTRAP_WINDOWS.bat
GODOT_RUN_ALL_WINDOWS.bat
```

The bootstrap wrapper is instruction-only by default. It prints exact official Godot 4.6.3 standard x86_64 editor and export-template URLs and does not download unless the PowerShell script is run with `-DownloadOfficial`.

Generated local evidence is written under `artifacts/desktop-spikes/godot-salto/latest/` and the v0.122 folder at `artifacts/desktop-spikes/godot-salto/v0122/`. If Godot or export templates are missing, runtime benchmark/export/package reports must say `BLOCKED_PENDING_LOCAL_GODOT_SETUP`.

## Scripted Surfaces

- `project.godot` and `.tscn` files are text-editable.
- `data/generated/` is populated from `artifacts/desktop-spike-fixture/latest/`.
- `scripts/adapters/*.gd` define text-owned content registry, stable-ID, read-only save, unit, building, site, Lume, and Results adapters.
- `scripts/fixture_importer.gd` validates selected stable IDs, unknown/missing/duplicate rejection, read-only save posture, and `linked_ward` parity.
- `scripts/salto_spike_workload_runtime.gd` defines the deterministic S/M/L workload, navigation metrics, bounded AI pressure, capture-site state, Lume state, benchmark reports, and the v0.122 fixed-seed parity harness for both placeholder modes.
- `tests/` contains Godot headless runner scripts for local runtime validation.
- `tools/godot/*.ps1` and root `.bat` wrappers provide simple commands for Emmanuel and Codex.
