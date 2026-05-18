# v0.14.4 Combat Control Retest Fix Report

Date: 2026-05-18  
Session: PT-20260518-EMMANUEL-BASELINE-01 v0.14.3 retest  
Baseline commit inspected: 28698152edca0967a561dc0de2a9c08b021d4061

## Evidence Used

Only Emmanuel's v0.14.3 retest notes were used. No additional human feedback was invented.

Confirmed fixed before this pass:

- Drag-select multiple units.
- Tutorial defeat Results screen.
- Retry Tutorial.
- Return to Main Menu.
- Class/origin mechanical explanations.

Still broken or partially broken:

- Melee hero/unit/enemy contact could idle until the player nudged a unit.
- Drag selection could lag while crossing the bottom-right HUD or top-right minimap.
- Complete Tutorial behaved too much like Exit Tutorial by going straight to Main Menu.
- Selected-unit hover over enemies lacked clear attack intent feedback.
- Tutorial capture copy said the ring turned blue, while the actual owned ring is green.
- A screenshot-backed visual bug was mentioned, but no screenshot artifact was attached in the current thread or found in repo artifacts.

## Fixes Made

### Adjacent Melee Engagement

- Increased melee contact tolerance inside `CombatSystem` by using a small visual contact margin on top of entity radii.
- Added coverage for melee targets whose sprite footprints visibly touch even when center distance is outside raw stat range.
- Added a regression where the hero kills one adjacent Stone Imp and then reacquires a second adjacent melee target without needing a movement nudge.

This is a contact interpretation fix, not balance tuning. Unit data, HP, damage, cooldowns, economy, maps, factions, and units were not changed.

### Drag Selection Across HUD And Minimap

- `InputSystem` now listens to global pointer movement while a battlefield drag is active.
- The selection rectangle keeps updating when the pointer crosses DOM HUD surfaces such as the side panel or minimap.
- Existing global pointer release/cancel cleanup remains intact.
- Minimap clicks now clear handled HUD focus/deferred markup state so the selected unit panel does not remain stale after minimap interaction.
- Deep browser coverage now checks release-over-side-panel selection and active drag behavior while crossing/releasing over the minimap.

### Tutorial Completion Semantics

- `Complete Tutorial` now routes through the existing no-save/no-reward Results flow as a tutorial victory.
- The Results screen offers `Retry Tutorial` and `Main Menu`.
- The smoke test now asserts the Results screen appears before returning to Main Menu.
- `Exit Tutorial` still returns directly to Main Menu with no completion notice.

### Attack Hover And Attack Intent

- Hovering a visible hostile or neutral combat target while player units are selected now changes the canvas cursor to a crosshair and marks the canvas with `data-battle-cursor="attack"`.
- Left-clicking that target issues an attack order, matching the visible attack intent.
- Right-click attack orders still work.
- Deep browser coverage asserts the attack cursor and accepted left-click attack command.

### Tutorial Ring Copy

- The Crown Shrine tutorial instruction now says the owned ring turns green.
- The hint now says green ownership starts battle income.
- Final tutorial hint now says completion opens a no-save Results summary instead of returning straight to Main Menu.

## Visual Bug Note

The retest notes mention an attached screenshot, but this pass did not receive that screenshot in the current thread, and a repo/artifact search did not find a matching v0.14.3 retest screenshot. No screenshot-specific visual fix is claimed.

`npm run visual:qa` remains required for this pass. If Emmanuel still sees the visual bug, the next report should include the image or a short description of the exact screen and UI element.

## Deferred

- No unit behaviour modes were implemented.
- No unit info panel redesign was attempted.
- No broad combat AI/pathing rewrite was attempted.
- No art/assets were added or replaced.
- No save migration was made.

## Retest Checklist

1. Put Aster or a melee unit beside a Stone Imp/Raider after one nearby enemy dies; confirm combat resumes without nudging.
2. Let an enemy stand beside Aster or a melee troop; confirm it attacks when appropriate.
3. Drag-select across the bottom-right side panel and top-right minimap; confirm no multi-second freeze and selection resolves cleanly.
4. Complete Tutorial; confirm it shows no-save/no-reward Results before Main Menu.
5. Select a unit, hover an enemy/imp, confirm attack cursor, then left-click and confirm an attack order.
6. Confirm the Crown Shrine tutorial copy says green, matching the ring.
7. Recheck the reported visual bug and capture the screenshot again if it persists.
