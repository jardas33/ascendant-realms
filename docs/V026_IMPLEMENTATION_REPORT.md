# v0.26 Implementation Report

Date: 2026-05-26

## Scope

v0.26 adds controlled enemy base development on top of the v0.24-v0.25 resource-site AI. It uses abstract base stages and existing spawned structures only. It does not add classic harvesting, visible enemy Workers, enemy construction placement, new maps, new factions, new runtime art/assets, save migration, broad pathing changes, Patrol, formations, or global rebalance.

## Runtime Changes

- Added a pure enemy base-development planner with early, mid, and late strategy stages.
- Enemy stage selection now considers elapsed time, enemy-owned sites, improved enemy sites, stockpile health, researched tech, and nearby player threat.
- Enemy Stronghold now acts as the existing base hub role for abstract fortification.
- Enemy Barracks now acts as the existing military and hexfire support role for shared tech escalation.
- Existing enemy Watchtowers remain the defensive role when a map already includes one.
- Enemy raids, expansion squads, and attacks preserve a small defensive reserve when the base is threatened or the enemy has escalated.
- Base and high-value site defense still use existing combat commands and can override raids or attacks.

## UI And Readability

- Added short status lines for base development and defense, including `Enemy is fortifying.`, `Enemy defending base.`, and `Enemy defending site: ...`.
- Existing status priority, minimap pings, combat movement, capture rings, and selection panels remain the primary readable surfaces.

## Abstract Handling

Enemy base stages are abstract runtime strategy state only. They do not create or display Workers, do not place construction sites, do not add cargo or drop-off rules, and do not persist into saves.

## Tests Added Or Expanded

- Unit coverage for early/mid/late stage selection.
- Unit coverage for economy/site-control tech planning.
- Unit coverage proving base defense can override economy raids.
- Hosted deep-battle proxy coverage for economy-backed enemy tech, base defense, and late escalation.

## Verification Notes

Checkpoint verification:

```text
npm test -- src/game/ai/EnemyAIController.test.ts PASS, 18 tests.
npm test -- src/game/ai/EnemyAIController.test.ts src/game/systems/UpgradeSystem.test.ts src/game/systems/ResourceSystem.test.ts PASS, 3 files / 40 tests.
npm test PASS, 66 files / 522 tests.
npm run build PASS with the known Vite Phaser chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "enemy base tech" --reporter=line PASS, 1 hosted proxy test.
npm run test:e2e:release:hosted:deep-battle PASS, 24 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npx playwright test tests/e2e/smoke.spec.ts --grep "campaign Border Village launches" --reporter=line PASS, 1 focused smoke repro.
npm run test:e2e:release PASS, 89 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors.
npm run smoke:preview PASS with 0 browser console errors.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-6dfab6b-dirty generated.
npm run verify:playtest-package PASS, 78 checks.
```

In-app Browser was attempted, but the plugin runtime failed before page control with a kernel asset path error. Production preview smoke is the local browser sanity fallback for this checkpoint.
