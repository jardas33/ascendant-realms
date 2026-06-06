# v0.137 Blockout Quality Gate

Classification: `BLOCKOUT_QUALITY_GREEN`
Gate: `BLOCKOUT_QUALITY_GREEN`

## Gate States

`BLOCKOUT_QUALITY_GREEN` means the packaged Godot player-facing slice proves the procedural composition, terrain readability, geometry-led silhouettes, restrained lighting/VFX, camera/screen use, screenshot review pack, and bounded performance smoke without forbidden proof paths.

`BLOCKOUT_QUALITY_AMBER` means the slice remains completable, but one or more composition, silhouette, VFX, camera, screenshot, or performance checks are incomplete, unclear, or not fully proven.

`BLOCKOUT_QUALITY_RED` means the normal packaged path fails, soft-locks, requires routine editor work, requires private/debug proof, hides critical battlefield information, imports/generated art, changes saves/stable IDs/browser runtime, or starts work outside v0.137.

## Green Requirements

- v0.136 gate is accepted from either `Classification:` or `Gate:` and is `USABILITY_PRESENTATION_GREEN`.
- `GODOT_BLOCKOUT_QUALITY_WINDOWS.bat` completes.
- `headed-blockout-quality-smoke.json` reports `PASS_V0137_HEADED_BLOCKOUT_QUALITY_SMOKE`.
- `composition-readability-report.json` reports `PASS_V0137_COMPOSITION_READABILITY`.
- `silhouette-readability-report.json` reports `PASS_V0137_SILHOUETTE_READABILITY`.
- `lighting-vfx-report.json` reports `PASS_V0137_LIGHTING_VFX`.
- `camera-screen-use-report.json` reports `PASS_V0137_CAMERA_SCREEN_USE`.
- `performance-smoke.json` reports `PASS_V0137_PERFORMANCE_SMOKE` and marks screenshot capture excluded from measured windows.
- `screenshot-manifest.json` reports `PASS_V0137_SCREENSHOT_MANIFEST` with title backdrop, battlefield default, mine, Barracks, friendly staging, Ashen approach, combat peak, Lume, minimap, Results, zoomed out, and zoomed in captures.
- `screenshot-hashes.json` reports `PASS_V0137_SCREENSHOT_HASHES`.
- `blockout-quality-validation.json` reports `PASS_V0137_BLOCKOUT_QUALITY_VALIDATION`.

No private harness shortcut, debug shortcut, state injection, fixture-only helper proof, screenshot-only proof, routine Godot-editor work, save write, stable-ID change, browser-runtime change, generated/imported art, runtime art integration, final engine choice, full port, or v0.138 work is allowed. `linked_ward` remains exactly `0.92`.

