# v0.128 Implementation Report

v0.128 adds a bounded player-facing HUD, minimap, objective-feedback, and micro-onboarding pass for the existing Godot Salto review slice.

## Implemented

- Added a compact procedural battle HUD with resource row, selected-entity card, hero/Worker/squad context, command row, current objective strip, pause affordance, and More Details disclosure.
- Added a denser authored procedural minimap with terrain outline, road, water, friendly, hostile, hero, objective, quarry, shrine, mine, Lume endpoint/link, and camera viewport markers.
- Added one-at-a-time micro-onboarding state for selecting Aster, moving to quarry, holding quarry, Worker posture, pressure preparation, wave defeat, Lume restore, and Results review.
- Added concise objective feedback for objective completion, pressure-wave notice, Lume activation/restoration, and Results readiness.
- Updated the player-slice capture path to generate the 12 requested v0.128 screenshots under ignored artifacts.
- Added v0.128 report generation for screenshot manifest, hashes, contact sheet, HUD, minimap, micro-onboarding, objective feedback, visual capture, and artifact README output.
- Added scaffold tests for no art import, linked_ward `0.92`, no save or stable-ID drift, no routine editor dependency, and no following-milestone start.

## Boundary

No generated image, imported artwork, final UI art, third-party asset, save write, stable-ID change, browser runtime change, new campaign progression, broad gameplay system, final Godot choice, full port, or following-milestone work was introduced.

## Verification

Required verification for closeout:

- `npm run godot:all`
- `npm run godot:fresh-checkout:validate`
- `npm run godot:validate:player-slice`
- `npm run godot:capture:player-slice`
- `npm run godot:package:windows`
- `npm test`
- `git diff --check`
