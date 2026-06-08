# v0.172 Safe Cleanup Execution Report

Status: `PASS_V0172_SAFE_CLEANUP_EXECUTION`

This checkpoint performs bounded housekeeping only. It generates zero images, adds zero slots, makes no runtime visual changes, preserves all selected local art and metadata, and leaves the browser runtime untouched.

## Cleanup Evidence

| Evidence | Status |
| --- | --- |
| `artifacts/desktop-spikes/godot-salto/v0172/cleanup/before-inventory/salto-experimental-artifact-inventory.json` | `PASS_V0165_EXPERIMENTAL_ARTIFACT_HYGIENE_DRY_RUN` |
| `artifacts/desktop-spikes/godot-salto/v0172/cleanup/before-dry-run/salto-experimental-cleanup-report.json` | `PASS_V0166_EXPERIMENTAL_ARTIFACT_CLEANUP_DRY_RUN` |
| `artifacts/desktop-spikes/godot-salto/v0172/cleanup/safe-only/salto-experimental-cleanup-report.json` | `PASS_V0166_EXPERIMENTAL_ARTIFACT_SAFE_ONLY_CLEANUP` |
| `artifacts/desktop-spikes/godot-salto/v0172/cleanup/post-launcher-safe-only/salto-experimental-cleanup-report.json` | `PASS_V0166_EXPERIMENTAL_ARTIFACT_SAFE_ONLY_CLEANUP` |
| `artifacts/desktop-spikes/godot-salto/v0172/cleanup/after-inventory/salto-experimental-artifact-inventory.json` | `PASS_V0165_EXPERIMENTAL_ARTIFACT_HYGIENE_DRY_RUN` |
| `artifacts/desktop-spikes/godot-salto/v0172/cleanup/after-dry-run/salto-experimental-cleanup-report.json` | `PASS_V0166_EXPERIMENTAL_ARTIFACT_CLEANUP_DRY_RUN` |
| `artifacts/desktop-spikes/godot-salto/v0172/cleanup/retention-final/salto-experimental-artifact-retention-report.json` | `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION` |

## Before And After

| Metric | Before | After |
| --- | ---: | ---: |
| Total files | 4540 | 4568 |
| Total bytes | 1601827996 | 1603456310 |
| Dry-run safe candidates | 61 files / 640663720 bytes | 67 files / 640823942 bytes |
| Archive candidates | 2400 files / 538855077 bytes | 2412 files / 539285057 bytes |
| Manual-review candidates | 592 files / 369206157 bytes | 602 files / 370244269 bytes |
| Selected evidence records | 10 | 10 |

The after inventory is larger because v0.172 launcher validation produced ignored validation logs and refreshed ignored package/build evidence. No tracked cleanup deletion or archive move caused that increase.

## Safe-Only Deletion

Initial safe-only cleanup found no sidecar residue and deleted `0` files.

After launcher validation, Godot regenerated the known sidecar class. The final safe-only cleanup deleted:

- Files: `14`
- Bytes: `5505`
- Class: known Godot-generated comparator `.gd.uid` files and fallback `.png.import` files only.

Final cleanup-scope dry-run found:

- Unknown files: `0`
- Remaining cleanup-scope safe sidecars: `0`
- Remaining cleanup-scope files: tracked required files only.

## Archive

Archive actions executed: `0`.

Archive candidates remain candidates only because v0.172 did not prove they are unreferenced by every current script/doc path. Top retained candidate buckets by dry-run size:

- `artifacts/desktop-spikes/godot-salto/v0168`: 201 files / 59111429 bytes.
- `artifacts/desktop-spikes/godot-salto/v0169`: 201 files / 57061617 bytes.
- `artifacts/desktop-spikes/godot-salto/v0164`: 187 files / 50679836 bytes.
- `artifacts/desktop-spikes/godot-salto/v0170`: 168 files / 45740911 bytes.
- `artifacts/desktop-spikes/godot-salto/v0166`: 142 files / 45633068 bytes.
- `artifacts/desktop-spikes/godot-salto/v0163`: 180 files / 43710740 bytes.

## Manifests

- `artifacts/desktop-spikes/godot-salto/v0172/cleanup/manifests/v0172-cleanup-before-after-manifest.json`
- `artifacts/desktop-spikes/godot-salto/v0172/cleanup/manifests/v0172-cleanup-before-after-manifest.md`
- `artifacts/desktop-spikes/godot-salto/v0172/cleanup/manifests/v0172-archive-manifest.json`
- `artifacts/desktop-spikes/godot-salto/v0172/cleanup/manifests/v0172-archive-manifest.md`
- `artifacts/desktop-spikes/godot-salto/v0172/cleanup/manifests/v0172-deleted-safe-only-manifest.json`
- `artifacts/desktop-spikes/godot-salto/v0172/cleanup/manifests/v0172-deleted-safe-only-manifest.md`
- `artifacts/desktop-spikes/godot-salto/v0172/cleanup/manifests/v0172-cleanup-rollback-instructions.md`

## Preservation

Preserved:

- Worker, Barracks material, Militia, Aster, and Ashen Raider selected derivatives.
- Matching selected metadata records.
- Tracked comparator fallbacks and contracts.
- Current v0.166 through v0.172 evidence.
- Historical evidence and manual-review candidates.
- Unknown files.

No selected asset, metadata file, tracked fallback, tracked doc, current capture, or unknown file was deleted.
