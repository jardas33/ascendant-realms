# v0.212 Implementation Report

Status: PASS.

## Changes

- Added `--salto-minimap-tooltip-accessibility` as an explicit v0.212 opt-in layered on the v0.211 production/objective/event shell.
- Added v0.212-only UI scaling for supported review capture resolutions.
- Added an enhanced minimap with playable bounds, roads, river, bridge, site, unit, hostile, camera and utility affordance markers.
- Added structured tooltips with title, body, cost, availability reason and shortcut fields.
- Added severity-aware alert rendering for informational, warning and hostile states.
- Added v0.212 capture and validation wrappers plus review-pack/boundary tooling.

## Commands

- `npm run godot:capture:salto-minimap-tooltip-accessibility`
- `npm run godot:validate:salto-minimap-tooltip-accessibility`
- `npm run godot:test`
- `npm run godot:export:windows`
- `npm run godot:package:windows`
- `npm run validate:runtime-art-slots`
- `node scripts/cleanupSaltoExperimentalArtifacts.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0212/cleanup-dry-run`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run build`
- `npm test`
- `git diff --check`

## Acceptance Tracking

- Default launcher remains procedural.
- Prior launchers and v0.211 production/objective/event shell remain available without the v0.212 flag.
- No new image generation or downloaded assets.
- No new runtime art slot.
- No gameplay, pathing, collision or stable-ID mutation.
- Validation and visual review passed.

## Artifacts

Manual review pack:

`D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0212-minimap-tooltip-accessibility\`

Required PNGs produced:

- `01_minimap.png`
- `02_viewport_marker.png`
- `03_tooltips.png`
- `04_alerts.png`
- `05_resolution_1920x1080.png`
- `06_resolution_1600x900.png`
- `07_resolution_1366x768.png`
- `08_contact_sheet.png`

## Notes

The implementation is constrained to the v0.212 opt-in shell flag and reuses existing Salto live UI shell drawing helpers. The capture path records per-step viewport dimensions so the 1920x1080, 1600x900 and 1366x768 layouts are validated from the packaged Windows Godot review path without enabling any new production art slot or changing the default launcher.
