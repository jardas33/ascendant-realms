# v0.112 Hot Path Allocation Audit

Rows are code-path allocation audits backed by the v0.110 phase profiler and v0.111 clean-profile classification. Counts are per activation shape counts, not total heap bytes.

| Row | Owner | Before arrays | After arrays | Before filters/maps | After filters/maps | Optimization | Risk |
| --- | --- | ---: | ---: | ---: | ---: | --- | --- |
| fog-vision-sources | src/game/scenes/BattleScene.ts | 4 | 0 | 6 | 0 | Reusable source slots filled by ordered loops. | low |
| fog-current-sources | src/game/systems/FogOfWarSystem.ts | 1 | 0 | 1 | 0 | Copy source fields into reusable current-source slots. | low |
| fog-overlay-cells | src/game/scenes/BattleScene.ts | 3 | 0 | 2 | 0 | Use FogOfWarSystem.forEachCell for overlay and signature traversal. | low |
| status-empty-carriers | src/game/systems/StatusEffectSystem.ts | 1 | 0 | 1 | 0 | Skip empty carriers and filter only when an effect expires. | low |
| movement-idle-grid | src/game/systems/MovementSystem.ts | 2 | 0 | 3 | 0 | Tick buffs, then skip grid when no move target and no same-team overlap exists. | medium |
| combat-attackers | src/game/systems/CombatSystem.ts | 2 | 1 | 1 | 0 | Build the single attacker list with loops preserving unit then building order. | low |
| minimap-snapshot | src/game/battle/BattleSceneSnapshots.ts | 7 | 1 | 10 | 0 | Build markers with ordered loops and retain objective-site Set. | low |
| private-profiler-counts | src/game/scenes/BattleScene.ts | 4 | 0 | 4 | 0 | Check profiler enabled before building count snapshots; loop private counters. | low |
