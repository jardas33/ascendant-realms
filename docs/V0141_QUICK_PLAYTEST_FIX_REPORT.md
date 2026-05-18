# v0.14.1 Emmanuel Quick Playtest Fix Report

Date: 2026-05-18

Session: `PT-20260518-EMMANUEL-BASELINE-01`

Scope: small, high-confidence fixes from Emmanuel's real 30-minute Baseline Cautious private playtest. This pass uses only Emmanuel's supplied feedback plus existing automated evidence for context.

## Fixed Or Narrowly Addressed

| Feedback ID | Outcome | Retest focus |
| --- | --- | --- |
| I05 - Hero rename input blocks A/S/D/W | Fixed. Global game hotkeys now ignore focused editable elements, and hero creation shields focused text input from game keyboard handling. | Start a new campaign, clear hero name, type names containing `W`, `A`, `S`, and `D`. |
| I07 - Selection marquee stuck over HUD | Fixed. Battle drag state now clears on lost release events including window `pointerup`, `pointercancel`, and blur, and also clears if the mouse button is no longer down during pointer movement. | Drag-select from battlefield into the side panel and release over the HUD. |
| I06 - Retreat/move command ignored during combat | Fixed narrowly. Normal move orders for player units no longer auto-stop to attack enemies in weapon range; attack-move still engages along the route. | Select engaged units, right-click safe ground away from enemies, confirm the order reads `Moving` and units try to leave. |
| I09 - Menu exits instead of pause | Fixed. The battle `Menu` button now opens a pause overlay with `Resume` and `Exit to Main Menu` instead of immediately leaving battle. | Click `Menu` during battle, resume, then separately confirm exit only when intended. |
| I02 - Hero skill lacks explanation | Fixed. Hero ability buttons now expose visible ability effect/cost copy plus title/aria descriptions. | Select hero and read Rally Banner or other unlocked skill controls. |
| I01 - Hover highlight flicker | Addressed. HUD refresh deferral now treats the tutorial panel as a stable interaction area, matching the side/objective panel protection already present. | Hover `Next Objective`, `Exit Tutorial`, and Barracks/Command Hall option buttons while resources/status update. |
| I03 - Tutorial Next Objective delay | Addressed through the same tutorial-panel stability fix. The active button should no longer be replaced underneath a hover/click during routine HUD refreshes. | On steps 5-9, click `Next Objective` once after it appears and confirm immediate transition. |
| I08 - Unit movement loop / teleport | Narrow fix. Movement/separation no longer applies large grid-center correction snaps when a nearby correction target is blocked. | Group-move all troops to one point and watch for any repeated snap-back loop. |
| I04 - Hero attack unclear | Partly addressed. Selected-unit order copy now says an attacking unit should make enemy HP drop when in weapon range. | Select hero during a fight and check whether `Attacking` plus enemy HP behavior is understandable. |

## Deferred Or Retest-Dependent

- I08 may still require a deeper pathing/formation pass if Emmanuel can reproduce a snap-back loop after this narrow correction.
- I04 remains a combat readability follow-up if selected order copy and existing health bars still do not make attacks clear enough.
- No combat VFX overhaul, art replacement, broad pathing rewrite, or balance tuning was attempted.

## Tests Added Or Updated

- Unit tests for normal move orders versus attack-move combat behavior.
- Unit test for blocked-separation movement correction avoiding large snap-back jumps.
- Unit test for pause menu rendering.
- Browser smoke test that hero name input accepts `WASD`.
- Browser smoke test that the tutorial `Next Objective` button remains stable across a HUD refresh while hovered.
- Browser smoke test that battle `Menu` opens a pause overlay and `Resume` returns to battle.
- Deep browser HUD test that releasing a selection drag over the side panel clears the marquee state.

## What Did Not Change

- No gameplay numbers changed.
- No save format changed.
- No maps, factions, units, runtime art, or runtime assets were added.
- No human feedback beyond Emmanuel's supplied session was invented or used.
- No hosted release assertions, canvas/world-click safeguards, or no-save/no-reward tutorial assertions were weakened.

## Recommended Retest

Run the same quick Baseline Cautious route on a clean v0.14.1 package and focus on:

1. Hero name typing with movement-key letters.
2. Tutorial steps 5-9 `Next Objective`.
3. Drag selection into HUD and release.
4. Retreating hero/troops out of a losing fight.
5. Group move to one point, watching for snap-back.
6. Battle `Menu` pause/resume.
7. Hero ability descriptions and attack state readability.
