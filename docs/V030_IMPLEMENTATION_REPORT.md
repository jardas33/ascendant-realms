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
