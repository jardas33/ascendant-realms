# v0.11.6 Optional Visual QA Hosted Navigation Fix

Date: 2026-05-12

## Purpose

v0.11.6 stabilizes the optional GitHub Actions visual QA job after the v0.11.5 fast-confidence lane split. This is a CI and test-harness-only fix. It does not change gameplay, content, saves, tutorial behavior, campaign progression, runtime art, visual assets, balance, screenshot coverage, or release test strength.

## GitHub Evidence

Emmanuel reported that commit `1948ce5` made the automatic `Fast confidence` job green, confirming that `npm run test:e2e:smoke:fast` is the correct automatic push/PR lane.

The manually triggered `Optional visual QA` job failed in workflow `CI Release Matrix Dry Run #6`:

- Failed step: `Run npm run visual:qa`
- Command: `playwright test --config=playwright.visual-qa.config.ts --reporter=line`
- Test: `Ascendant Realms visual QA capture > captures the current menu, campaign, tutorial, results, inventory, gallery, and Cinderfen battle views`
- Failure location: `tests/visual-qa/visual-qa.spec.ts:195`
- Error: `Test timeout of 240000ms exceeded`
- Navigation error: `page.goto: net::ERR_ABORTED; maybe frame was detached?`
- Stack path: `gotoReadyMainMenu(page, context)` -> `openMainMenuForStorageSeed` -> `seedCompletedCinderfenRouteCampaign` -> visual QA capture.

The failure was not a pixel comparison failure, not a screenshot assertion failure, not a browser console error report, and not a gameplay failure. It happened while the visual QA harness was navigating and seeding storage during a long single-test screenshot pass.

## Root Cause Hypothesis

The optional visual QA harness performs 18 screenshot captures through one Playwright test. That gives one browser page a lot of work:

- repeated main-menu boot navigation
- viewport changes
- storage seeding
- campaign continuation
- battle scene launches
- results-screen setup
- screenshot capture and index writing
- browser console error collection

Local runs were already close to the former 240 second test budget. On a hosted runner, a transient `net::ERR_ABORTED` or frame-detach during setup navigation can consume enough time to make the single visual QA test time out before coverage completes.

## Changes

### Shared app-boot navigation helper

`tests/e2e/shared-helpers.ts` now routes `gotoReadyMainMenu` through a focused `gotoAppRootWithRetry` helper.

The retry is intentionally narrow:

- it only wraps app-root setup navigation
- it retries only transient setup-navigation aborts, frame-detach errors, and setup-navigation timeouts
- it accepts a navigation timeout only when the real main menu is already visible
- it uses a bounded per-attempt navigation timeout
- it still requires the real `main-menu` and `menu-new-campaign` test IDs afterward
- it does not suppress browser console errors
- it does not change app runtime behavior

### Visual QA timeout

`tests/visual-qa/visual-qa.spec.ts` now gives the optional 18-screenshot capture test a 420 second budget.

The timeout change is scoped to this optional visual QA test only. It does not change smoke, release, shard, simulator, preview smoke, or gameplay tests.

## What Did Not Change

- The automatic `Fast confidence` job remains on `npm run test:e2e:smoke:fast`.
- The visual QA harness still captures 18 screenshots.
- Browser console errors still fail visual QA.
- Visual QA remains human-reviewed and non-pixel-perfect.
- No screenshot target was removed.
- No gameplay, content, save, tutorial, campaign, runtime art, visual asset, balance, or production behavior changed.

## Screenshot Coverage Preserved

The visual QA pass still covers:

- main menu desktop
- Asset Gallery
- main menu tablet
- main menu mobile
- Hero Inventory
- Tutorial desktop
- Tutorial mobile
- campaign map
- completed route campaign map
- skirmish setup
- Cinderfen Crossing launch
- Cinderfen Crossing tablet
- Cinderfen Shrine captured
- Cinderfen Crossing pressure warning
- Results victory
- Cinderfen Watch launch
- Cinderfen Watch pressure warning
- Results defeat

## Local Verification

During local verification, the first `release:shard2of3` run caught an overly narrow first version of the navigation retry: `page.goto` timed out at 30s even though the failure snapshot showed the real main menu was already rendered. The helper was refined so a setup-navigation timeout is accepted only when `main-menu` and `menu-new-campaign` are visible, otherwise it retries/fails with context. The final shard run exercised that retry path once and passed.

Final local gate:

```bash
npm test                                      # PASS, 46 files / 351 tests
npm run build                                # PASS with known Phaser vendor warning
npm run validate:content                     # PASS
npm run validate:art-intake                  # PASS
npm run test:e2e:smoke:fast                  # PASS, 6 tests in about 2.3m
npm run visual:qa                            # PASS, 18 screenshots, 0 console errors, about 4.1m
npm run smoke:preview                        # PASS, 0 browser console errors
npm run test:e2e:smoke                       # PASS, 12 tests in about 5.4m
npm run playtest:sim                         # PASS, 255 runs / 85 campaign battle nodes
```

Because `gotoReadyMainMenu` is a shared e2e helper, the 3-way release shards were also run before the final commit:

```bash
npm run test:e2e:release:shard1of3           # PASS, 28 tests in about 11.7m
npm run test:e2e:release:shard2of3           # PASS, 27 tests in about 14.8m
npm run test:e2e:release:shard3of3           # PASS, 12 tests in about 5.7m
git diff --check                             # PASS
```

## Next GitHub Check

Emmanuel should rerun the manual `Optional visual QA` job in GitHub Actions and confirm:

- the job reaches `Visual QA capture`
- `npm run visual:qa` completes
- `visual-qa-latest` uploads with `index.md` and 18 screenshots
- `playwright-visual-qa` uploads only if Playwright emits diagnostics
- browser console error count remains 0

If hosted visual QA still fails, inspect whether the failure is a new app assertion, a browser console error, another setup navigation timeout, or a total job timeout before making further changes.
