# v0.30 Rival Champion Foundation Spec

Date: 2026-05-27

## Goal

Add a safe first enemy commander foundation that makes selected campaign battles feel more personal without adding factions, maps, art, save migration, boss mechanics, or broad AI rewrites.

The codebase already has a named enemy commander scaffold at the v0.29.2 baseline. v0.30 formalizes that scaffold as the Rival Champion foundation, tightens AI safety around it, and documents the supported behavior.

## Enemy Champion Purpose

Rival champions are named enemy commanders that:

- use the existing `enemy_commander` unit slot and existing runtime visuals;
- are stronger than normal enemy troops but not a raid-ending boss;
- have readable names, titles, objective copy, minimap marker treatment, and result summaries;
- interact with existing combat, damage, XP, ability cooldown, objective, and rival-state systems;
- provide a personal target in selected campaign battles.

## Spawn Rules

Rival champions are opt-in through battle launch data:

- campaign nodes may set `enemyHeroId`;
- the battle launch resolver rejects missing enemy hero ids;
- the battle spawner upgrades only the existing `enemy_commander` spawn when a valid `enemyHeroId` is present;
- battles without `enemyHeroId` keep normal enemy commander behavior;
- Tutorial remains no-save/no-reward and should not introduce rival champion complexity.

No new maps, factions, unit rosters, or runtime assets are part of v0.30.

## AI Behavior

Rival champions should read as protected commanders:

- defend the enemy base when the player pushes it;
- defend valuable enemy-owned resource sites when threatened;
- avoid neutral-site capture and player-resource-site raid squads;
- avoid first attacks and early pressure;
- join only late, coordinated attacks when the enemy economy/base plan is strong and enough escort units are available;
- never respawn infinitely.

Generic non-rival enemy commanders can still use the prior commander timing rules. Rival champions receive the stricter protected-commander rules.

## Rewards

Defeating a rival champion can:

- grant normal unit XP through the champion unit's existing `xpValue`;
- complete champion-specific battle objectives;
- record rival defeat telemetry;
- contribute to campaign rival first-defeat rewards where already supported;
- preview a tiny relic reward in v0.31.

The existing rival first-defeat rewards remain one-time and duplicate-protected.

## UI Copy

Use existing UI surfaces only:

- battle-start status includes the enemy commander name/title when present;
- sighting alert: `Enemy commander sighted: Name, Title`;
- objectives can name the commander, such as `Defeat Captain Malrec`;
- minimap uses existing enemy-hero marker styling;
- results show `Enemy commander`, `Commander defeated`, rival outcome, XP, one-time reward, trophy, and relic preview when applicable.

## Deferrals

Deferred beyond v0.30:

- new enemy champion roster;
- new commander art, portraits, VFX, sounds, or animation;
- player-facing boss health bar;
- enemy hero progression tree;
- broad AI/pathing rewrite;
- global rebalance;
- save migration;
- Patrol, formations, or other large RTS command systems.
