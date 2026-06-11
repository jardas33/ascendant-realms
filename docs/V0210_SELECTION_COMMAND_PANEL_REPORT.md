# v0.210 Selection Command Panel Report

Status: PASS.

## Scope

v0.210 polishes only the isolated Godot Salto UI shell opt-in path. The default procedural launcher, earlier launchers, browser runtime, gameplay, pathing, collisions, objectives, AI, economy, saves, stable IDs and balance remain unchanged.

## Panel Coverage

- Aster: portrait source when hash-validated, name, role, HP, stat pills, ability row, command row, shortcuts, focus styling and disabled Lume explanation.
- Worker: mine assignment, restore/build/site-support context, Worker-specific commands and disabled restore explanation.
- Barracks restoring: restoration progress, train/rally disabled states and explanation.
- Barracks queue: Militia queue, rally, hold and locked Ranger/Lume-tech explanation.
- Militia: squad count, HP summary, attack/hold/move/focus command state.
- Multi-select: common commands plus specialist command filtering for hero and Worker context.

## Portrait Reuse

No image was generated for v0.210. The panel reuses the approved private v0.152 Aster derivative only when the source file, metadata and SHA-256 match:

`b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a`

If the portrait is missing, mismatched or explicitly forced to fallback, the opt-in panel renders a procedural silhouette. The portrait path is inert unless `--salto-selection-command-panel` is present.

## Review Pack

Expected ignored manual review path:

`artifacts/manual-review/v0210-selection-command-panel/`

Required PNGs:

- `01_aster.png`
- `02_tooltips.png`
- `03_worker.png`
- `04_barracks_restoring.png`
- `05_queue.png`
- `06_militia.png`
- `07_multi_select.png`
- `08_portrait_fallback.png`
- `09_contact_sheet.png`

Final absolute review-pack path:

`D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0210-selection-command-panel\`

Visual review notes:

- Aster source portrait is cropped to a bounded head-and-shoulders HUD region so it reads inside the panel without escaping into command buttons.
- Forced fallback renders the procedural portrait silhouette and keeps the same stats, ability and command layout stable.
- Worker, Barracks restoring, Barracks queue, Militia and multi-select states keep command rows and disabled explanations legible in the normal RTS capture.
- The command panel remains an explicit opt-in surface behind `--salto-selection-command-panel`.

## Boundary Notes

- Generated images: zero.
- Downloaded assets: zero.
- New runtime art slots: zero.
- Production UI slot: zero.
- Browser runtime changes: none.
- Default launcher mutation: none.

Validation:

- Capture pack: `PASS_V0210_SELECTION_COMMAND_PANEL_CAPTURE_READY`
- Selection command panel validation: `PASS_V0210_SELECTION_COMMAND_PANEL_VALIDATION_READY`
- Boundary scan: `PASS_V0210_SELECTION_COMMAND_PANEL_BOUNDARY`
- Artifact retention: `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`
