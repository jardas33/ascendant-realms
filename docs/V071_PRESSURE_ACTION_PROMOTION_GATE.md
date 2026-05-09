# v0.7.1 Pressure Action Promotion Gate

Date: 2026-05-09

Status: Phase 7 decision gate for v0.7.1 Enemy Pressure Feel Review and Warning Polish.

Decision: keep `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` warning/telemetry-only for now. Do not promote any of them into stronger live combat behavior during v0.7.1.

This document is intentionally conservative. v0.7.1 is a readability, warning-salience, telemetry, and balance-review gate. It is not a feature expansion and must not become enemy construction, workers, hidden spawning, enemy economy, new units, new maps, new factions, capture-site AI, or a broad `BattleScene` rewrite.

## Evidence Summary

- Current simulator scope: 255 deterministic runs across 85 campaign battle node/profile summaries.
- Pressure scope: `cinderfen_crossing` and `cinderfen_watch` only.
- Pressure-enabled Cinderfen runs: 75.
- Triggered pressure runs: 63.
- Warnings shown: 149.
- Simulated reinforcement applications: 0.
- Enemy-pressure analyzer warnings: none.
- Structural `too_easy`: none.
- Structural `too_hard`: none.
- Cinderfen Crossing: 26 wins / 0 defeats / 13 timeouts.
- Cinderfen Watch: 25 wins / 0 defeats / 11 timeouts.
- Ashen Outpost: unaffected by pressure.

The current evidence supports warning salience and report clarity. It does not prove that stronger live actions would be fair, readable, or necessary.

## `reinforce_next_wave`

Player value:

- Could make the enemy feel like it answered a captured route or player advance with a more concrete tactical response.
- Could make Watchpost pressure matter more against strong or fast player openings.
- Could give warning copy a visible follow-through if the next wave clearly changes.

Risk:

- Easy to blur into hidden unit spawning if the units are not clearly sourced from an existing future wave or existing training rules.
- Can create invisible difficulty spikes because the player may not know why a wave became larger.
- May punish Greedy Economy timeouts without producing a better learning signal.
- Can make Fast Army/retinue balance worse by encouraging pressure buffs aimed at the strongest profiles.
- Requires careful distinction from forbidden enemy construction, workers, and economy simulation.

Required tests:

- Unit tests proving reinforcement only affects explicit campaign pressure nodes.
- Unit tests proving tutorial, skirmish, Ashen Outpost, and Chapter 1 remain pressure-free.
- Runtime tests proving the action uses existing unit ids only, respects validation, and does not place units as construction.
- E2E test showing warning copy appears before the reinforced wave matters.
- Simulator determinism test proving `reinforcementApplied` is stable and readable.

Required telemetry:

- Per-plan reinforcement counts.
- First reinforced-wave time.
- Losses after reinforced waves, separated from losses after warning-only stages.
- Strategy split for Safe Beginner, Greedy Economy, Fast Army, and retinue profiles.
- Analyzer warning if reinforced pressure creates structural too-hard, warning invisibility, or a single dominant strategy.

Required human-play evidence:

- Human players notice the warning before the stronger wave arrives.
- The stronger wave feels like a response to the route objective, not an unexplained spawn.
- Safe Beginner can still stabilize without perfect inputs.
- Greedy Economy timeouts feel like strategic debt, not surprise punishment.
- Retinue + Training Yard II does not force enemy escalation just to remain relevant.

Files likely touched:

- `src/game/battle/EnemyPressureRuntime.ts`
- `src/game/ai/EnemyAIController.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/playtest/PlaytestRunner.ts`
- `src/game/playtest/PlaytestTypes.ts`
- `src/game/playtest/PlaytestAnalyzer.ts`
- `src/game/playtest/PlaytestReportWriter.ts`
- `tests/e2e/enemy-pressure.spec.ts`

Why not now:

- v0.7.1 telemetry has no pressure-specific structural problem to solve.
- Current warnings and status-priority changes need human readability review first.
- Adding units to future waves would be a mechanics promotion, not warning polish.

Safest future first implementation:

- Add one explicit simulator-only experiment profile before live runtime promotion.
- Limit it to one existing unit added to one future wave on `cinderfen_watch` only.
- Require the pressure warning to fire at least 20-30 seconds before the adjusted wave.
- Keep `reinforcementApplied` false in live runtime until simulator and human play both pass.

## `contest_capture_site`

Player value:

- Could make Cinderfen Crossing's Cinder Shrine feel more contested.
- Could make the causeway identity more visible when the player claims the central route.
- Could create a clearer tactical loop: take shrine, hold route, then push.

Risk:

