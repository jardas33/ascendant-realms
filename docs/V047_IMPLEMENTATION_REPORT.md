# v0.47 Onboarding and Player Guidance Implementation Report

Date: 2026-05-29

## Scope

v0.47 improves campaign and Results guidance so the player understands the next practical action after Act 1 milestones: capture sites, produce Workers, build production, use resources, spend skill points, equip relics, and replay optional objectives.

## Runtime Changes

- Updated `FirstExperienceGuidance` to distinguish Tutorial / Proving Grounds from Border Village as the first persistent campaign battle.
- Added base-development reminders for Old Stone Road.
- Added resource-site assignment and upgrade reminders for Aether Well Ruins.
- Added rival-pressure and army-staging reminders for Bandit Hillfort.
- Added relic equip, skill spending, and replay objective reminders for Ashen Outpost.
- Updated Results status and guidance to mention next mission unlocks, replay availability, skill spending, and relic equip paths when relevant.
- Added hosted deep-flow assertions for new campaign Act 1 start state, first-clear unlock/replay copy, and champion relic milestone guidance.

## Tutorial Impact

Tutorial / Proving Grounds remains no-save and no-reward. It does not receive persistent campaign rewards, relic choice prompts, Act 1 campaign-node state, or scenario modifier complexity.

## Save Format

No save-version bump and no new save fields. Guidance is derived from existing campaign and hero save state.

## Verification

```text
npm test -- src/game/core/campaign/CampaignActSpineRules.test.ts src/game/campaign/CampaignPresentationViewModels.test.ts src/game/results/ResultsViewModel.test.ts PASS, 3 files / 31 tests.
npm run validate:content PASS.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm test PASS, 74 files / 570 tests.
npm test -- src/game/playtest/PlaytestPackageValidation.test.ts PASS, 1 file / 3 tests.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "first campaign battle path|Ashen Outpost special objectives|Old Stone Road victory" --reporter=line PASS, 3 hosted proxy tests.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS on final rerun after manual dev-server start, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release:shard1of3 PASS, 44 tests.
npm run test:e2e:release:shard2of3 PASS, 34 tests.
npm run test:e2e:release:shard3of3 PASS, 14 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-78df198-dirty` generated.
npm run verify:playtest-package PASS, 133 checks against the dirty pre-commit package.
git diff --check PASS.
```

Full release note: `npm run test:e2e:release` was attempted with a 40-minute timeout and remained non-pass evidence after timing out without a summary. The timed-out Playwright/Vite process stack was stopped, and the 3-way shard fallback passed completely.

Smoke note: the first fast-smoke attempt timed out without a summary, and the next rerun failed 8/8 with `ERR_CONNECTION_REFUSED` because the local dev server was not running. After starting and verifying the dev server, fast smoke passed; full smoke then passed.

## Deferrals

- Full campaign journal.
- Cinematic/tutorial dialog system.
- New HUD alert system.
- New maps, factions, or art.
- Full objective tracker rewrite.
