# v0.117 Emmanuel One-Click Guide

This guide is for the v0.117 Godot Salto spike only.

## Quickest Path

From the repository root:

```bat
GODOT_RUN_ALL_WINDOWS.bat
```

That one script runs doctor, fixture export, fixture validation, scene generation, Godot validation, Godot tests, both benchmark modes, Windows export, Windows package, and scorecard generation when local Godot and export templates are available.

## If Godot Is Missing

Run:

```bat
GODOT_DOCTOR_WINDOWS.bat
GODOT_BOOTSTRAP_WINDOWS.bat
```

The bootstrap script is instruction-only by default. It tells you the exact official Godot 4.6.3 standard x86_64 setup step. It does not require administrator rights and does not change PATH.

If you explicitly approve the official download on this machine, the scripted form is:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot/bootstrapGodotWindows.ps1 -DownloadOfficial -InstallExportTemplates
```

## Useful One-Click Scripts

```bat
GODOT_DOCTOR_WINDOWS.bat
GODOT_VALIDATE_WINDOWS.bat
GODOT_TEST_WINDOWS.bat
GODOT_BENCHMARK_WINDOWS.bat
GODOT_EXPORT_WINDOWS.bat
GODOT_PACKAGE_WINDOWS.bat
GODOT_RUN_ALL_WINDOWS.bat
```

## Packaged Build

After package generation, the ignored ZIP lives at:

```text
artifacts/desktop-spikes/godot-salto/latest/AscendantRealmsGodotSalto-v0117-windows.zip
```

The ignored executable lives at:

```text
desktop-spikes/godot-salto/builds/AscendantRealmsGodotSalto.exe
```

## What To Review

- Does the 2D placeholder mode feel readable for a tactical top-down RTS/RPG?
- Does the 2.5D orthographic placeholder mode better suggest the desired 2026 lighting, terrain, and VFX ambition?
- Does the workflow feel practical if Codex handles routine setup, validation, build, export, and package work?

## What Not To Do

- Do not assemble scenes manually in the Godot editor for routine v0.117 work.
- Do not drag assets into the editor.
- Do not import final art.
- Do not treat this as a full port.
- Do not treat Godot as finally chosen.
- Do not start v0.118 from this guide.
