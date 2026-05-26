# v0.29 Implementation Report

Date: 2026-05-26

## Scope

v0.29 tightens active hero ability readability and the lightweight battlefield reward summary around the existing ability and reward systems. It does not add a new ability roster, enemy hero progression, inventory overhaul, complex loot, runtime art/assets, new maps/factions, save migration, broad AI/pathing changes, Patrol, formations, or global rebalance.

## Runtime Changes

- Preserved the existing `AbilitySystem` for Warlord, Arcanist, and Shepherd abilities.
- Added tested ability button readiness state helpers for ready, cooldown, and insufficient-mana states.
- Ability buttons now expose `data-ability-state`, disabled state, and readable text such as `Ready`, `Cooldown Ns`, or `Need N mana`.
- Rally Banner remains the safe command-buff example; Cleave remains the safe short-range burst example.
- Ability casts still spend mana and start cooldowns only after successful effects.
- Cooldown casts are rejected without spending additional mana.

## Rewards And Results

- Victory results summarize live battle XP plus victory reward XP through the existing results panels.
- Reward-table XP remains listed as `Reward XP`.
- Campaign node XP remains listed in the campaign reward block.
- Defeat and Tutorial continue to avoid saved battle XP or rewards.

## Tutorial Impact

- Tutorial / Proving Grounds keeps its step count and no-reward rule.
- Rally Banner tutorial hint now mentions mana, cooldowns, and that campaign XP saves only outside no-reward training.
- No extra RPG management step was added to the tutorial.

## Tests Added Or Expanded

- AbilitySystem tests for Rally Banner buff validity, cooldown spam prevention, and Cleave hostile-only damage.
- AbilityBar tests for readiness/cooldown/mana labels.
- Hero HUD tests for level/XP/stat/ability unlock summaries and disabled cooldown state.
- Hosted proxy tests for ability cooldown HUD state and repeat-cast blocking.
- Hosted proxy test for victory results showing battle XP, level-up, and reward XP.

## Verification Notes

Focused and full checkpoint verification passed:

```text
npm test -- src/game/core/progression/HeroLevelRules.test.ts src/game/entities/Hero.test.ts src/game/systems/XPSystem.test.ts src/game/systems/AbilitySystem.test.ts src/game/ui/AbilityBar.test.ts src/game/ui/hudPanels/HeroHudPanel.test.ts PASS, 6 files / 10 tests.
npm test -- src/game/battle/BattleRuntime.test.ts PASS, 12 tests.
npm test -- src/game/playtest/PlaytestPackageValidation.test.ts PASS, 3 tests.
npm test PASS, 72 files / 533 tests.
npm run build PASS with the known Vite Phaser chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "hero battle XP|hero ability buttons|victory results summarize" --reporter=line PASS, 3 hosted proxy tests.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release:shard1of3 PASS, 44 tests.
npm run test:e2e:release:shard2of3 PASS, 34 tests.
npm run test:e2e:release:shard3of3 PASS, 14 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run smoke:preview PASS at http://127.0.0.1:4173/ with Browser console errors: 0.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-4f78ac6-dirty generated.
npm run verify:playtest-package PASS, 83 checks.
```

`npm run test:e2e:release` was attempted but exceeded a 30-minute tool window before producing usable output. The three 3-way release shards passed afterward and preserve the full release suite coverage.
