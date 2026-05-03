# Development Checkpoint

Updated: 2026-05-02 22:56 -04:00

## Checkpoint Scope

This checkpoint records the full verification pass after Rival / Nemesis Persistence V1, Rival Rewards and Trophies V1, the CampaignRules module split, and the follow-up HUD interaction plus captured-site fog polish.

The worktree also includes the accumulated v0.2+ prototype work: Unit Veterancy V1, Retinue Camp V1, Enemy Hero / Rival Commander V1, Stronghold Tier II, reputation hooks, randomized item affixes V1, HeroProgressionRules split, playtest simulator split, CampaignRules split, rival persistence/rewards/trophies, regenerated telemetry, documentation updates, and the player-reported HUD/fog UX polish. No files were reset, checked out, deleted, or reverted during this checkpoint.

One narrow UI fix was made during this verification because the first full e2e run exposed stale battle-HUD updates after the anti-flicker patch. `HUD.ts` now allows forced command/test-hook refreshes and a short deferred flush; `UISystem.ts` treats explicit zero-delta HUD refreshes as forced; the enemy-hero scout test hook refreshes its HUD status after re-announcing the commander. No gameplay, balance, map, faction, worker, enemy construction, diplomacy, or save-format behavior changed.

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
210 tests passed
Latest duration: 11.43s
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
Latest output: assets/index-jewPzW0W.js, 1,883.55 kB minified / 449.61 kB gzip.
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
45 Playwright tests passed
Total duration: 20.3m
Slow files noted by Playwright: tests/e2e/deep-flow.spec.ts and tests/e2e/layout.spec.ts
```

Note:

```text
An initial full-suite run failed 6 HUD/status-selection assertions after the narrow HUD/fog polish. A focused HUD stale-refresh fix was applied, the 7 affected paths passed in 3.8m, and the full 45-test Playwright suite then passed.
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
Checkpoint rival persistence rewards and HUD fog polish
```

Checkpoint commit hash:

```text
Pending until the checkpoint commit is created.
```

Branch:

```text
main tracking origin/main
```

Branch sync status at verification time:

```text
Before the checkpoint commit, git status reported `## main...origin/main` with intentional dirty code, test, telemetry, and documentation edits.
Push status is pending until the checkpoint commit is created.
```

## Remaining Known Risks

- Human spot-check the battle HUD hover behavior, command-button clickability, side-panel scroll retention, and captured-site fog reveal because those issues were tactile player reports.
- Human-play Border Village and Old Stone Road on Easy with no retinue, one Veteran Militia, one Veteran Ranger, and mixed retinue.
- Human-play Aether Well Ruins and Bandit Hillfort on Normal to confirm Gorak and Veyra add identity without unfair pressure.
- Human-play Ashen Outpost with and without Chapel repair, retinue, Stronghold Tier II, and Captain Malrec.
- Rival first-defeat rewards and trophies are automated and one-time, but still need human readability checks in Results and Campaign Map.
- Balance remains prototype-level even though the simulator reports no structural too-hard or too-easy nodes.
- `BattleScene`, `HUD.ts`, `PlaytestRunner.ts`, `PlaytestAnalyzer.ts`, save normalization, and campaign/results reward handoff remain the highest integration-risk areas.
- Vite still reports the known large Phaser bundle warning.

## Recommended Next Milestone

Do a human-paced v0.2+ campaign readability and balance review, especially retinue, rivals, rival rewards/trophies, HUD hover/scroll behavior, and captured-site fog. Keep the next work compact and do not move into workers, enemy construction, new factions, diplomacy, procedural campaign, crafting, durability, broad loot complexity, or a full trophy room yet.
