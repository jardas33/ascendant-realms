# v0.16.7 Combat Contact And Aggro Audit

Date: 2026-05-21

## Files Audited

- `src/game/systems/CombatSystem.ts`
- `src/game/systems/InputSystem.ts`
- `src/game/systems/MovementSystem.ts`
- `src/game/systems/BehaviourModeSystem.ts`
- `src/game/systems/CollisionSystem.ts`
- `src/game/systems/SelectionSystem.ts`
- `src/game/entities/Unit.ts`
- `src/game/entities/Building.ts`
- `src/game/entities/BaseEntity.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/battle/BattleSceneSystems.ts`
- `src/game/ai/EnemyAIController.ts`
- `src/game/systems/CombatSystem.test.ts`
- `tests/e2e/deep-flow.spec.ts`
- v0.14.4, v0.15, v0.16 behaviour/control docs

## Findings

### Adjacent Melee After First Kill

`CombatSystem` already clears a dead explicit target and can acquire another hostile through opportunistic acquisition. The v0.14.4/v0.15 contact tests cover adjacent target reacquisition, but the current melee contact threshold uses raw range plus circular radii plus a small visual margin.

The manual report points at a visible-contact edge case: ground rings and sprite footprints can read as adjacent while center distance is slightly outside the current contact threshold. Hold Ground also depends on that same threshold for non-direct-contact enemies, so the contact interpretation needs to match the visible footprint without turning Hold Ground into distant chase.

### Enemy Melee Building Aggro

Enemy units already consider hostile buildings valid acquisition targets inside `DEFAULT_AGGRO_RADIUS`; the issue is the attack-contact check. Building collision/pathing uses a rectangular footprint plus static obstacle padding, while melee attack contact currently uses the building's circular `radius`, which is `max(width, height) / 2`.

For Command Hall-style buildings, a melee unit can be visually beside or blocked by the rectangular obstacle while still outside the circular center-distance melee contact threshold. In that state the unit keeps trying to move closer instead of attacking. Ranged units are less affected because their raw weapon range already reaches the building, matching Emmanuel's report that ranged units seemed to attack while many melee units idled.

### Retreat / Move-Away Priority

`Unit.commandMove(..., false)` clears explicit attack state and starts `moveOrderCombatSuppressionSeconds`. `CombatSystem.resolveTarget` suppresses opportunistic reacquisition while the player unit has both a normal move target and positive suppression time.

The brittle edge is that suppression only applies when `moveTarget` is still present. If pathing clears the move target early because the target is unreachable, invalid, or treated as complete, the next combat frame can reacquire immediately. That matches the manual report where retreat usually works but one unit near multiple enemies can stop and keep fighting while the rest move.

### Attack Hover Hit Tolerance

`BattleScene.findWorldEntityAt` uses `CollisionSystem.findEntityAt`, which checks raw entity radius. `SelectionSystem.selectAt` is already more forgiving for player selection by using `Math.max(entity.radius, 22)`. Attack hover/click intent does not get that forgiveness, so small enemies can require hovering a tiny center spot even though their sprite, label, healthbar, or ground ring reads larger.

The right fix is a small interaction hit radius for world entity lookup, still bounded enough that empty terrain near an enemy remains empty terrain.

## Audit Question Answers

1. After a melee target dies, a unit can reacquire another adjacent hostile if that hostile falls inside the current effective range; the manual evidence suggests the effective range is too strict for some visible-contact placements.
2. Hold Ground can refuse too much after a kill when the next hostile is visually adjacent but just outside circular contact range. It still correctly refuses distant idle enemies.
3. Enemy melee units do consider buildings and Command Hall valid hostile targets.
4. Enemies do not require a building to attack them first before acquiring it; acquisition is local aggro based.
5. Melee reach is based on raw range plus circular body radii and a visual margin. It does not account for rectangular building corners/padding.
6. Move-away suppression can effectively expire too early if movement/pathing clears the move target before the suppression timer finishes.
7. Explicit move commands clear attack target state, but opportunistic reacquisition can resume once the move target disappears.
8. Collision/pathing can make one unit in a group behave differently from the others if its route is blocked or invalidated.
9. Attack-hover hit testing uses the raw entity radius and is smaller than selected-unit tolerance.
10. Enemy label/health/sprite hover area can be larger than the raw hit circle, especially for small units.

## Smallest Safe Fix

- Interpret melee visual contact slightly more generously for unit-vs-unit contact while preserving Hold Ground distant refusal.
- For melee unit-vs-building contact, use a building footprint-aware range based on the building rectangle diagonal plus the existing visual contact margin.
- Keep player move-away suppression active for its intended short window even if movement clears the move target early.
- Add a small world-entity interaction hit minimum/padding used by `BattleScene.findWorldEntityAt`, then test that empty nearby terrain still does not count as attack intent.

## Not A v0.16.7 Fix

- Worker construction is deferred.
- Patrol, formations, broad AI/pathing, save persistence, new art/assets, new units, new buildings, balance tuning, and enemy wave timing changes are out of scope.
