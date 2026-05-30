# V074 Adaptive Pressure and Readability Spec

## Goal

Make battlefield events feel connected to the known enemy doctrine and selected tactical plan while keeping pressure stable, readable, and mission-local.

## Doctrine Hooks

- Raider favors Site Under Threat against resource sites and Workers.
- Fortress favors Hold the Line or defended-objective pressure.
- Hunter favors Retinue/hero pressure reminders and elite/commander reads.
- Warband favors readable coordinated pressure windows.

## Tactical Plan Hooks

- Guarded Advance helps Hold the Line and Retinue readiness events.
- Resource Push helps site-control events.
- Champion Hunt helps elite/commander and Aether Surge events.
- Plan support is a modest timer, bonus, or copy change rather than an auto-complete.

## Readability Rules

- HUD event copy should be short: title, objective, timer, counterplay.
- Results should summarize what happened without crowding reward/relic/skill text.
- Minimap pings may highlight relevant sites or safe Retinue timing.
- Events must not surprise-kill Retinue or erase Safe Beginner Act 1 stability.

## Integration Boundaries

- Preserve Retinue recovery/reinforcement, tactical plans, doctrines/elites, Workers/sites, control groups, Patrol, hero skills/relics, replay rules, and Act 1 telemetry.
- No broad AI/pathing rewrite.
- No global balance changes.
- No Tutorial complexity.

## Deferrals

- Enemy doctrine swapping mid-battle.
- Event-specific enemy formations.
- Campaign-level event memory.
- New art or audio.
