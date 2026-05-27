# v0.29.2 Release Matrix Closeout

Date: 2026-05-27
Scope: close out the hosted deep-battle recovery before any v0.30 work.

## Current Status

- Local hosted `deep-battle`: green after the narrow test-harness fix and the follow-up stale-summary assertion fix.
- Remote Fast confidence on first v0.29.2 fix commit `45c7eb1`: passed in push run `26490257582`.
- Remote manual release matrix on first v0.29.2 fix commit `45c7eb1`: run `26490433401` passed checkout, Fast confidence, Release simulator, hosted `deep-meta`, hosted `deep-campaign-pressure`, hosted `layout-core`, hosted `layout-cinderfen`, and hosted `smoke`.
- Remote hosted `deep-battle` on run `26490433401`: failed one stale duplicate movement-summary assertion after the helper had already observed the transient move summary.
- Follow-up fix commit `b7604e5`: pushed successfully; push run `26493632871` passed Fast confidence.
- Manual release-matrix run `26493804376` on `b7604e5`: passed checkout, Fast confidence, Release simulator, hosted `deep-meta`, hosted `deep-battle`, hosted `deep-campaign-pressure`, hosted `layout-core`, hosted `layout-cinderfen`, and hosted `smoke`.
- Clean v0.29.2 tester package: pending final docs-only closeout commit and clean package generation.

## Required Remote Evidence

After pushing the v0.29.2 commit:

1. Inspect the push Fast confidence run.
2. Trigger or inspect a manual `CI Release Matrix Dry Run` with release matrix enabled.
3. Confirm checkout succeeds.
4. Confirm hosted `deep-battle` is green.
5. Confirm the other release groups stay green.

If the GitHub connector or Actions dispatch path is unavailable, record the exact manual action required instead of claiming remote CI green.

## Local Evidence So Far

```text
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "behaviour mode control gauntlet" --repeat-each=5 --retries=0 --trace=retain-on-failure --reporter=line
PASS, 5 tests.

npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "battle HUD supports minimap movement|battle HUD keeps hovered command buttons stable|behaviour mode control gauntlet|Worker assignment and site upgrade boost" --retries=0 --trace=retain-on-failure --reporter=line
PASS, 4 tests.

npm run test:e2e:release:hosted:deep-battle
PASS, 27 tests.

npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "battle HUD supports minimap movement, fog toggle, and move commands" --repeat-each=5 --retries=0 --trace=retain-on-failure --reporter=line
PASS, 5 tests after the stale-summary follow-up fix.

npm run test:e2e:release:hosted:deep-battle
PASS, 27 tests after the stale-summary follow-up fix.
```

```text
npm test
PASS, 72 files / 533 tests.

npm run build
PASS with the known Vite Phaser chunk-size warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.

npm run test:e2e:smoke:fast
PASS, 8 tests.

npm run test:e2e:smoke
PASS, 14 tests.

npm run playtest:controls
PASS, 18 scenarios / 18 pass rows.

npm run playtest:controls:extended
PASS, 18 scenarios / 90 pass rows.

npm run playtest:controls:verify
PASS, 1658 checks.

npm run test:e2e:release:hosted:smoke
PASS, 14 tests.

npm run test:e2e:release:hosted:deep-campaign-pressure
PASS, 7 tests.

npm run visual:qa
PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.

git diff --check
PASS.
```

## Package Rule

Do not send a v0.29.2 package until:

- the local verification matrix passes,
- remote hosted `deep-battle` status is documented,
- package metadata names v0.29.2,
- the package is regenerated from the final clean commit,
- `npm run verify:playtest-package` passes,
- the package name has no `-dirty` suffix.

## Final Remote Status

Green for the runtime/test fix commit.

- Push run `26493632871` on `b7604e5`: Fast confidence passed; release matrix, simulator, full release, and visual QA were skipped by push rules.
- Manual release-matrix run `26493804376` on `b7604e5`: passed.
- Successful jobs in run `26493804376`: Fast confidence, Release simulator, hosted `deep-meta`, hosted `deep-battle`, hosted `deep-campaign-pressure`, hosted `layout-core`, hosted `layout-cinderfen`, and hosted `smoke`.
- Skipped by requested manual inputs: Optional visual QA and Full release e2e.

## Final Package

Pending final clean package generation from the final closeout commit.
