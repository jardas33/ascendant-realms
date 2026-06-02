# v0.103 Visual QA Report

## Coverage Added

Visual QA adds 27 v0.103 screenshots under the `v0103-clutter-performance` group:

- Playtest Hub at 1920x1080, 1600x900, and 1366x768.
- Performance Lab group visibility.
- Profiler off, active, and stopped-summary states.
- Sixteen private Performance Lab battlefield/campaign/Lume states.
- Lume Auto details disclosure.
- Capture-site label density at an additional viewport.
- Results compact and expanded performance-lab fixtures.

## Acceptance Focus

- No hidden primary action.
- No Lume private-demo exit loss.
- Stable Auto Lume is quieter.
- Hidden/Always remain available.
- Capture-site labels and rings remain readable when important.
- Profiler is visible only in private/dev posture.

## Closeout Result

`npm run visual:qa` passed after the v0.103 Performance Lab group timeout was expanded to match the larger 27-shot slice.

- Result: PASS.
- Tests: 17 visual QA groups passed.
- Screenshot count: 172.
- v0.103 screenshot count: 27.
- Browser console errors: 0.
- Screenshot retries: 0.
- Output: `visual-qa/latest/`.

`npm run visual:review-pack` also passed and generated `artifacts/visual-review/latest/` with 172 screenshots and 7 contact sheets.

Non-pass evidence: an earlier 30-minute wrapper timed out before `visual:qa` returned a final result, and the first full rerun exposed a real private-profiler overlay intercepting `Return to Hub`. v0.103 fixed that by making the display panel ignore pointer events while keeping the toggle button usable.
