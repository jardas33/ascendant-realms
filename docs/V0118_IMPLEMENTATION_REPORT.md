# v0.118 Implementation Report

v0.118 adds a packaged-build headed smoke path, automated screenshot capture, a headed benchmark path, package validation evidence, and a one-click Emmanuel review guide for the existing Godot Salto workflow spike.

## Implemented

- Added private in-build review harness controls and scripted review steps.
- Added `--review-smoke`, `--capture-review`, and `--headed-benchmark` packaged executable flags.
- Set the Godot spike viewport to 1600x900.
- Added visible 2D and 2.5D state changes for selection, commands, camera movement, site capture, Lume focus, pause, and Results.
- Added root launchers: `GODOT_LAUNCH_REVIEW_WINDOWS.bat`, `GODOT_HEADED_SMOKE_WINDOWS.bat`, and `GODOT_CAPTURE_REVIEW_WINDOWS.bat`.
- Added npm scripts: `godot:launch:review`, `godot:headed:smoke`, and `godot:capture:review`.
- Added v0.118 artifact generation for headed smoke, headed benchmarks, screenshot manifest, package validation, review summary, README, and SVG contact sheet.
- Advanced the desktop-spike boundary from blocking v0.118 docs to blocking v0.119 docs.

## Boundaries Preserved

- No full port.
- No final engine choice.
- No Unity, Unreal, Electron, or third-party asset path.
- No runtime art import.
- No save migration or save writes.
- No routine Godot editor dependency.
- No manual drag-and-drop asset registration.

## Verification

Closeout verification:

- `npm test` - PASS.
- `npm run build` - PASS with the known Phaser/vendor chunk-size warning.
- `npm run validate:content` - PASS.
- `npm run validate:art-intake` - PASS.
- `npm run export:desktop-spike-fixture` - PASS.
- `npm run validate:desktop-spike-fixture` - PASS.
- `npm run godot:all` - PASS.
- `npm run godot:headed:smoke` - PASS.
- `npm run godot:capture:review` - PASS.
- `git diff --check` - PASS.

## Generated Evidence

```text
artifacts/desktop-spikes/godot-salto/v0118/headed-smoke.json
artifacts/desktop-spikes/godot-salto/v0118/headed-benchmark-2d.json
artifacts/desktop-spikes/godot-salto/v0118/headed-benchmark-2_5d.json
artifacts/desktop-spikes/godot-salto/v0118/screenshot-manifest.json
artifacts/desktop-spikes/godot-salto/v0118/package-validation.json
artifacts/desktop-spikes/godot-salto/v0118/review-summary.md
artifacts/desktop-spikes/godot-salto/v0118/contact-sheet.svg
```

Final measured status is held in ignored v0.118 artifacts and the pushed checkpoint commit.
