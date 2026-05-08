# Command Log Replay Feasibility

Last updated: 2026-05-08

## Purpose

This v0.5 study asks whether Ascendant Realms should eventually record and replay deterministic command logs for stronger e2e and simulator confidence.

Conclusion: build a tiny, test-only command-log V1 later, but do not wire production command replay yet. The safest first slice is a high-level Playwright/test-hook replay for one existing first-campaign-battle flow, not a low-level pointer replay system.

No implementation was added in this phase.

## Current Command Surface

Battle commands currently exist across Phaser input, HUD buttons, direct scene helpers in e2e, and the scripted playtest driver.

Player-facing battle input:

- Select entity: left-click a unit/building or drag-select a box through `InputSystem` and `SelectionSystem`.
- Move: right-click ground with selected player units.
- Attack: right-click an enemy entity with selected player units.
- Attack-move: Shift+A arms attack-move, then right-click destination.
- Capture: indirect command; units move onto capture sites and `ResourceSystem` resolves ownership over time.
- Build: select a builder source such as Command Hall, click HUD `data-action="build"`, then left-click valid ground to place through `BuildingSystem`.
- Cancel building placement: Escape or right-click while placing.
- Train unit: click HUD `data-action="train"`.
- Cancel training: click HUD `data-action="cancel-train"`.
- Set rally: select completed production building and right-click ground with no selected units.
- Research upgrade: click HUD `data-action="upgrade"`.
- Cancel upgrade: click HUD `data-action="cancel-upgrade"`.
- Cast hero ability: click HUD `data-action="ability"` or press hotkeys 1, 2, and 3.
- Camera and help-adjacent commands: H selects hero, Space centers hero, F toggles fog debug when available, Escape clears selection/cancels placement.
- Minimap move: click the HUD minimap.

Campaign commands:

- Select campaign node: click `button[data-campaign-node]`.
- Start selected battle node: click `button[data-campaign-action="start"]`.
- Choose event/town choice: click `button[data-campaign-choice]`.
- Buy Stronghold upgrade: click `button[data-stronghold-upgrade]`.
- Dismiss retinue unit: click `button[data-retinue-dismiss]`.
- Open inventory or return to menu from campaign.

Existing automated command-like helpers:

- Playwright deep-flow helpers directly select buildings, place buildings, complete construction, finish training, and advance battle simulation through `window.ascendantRealmsGame` scene access.
- Safe e2e hooks expose targeted actions such as `captureSite`, `forceBattleVictory`, `grantSelectedUnitVeterancyXp`, `scoutEnemyHero`, and `defeatEnemyHero`.
- The playtest simulator has high-level `PlaytestStrategyDriver` commands: select hero, select Command Hall, move to capture point, build, wait for construction, train, set rally, research, wait, and attack enemy base.

## State Needed For Deterministic Replay

A useful command log needs more than the command list. A replay needs a stable starting envelope:

- Schema version for the command log.
- Game build/checkpoint identifier.
- Map ID and campaign node ID.
- Mode: campaign node, skirmish, or test harness.
- Difficulty.
- Enemy faction and AI personality.
- Initial hero state: class, origin, level, XP, stats, skills, abilities, inventory, equipment, affixes, and cleared maps.
- Campaign state: completed nodes, unlocked nodes, locked nodes, selected chapter/node, campaign resources, resources spent, choice claims, town service use counts, active modifiers, Stronghold upgrades, reputation, retinue, rivals, and trophies.
- Launch modifiers from Stronghold, reputation, campaign choices, rivals, retinue, and Cinderfen services.
- RNG seed or injected RNG streams for item rewards, affixes, generated item instance IDs, enemy decisions if any become randomized, and future procedural systems.
- Entity ID seed from `resetEntityIds`.
- Simulation clock and command timestamps or ticks.
- Camera state if the replay is UI-level.
- Viewport size and UI scale if the replay clicks actual UI controls.
- Test-hook capability version if commands replay through safe hooks.

## Current Determinism Blockers

