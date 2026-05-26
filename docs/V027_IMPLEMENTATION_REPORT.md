# v0.27 Implementation Report

Date: 2026-05-26

## Scope

v0.27 lets enemy strategy escalate into existing research and stronger coordinated pressure when its economy is healthy. It keeps tech conservative and existing-system-only: no new tech roster, no new units, no new maps, no enemy construction rewrite, no visible enemy Workers, no classic harvesting, and no global army-stat buff.

## Runtime Changes

- Enemy AI can queue existing upgrades through `UpgradeSystem` using enemy-owned structures and enemy resources.
- Enemy tech is delayed, cooldown-gated, and blocked while an enemy upgrade queue is already active.
- Enemy Stronghold can queue `camp_foundations_1` as a base-hub fortification role.
- Enemy Barracks can queue existing military/aether upgrades that already affect Ashen units.
- Existing enemy Watchtowers can queue `sentry_bracing_1` only after `camp_foundations_1` is researched.
- Enemy tech candidates are filtered by affordability, existing building support, completed-role prerequisites, researched state, and active queues.
- Late-stage pressure can select a slightly larger wave from existing units only when enemy site control and economy are healthy.
- Late pressure still keeps a defensive reserve and can be interrupted by base/site defense.

## Existing Upgrade Adjustments

- Shared upgrade effects now include relevant Ashen targets where the enemy can research them:
  - `camp_foundations_1` can improve the Enemy Stronghold as a base hub.
  - `infantry_weapons_1` already improves Raiders.
  - `reinforced_armor_1` now also improves Raiders, Hexers, and Brutes.
  - `aether_study_1` now also improves Hexers.
  - `sentry_bracing_1` continues to improve Watchtowers and keeps the Camp Foundations prerequisite.

These are research-gated effects, not global free buffs.

## UI And Readability

- Enemy tech and escalation use short battle status lines: `Enemy tech is advancing.`, `Enemy is fortifying.`, `Enemy raid forming at ...`, and `Enemy pressure is escalating.`
- Existing selected-site copy from v0.24-v0.25 continues to show contested, upgraded, and logistics state.

## Tests Added Or Expanded

- Unit coverage for tech choice from economy/site control.
- Unit coverage proving enemy tech pays normal upgrade costs.
- Unit coverage proving locked Watchtower defense tech waits for Camp Foundations.
- Unit coverage proving unsupported or impossible upgrades are not selected.
- Existing v0.24-v0.25 raid cooldown, retake, defense, upgrade, abstract logistics, and Worker/site-loss tests remain in the same file and continue to pass.
- Hosted deep-battle proxy coverage for economy tech, base defense, and late escalation.

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
