# v0.434 First Real Combat, Damage, and Casualty Loop

## Executive summary

v0.434 is a bounded first-combat checkpoint on top of the accepted v0.433 worker/economy runtime. It closes the first real combat loop in the production Salto scene: a Barrosan spear unit and a newly trained Crag Archer can issue valid attacks against Lioraen enemies, apply real `GameData.compute_damage` damage, show reusable world-space health bars, remove dead units exactly once, and credit player kills from preserved source provenance. Attack-move engagement resumes its destination after a kill, while ordinary stop/move/order paths clear continuation state.

The implementation is opt-in through the v0.434 capture path and does not change the true default runtime, the accepted economy chain, stable IDs, saves, or unrelated gameplay systems.

## Base, branch, and review target

- Base v0.433-R1: `3b09035fc1001acd423801d46c557852daec8f70`
- Branch: `codex/v0434-first-combat-casualty-loop`
- Implementation commit: `9d5035443ccd5cafa39a555a3197cefc33893502`
- Stacked review target: `codex/v0433-multi-resource-worker-economy-loop`
- Stacked pull request target: PR #8
- Production scene: `production/ascendant-realms-godot/scenes/main.tscn`
- Review pack: `artifacts/manual-review/v0434-first-combat-casualty-loop/`

## Root causes repaired

The first combat slice exposed five concrete integrity gaps:

1. Attack commands could accept null, dead, self, friendly, non-combat, or unbuilt targets.
2. Attack-move had no durable engagement continuation and could lose its destination after a kill.
3. Delayed melee impacts did not revalidate attacker/target liveness, hostility, or range at impact time.
4. Projectile impacts did not preserve enough live source metadata for safe attribution after the source changed or died.
5. Death cleanup and kill credit could be duplicated or credited without proving a player-owned source.

The repair keeps rejection side-effect free, revalidates at impact, carries source/team/runtime identity through projectiles, deduplicates death records, and credits only player-team sources.

## Real runtime path

The capture is headed official Godot Forward Plus against the real production scene. The driver uses the public RTS controller commands, real War Hall production, real Crag Archer spawn, real direct attack and attack-move orders, and the production unit/projectile/death path. It does not inject HP, call `_die`, spawn a fake projectile, or synthesize combat events.

Commands:

```text
npm run godot:test:v0434-combat
npm run godot:smoke:v0434-combat
npm run godot:capture:v0434-combat
npm run godot:validate:v0434-combat
```

## Runtime evidence

The latest exact-source capture produced:

- 11 real damage events
- 3 real death events
- 3 player kill credits
- 2 ranged kills credited to `barrosan_crag_archer`
- 1 melee kill credited to `barrosan_spear_guard`
- one death record per victim, with roster and selection cleanup
- `GameData.compute_damage` used for every recorded damage event
- fresh-scene replay with zero stale combat events, target, projectile, attack-move, or selection state

The runtime audit is `v0434-runtime-combat-audit.json`. The formula, casualty, ranged-credit, melee-credit, and replay audits are retained beside it in the review pack.

## Combat behavior

`Unit.command_attack` now validates target type, liveness, self/friendly ownership, building readiness, and combat identity before mutating order state. Attack-move stores its destination, engages an enemy, and resumes the destination after the target dies. Move, stop, hold, patrol, guard, gather, build, direct attack, and death clear the continuation path as required.

Melee damage is delayed but rechecked at impact. The attacker and target must still be alive and hostile, and the target must still be in engage range. Ranged projectiles carry source unit ID, runtime ID, source team, and projectile kind through impact. Friendly fire is rejected, and duplicate impacts are prevented.

## Health and casualty presentation

Units expose reusable world-space `CombatHealthBar`, `HealthBarBackground`, and `HealthBarFill` children. Damaged units show the bar, dead units are hidden, and the selected-unit panel remains intact. The evidence frame `10_V0434_DAMAGED_UNIT_HEALTH_BARS.png` shows the real damaged-unit presentation. `v0434-health-presentation-audit.json` records the presentation contract.

Death handling is one-shot. It removes the unit from the live roster and selection, records the victim once, and awards veterancy/bounty only from a live player-owned source. Enemy-on-enemy and source-less damage cannot create player kill credit.

## Review evidence

The 20-frame pack contains real production screenshots for the setup, production, selection, direct attack, melee contact, projectile flight, damage, casualties, ranged/melee attribution, attack-move engagement/resume, stop clearing, fresh-scene replay, and the final contact sheet.

Key reviewed frames:

- `10_V0434_DAMAGED_UNIT_HEALTH_BARS.png` — real damaged unit and world-space health bar.
- `12_V0434_ARCHER_PROJECTILE_KILL.png` — real ranged encounter with production terrain/buildings and casualty state.
- `16_V0434_ATTACK_MOVE_ENGAGEMENT.png` — attack-move engagement in the production scene.
- `17_V0434_ATTACK_MOVE_RESUMED_DESTINATION.png` — continuation destination after the kill.
- `20_V0434_COMBAT_LOOP_CONTACT_SHEET.png` — real rendered contact sheet, not a title-card substitute.

Early setup frames are intentionally contextual. The later encounter, health, casualty, attribution, and attack-move frames are the authoritative visual proof. `v0434-black-frame-rejection.json` reports `all_real_gameplay: true`, with no black or blank rejection entries.

## Preserved scope

Preserved from v0.433/v0.432:

- multi-resource worker economy and War Hall production
- accepted state and production semantics
- stable IDs and saves
- current production art/runtime path
- true default runtime
- existing selection/HUD contracts

Explicitly out of scope:

- no new economy or resource mutation
- no AI or waves
- no pathfinding redesign
- no fog
- no broad animation pass
- no unrelated building, movement, or production features

The only new gameplay semantics are the requested first bounded direct-attack, damage, health, death, player-kill attribution, and attack-move continuation loop.

## Validation evidence

Passed locally:

- `npm run godot:test:v0434-combat`
- `npm run godot:smoke:v0434-combat`
- `npm run godot:capture:v0434-combat`
- `npm run godot:validate:v0434-combat`
- `npm run godot:smoke:v0433-worker-economy`
- `npm run godot:validate:v0433-worker-economy`
- `npm run godot:smoke:v0432-war-hall-production`
- `npm run godot:validate:v0432-war-hall-production`
- `npm run godot:import:production`
- `npm run godot:asset-scan:production`
- `npm run godot:smoke:production`
- `npm run godot:validate:production`
- `npm test` — 122 files, 887 tests
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run validate:runtime-art-slots`
- `npm run validate:artifact-retention`
- `npm run godot:all`
- `git diff --check`

The repository’s pre-existing historical untracked backlog was left untouched. Validation-generated tracked noise was restored before this report/evidence closeout so the v0.434 change set remains scoped.

## CI and closeout

The evidence closeout was pushed and verified by GitHub Actions:

- Exact final-source SHA before this documentation-only closeout: `94de933eb98502d0f20213e3a2560f26934c0c27`
- GitHub Actions run: `30513563109` / run 645
- Workflow: `CI Release Matrix Dry Run`
- Result: success
- Verified jobs: unit/pure-rule tests, production build, content validation, art-intake validation, E2E fast smoke, and production preview smoke

This report-only confirmation does not change combat behavior. The final documentation closeout commit and its exact-SHA Actions result are recorded in the repository handoff after this update.

## Final state target

The checkpoint is complete only when the v0.434 implementation/report/review pack are committed, the branch is pushed, the exact pushed SHA has a successful GitHub Actions run, and tracked local changes are clean and synchronized with the remote branch. The historical untracked backlog remains user-owned and is not part of this checkpoint.
