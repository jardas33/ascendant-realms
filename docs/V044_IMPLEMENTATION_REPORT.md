# v0.44 Campaign Pacing and Briefing Implementation Report

Date: 2026-05-28

## Scope

v0.44 improves campaign pacing readability by showing mission type, briefing, primary objective, scenario modifiers, reward preview, and after-action summary on existing campaign and Results surfaces.

## Briefing and Results

Campaign node details now show the mission's role before launch. Results campaign reward blocks now show:

- completed mission name;
- mission type;
- primary objective;
- active scenario modifiers;
- first-clear or replay reward state;
- campaign reward claimed/already-claimed state;
- optional objective credit;
- after-action summary;
- existing relic choice, XP, and skill-point reminder flows.

Replay copy remains explicit and one-time rewards do not duplicate.

## Tutorial Impact

Tutorial / Proving Grounds remains no-save and no-reward. It does not receive campaign node mission modifiers, scenario modifier complexity, campaign reward preview copy, or persistent reward noise.

## Save Format

No save-version bump. The checkpoint adds no new save fields. Existing campaign progression, optional objective, hero XP, relic inventory/equipment, and skill-tree fields remain compatible.

## Verification

Focused verification completed:

```text
npx tsc -p tsconfig.json --noEmit PASS.
npm run validate:content PASS.
npx vitest run src/game/data/campaignModifiers.test.ts src/game/core/CampaignRules.test.ts src/game/campaign/CampaignPresentationViewModels.test.ts src/game/results/ResultsViewModel.test.ts PASS, 4 files / 71 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Ashen Outpost special objectives|Old Stone Road victory" --reporter=line PASS after a fresh build, 2 hosted tests.
npm test PASS, 73 files / 563 tests.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS on final rerun, 8 tests.
npm run test:e2e:smoke PASS on final rerun, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npx playwright test tests/e2e/deep-flow.spec.ts --grep @hosted-deep-meta --reporter=line PASS on final local rerun, 12 tests.
npx playwright test tests/e2e/layout.spec.ts:642 --reporter=line PASS, 4 viewport tests.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-ac3d203-dirty` generated.
npm run verify:playtest-package PASS, 126 checks against the dirty pre-commit package.
git diff --check PASS.
```

Full local release note: `npm run test:e2e:release` was attempted with a 40-minute timeout and remained non-pass evidence after timing out without a summary. `npm run test:e2e:release:shard1of3` was also attempted and timed out at 20 minutes. Focused local reruns narrowed the surfaced local failures to cold dev-server main-menu/layout boot budgets and transient Windows `net::ERR_NO_BUFFER_SPACE` app-root navigation; the relevant helper/test timeouts were increased without changing assertions, and exact/group reruns passed. The hosted production-preview release groups above are the final release-matrix evidence.

## Deferrals

- Full campaign codex.
- Cinematic briefing flow.
- Branching route pacing.
- Mission scoring.
- New maps or factions.
