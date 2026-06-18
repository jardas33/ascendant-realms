# v0.225 Reboot Artifact Hygiene Report

Date: 2026-06-17

Safe-only cleanup deleted 22 positively identified generated Godot sidecars:

- 13 comparator `.gd.uid` files.
- 9 fallback `.png.import` files.

All tracked sources, selected source images, metadata, tracked fallbacks and retained evidence were preserved. Unknown cleanup-scope files before cleanup: 0. Safe candidates after cleanup: 0. The final dry-run reported 0 safe candidates and 0 unknown files.

The exact deleted paths, byte counts and SHA-256 values are retained in:

`artifacts/desktop-spikes/godot-salto/v0225/artifact-cleanup-final-applied/salto-experimental-cleanup-report.json`
