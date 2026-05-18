# v0.14.3 Reproduction Plan

Date: 2026-05-18  
Session: PT-20260518-EMMANUEL-BASELINE-01 retest

## 1. Drag-select several units on the battlefield

- Steps: Launch a battle with hero and troops, press and hold left mouse on empty battlefield, drag a rectangle over multiple player units, release on battlefield.
- Expected: Units inside the rectangle become selected; direct click selection still works.
- Actual: Emmanuel can draw the square, but units inside are not selected.
- Likely files: `src/game/systems/InputSystem.ts`, `src/game/systems/SelectionSystem.ts`, HUD pointer-event CSS.
- Test strategy: Add regression coverage for input drag completion and/or Playwright battle drag selecting multiple units.
- Risk: Medium; must not reintroduce stuck marquee.

## 2. Drag-select while rectangle crosses the bottom-right HUD

- Steps: Start drag on battlefield, drag across units and into the bottom-right side panel/HUD, release over HUD or outside canvas.
- Expected: Selection resolves or cancels cleanly; selection rectangle disappears; HUD elements are not selected.
- Actual: v0.14.1 fixed stuck rectangles, but retest shows selection no longer completes reliably.
- Likely files: `src/game/systems/InputSystem.ts`, `src/game/ui/HUD.ts`, HUD panel pointer handling.
- Test strategy: Add release-over-HUD regression coverage that verifies drag state clears and units can still be selected.
- Risk: Medium; global pointer release must complete active battlefield drags instead of only clearing them.

## 3. Hero adjacent to melee enemy should attack or explain why not

- Steps: Move hero next to Stone Imp or melee enemy and wait through attack cooldown.
- Expected: Hero attacks if hostile target is in contact/range, or selected panel clearly reports a non-attacking order state.
- Actual: Hero can stand next to enemy with no visible HP loss.
- Likely files: `src/game/systems/CombatSystem.ts`, `src/game/entities/Unit.ts`, `src/game/ui/UnitOrderSummary.ts`, `src/game/ui/hudPanels/SelectedEntityPanel.ts`.
- Test strategy: Combat system test with adjacent melee hero/unit damaging hostile target after ticks.
- Risk: Medium; fix contact/range math without broad balance changes.

## 4. Melee enemy adjacent to hero should attack

- Steps: Let a Stone Imp or Raider stand next to hero without the hero moving away.
- Expected: Enemy melee attack damages the hero when contact/range is valid.
- Actual: Enemy can stand beside the hero without combat.
- Likely files: `src/game/systems/CombatSystem.ts`, melee unit definitions for current ranges/radii.
- Test strategy: Combat system test where enemy melee unit at contact distance damages hero.
- Risk: Medium; ranged behavior must remain unchanged.

## 5. Move/retreat command away from combat should override opportunistic engagement

- Steps: Select hero/troops in combat, right-click a safe point away from enemies.
- Expected: Units visibly attempt to move away and their order reads Moving/Retreating; enemies may still chase or attack.
- Actual: Units sometimes make tiny movement but remain glued to enemies.
- Likely files: `src/game/entities/Unit.ts`, `src/game/systems/InputSystem.ts`, `src/game/systems/CombatSystem.ts`, `src/game/systems/MovementSystem.ts`, `src/game/ui/UnitOrderSummary.ts`.
- Test strategy: Unit-level combat test that normal move orders suppress immediate reacquisition briefly, plus movement guard that position advances and does not snap back.
- Risk: Medium; must not make retreat invulnerable or disable enemy pursuit.

## 6. Tutorial defeat should show useful result feedback

- Steps: Launch Tutorial / Proving Grounds, allow player-side defeat.
- Expected: A defeat/results message explains no save/no reward occurred and offers Retry Tutorial and Return to Main Menu.
- Actual: Tutorial defeat returns directly to main menu.
- Likely files: `src/game/battle/BattleSceneResults.ts`, `src/game/scenes/ResultsScene.ts`, `src/game/results/*`.
- Test strategy: Results view/model and smoke coverage for tutorial defeat result state and no-save/no-reward messaging.
- Risk: Low/medium; must preserve no-save/no-reward tutorial rules.

## 7. Hero creation class/origin must show mechanical effects

- Steps: Open Hero Creation, inspect each class and origin option.
- Expected: Each option explains concrete stat/ability effects and tradeoffs using actual data.
- Actual: Choices are flavorful but mechanically thin.
- Likely files: `src/game/scenes/HeroCreationScene.ts`, `src/game/data/heroClasses.ts`, `src/game/data/origins.ts`, content index for ability names.
- Test strategy: E2E or unit coverage that class/origin option text includes mechanical terms/stats and W/A/S/D still types in the name input.
- Risk: Low; copy-only UI change if based on existing data.