- Real contest behavior requires movement/pathing decisions, target selection, and site ownership timing.
- If implemented as spawned contest units, it becomes hidden spawning and risks violating the no-construction/no-new-economy boundary.
- If implemented by redirecting existing units, it can weaken base defense or produce odd pathing without a broader AI rewrite.
- Can conflict with neutral camps, capture-site ownership rules, and the existing wave/defense behavior.
- Could bloat e2e runtime because assertions would need to wait for movement and site interactions.

Required tests:

- Unit tests for route-target selection using existing units only.
- Runtime tests proving no units or buildings are created to contest the site.
- Pathing/regression tests for selected maps, especially Cinderfen Causeway.
- E2E test verifying the site can be contested visibly without requiring a full victory.
- Negative coverage for Tutorial, Skirmish, Ashen Outpost, and Chapter 1.

Required telemetry:

- Contest order issued yes/no.
- Existing unit source category, such as wave unit or defender, without adding new units.
- Time from warning to contest arrival.
- Capture-site owner before and after contest pressure.
- Player losses and site recaptures after contest pressure.

Required human-play evidence:

- Players understand that the shrine route is being contested.
- The contesting force is visible and not perceived as unfair spawning.
- Holding the shrine feels valuable but not mandatory.
- Fast Army can still bypass the route without making the plan feel broken.

Files likely touched:

- `src/game/battle/EnemyPressureRuntime.ts`
- `src/game/ai/EnemyAIController.ts`
- `src/game/systems/PathfindingGrid.ts`
- `src/game/systems/CombatSystem.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/playtest/PlaytestRunner.ts`
- `tests/e2e/enemy-pressure.spec.ts`

Why not now:

- v0.7.1 is not a capture-site AI goal.
- Current evidence says Crossing pressure is safe but sometimes bypassed, not broken.
- Promoting this action would need movement/pathing proof and human visibility review.

Safest future first implementation:

- Prototype only in simulator/reporting first, marking when an existing future wave would be assigned a shrine-route objective.
- If live promotion is later approved, redirect one already-launched existing wave toward the shrine only when the route is clear and the warning already fired.
- Do not spawn contest units, create patrols, add workers, or alter capture-site rules.

## `defensive_hold`

Player value:

- Could make late tower/stronghold pushes feel like the enemy is bracing for the final assault.
- Could support Cinderfen Watchpost identity around its raised-road tower and enemy base.
- Could make late warnings feel more concrete without changing early pressure.

Risk:

- Defense behavior is already tied to existing AI personality, defense radius, building positions, and wave launch state.
- A stronger hold can produce frustrating base turtling or pathing stalls.
- If it increases unit creation or resource behavior, it becomes forbidden enemy economy/construction pressure.
- If it changes global AI defense logic, it risks a broad `EnemyAIController` or `BattleScene` rewrite.

Required tests:

- Unit tests proving the hold only affects existing units and existing buildings.
- Runtime tests proving hold scope is local to selected pressure nodes.
- Simulator tests separating late-hold timing from ordinary late wave pressure.
- E2E coverage that launches the node and observes the warning without requiring a long victory.
- Regression coverage for normal generic battle messages and objective priority.

Required telemetry:

- Defensive hold stage triggered yes/no.
- First hold time.
- Player losses after hold.
- Battle duration after hold.
- Timeout rate after hold.
- Analyzer warning if late hold increases structural timeouts.

Required human-play evidence:

- Players understand the late warning as a prompt to regroup before pushing.
- The hold does not feel like the enemy is building a new base or receiving hidden defenders.
- Late Cinderfen fights remain finishable without retinue/Stronghold power spikes.

Files likely touched:

- `src/game/battle/EnemyPressureRuntime.ts`
- `src/game/ai/EnemyAIController.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/playtest/PlaytestRunner.ts`
- `src/game/playtest/PlaytestAnalyzer.ts`
- `tests/e2e/enemy-pressure.spec.ts`

Why not now:

- v0.7.1 has no late-hold balance problem to solve.
- Cinderfen already has human-review watchpoints around Fast Army, Greedy Economy timeouts, and Retinue + Training Yard II.
- Defensive behavior changes risk becoming a broad AI behavior pass.

Safest future first implementation:

- Keep the stage warning-only until a human play pass confirms late pushes feel unclear.
- If approved later, add a local temporary defense-radius modifier around the existing enemy stronghold only, with no unit creation and no economy effect.
- Gate it to one node and one late stage, then require simulator and targeted e2e proof before expanding.

## Overall Promotion Decision

Do not promote stronger actions in v0.7.1.

The next useful work is human play review, not more mechanics. The project should first verify that the new warning copy, pressure priority, and telemetry reporting make the current V1 pressure understandable. Only after that should a future goal consider one tiny simulator-first experiment for one action on one node.
