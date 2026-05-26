# v0.28 Implementation Report

Date: 2026-05-26

## Scope

v0.28 formalizes the player hero's live battle progression foundation. It uses the existing hero save, reward, stat, skill, and results systems. It does not add a save migration, new factions, new maps, runtime art/assets, inventory overhaul, enemy hero progression, broad AI/pathing changes, Patrol, formations, or global rebalance.

## Runtime Changes

- Added shared hero level stat-gain helpers so live battle level-ups match saved stat recalculation.
- Live hero level-ups now grant the existing modest HP and Mana gains, plus matching damage and every-other-level armor growth.
- Live hero level-ups still refill HP and Mana and grant skill points through the existing curve.
- Added one-time resource-site capture XP for the player hero through `XPSystem`.
- Capture-site XP is awarded once per site per battle and only when rewards are enabled.
- Tutorial no-reward behavior remains protected by the existing rewards-disabled launch flag.
- Victory completion continues to persist the live hero state and then applies reward-table XP through the existing results flow.

## UI And Readability

- The battle hero panel now shows XP, skill points, damage, armor, and ability unlock count.
- Existing floating/status XP feedback remains the live level-up notification surface.
- Results continue to show before/after XP progress, total XP gained, level-up count, and skill points gained.

## Balance Notes

- Site capture XP is intentionally small at `10` XP.
- Kill XP still uses existing unit/building `xpValue` data and the existing hero share radius.
- No early enemy pressure tuning was changed.
- No new ability, item, or class content was added.

## Tests Added Or Expanded

- Pure tests for hero level stat-gain rules.
- Hero live level-up test for HP, Mana, damage, armor, and skill points.
- XPSystem tests for valid kill XP, invalid/distant kills, and one-time site-capture XP.
- BattleRuntime test proving live battle XP is preserved on victory before reward XP is applied.
- Hosted proxy test proving battle XP can level the hero and update the HUD.

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
