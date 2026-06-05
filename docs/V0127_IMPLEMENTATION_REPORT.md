# v0.127 Implementation Report

v0.127 adds a bounded Godot procedural silhouette library, selection feedback, and combat-readability pass for the existing player-facing Salto review slice.

## Implemented

- Added composite procedural unit silhouettes for Aster, Worker, Militia, Ranger, Ashen Raider, and optional Ashen Brute placeholder.
- Added role-specific procedural building, site, ruin, quarry, and Lume endpoint silhouette cues.
- Added hover, click-select, box-select, selected-role, enemy-target, move-order, attack-order, health-bar, damage-flash, and death-fade feedback evidence.
- Added bounded combat-readability markers for melee contact, ranged shot, hit feedback, pressure wave arrival, site contest, death, and Results readiness.
- Updated player-slice capture to generate the 21 requested v0.127 screenshots under ignored artifacts.
- Added v0.127 report generation for screenshot manifest, hashes, contact sheet, silhouette library, selection feedback, combat readability, visual capture, and artifact README output.
- Added scaffold tests for no art import, art-slot fallback, linked_ward `0.92`, no save or stable-ID drift, fresh-checkout/package posture, and zero routine editor workflow.

## Boundary

No generated image, imported artwork, third-party asset, final unit art, final building art, final animation system, broad combat system, save write, stable-ID change, browser runtime change, final Godot choice, full port, or v0.128 work was introduced.

## Verification

Required verification for closeout:

- `npm run godot:all`
- `npm run godot:fresh-checkout:validate`
- `npm run godot:validate:player-slice`
- `npm run godot:capture:player-slice`
- `npm run godot:package:windows`
- `npm test`
- `git diff --check`
