# Foundation Review

This document records the senior engineering/design review after the first playable prototype.

## High-Priority Findings Fixed

- `BattleScene` hard-coded the first skirmish's buildings, unit spawns, hero spawn, objectives, and AI target IDs. These now live in `src/game/data/maps.ts` under `scenario`.
- Enemy AI hard-coded income, wave timing, unit composition, and base IDs. These are now map scenario AI settings.
- AI training messages were overwriting player HUD feedback. Enemy training now runs silently while player training still announces.
- Hero XP bar logic duplicated the level curve in the HUD. Progression logic now lives in `src/game/core/Progression.ts`.
- Building placement rules were buried inside `BuildingSystem`. The pure rule now lives in `src/game/systems/BuildingPlacementRules.ts` and has tests.
- Content references had no automated safety net. `src/game/data/contentValidation.ts` now validates unit, building, ability, faction, map, objective, spawn, and AI references.
- The hero inherited a generic unit ID. The player hero now uses `hero-player` for clearer debugging and future save/multiplayer boundaries.
- HUD DOM was rebuilt every update even if nothing changed. The HUD now skips identical renders.

## Still Intentionally Deferred

- Entities still own Phaser view objects. This is acceptable for the prototype, but a larger campaign or multiplayer architecture should eventually split simulation state from rendering adapters.
- Combat and ability systems still create Phaser projectiles directly. Future multiplayer or replay support should separate combat events from visual effects.
- Movement is still direct steering with light separation. A real pathfinding layer remains postponed.
- Save validation is basic. Future save slots and migrations should include schema versions and recovery messages.
- AI is configurable but still simple. It does not scout, retreat, preserve unit roles, or build structures.

## Design Notes

- The prototype is more useful if early battles are readable than if they are content-heavy. Keep new factions small until combat roles, counters, and UI clarity are stronger.
- Every new map should define its own scenario block instead of adding conditions to `BattleScene`.
- Every content edit should be followed by `npm run test`. The content validation test is the first guardrail for non-coder iteration.
