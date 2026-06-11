# v0.212 Minimap Tooltip Accessibility Report

Status: PASS.

## Scope

v0.212 hardens only the isolated Godot Salto UI shell opt-in path behind `--salto-selection-command-panel --salto-production-objectives-log --salto-minimap-tooltip-accessibility`. The default procedural launcher, prior launchers, browser runtime, gameplay, pathing, collisions, objectives, AI, economy, saves, stable IDs and balance remain unchanged.

## Review Pack

Ignored manual review path:

`D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0212-minimap-tooltip-accessibility\`

Required PNGs:

- `01_minimap.png`
- `02_viewport_marker.png`
- `03_tooltips.png`
- `04_alerts.png`
- `05_resolution_1920x1080.png`
- `06_resolution_1600x900.png`
- `07_resolution_1366x768.png`
- `08_contact_sheet.png`

## Boundary Notes

- Generated images: zero.
- Downloaded assets: zero.
- New runtime art slots: zero.
- Browser runtime changes: none.
- Default launcher mutation: none.
- Gameplay/pathing/collision/stable-ID changes: none.

## Visual QA Result

- Minimap playable bounds, camera viewport outline, road/bridge/river traces, unit markers, hostile marker and utility affordances remain readable in the normal review frame.
- Tooltip panel now exposes a title, concise explanation, cost, availability reason and shortcut, with viewport-safe placement across the supported review resolutions.
- Alert treatment distinguishes info, warning and hostile states with restrained emphasis; hostile emphasis does not obscure the tactical field.
- Resolution checks passed at 1920x1080, 1600x900 and 1366x768 with the UI shell scaled and centered inside the viewport.
- Contact-sheet review did not show text clipping, detached UI fragments, marker occlusion or layout overflow.

## Validation Evidence

- `npm run godot:test`
- `npm run godot:export:windows`
- `npm run godot:package:windows`
- `npm run godot:capture:salto-minimap-tooltip-accessibility`
- `npm run godot:validate:salto-minimap-tooltip-accessibility`
- `npm run validate:runtime-art-slots`
- `node scripts/cleanupSaltoExperimentalArtifacts.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0212/cleanup-dry-run`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run build`
- `npm test`
- `git diff --check`

The v0.212 validator reported `PASS_V0212_MINIMAP_TOOLTIP_ACCESSIBILITY_VALIDATION`, `PASS_V0212_MINIMAP_TOOLTIP_ACCESSIBILITY_BOUNDARY`, `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION` and `PASS_V0212_MINIMAP_TOOLTIP_ACCESSIBILITY_VALIDATION_READY`.
