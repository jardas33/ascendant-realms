# v0.66 Enemy Tactical Doctrines Implementation Report

## Summary

v0.66 adds a small data-driven enemy doctrine layer on top of the existing enemy AI. The goal is readable enemy intent, not a difficulty spike or a new AI rewrite.

## Runtime Changes

- Added four conservative doctrine definitions: Raider, Fortress, Hunter, and Warband.
- Selected doctrines from existing campaign mission type, scenario modifiers, enemy hero milestones, and Tutorial/no-reward protections.
- Added Raider site/Worker pressure tuning through the existing resource-site raid path.
- Added Fortress reserve and tech-timing tuning through existing defensive reserve and upgrade paths.
- Added Hunter hero/Retinue pressure only after a cooldown, with an escort requirement and existing attack orders.
- Added Warband late mixed-push tuning only after the battle has had time to develop.
- Recorded doctrine id and doctrine action telemetry in battle stats and Results data.

## Rules Preserved

- Tutorial / Proving Grounds and rewards-disabled routes do not receive doctrine complexity.
- No new maps, factions, art assets, save migration, broad pathing rewrite, enemy formation rewrite, global rebalance, or spam loop was added.
- Doctrine hooks are mission-local and cooldown-gated.

## Verification Notes

- Unit coverage validates doctrine selection, no-spam timing, mission hooks, and AI action telemetry.
- Hosted proxy coverage validates Raider and Fortress doctrine readability through campaign, battle HUD, and Results surfaces.
- Full checkpoint verification is tracked in the handoff and checkpoint docs.
