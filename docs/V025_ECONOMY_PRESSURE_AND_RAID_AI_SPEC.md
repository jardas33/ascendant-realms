# v0.25 Economy Pressure And Raid AI Spec

Date: 2026-05-25

## Mission

Layer readable economy pressure on top of v0.24 enemy resource-site strategy. The enemy should pressure the player's economy by contesting resource sites, especially upgraded or Worker-boosted sites, without turning every battle into nonstop chaos.

## Scope

v0.25 adds light raid behavior and abstract enemy logistics. It does not globally buff the enemy army, add new units, add new maps, add classic harvesting, implement full enemy Workers, rewrite pathing, add formations, or weaken tests.

## Raid Goals

The enemy may periodically:

- target player-owned resource sites,
- prefer upgraded player sites,
- prefer player sites with active Worker assignments,
- contest a site by moving a small squad into the capture ring,
- retreat or regroup if the raid is too weak against the nearby player force.

Raids are periodic, not continuous:

- a first-raid delay prevents immediate pressure,
- a raid cooldown prevents every-tick retargeting,
- active raid squads can expire or regroup before another raid begins.

## Fairness Rules

- The enemy does not receive a global army-stat buff from raids.
- Raid squads are drawn from existing enemy units.
- The enemy does not force-click or bypass the world interaction model; it uses normal movement and combat commands.
- The AI avoids attacks when nearby player threat heavily exceeds the selected squad's combat power.
- Main base attacks keep their existing pacing and protections.

## Abstract Enemy Worker Slots

Enemy Worker slots are abstract in v0.25:

- no enemy Worker unit is trained or simulated,
- no cargo, harvesting, or drop-off path is added,
- enemy abstract logistics can add a conservative Worker-slot income bonus only to enemy-owned upgraded sites,
- abstract logistics are paced by cooldown and capped conservatively,
- losing site control clears abstract logistics along with level and player Worker slots.

This gives enemy site ownership some economy pressure without introducing a full enemy Worker economy.

## Player Readability

The player should understand when their economy is under pressure:

- player-owned sites under enemy presence reuse the existing under-attack warning,
- selected sites show owner, level, upgrade bonus, Worker slots, Worker bonus, total income, and contested state,
- enemy-owned upgraded sites can show abstract enemy logistics as status text,
- enemy capture or upgrade alerts should be short and cooldown-paced.

## Testing Requirements

Focused tests should cover:

- site scoring,
- neutral-site capture plans,
- retake plans,
- enemy upgrade rules,
- invalid enemy upgrade targets,
- player-site pressure raids,
- raid cooldown behavior,
- site loss cleanup for Worker slots and abstract enemy logistics,
- existing Worker assignment and upgrade regressions.
