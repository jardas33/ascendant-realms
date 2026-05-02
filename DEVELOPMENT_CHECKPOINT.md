# Development Checkpoint

Updated: 2026-05-02 17:31 -04:00

## Checkpoint Scope

This checkpoint records the clean pre-feature checkpoint pass after Unit Veterancy V1, Retinue Camp V1, Enemy Hero / Rival Commander V1, the retinue/enemy-hero telemetry balance passes, v0.2 product/readability polish, and the HeroProgressionRules refactor. No files were reset, checked out, deleted, or reverted.

The repository currently has verified Stronghold Tier II, reputation effects, randomized item affixes V1, affix display, equipment persistence, battle-local Unit Veterancy V1, compact Retinue Camp V1 persistence/deployment, named rival commanders, enemy-hero telemetry, retinue-aware telemetry profiles, and the focused `src/game/core/progression/` rule-module split. This pass made checkpoint documentation updates and one e2e wait hardening for Command Hall selection after the full suite exposed a slow HUD refresh; no gameplay behavior was changed.

Product/version copy follow-up: the visible main menu now says `Prototype v0.2` and shows `v0.2 Prototype - Campaign, Stronghold, Affixes, Veterancy and Retinue`. Playwright smoke coverage asserts the v0.2 label/subtitle and absence of `Prototype v0.1`.

Enemy Hero / Rival Commander V1 is now part of the checkpoint scope. The latest verified working tree has three named Ashen commanders, campaign node assignments, scout/battle/results feedback, objective credit, simulator telemetry, and no enemy construction, workers, new factions, diplomacy, procedural campaign, or raid-boss layer.

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
200 tests passed
Vitest duration: 16.85s
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
Latest build output: assets/index-WeVc0l2k.js, 1,863.80 kB minified / 444.10 kB gzip.
```

### Browser E2E

Command:

```bash
npm run test:e2e -- --reporter=line
```

Result:

```text
PASS
44 Playwright tests passed
Total duration: 23.3m
Slow files noted by Playwright: tests/e2e/deep-flow.spec.ts and tests/e2e/layout.spec.ts
```

Note: an initial full-suite run exposed a slow Command Hall selection HUD refresh in `tests/e2e/deep-flow.spec.ts`. The test helper now forces the HUD refresh and waits up to 20s for the Command Hall side panel. The focused rerun passed in 48.9s before the full suite was rerun.

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
Current expected visible product copy: Prototype v0.2 with subtitle "v0.2 Prototype - Campaign, Stronghold, Affixes, Veterancy and Retinue".
```

## Git And Branch Status

Checkpoint commit hash:

```text
pending; replace with the checkpoint commit hash after creating the commit
```

Checkpoint commit message:

```text
Checkpoint enemy heroes rival commanders and v0.2 polish
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
Before checkpoint commit creation, main and origin/main both pointed at b2da48effc0dca5d6cf91b38cc12801f00a87e16.
The local branch was not ahead or behind origin/main before committing.
The worktree was dirty with intentional code, test, telemetry, and documentation edits from v0.2 product copy, Unit Veterancy V1, Retinue Camp V1, readability UX, conservative retinue balance, Enemy Hero / Rival Commander V1, enemy-hero balance docs/telemetry, and e2e timing hardening.
A small metadata follow-up records the created checkpoint hash in this file and LLM_GAME_HANDOFF.md before pushing.
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
- Aether Well Ruins and Bandit Hillfort still need Normal human playtests from a typical early campaign save, including Veyra and Gorak readability.
- Ashen Outpost still needs manual validation with and without Chapel repair, including Captain Malrec readability.
- Retinue should be human-played on early nodes and Ashen Outpost to confirm it helps without becoming mandatory.
- Automated telemetry currently reports no structural too-hard or too-easy nodes after the Stronghold Tier II, reputation, affix, Unit Veterancy, Retinue Camp, and Enemy Hero / Rival Commander work, but balance remains prototype-level.
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

## Recommended Next Milestone

Rival/Nemesis Persistence V1.

Keep it compact: persistent rival identity/state should build on Enemy Hero / Rival Commander V1 without adding enemy construction, workers, new factions, diplomacy, procedural campaign, or a broad army-management layer.
