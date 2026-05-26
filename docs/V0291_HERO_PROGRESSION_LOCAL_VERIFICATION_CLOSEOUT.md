# v0.29.1 Hero Progression Local Verification Closeout

Date: 2026-05-26

## Scope

v0.29.1 is a closeout and documentation checkpoint for the v0.28-v0.29 hero progression and ability foundation. It adds no gameplay systems, no balance changes, no maps, no factions, no runtime art/assets, no save migration, no pathing rewrite, and no test weakening.

## Baseline

- Baseline commit: `aa6fc05`
- Baseline package: `ascendant-realms-private-playtest-aa6fc05`
- Runtime checkpoint being closed out: v0.28-v0.29 hero progression and ability foundation
- Remote CI status: the original v0.28-v0.29 push run was blocked before checkout by GitHub HTTP 403 account-suspension response; checkout was later restored for v0.29.1, and follow-up status is recorded in `docs/V0291_BLOCKED_REMOTE_CI_STATUS.md`.

## Package And Retest Guidance

The private package continues to include the v0.28-v0.29 hero progression material:

- `V028_HERO_PROGRESSION_SPEC.md`
- `V028_IMPLEMENTATION_REPORT.md`
- `V029_HERO_ABILITIES_AND_REWARDS_SPEC.md`
- `V029_IMPLEMENTATION_REPORT.md`
- `V029_EMMANUEL_RETEST_CHECKLIST.md`

v0.29.1 also includes:

- `V0291_BLOCKED_REMOTE_CI_STATUS.md`
- `V0291_HERO_PROGRESSION_LOCAL_VERIFICATION_CLOSEOUT.md`

## Emmanuel Retest Focus

Use the v0.29.1 package once regenerated from the closeout commit. Retest the same v0.28-v0.29 hero progression surfaces:

- Hero gains XP from valid combat participation.
- Hero gains one-time XP from first player capture of a resource site.
- Hero level, XP progress, damage, armor, skill points, and ability unlock state remain readable in the HUD.
- Rally Banner and Cleave show ready, cooldown, and disabled states clearly.
- Abilities cannot be spammed while on cooldown.
- Tutorial / Proving Grounds remains no-save and no-reward.
- Victory results summarize battle XP, reward XP, level-ups, and skill points.
- v0.22/v0.23 Worker/resource-site behavior and v0.24-v0.27 enemy site/base/tech pressure still regress cleanly.

## Local Fallback Verification

The original remote GitHub Actions run was blocked before checkout, so this local matrix was the v0.29.1 fallback evidence before checkout recovered:

```text
npm test PASS, 72 files / 533 tests.
npm run build PASS with the known Vite Phaser chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-aa6fc05-dirty generated.
npm run verify:playtest-package PASS, 85 checks.
```

Run `git diff --check` after these docs are synchronized. After committing v0.29.1, regenerate the package from the clean final commit and rerun `npm run verify:playtest-package` before sending the package to testers.

## Remote Recovery Follow-Up

After v0.29.1 commit `765a995` was pushed, GitHub Actions checkout succeeded again:

```text
Push run 26478377719 PASS: Fast confidence completed successfully.
Manual workflow_dispatch run 26478600449: Fast confidence PASS, release simulator PASS, hosted matrix PASS for deep-meta, deep-campaign-pressure, layout-core, layout-cinderfen, and smoke.
Manual workflow_dispatch run 26478600449: hosted deep-battle failed once and failed again on one job rerun at the behaviour mode control gauntlet retreat/move assertion.
```

The hosted `deep-battle` failure was not a checkout/account failure. It reproduced as a Playwright world-command stability issue around `tests/e2e/deep-flow.spec.ts:3829`. A test-only stabilization was added locally, then verified with:

```text
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "behaviour mode control gauntlet" --reporter=line PASS, 1 test.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Worker move-away pauses construction" --reporter=line PASS, 1 test.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
```

This follow-up does not change runtime gameplay. It only makes the hosted deep-battle e2e world-move helper choose safer ground targets and preserve unit selection across retries.
