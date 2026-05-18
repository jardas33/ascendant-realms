# v0.14.1 Emmanuel Quick Playtest Reproduction Plan

Date: 2026-05-18

Scope: focused reproduction and test strategy for Emmanuel's real v0.14 quick Baseline Cautious feedback.

Do not broaden this into balance tuning, new content, art overhaul, save migration, broad AI rewrite, or automated simulation expansion.

## I05 - Hero Rename Input Blocks A/S/D/W

- Steps: start New Campaign, focus hero name input, clear current name, type strings containing `W`, `A`, `S`, and `D`.
- Expected: typed letters appear normally while the text input is focused.
- Actual: Emmanuel reported many letters, specifically A/S/D/W, do not appear.
- Likely files: hero creation scene/UI, global keyboard handler, battle/campaign hotkey registration, tests in `tests/e2e/smoke.spec.ts`.
- Test strategy: browser test typing a WASD-heavy name into the hero input; unit-level guard if keyboard helper exists.
- Fix risk: low if implemented as "ignore global hotkeys while editable elements are focused."

## I07 - Selection Marquee Stuck Over HUD

- Steps: enter a battle, begin drag-select on the battlefield, drag into the bottom-right HUD/side panel area, release pointer over HUD.
- Expected: selection rectangle clears on pointerup/pointercancel/window blur, and drag selection completes or cancels safely.
- Actual: Emmanuel reported the rectangle remains stuck across battlefield/HUD until random clicks.
- Likely files: battle input system, selection marquee rendering/state, HUD pointer handling, side panel DOM/CSS, e2e smoke/layout helpers.
- Test strategy: Playwright drag from canvas into side panel then release; assert selection box is not visible/stuck.
- Fix risk: medium; must avoid weakening canvas/world click patterns or side-panel assertions.

## I08 - Unit Movement Loop / Teleport

- Steps: select all troops, issue a move command to one spot, observe whether any unit repeatedly snaps back to its starting position.
- Expected: units move toward target or become blocked with stable state; no repeated snap-back loop.
- Actual: one troop reportedly moved partway, snapped back, and repeated endlessly.
- Likely files: movement system, pathfinding grid, local separation, group command logic, stuck recovery, battle runtime/entity sync.
- Test strategy: model-level movement/pathing regression if root cause is found; otherwise focused browser repro and document deeper follow-up.
- Fix risk: high if it requires formation/pathing rewrite. Stop and document if no narrow root cause is found.

## I03 - Tutorial Next Objective Delay

- Steps: launch Tutorial / Proving Grounds, reach steps 5-9, click Next Objective when visible.
- Expected: if active, one click advances immediately; if gated, the UI clearly shows the requirement instead of implying free advance.
- Actual: Emmanuel reported many-second delay or repeated clicks before advancing.
- Likely files: tutorial overlay, objective panel, tutorial step model, e2e tutorial smoke.
- Test strategy: unit test for step progression state; Playwright test for next button disabled/enabled behavior and no swallowed click.
- Fix risk: low/medium; must preserve no-save/no-reward tutorial behavior.

## I06 - Retreat / Move Command Ignored During Combat

- Steps: select hero/troops engaged with enemies, right-click safe ground behind them repeatedly.
- Expected: selected units accept the move command, clear attack intent where appropriate, and attempt to retreat. Enemies may chase, but the player should see units obeyed.
- Actual: Emmanuel reported tiny movement but units stayed engaged and died.
- Likely files: battle input command routing, movement/attack state, combat system, enemy aggro/chase behavior, selected panel order text.
- Test strategy: model-level test that explicit move command clears combat target/attack intent if a command model exists; browser smoke if feasible.
- Fix risk: medium/high; avoid broad combat AI rewrite or making retreat trivial.

## I09 - Menu / Pause Behavior

- Steps: enter battle and click Menu.
- Expected: player can pause/resume or confirm exit before leaving battle.
- Actual: Emmanuel reported Menu immediately interrupts and sends player to main menu.
- Likely files: battle HUD, BattleScene menu handler, scene pause/resume flow, smoke tests for tutorial exit/menu routes.
- Test strategy: Playwright test that battle Menu opens pause/confirmation overlay and Resume returns to battle.
- Fix risk: medium if true simulation pause is not centralized; lower if implemented as confirmation overlay.

## I02 - Hero Skill Lacks Explanation

- Steps: select hero or view skill/ability controls, inspect visible ability text.
- Expected: ability explains what it does, cost/cooldown if relevant, and when to use it.
- Actual: Emmanuel reported hero skills lack explanation.
- Likely files: selected entity panel, hero ability definitions, HUD ability rendering, tooltip/copy helpers.
- Test strategy: unit test selected-panel view model or DOM smoke text presence.
- Fix risk: low if copy-only.

## I04 - Hero Attack Unclear / Possibly Not Attacking

- Steps: order hero to attack or move near enemy, select hero, observe order/status and target health.
- Expected: selected panel or order summary says Attacking/Moving/Guarding clearly; if attacking, target feedback is visible.
- Actual: Emmanuel could not tell whether hero attacked because enemy life did not drop visibly.
- Likely files: combat system, unit order summary, selected entity panel, health bar rendering.
- Test strategy: view-model/unit test for attacking status text; browser observation if available.
- Fix risk: medium; readability copy is safer than combat behavior changes unless a bug is reproduced.

## I01 - Hover Highlight Flicker

- Steps: hover Tutorial objective buttons, Exit Tutorial, Barracks training buttons/options.
- Expected: hover/focus highlight remains stable while pointer remains over the control.
- Actual: hover highlight flickers nonstop.
- Likely files: HUD CSS, tutorial overlay CSS, command button rendering, pointer hover state.
- Test strategy: inspect CSS animation/state churn; Playwright screenshot/manual browser check if changed.
- Fix risk: low for CSS-only stabilization, but preserve focus-visible accessibility.
