# v0.14.3 Combat Selection Retest Fix Report

Date: 2026-05-18  
Session: PT-20260518-EMMANUEL-BASELINE-01 retest  
Baseline commit inspected: 029a1c730d03ede1e126a8da5ffce3c88eccba93

## What Emmanuel Reported

Confirmed fixed from v0.14.1/v0.14.2:

- Hero rename accepts W/A/S/D.
- Tutorial Next Objective advances.
- Hover flicker appears fixed.
- Hero skill explanation exists.
- Menu/pause behavior is fixed.

Still broken or partially broken:

- Hero and melee enemies can stand beside each other without clear attacks.
- Retreat/move-away commands are inconsistent.
- Marquee selection draws a rectangle but does not select units inside it.
- Tutorial defeat returns directly to main menu.
- Hero class/origin choices need mechanical explanations.
- Unit snap-back was not seen in this retest but should remain guarded.
- Unit info panel and behaviour modes remain future readability/control work.

## What Was Fixed

### Marquee Selection

- `InputSystem` now completes an active battlefield drag on global `pointerup`, including release over the HUD or outside the canvas.
- `pointercancel` and window blur still clear the drag without selecting.
- Phaser canvas `pointerup` still handles normal direct click and direct battlefield drag selection.
- A deep Playwright HUD test now verifies release-over-side-panel marquee selection selects multiple battlefield units and clears drag state.
- A `SelectionSystem` unit test verifies marquee rectangles select multiple units and ignore buildings.

### Melee Engagement

- `CombatSystem` now treats melee body contact as valid attack reach by considering attacker and target radii for melee-range units.
- This fixes the visual "standing next to target but not attacking" case for hero, Stone Imp, Raider, and other melee units without changing unit data.
- Ranged attack behavior still uses existing range logic.
- Unit tests cover adjacent player melee attacks and adjacent enemy melee attacks.

### Retreat / Move-Away Intent

- Normal player move orders now suppress opportunistic target reacquisition only briefly instead of forever.
- This gives retreat/move-away commands a visible chance to start, while allowing units to fight again if they remain stuck beside enemies.
- Attack-move and explicit attack commands still engage immediately.
- Unit order copy now explains that a move order briefly takes priority so movement intent is clear.

### Teleport / Snap-Back Guard

- The v0.14.1 blocked-movement correction remains intact.
- A movement regression test now verifies repeated move commands advance the unit instead of resetting it to the original point.

### Tutorial Defeat

- Tutorial battle completion now uses the existing Results screen instead of silently returning to the main menu.
- Tutorial defeat copy explicitly says the run is no-save and no-reward.
- Tutorial defeat actions are `Retry Tutorial` and `Main Menu`; no inventory or campaign-save action is shown.
- Results tests cover the no-save/no-reward tutorial defeat guidance.

### Hero Class / Origin Explanation

- Hero creation choices now show concise mechanical summaries based on existing class stats, origin stat modifiers, and primary ability data.
- The copy names HP, Mana, Damage, Armor, Range, attributes, primary ability, and basic strengths/tradeoffs.
- The smoke test for W/A/S/D name input also checks that the mechanical explanation text is present.

## What Was Deferred

- No unit behaviour modes were implemented in v0.14.3. A design-only stance document was created for a future pass.
- No broad unit info panel redesign was attempted.
- No patrol command was implemented.
- No combat VFX overhaul was attempted.
- No gameplay numbers, save format, maps, factions, units, or runtime art/assets changed.

## Retest Checklist

Ask Emmanuel to retest the same Baseline Cautious route and focus on:

1. Drag-select several units on the battlefield.
2. Drag-select units while releasing over the bottom-right side panel.
3. Put hero next to a Stone Imp or Raider and confirm HP changes or order state is clear.
4. Let a melee enemy stand next to the hero and confirm it attacks.
5. Move-order hero/troops away from a losing combat and confirm they visibly attempt to move.
6. Lose the tutorial and confirm the no-save/no-reward defeat results screen appears.
7. Open Hero Creation and confirm class/origin choices explain mechanics.
8. Watch for any return of the unit teleport/snap-back loop.

## Known Limitations

- The retreat fix is not invincibility. Enemies can still chase and hit retreating units.
- The melee fix improves contact engagement, but it does not add new combat animations or VFX.
- The class/origin copy is factual and compact; it is not a full hero build guide.
- Behaviour modes remain a future original-control feature, not a v0.14.3 runtime feature.

