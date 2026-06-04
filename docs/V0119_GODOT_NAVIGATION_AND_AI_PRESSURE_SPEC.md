# v0.119 Godot Navigation And AI Pressure Spec

v0.119 adds bounded Godot-only placeholder navigation and pressure logic so the benchmark measures a representative RTS workload without creating a full pathfinding or AI strategy system.

## Navigation

- Box select uses the friendly squad subset.
- Move orders apply formation-lite offsets.
- Movement tracks accepted commands, completed movement, navigation query count, and stuck-unit count.
- Obstacle handling uses a deterministic rectangular nudge around placeholder structures.
- The benchmark rejects stuck-unit evidence in required headless tests.

## AI Pressure

- Target choice is deterministic: nearest valid target with stable ID tie-breaking.
- Tier S has no autonomous pressure beyond representative command/combat handling.
- Tier M records one bounded enemy-pressure beat.
- Tier L records sustained enemy pressure during the combat phase.
- Cooldowns, attack ranges, damage, death counts, and site contest state are tracked.

## Site And Lume State

- Capture sites track neutral, friendly, enemy, and contested ownership.
- Lume links track active, severed, restored, and candidate states.
- Both modes preserve `linked_ward` at exactly `0.92`.
- Results readiness is reached during the combat phase and recorded in the benchmark report.

## Boundary

This is spike logic only. It does not alter browser gameplay pathing, browser AI, campaign state, save data, balance, factions, stable IDs, or runtime art.
