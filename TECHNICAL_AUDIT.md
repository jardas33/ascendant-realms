# Ascendant Realms Technical Audit

This audit focuses on the current browser prototype foundation, not on adding new gameplay features. The goal is to keep the skirmish playable while preparing the project for more factions, hero classes, campaign systems, saves, and manual assets.

## Current Strengths

- The project already has a clean Phaser 3, TypeScript, and Vite foundation.
- Core content is mostly data-driven through files such as `units.ts`, `buildings.ts`, `abilities.ts`, `heroClasses.ts`, `skillTrees.ts`, `items.ts`, and `maps.ts`.
- Gameplay logic is split into systems for input, movement, combat, resources, abilities, training, building placement, AI, UI, and XP.
- Movement now has a pure, tested grid/A* pathfinding layer for blocked terrain, water, and building footprints while preserving the existing command and local separation flow.
- BattleScene has been partially split into focused helpers for spawning, map rendering, alerts, snapshots, objectives, and result transitions.
- Battle setup, objective checks, battle statistics, reward decisions, and save-output decisions now have a pure `BattleRuntime` layer with tests.
- Battle launches now flow through a `BattleLaunchRequest` contract, so skirmish is no longer hardwired as the only possible battle source.
- Persistent hero progression exists with class, origin, level, XP, skill points, unlocked abilities, inventory, equipment, and local save data.
- Inventory now stores item instances with migration from older catalog-ID saves, and equipment references item instances where possible.
- Playwright smoke tests cover the main menu, new campaign, campaign battle launch, skirmish setup, Broken Ford launch, and inventory boot paths.
- The manual asset pipeline avoids paid image APIs and supports `final`, `manual`, `placeholder`, and runtime fallback sources.
- The project has tests for pure progression rules, building placement, content references, and save migration.
- The prototype remains small enough to refactor safely while still being playable.

## Current Weaknesses

- `BattleScene` still handles Phaser entity spawning, system creation, rendering, input, and scene transitions. It is thinner than before, but campaign battles will eventually need a fuller battle factory and serializable entity state.
- The UI now has a reusable procedural skin layer, but it still needs purpose-made UI art assets rather than relying on one general HUD panel texture.
- Runtime entities still mix simulation state with Phaser view objects. This is fast for a prototype, but future persistent retinues, replays, deterministic tests, or multiplayer will need a cleaner simulation/view boundary.
- Ability behavior is still hardcoded in a switch statement. Ability data defines costs and numbers, but new effect types still require engine code.
- The HUD and progression screens use large DOM string rendering. This is fine for quick iteration, but larger UI surfaces should move toward smaller view helpers/components.
- Input mappings are hardcoded in `InputSystem`. Future rebinding, tutorials, controller support, and accessibility will need an input action layer.
- Pathfinding is intentionally coarse. `PathfindingGrid` uses 80px cells and A* over blocked terrain, water, and static building footprints, then `MovementSystem` layers local separation on top. This is much better than direct steering, but it is not yet a tile-accurate navmesh, flow-field system, or formation-aware RTS pathing solution.
- UI CSS is now split by domain with `ui.css` as the ordered import entrypoint. Future risk is selector sprawl within domain files rather than one giant stylesheet.
- The production JavaScript bundle is currently large because Phaser and the whole prototype ship together. It builds correctly, but later releases should consider code splitting and asset loading discipline.
- Save data is local only, but it now has explicit version 2 migration discipline. More migrations will still be needed before multiple heroes, save slots, or modded content.
- There is a setup snapshot in `BattleRuntime`, but not yet a full serializable battle snapshot for every live entity.
- Workers, tile-accurate pathfinding, formation movement, diplomacy, and retinue persistence are intentionally postponed.

## What Was Fixed In This Pass

- Added `SceneKeys.ts` so scene transitions use shared constants instead of repeated string literals.
- Added boot-time content validation. If a data file has a broken reference or invalid map/resource setup, the game now shows a clear data error screen instead of failing later in gameplay.
- Hardened `SaveSystem` so localStorage read/write/reset errors are caught and malformed saves do not enable Continue Hero.
- Normalized save fields for safer progression data: level, XP, skill points, completed battles, stat values, and allocated skill ranks are clamped or rejected as needed.
- Added explicit save version 2 types and migration helpers so V1 saves load safely into the current shape with `createdAt`, `updatedAt`, campaign state, settings, and statistics placeholders.
- Expanded content validation to cover resources, map dimensions, terrain bounds, duplicate map object IDs, capture site resources, spawn bounds, camp contents, ability numeric values, building attack values, and more.
- Updated tests to cover save normalization for unsafe numeric values.
- Updated README language to reflect the current manual asset workflow, Asset Gallery, and known foundation limits.
- Added TODO comments at the key future split points: battle session orchestration, ability effect handlers, and simulation/view separation.
- Added `BattleRuntime.ts` as a pure battle boundary for setup summaries, starting resources, objective resolution, battle stats, rewards, and save-output decisions.
- Added `BattleRuntime.test.ts` for battle setup, objective checks, stats tracking, victory rewards, defeat output, and one-shot completion.
- Hardened CSS asset URLs and upgraded the Asset Gallery so every image card reports whether the image actually loaded.
- Added `BattleLaunchRequest.ts` with skirmish, campaign node, and scenario mission launch modes.
- Refactored main menu, hero creation, progression, results retry, and battle scene startup to pass battle launch requests.
- Added `BattleLaunchRequest.test.ts` for default skirmish launches, invalid launch data, future mode requirements, and retry cloning.
- Removed the stretched `battle_hud_panel` image from menus, result panels, HUD panels, gallery cards, and small UI rows. Those surfaces now use cleaner procedural CSS panels with manual images reserved for backgrounds, portraits, emblems, icons, and future purpose-built UI art.

## What Still Needs Improvement

- Expand `BattleRuntime` into a fuller `BattleSession` that owns live unit/building/capture-site state outside Phaser.
- Introduce full serializable battle snapshots for campaign nodes, scenario retries, tests, replay tooling, and future multiplayer research.
- Split entity simulation data from rendering. Phaser objects should become views of simulation state, not the state itself.
- Move ability effects into a registry of effect handlers so new abilities can be added with less switch-case growth.
- Split ResultsScene, CampaignMapScene, HeroProgressionScene, and HUD DOM rendering into smaller UI modules.
- Add a content error checklist to documentation for non-coders who edit data files.
- Add save slots and richer import/export UI after more manual QA on save migration.
- Add map validation for buildable placement, blocked zones, and future pathfinding grids.
- Add pathfinding debug visualization, route profiling, and chokepoint tests for every map.
- Add a lightweight logging/debug overlay for AI state, resource flow, and combat events.
- Expand repeatable browser smoke tests to cover ResultsScene rewards, Equip Now, Marcher Camp services, campaign choices, and reset/continue saves.
- Add a performance budget and revisit Vite/Rollup chunking before adding large campaign systems or heavier assets.
- Add a dedicated UI prompt/asset batch for panel frames, buttons, ornate dividers, resource frames, minimap frame, tooltip frame, and victory/defeat result panels.

## Recommended Next Milestone

Stabilize the current campaign RTS prototype before adding another major feature. The milestone should:

1. Commit or publish the current verified checkpoint.
2. Run the full manual browser QA checklist from `LLM_GAME_HANDOFF.md`.
3. Add e2e coverage for ResultsScene rewards, Equip Now, Marcher Camp services, campaign choices, and reset/continue saves.
4. Split ResultsScene, CampaignMapScene, and HeroProgressionScene into smaller helpers.
5. Rebalance the first 30 minutes after several human Easy/Normal playthroughs.
