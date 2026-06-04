# v0.121 Godot Visual Capture Report

Status: `PASS_GODOT_PROCEDURAL_VISUAL_CAPTURE`.

The v0.121 capture workflow launches the packaged Godot spike executable and writes ignored artifacts under:

`artifacts/desktop-spikes/godot-salto/v0121/`

Required capture coverage:

- 1600x900 and 1920x1080.
- 2D control default.
- 2.5D clean readability default.
- 2.5D atmospheric balanced.
- 2.5D VFX stress private.
- Selected hero, selected Worker, squad, buildings/landmarks, capture site, stable Lume line, Lume transition pulse, and Results.

Verified capture result:

- Capture count: 32/32 required screenshots.
- Viewports: 1600x900 and 1920x1080.
- Presets: `2D_CONTROL`, `CLEAN_READABILITY`, `ATMOSPHERIC_BALANCED`, and private `VFX_STRESS_PRIVATE`.

Generated outputs:

- `screenshot-runtime-manifest.json`
- `screenshot-manifest.json`
- `contact-sheet.svg`
- `contact-sheet-1600x900.svg`
- `contact-sheet-1920x1080.svg`
- `visual-capture-summary.md`

This report is not a final art-quality certification.
