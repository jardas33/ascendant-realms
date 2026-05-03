# Development Checkpoint

Updated: 2026-05-03 08:58 -04:00

## Checkpoint Scope

This checkpoint records the full verification pass for the v0.2.1 baseline candidate plus the minimal Chapter 2 scaffold before any Chapter 2 gameplay implementation.

The checkpoint includes the accumulated v0.2.1 prototype work: Unit Veterancy V1, Retinue Camp V1, Enemy Hero / Rival Commander V1, Rival / Nemesis Persistence V1, Rival Rewards and Trophies V1, Stronghold Tier II, reputation hooks, randomized item affixes V1, HeroProgressionRules split, playtest simulator split, CampaignRules split, permanent HUD/fog regression coverage, readability/planning docs, and the minimal non-playable Chapter 2 scaffold.

The Chapter 2 scaffold is metadata and UI preview only: chapter cards, locked/upcoming Cinderfen Road placeholder nodes, safe save normalization, content validation, and tests that prevent a missing future map from launching. No gameplay, balance, map, faction, worker, enemy construction, diplomacy, procedural generation, crafting, or save-format behavior changed during this checkpoint.

## Verification Results

### Unit Tests

Command:

```bash
npm test
```

Result:

```text
PASS
36 test files passed
217 tests passed
Latest duration: 11.91s
```

### Production Build

Command:

```bash
npm run build
```

Result:

```text
PASS
TypeScript compile passed
Vite production build passed
Latest output: assets/index-CZ2MQO2_.js, 1,888.89 kB minified / 450.96 kB gzip.
```

Known build warning:

```text
Some chunks are larger than 500 kB after minification.
```

### Browser E2E

Command:

```bash
npm run test:e2e -- --reporter=line
```

Result:

```text
PASS
49 Playwright tests passed
Total duration: 19.2m
Slow files noted by Playwright: tests/e2e/deep-flow.spec.ts and tests/e2e/layout.spec.ts
```

Note:

```text
Full Playwright coverage includes the permanent HUD/fog regressions plus the Chapter 2 locked/upcoming scaffold smoke assertion.
```

### Playtest Simulation

Command:

```bash
npm run playtest:sim
```

Result:

```text
PASS
Simulated 180 runs across 60 campaign battle nodes.
Regenerated PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json.
No structural too-hard nodes.
No structural too-easy nodes.
Ashen Outpost remains beatable.
```

## Git And Branch Status

Checkpoint commit message:

```text
Checkpoint v0.2.1 baseline and Chapter 2 scaffold
```

Checkpoint commit hash:

```text
2d5b0cd58da7ed61967d41b02c3b17b28c1fcbf2
```

Branch:

```text
main tracking origin/main
```

Branch sync status at verification time:

```text
Before the checkpoint commit, `git fetch origin` completed and `git status -sb` reported `## main...origin/main` with intentional dirty v0.2.1 docs, HUD/fog regression coverage edits, readability/planning docs, and Chapter 2 scaffold edits.
Checkpoint commit `2d5b0cd58da7ed61967d41b02c3b17b28c1fcbf2` was pushed successfully to `origin/main`.
This metadata follow-up records the pushed checkpoint. After the metadata follow-up is pushed, final `git status -sb` should report `## main...origin/main`.
```

## Remaining Known Risks

- Human spot-check the battle HUD hover behavior, command-button clickability, side-panel scroll retention, and captured-site fog reveal because those issues were tactile player reports.
- Human-review the minimal Chapter 2 scaffold copy on the campaign map before adding playable Chapter 2 content.
- Chapter 2 currently has no playable map, units, faction, event implementation, town service, or battle content; this is intentional.
- Human-play Border Village and Old Stone Road on Easy with no retinue, one Veteran Militia, one Veteran Ranger, and mixed retinue.
- Human-play Aether Well Ruins and Bandit Hillfort on Normal to confirm Gorak and Veyra add identity without unfair pressure.
- Human-play Ashen Outpost with and without Chapel repair, retinue, Stronghold Tier II, and Captain Malrec.
- Rival first-defeat rewards and trophies are automated and one-time, but still need human readability checks in Results and Campaign Map.
- Balance remains prototype-level even though the simulator reports no structural too-hard or too-easy nodes.
- `BattleScene`, `HUD.ts`, `PlaytestRunner.ts`, `PlaytestAnalyzer.ts`, save normalization, and campaign/results reward handoff remain the highest integration-risk areas.
- Vite still reports the known large Phaser bundle warning.

## Recommended Next Milestone

Chapter 2 vertical slice implementation. Keep it compact and do not move into workers, enemy construction, full new factions, diplomacy, procedural campaign, crafting, durability, broad loot complexity, a full trophy room, or broad army management.
