# v0.41 Replay and Objective State Implementation Report

Date: 2026-05-28

## Scope

v0.41 adds the first safe optional-objective persistence and replay-state foundation. It uses existing map secondary objectives and records one-time completion credit per campaign mission without adding objective reward currencies or a quest journal.

## Optional Objective State

- New campaign save field: `optionalObjectiveCompletionIds`.
- Keys use `missionId:objectiveId`.
- Old saves without the field load with an empty list.
- Unknown mission ids and unknown objective ids are ignored during normalization.
- Completion credit is recorded once and does not grant duplicate rewards.
- Results show whether an objective was newly recorded, already recorded, previously recorded, or incomplete.

## Replay Rules

- Completed battle nodes can be replayed.
- Campaign node rewards do not duplicate after `nodeRewardsClaimedIds` contains the node id.
- Optional objective completion credit does not duplicate after the objective key is recorded.
- Existing repeat-clear battle reward rules continue to govern replay battle XP/items.

## UI

- Campaign node details show replay status, reward-claimed state, optional objective progress, and build hints for rival commander nodes.
- Results campaign reward blocks show first-clear/replay state, node reward claim status, optional objective credit, and campaign bank state.
- Special Objectives on Results include new/old recorded state when a campaign mission is involved.

## Verification

```text
npx tsc -p tsconfig.json --noEmit PASS.
npx vitest run src/game/core/SaveSystem.test.ts src/game/core/CampaignRules.test.ts src/game/campaign/CampaignPresentationViewModels.test.ts src/game/campaign/CampaignMapViewModel.test.ts src/game/results/ResultsViewModel.test.ts PASS, 5 files / 110 tests.
npx vitest run src/game/playtest/PlaytestPackageValidation.test.ts PASS, 1 file / 3 tests.
npm test PASS, 73 files / 558 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Ashen Outpost special objectives|Old Stone Road victory" --reporter=line PASS, 2 hosted tests.
npm run test:e2e:smoke:fast PASS on rerun, 8 tests.
npm run test:e2e:smoke PASS on rerun after focused campaign-node helper cleanup, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-ba7ac16-dirty` generated.
npm run verify:playtest-package PASS, 119 checks against the dirty pre-commit package.
git diff --check PASS.
```

Optional full release note: `npm run test:e2e:release` was attempted as extra local full-suite evidence and hit the 30-minute command timeout before returning a summary. The temporary Playwright/dev-server processes from that attempt were stopped. The required hosted release groups and visual QA are the final release evidence for this checkpoint.
