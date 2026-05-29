# v0.51 Implementation Report - Player UX Audit and Affordance Foundation

## Scope

v0.51 starts the v0.51-v0.53 player-facing polish checkpoint. It audits and improves existing battle UX surfaces without adding new gameplay systems, maps, factions, save fields, runtime art, or broad UI redesign.

## Runtime Changed

- Added a small pure cursor-intent rule for battle hover affordances.
- Exposed readable canvas cursor labels for attack, build, repair, assign, and invalid target states.
- Extended existing command buttons with stable command state and disabled-reason metadata.
- Added hero ability reason metadata for cooldown and resource readability.
- Slightly improved Burn status badge size, contrast, and health-bar separation.
- Slightly increased world hover tolerance for units to improve enemy/target confidence without changing commands.

## Save Format

No save-version bump and no new save fields.

## Verification

Focused coverage passed:

```text
npm test -- src/game/systems/CursorAffordance.test.ts src/game/ui/AbilityBar.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/entities/BaseEntity.test.ts src/game/playtest/PlaytestPackageValidation.test.ts PASS, 5 files / 20 tests.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "battle HUD supports minimap|Worker can be trained|Worker repairs|Worker assignment|hero ability buttons" --reporter=line PASS, 5 hosted tests.
```

Full checkpoint verification:

```text
npm test PASS, 76 files / 579 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-be51130-dirty` generated.
npm run verify:playtest-package PASS, 148 checks against the dirty pre-commit package.
```

Optional local release shard note: shard 2 and shard 3 passed. Shard 1 produced non-pass local-dev evidence with 43 passed / 1 failed on `tests/e2e/deep-flow.spec.ts:6064`; the exact failed case passed on immediate rerun. The hosted production-preview release lanes above are green.
