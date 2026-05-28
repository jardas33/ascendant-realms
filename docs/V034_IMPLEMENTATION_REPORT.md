# v0.34 Relic Reward Choice Implementation Report

Date: 2026-05-27

## Scope

v0.34 replaces the v0.32-v0.33 source relic auto-grant with a tiny inline Results choice flow for eligible rival champion victories. The implementation stays inside existing Results, hero save, item inventory, and equipment structures. It does not add maps, factions, runtime art/assets, shop, crafting, broad inventory UI, a modal picker, save-version bump, global rebalance, Patrol, formations, broad AI/pathing rewrite, or canvas/world force-click behavior.

## Reward Choice

- Eligible non-Tutorial campaign victories that defeat a known rival champion now create a `RelicRewardChoice` before any relic is added to inventory.
- The source champion relic is first when unowned, and one additional unowned relic appears when available.
- If only one unowned relic remains, Results shows a one-choice confirmation.
- If every relic is already owned for an otherwise eligible first-defeat or catch-up reward, the existing unique duplicate conversion applies once.
- Repeat clears do not repeatedly farm relic duplicates.

## Results Flow

- Results shows an inline `Relic Reward Choice` block with source copy, rarity, Warrior/Seer/Commander archetype, effect summary, stat summary, tags, and owned state.
- Choosing a relic immediately grants the selected persistent item instance, saves the hero, replaces the choice with the final `Relic Reward` block, and preserves the existing `Equip Relic` action.
- The Ashen Outpost hosted proxy now verifies that the choice appears before inventory mutation, selection grants `Outpost Command Signet`, and equipping from Results updates the hero save.

## Relic Pool

No new relics were added. v0.34 keeps the tiny three-relic pool:

- `emberbrand_shard`
- `cinderseer_focus`
- `outpost_command_signet`

## Tutorial Impact

Tutorial / Proving Grounds still uses the no-save/no-reward launch. It does not create a relic choice, does not grant a relic, and does not show the final Relic Reward block.

## Verification

Required verification passed:

```text
npx vitest run src/game/core/RelicRewardRules.test.ts src/game/core/RivalRules.test.ts src/game/results/ResultsViewModel.test.ts src/game/ui/hudPanels/HeroHudPanel.test.ts src/game/data/contentValidation.test.ts src/game/playtest/PlaytestPackageValidation.test.ts PASS, 6 files / 70 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm test PASS, 73 files / 549 tests.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Ashen Outpost special objectives" --reporter=line PASS, 1 hosted test.
npm run test:e2e:smoke:fast PASS on rerun, 8 tests.
npm run test:e2e:smoke PASS on rerun, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS after the relic-choice click-helper follow-up, 7 tests.
npm run visual:qa PASS on rerun, 5 tests / 18 screenshots / 0 console errors / 0 screenshot retries.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-2a411ed-dirty` generated.
npm run verify:playtest-package PASS, 105 checks against the dirty pre-commit package.
git diff --check PASS.
```

Optional `npm run test:e2e:release` was attempted. The first run exposed one mobile-short layout itinerary exceeding the default 35s budget; the test now uses the existing targeted hosted-layout-core timeout and the exact case passes. The second run exposed the new relic-choice click helper treating a successful disappearing choice button as a failure; the helper call now accepts the final Relic Reward state, and the focused hosted Ashen Outpost plus hosted deep-campaign group pass. The full optional lane was not used as final release evidence.
