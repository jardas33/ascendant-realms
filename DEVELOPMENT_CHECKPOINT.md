# Development Checkpoint

Updated: 2026-05-02 11:51 -04:00

## Checkpoint Scope

This checkpoint records the clean pre-feature checkpoint pass after Unit Veterancy V1, Retinue Camp V1, the retinue telemetry balance pass, and the HeroProgressionRules refactor. No files were reset, checked out, deleted, or reverted.

The repository currently has verified Stronghold Tier II, reputation effects, randomized item affixes V1, affix display, equipment persistence, battle-local Unit Veterancy V1, compact Retinue Camp V1 persistence/deployment, retinue-aware telemetry profiles, and the focused `src/game/core/progression/` rule-module split. This pass changed checkpoint documentation only; no gameplay behavior was changed.

## Verification Results

### Unit Tests

Command:

```bash
npm test
```

Result:

```text
PASS
35 test files passed
194 tests passed
Vitest duration: 9.42s
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
```

Known build warning:

```text
Some chunks are larger than 500 kB after minification.
Main JS bundle: 1,845.84 kB minified / 439.59 kB gzip.
Latest build output: assets/index-BAXIULJg.js, 1,846.11 kB minified / 439.63 kB gzip.
```

### Browser E2E

Command:

```bash
npm run test:e2e -- --reporter=line
```

Result:

```text
PASS
43 Playwright tests passed
Total duration: 18.0m
Slow file noted by Playwright: tests/e2e/deep-flow.spec.ts, 10.7m
```

### Playtest Simulation

Command:

```bash
npm run playtest:sim
```

Result:

```text
PASS
Simulated 180 runs across 60 campaign battle node/profile summaries.
No structural too-hard nodes.
Too easy: none.
Ashen Outpost beatable: yes.
Stronghold warnings: none.
Regenerated PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json.
```

### Browser Use Preview Sanity

Target:

```text
http://127.0.0.1:4182/
```

Result:

```text
PASS
Title: Ascendant Realms
Main menu visible
Browser console errors: 0
Known copy/version mismatch: visible menu still says Prototype v0.1 while docs describe the v0.2 prototype baseline.
```

## Git And Branch Status

Checkpoint commit hash:

```text
CHECKPOINT_COMMIT_PENDING
```

Checkpoint commit message:

```text
Checkpoint unit veterancy retinue camp and progression refactor
```

Branch:

```text
main tracking origin/main
```

Remote:

```text
origin https://github.com/jardas33/ascendant-realms.git
```

Branch sync status at verification time:

```text
Before checkpoint commit creation, main and origin/main both pointed at 9cd3205e3d1be23ed967bd51f315bab3d39cc52e.
The local branch was not ahead or behind origin/main before committing.
The worktree was dirty with intentional uncommitted code, test, telemetry, and documentation edits from Unit Veterancy V1, Retinue Camp V1, retinue telemetry balance, release docs, and the HeroProgressionRules refactor.
Final post-push sync status: CHECKPOINT_SYNC_PENDING
```

Dirty files observed:

```text
BALANCE.md
CONTENT_GUIDE.md
DESIGN.md
DEVELOPMENT_CHECKPOINT.md
LLM_GAME_HANDOFF.md
README.md
ROADMAP.md
src/game/battle/BattleRuntime.test.ts
src/game/battle/BattleRuntime.ts
src/game/battle/BattleLaunchRequest.test.ts
src/game/battle/BattleLaunchRequest.ts
src/game/battle/BattleSceneResults.ts
src/game/battle/BattleSceneSpawner.ts
src/game/battle/BattleSceneSystems.ts
src/game/campaign/CampaignChoicePanel.ts
src/game/campaign/CampaignMapViewModel.test.ts
src/game/core/HeroProgressionRules.ts
src/game/core/RetinueRules.test.ts
src/game/core/RetinueRules.ts
src/game/core/progression/
src/game/core/SaveSystem.test.ts
src/game/core/StrongholdRules.test.ts
src/game/data/strongholdUpgrades.ts
src/game/data/unitVeterancy.test.ts
src/game/data/unitVeterancy.ts
src/game/entities/Unit.ts
src/game/playtest/ScriptedBattlePlaytest.test.ts
src/game/playtest/ScriptedBattlePlaytest.ts
src/game/results/ResultsNavigation.ts
src/game/results/ResultsObjectiveSummary.ts
src/game/results/ResultsRetinuePanel.ts
src/game/results/ResultsViewModel.test.ts
src/game/save/SaveDefaults.ts
src/game/save/SaveNormalization.ts
src/game/save/SaveTypes.ts
src/game/scenes/BattleScene.ts
src/game/scenes/CampaignMapScene.ts
src/game/scenes/ResultsScene.ts
src/game/systems/CombatSystem.ts
src/game/types/CombatTypes.ts
src/game/types/MapTypes.ts
src/game/ui/hudPanels/SelectedEntityPanel.ts
tests/e2e/deep-flow.spec.ts
.gitignore
PLAYTEST_TELEMETRY.md
PLAYTEST_TELEMETRY.json
CHANGELOG.md
RELEASE_CHECKLIST.md
src/game/campaign/RetinuePanel.ts
```

## Remaining Known Risks

- Full human-paced Border Village and Old Stone Road playthroughs still need timing and feel checks on Easy.
- Aether Well Ruins and Bandit Hillfort still need Normal human playtests from a typical early campaign save.
- Ashen Outpost still needs manual validation with and without Chapel repair.
- Retinue should be human-played on early nodes and Ashen Outpost to confirm it helps without becoming mandatory.
- Automated telemetry currently reports no structural too-hard or too-easy nodes after the Stronghold Tier II, reputation, affix, Unit Veterancy, and Retinue Camp checkpoint, but balance remains prototype-level.
- Mixed retinue, mixed retinue plus Training Yard II, and mixed retinue plus Quartermaster II are useful in Ashen Outpost and should be human-reviewed to ensure they do not feel mandatory.
- Audible audio behavior still needs human-ear confirmation.
- Full real-time victory from first click to enemy base kill remains manual QA.
- `ScriptedBattlePlaytest.ts` is now the largest file and should be kept focused if simulator coverage grows.
- `BattleScene` remains the highest live-scene integration risk.
- Save migration and normalization remain sensitive because localStorage compatibility must stay intact.
- `src/game/core/progression/ItemRewardRules.ts` is now the main focused hero reward/affix integration risk after the HeroProgressionRules split.
- The focused content validators are valuable but should be extended carefully because they protect many data contracts.
- Vite still reports the known large Phaser bundle warning.
- Balance is still prototype-level and should not be expanded with new systems until the current first-hour campaign feels good in manual play.

## Recommended Next Task

Human-paced campaign balance/readability review with no retinue, one Veteran Militia, one Veteran Ranger, mixed retinue, mixed retinue plus Training Yard II, and mixed retinue plus Quartermaster II.
