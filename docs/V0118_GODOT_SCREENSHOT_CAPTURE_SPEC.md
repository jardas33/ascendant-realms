# v0.118 Godot Screenshot Capture Spec

The screenshot capture pass runs the packaged Godot executable with `--capture-review` and writes deterministic PNG evidence under `artifacts/desktop-spikes/godot-salto/v0118/screenshots/`.

## Required Captures

- Home
- 2D default
- 2D hero selected
- 2D Worker selected
- 2D squad box selected
- 2D capture site
- 2D Lume link
- 2D Results transition
- 2.5D default
- 2.5D hero selected
- 2.5D Worker selected
- 2.5D squad box selected
- 2.5D capture site
- 2.5D Lume link
- 2.5D Results transition

Each capture must be 1600x900. `screenshot-manifest.json` records order, mode, action, file path, dimensions, and SHA-256 hash. `contact-sheet.svg` is generated without adding third-party dependencies.

## One-Command Capture

Run:

```powershell
npm run godot:capture:review
```

This command exports/packages if needed, launches the packaged executable, captures the review sequence, writes the manifest, and refreshes the review summary.

## Current Result

```text
Status - PASS_SCREENSHOT_CAPTURE
Capture count - 15 / 15
Dimensions - 1600x900 for every PNG
Manifest - artifacts/desktop-spikes/godot-salto/v0118/screenshot-manifest.json
Contact sheet - artifacts/desktop-spikes/godot-salto/v0118/contact-sheet.svg
```
