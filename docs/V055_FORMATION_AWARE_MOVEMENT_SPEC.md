# v0.55 Formation-Aware Movement Spec

## Goal

Improve multi-unit movement readability by avoiding identical move targets for grouped units while preserving the existing pathing, collision, retreat, Worker, and attack command systems.

## Runtime Rules

- When two or more selected player units receive a normal move or attack-move command, each unit receives a conservative destination offset around the clicked point.
- The first unit keeps the clicked point. Additional units use the existing spiral offset pattern.
- Offsets are accepted only when they are inside the map, near the clicked point, not clearly inside blocked terrain, and not inside an alive building footprint.
- If an offset is unsafe, the command falls back to the clicked point or a smaller safe offset.
- Attack commands, Worker build/repair/resource-site orders, rally point orders, and explicit retreat behavior keep their current semantics.

## Readability

- Group movement status copy uses the existing order summary.
- Multi-unit move command feedback says `Group move accepted` or `Group attack-move accepted` when more than one unit receives separated destinations.
- No formation editor, facing control, rank columns, or broad pathing rewrite is added.

## Safety

- Uses existing movement/pathfinding after assigning targets.
- Does not change unit speed, collision radius, combat ranges, AI behavior, campaign balance, or map data.
- Graceful fallback is required when terrain or building blockers make a destination offset invalid.

## Deferrals

- No saved formations.
- No enemy formation AI.
- No dynamic obstacle reservation or flow fields.
- No per-unit role positioning beyond simple safe offsets.
