# v0.30 Rival Champion Foundation Implementation Report

Date: 2026-05-27

## Scope

v0.30 formalizes and tightens the existing named enemy commander scaffold. Runtime changes are limited to enemy AI commander selection and tests. No new maps, factions, art, save migration, global rebalance, pathing rewrite, Patrol, formations, or broad ability work were added.

## Implemented

- Kept rival champions on the existing `enemy_commander` unit slot and existing visuals.
- Preserved launch-time opt-in through `enemyHeroId`.
- Preserved campaign node validation for enemy hero references.
- Preserved existing battle telemetry for commander presence, pressure, joined attacks, and defeat.
- Preserved objective/result readability for named commanders.
- Tightened enemy AI so rival champions do not join resource-site capture, retake, or raid squads.
- Prioritized rival champions in base/site defense squads.
- Restricted rival champions to late, coordinated base attacks only when the base-development plan is late, has an attack-wave bonus, the commander join delay has passed, at least one attack already launched, and enough escort units are available.

## Runtime Impact

Runtime changed: yes, narrowly.

The change affects only enemy AI unit selection for live enemy champion units. It does not change combat formulas, pathing, unit stats, map data, save data, or campaign progression.

## Tests Added Or Extended

- Rival champion stays out of resource-site raids.
- Rival champion defends threatened sites.
- Rival champion joins only late coordinated attacks with escorts.
- Existing first-battle commander pacing remains protected.
- Hosted Ashen Outpost proxy still scouts, defeats, and summarizes Captain Malrec.

## Status

Local focused tests, hosted commander/relic proxy coverage, hosted deep-meta, hosted deep-battle, hosted smoke, hosted deep-campaign-pressure, visual QA, and the broad unit/build/validation/control/smoke gates passed. Full local release was attempted and exposed one transition-helper issue in the first deep-meta test; the narrow helper call fix passed in targeted rerun and hosted deep-meta.

Remote closeout:

- Commit `4b72481` contains the v0.30-v0.31 runtime/reward implementation.
- Push run `26510324409` on `4b72481` passed Fast confidence.
- Manual release-matrix run `26510633476` on `4b72481` failed hosted deep-battle only; root cause was hosted minimap click actionability/timing in an overloaded behaviour gauntlet.
- Commit `e466870` stabilized hosted minimap clicking without force clicks or canvas/world DOM fallback.
- Push run `26512926475` on `e466870` passed Fast confidence.
- Manual release-matrix run `26513207423` on `e466870` still failed hosted deep-battle only; root causes were hosted canvas/minimap actionability pressure in the overloaded behaviour gauntlet and a stale first-campaign rally-order assertion after durable rally progress was already satisfied.
- Commit `62e35ae` narrowed duplicated gauntlet setup, kept real verified canvas/world pointer input, added minimap-only coordinate fallback for the minimap UI control, and changed the stale rally assertion to durable rally progress.
- Push run `26518961193` on `62e35ae` passed Fast confidence.
- Manual release-matrix run `26519266738` on `62e35ae` passed Fast confidence, Release simulator, hosted deep-meta, hosted deep-battle, hosted deep-campaign-pressure, hosted layout-core, hosted layout-cinderfen, and hosted smoke.