The current game has deterministic islands, but a full command replay would still be brittle.

Phaser/browser timing:

- Pointer events, keyboard debounce windows, tweens, rendering cadence, and Playwright scheduling are not a stable simulation clock.
- `InputSystem` uses `performance.now()` for attack-move and ability-key debounce.

Pointer coordinates:

- Real selection, placement, minimap, and right-click commands depend on camera scroll, canvas bounds, browser viewport, UI scale, and responsive layout.
- Building placement depends on a valid world point near the current base and current obstacle state.

Runtime state drift:

- Movement and pathfinding are deterministic for a fixed state, but entity positions can diverge if command timing differs.
- Combat, capture progress, construction, training, upgrades, enemy waves, and hero abilities all depend on elapsed time.

Reward and affix randomness:

- Battle rewards and item affixes already support deterministic paths for tests and simulator.
- Production item instance IDs still use `Date.now()` and `Math.random()` in `createItemInstance`.

AI and wave timing:

- The current enemy AI is mostly data/time driven, but future enemy construction, workers, procedural map state, or randomized AI personalities would need seed control.

Existing test hooks:

- E2E hooks are useful for safety, but a replay built only on hooks could miss real UI regressions.
- A replay built only on UI clicks would be slower and more fragile than current deep-flow tests.

## Safe First Vertical Slice

Recommended first implementation later: test-only command log V1 for the existing deep-flow test `first campaign battle path covers capture, build, train, rally, and victory rewards`.

Scope:

- Store commands as high-level semantic records, not raw mouse coordinates.
- Replay through existing Playwright page helpers and safe scene/test hooks where the UI path is already covered elsewhere.
- Use deterministic launch state and deterministic reward options.
- Keep the command log in `tests/fixtures/command-logs/`, not production data.
- Assert end state: capture site owned or in progress, Barracks placed/completed, Militia trained, rally marker present, victory reward flow reachable, and no console errors.

Example command vocabulary for V1:

```text
selectHero
moveSelectionToCaptureSite(crown_shrine)
waitUntilCaptureProgress(crown_shrine)
selectBuilding(command_hall)
placeBuilding(barracks, near_command_hall)
completeConstruction(barracks)
selectBuilding(barracks)
trainUnit(militia)
waitForTrainingComplete(militia)
setRallyPoint(barracks, pointLabel: forward_safe)
advanceBattle(seconds)
forceOrFinishVictoryForExistingDeepFlow
```

This is deliberately not a production-facing replay engine.

## Risks

- Brittle tests if command logs encode coordinates instead of semantic targets.
- False confidence if command logs rely too heavily on hooks and skip UI behavior.
- Slow e2e if every command waits through real time.
- Hidden coupling to private scene fields if the replay helper reaches into `BattleScene` internals without a stable test API.
- Save compatibility risk if command logs embed full saves instead of referencing save fixtures.
- Future replay breakage if entity IDs, map coordinates, command names, or reward policies shift without fixture update notes.

## Recommendation

Build command log V1 soon, but only after the v0.5 validation and simulator gates are complete.

Exact recommended first target:

- Add one test-only command log fixture for the existing first-campaign-battle deep-flow path.
- Add a small replay helper under `tests/e2e/` that interprets semantic commands by calling existing Playwright helpers.
- Do not add production UI, save fields, or runtime replay systems.
- Do not use command replay to replace the current smoke, layout, deep, release, simulator, or content-validation gates.

Prerequisites before any broader replay:

- Stable command-log schema doc.
- Explicit seed policy for rewards, affixes, entity IDs, and future randomized AI/procedural systems.
- A thin test-only command API that avoids direct arbitrary mutation of gameplay state.
- One passing replay fixture that proves the value without reducing current coverage.

## Non-Goals

- No production replay UI.
- No multiplayer lockstep.
- No broad deterministic simulation rewrite.
- No save-version bump.
- No new gameplay, maps, units, factions, workers, enemy construction, crafting, diplomacy, procedural generation, or broad army-management systems.
