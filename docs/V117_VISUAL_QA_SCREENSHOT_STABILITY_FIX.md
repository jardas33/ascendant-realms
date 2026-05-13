# v0.11.7 Optional Visual QA Screenshot Stability Fix

Date: 2026-05-13

## Purpose

v0.11.7 stabilizes the manually triggered GitHub Actions `Optional visual QA` lane after v0.11.6 fixed the earlier hosted navigation failure but exposed a screenshot-capture hang. This is a Playwright visual-QA harness change only. It does not change gameplay, content, saves, tutorial behavior, campaign progression, visual assets, runtime art, balance, screenshot coverage strength, or release coverage.

## GitHub Evidence

Emmanuel reported that the manual `Optional visual QA` job still failed on commit `caeff57`.

- Workflow: `CI Release Matrix Dry Run`
- Failed job: `Optional visual QA`
- Failed step: `Run npm run visual:qa`
- Command: `playwright test --config=playwright.visual-qa.config.ts --reporter=line`
- Test: `Ascendant Realms visual QA capture > captures the current menu, campaign, tutorial, results, inventory, gallery, and Cinderfen battle views`
- Failure: `Test timeout of 420000ms exceeded`
- Specific operation: `page.screenshot`
- Call log: taking page screenshot, waiting for fonts to load, fonts loaded
- Stack: `captureView(...)` in `tests/visual-qa/visual-qa.spec.ts`

The reported stack points to the screenshot call for `Cinderfen Crossing tablet` (`cinderfen-crossing-tablet.png`). The failure is therefore no longer the v0.11.6 `page.goto net::ERR_ABORTED` navigation issue. It is a hosted-runner screenshot capture hang inside one long visual-QA test.

## Root Cause Hypothesis

The v0.11.6 harness still captured all 18 screenshots in one Playwright test. A single stuck `page.screenshot` could consume the whole 420 second test budget, hide which capture was active until the trace was inspected, and prevent later screenshots from producing independent pass/fail evidence.

The screenshot coverage itself remains valuable; the problem was the monolithic harness shape and missing per-screenshot diagnostics.

## Changes

### Split Capture Groups

`tests/visual-qa/visual-qa.spec.ts` now runs five smaller tests:

- `menu-gallery-inventory`
- `tutorial`
- `campaign-skirmish`
- `cinderfen-crossing`
- `cinderfen-watch`

Each Playwright test receives a fresh `page` fixture. The visual QA command still runs with one worker, so the generated index remains deterministic.

### Per-Screenshot Diagnostics

Each screenshot now logs:

- capture group
- screenshot file name
- viewport
- current URL
- elapsed run time
- attempt number
- completion duration
- whether retry was used

Expected log shape:

```text
[visual-qa] START screenshot group="cinderfen-crossing" file="cinderfen-crossing-tablet.png" viewport="1024x768 tablet" url="http://127.0.0.1:5173/" elapsed=184383ms attempt=1
[visual-qa] DONE screenshot group="cinderfen-crossing" file="cinderfen-crossing-tablet.png" elapsed=187749ms duration=3366ms retry=no
```

If a hosted screenshot capture times out, the log should identify the exact group and file before retrying or failing.

### Per-Screenshot Timeout And Retry

`captureView` now uses a screenshot wrapper with:

- `page.screenshot({ timeout: 45_000 })`
- `animations: "disabled"`
- `caret: "hide"`
- one retry for transient screenshot timeout/capture failures
- explicit `FAIL` and `RETRY` console logs

This prevents one screenshot from silently consuming the entire visual QA budget.

### Index Metadata

`visual-qa/latest/index.md` now records:

- screenshot count
- browser console error count
- viewports covered
- capture groups
- screenshot retry count
- group and retry status for every screenshot

## Coverage Preserved

All 18 screenshot targets remain covered:

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

Browser console errors still fail visual QA. No pixel-perfect assertions were added.

## Local Verification

Initial local `npm run visual:qa` after the split:

```text
PASS: 5 Playwright visual QA tests in about 4.2m.
PASS: 18 screenshots written.
PASS: browser console errors 0.
PASS: screenshot retries 0.
```

Full required verification for this checkpoint:

```bash
npm test                                      # PASS, 46 files / 351 tests
npm run build                                # PASS with known Phaser vendor warning
npm run validate:content                     # PASS
npm run validate:art-intake                  # PASS
npm run test:e2e:smoke:fast                  # PASS, 6 tests in about 2.0m
npm run visual:qa                            # PASS, 5 tests in about 4.1m, 18 screenshots, 0 console errors, 0 retries
npm run smoke:preview                        # PASS, 0 browser console errors
npm run test:e2e:smoke                       # PASS, 12 tests in about 5.3m
npm run playtest:sim                         # PASS, 255 runs / 85 campaign battle nodes
npm run test:e2e:release:shard1of3           # PASS, 28 tests in about 11.3m
npm run test:e2e:release:shard2of3           # PASS, 27 tests in about 14.8m
npm run test:e2e:release:shard3of3           # PASS, 12 tests in about 5.2m
git diff --check                             # PASS
```

## Next GitHub Check

Emmanuel should rerun the manual GitHub Actions `Optional visual QA` job and confirm:

- GitHub shows 5 visual QA tests instead of 1.
- Logs show `START` and `DONE` lines for `cinderfen-crossing-tablet.png`.
- `visual-qa-latest` uploads with `index.md` and 18 screenshots.
- The index reports 5 capture groups, 18 screenshots, and 0 browser console errors.
- Screenshot retries are 0 or clearly logged if a retry was needed.

If it fails again, the next report should include the final `[visual-qa] START`, `FAIL`, or `RETRY` line so the exact screenshot target is known without digging through the trace first.
