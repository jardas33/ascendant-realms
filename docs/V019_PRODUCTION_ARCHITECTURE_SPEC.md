# v0.19 Production Architecture Spec

Date: 2026-05-24
Status: complete; local verification green

## Baseline

- Stable runtime/package baseline: commit `ce43d0e`, package `ascendant-realms-private-playtest-ce43d0e`.
- Emmanuel manual retest result for v0.18.3: Worker construction assignment, pause/resume, and base-cluster pathing now seem resolved.
- GitHub Actions CI Release Matrix Dry Run #26365296115 passed on `main` / `ce43d0e`; use that as the v0.18.3 Worker construction foundation baseline.

## Scope

Clarify production architecture and building roles using existing units, buildings, upgrades, construction rules, UI surfaces, and Tutorial steps.

This pass does not add:

- Harvesting.
- Repair.
- Multiple-worker acceleration.
- Enemy construction AI.
- New maps or factions.
- Runtime art/assets.
- Save migration.
- Broad AI/pathing rewrite.
- Global rebalance.
- Patrol or formations.

## Role Architecture

### Command Hall

- Role: base hub.
- Player-facing production: Worker only.
- Normal army unit production is not exposed from Command Hall.
- Direct player-facing construction remains hidden from Command Hall; Workers own building placement.
- Existing basic troop upgrades are migrated to Barracks so Command Hall no longer looks like an army-production building.

### Worker

- Role: construction unit.
- Existing build set remains Barracks, Mystic Lodge, and Watchtower.
- Construction assignment, pause/resume, and pathing rules remain the v0.18.3 baseline.
- No harvesting, repair, or multiple-worker acceleration is added.

### Barracks

- Role: basic army production.
- Completed Barracks trains Militia and Ranger.
- Completed Barracks researches the existing basic troop upgrades: Infantry Weapons I, Reinforced Armor I, and Ranger Training I.
- Incomplete Barracks remains inactive and cannot train or research.

### Mystic Lodge

- Role: mystic support.
- Completed Mystic Lodge trains Acolyte.
- Completed Mystic Lodge researches the existing Aether Study I upgrade.
- Incomplete Mystic Lodge remains inactive and cannot train or research.

### Watchtower

- Role: defense.
- Completed Watchtower attacks nearby enemies using its existing defensive attack.
- Incomplete Watchtower remains inert and cannot attack.

## UI Requirements

- Command buttons show action type, cost, lock status, and role/effect context through existing command-button surfaces.
- Selected completed buildings show readable role text.
- Selected incomplete buildings show construction status, progress, assigned Worker, and what completion unlocks.
- Inactive incomplete buildings expose no completed-building train/research actions.

## Tutorial Requirements

- Keep Tutorial / Proving Grounds at the same length.
- Clarify the existing route:
  - Command Hall -> Worker.
  - Worker -> building.
  - Barracks -> army.
  - Watchtower -> defense.
- Do not add a new Tutorial objective or a longer production chain.

## Retest Focus

1. Select Command Hall and confirm only Worker training is player-facing.
2. Train a Worker, place Barracks, and confirm incomplete Barracks is inactive.
3. Complete Barracks and confirm Militia/Ranger plus basic troop research are available there.
4. Place Mystic Lodge and confirm Acolyte/Aether Study are inactive while incomplete and visible when complete.
5. Place Watchtower and confirm incomplete Watchtower is inert and completed Watchtower attacks.
6. Recheck v0.18.3 Worker move-away pause/resume and compact base-cluster movement.
