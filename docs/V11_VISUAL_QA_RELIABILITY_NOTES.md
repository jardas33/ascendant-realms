# v0.11 Visual QA Reliability Notes

Date: 2026-05-11

Scope: review and lightly improve the optional screenshot QA workflow without adding pixel-perfect assertions, new art, gameplay changes, runtime asset changes, UI redesign, or new coverage requirements for ordinary source edits.

## Current Harness

Command:

```text
npm run visual:qa
```

Configuration:

- Config file: `playwright.visual-qa.config.ts`
- Test directory: `tests/visual-qa/`
- Worker count: `1`
- Default per-test timeout: `120_000`
- v0.11.7 visual QA group timeout override: `180_000`
- Browser: Chromium desktop profile with the same SwiftShader/ANGLE launch args used by e2e
- Dev server: `npm run dev` at `http://127.0.0.1:5173`
- Retries: `0`
- Failure artifacts: trace/video retained on failure, screenshot only on failure

The harness is intentionally separate from the release e2e suite. It creates human-review screenshots and checks browser console errors, but it does not approve art quality and does not compare pixels.

## Output Behavior

Output path:

```text
visual-qa/latest/
```

Git behavior:

```text
/visual-qa/
```

The output folder is ignored by git. Screenshots and the generated `index.md` are local review artifacts only.

The harness currently writes 18 screenshots covering:

- main menu desktop/tablet/mobile
- Asset Gallery
- Hero Inventory
- Tutorial desktop/mobile
- campaign map
- completed Cinderfen route map
- Skirmish Setup
- Cinderfen Crossing desktop/tablet
- Cinder Shrine captured
- Cinderfen Crossing pressure warning
- Results victory
- Cinderfen Watch
- Cinderfen Watch pressure warning
- Results defeat

As of v0.11.7, those captures are split into 5 smaller Playwright tests:

- `menu-gallery-inventory`
- `tutorial`
- `campaign-skirmish`
- `cinderfen-crossing`
- `cinderfen-watch`

## v0.11 Reliability Improvement

The generated index now includes an explicit summary:

- screenshot count
- browser console error count
- viewports covered
- harness path

v0.11.7 extends this summary with:

- capture groups
- screenshot retry count
- group and retry status per capture

The test output also prints a short summary after writing the index:

```text
Visual QA wrote 18 screenshot(s) across menu-gallery-inventory, tutorial, campaign-skirmish, cinderfen-crossing, cinderfen-watch to <repo>/visual-qa/latest. Browser console errors: 0. Screenshot retries: 0.
```

This helps future reviewers confirm they are looking at a complete capture set without adding brittle image comparisons.

## v0.11.7 Screenshot Stability Improvement

Remote hosted evidence showed the previous monolithic visual QA test could hang inside `page.screenshot`, specifically around the Cinderfen Crossing tablet capture. The harness now logs each screenshot before and after capture:

```text
[visual-qa] START screenshot group="cinderfen-crossing" file="cinderfen-crossing-tablet.png" viewport="1024x768 tablet" url="http://127.0.0.1:5173/" elapsed=184383ms attempt=1
[visual-qa] DONE screenshot group="cinderfen-crossing" file="cinderfen-crossing-tablet.png" elapsed=187749ms duration=3366ms retry=no
```

Each screenshot uses a 45 second screenshot timeout, disabled animations/caret, and one retry for transient screenshot timeout/capture failures. Browser console errors are still recorded and fail the run.

## Cleanup Decision

No automatic cleanup of `visual-qa/latest/` was added in this phase.

Reason: the folder is ignored, and the generated `index.md` is already the source of truth for the current run. Adding deletion behavior would create unnecessary filesystem risk for local review artifacts and is not needed to improve release reliability.

## Console Error Policy

The harness records:

- browser `console.error`
- browser `pageerror`

The capture fails if the error list is not empty. Warnings are not treated as failures because the purpose is to catch real browser errors without making the visual review lane noisy.

## Naming And Viewport Policy

Screenshot names remain stable, descriptive, and grouped by view:

- `main-menu-desktop.png`
- `tutorial-mobile.png`
- `cinderfen-crossing-pressure-desktop.png`
- `results-defeat-desktop.png`

Viewport labels stay explicit in the index, such as `1440x900 desktop`, `1024x768 tablet`, and `390x844 mobile`.

## What This Does Not Do

This pass does not:

- add pixel-perfect baselines
- approve visual quality automatically
- add generated art
- alter runtime assets
- alter gameplay, campaign, tutorial, or save behavior
- make visual QA mandatory for every docs/source change
- delete local screenshot artifacts

## Phase 4 Verification

Required after this harness/reporting change:

```text
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run visual:qa
git diff --check
```
