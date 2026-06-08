# v0.166 Safe Artifact Cleanup Execution Report

Status: `PASS_V0166_EXPERIMENTAL_ARTIFACT_SAFE_ONLY_CLEANUP`

v0.166 adds `scripts/cleanupSaltoExperimentalArtifacts.mjs` and `GODOT_CLEANUP_SALTO_EXPERIMENTAL_ARTIFACTS_SAFE_WINDOWS.bat`.

## Rules

- Dry-run is the default.
- Deletion requires explicit `--apply-safe-only`.
- Tracked files are never deleted.
- Selected Worker, Barracks, and Militia sources are never deleted.
- Selected metadata is never deleted.
- Tracked fallbacks are never deleted.
- Current v0.165/v0.166 evidence is never deleted.
- Unknown untracked files in cleanup scope block the run.

## Safe Deletion Class

The only safe deletion class is Godot-generated comparator sidecars already audited by the pre-v0.166 hygiene unblock:

- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/*.gd.uid`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/*.png.import`

The script emits before/after JSON and markdown manifests under `artifacts/desktop-spikes/godot-salto/v0166/artifact-cleanup/`.

## Execution Result

Dry-run and `--apply-safe-only` both passed. The safe-only cleanup deleted exactly 14 Godot-generated sidecars: 9 comparator `.gd.uid` files and 5 fallback `.png.import` files. No tracked file, selected local art, selected derivative, metadata file, tracked fallback, required evidence packet, or unknown file was deleted.
