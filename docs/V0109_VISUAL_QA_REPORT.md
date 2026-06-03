# v0.109 Visual QA Report

Visual QA adds trusted manual benchmark and private diagnostic-toggle screenshots. The captures are private QA evidence only and do not introduce public controls.

Required states: intro, warm-up, steady-state, interaction, export summary, diagnostic collapsed/expanded, labels hidden, rings minimal, Lume Hidden/Auto/Always, minimap reduced/paused, fog redraw reduced, HUD Minimal/Standard/Debug, notifications suppressed, overlay off/on, root-cause baseline, overlays minimized/enabled, and 1920x1080/1600x900/1366x768.

## Verification

- `npm run visual:qa` PASS after resolving the v0.109 final cleanup click failure, 21 tests / 240 screenshots / 0 browser console errors / 0 screenshot retries.
- `npm run visual:review-pack` PASS, 240 screenshots and 10 contact sheets.
- Browser plugin manual review PASS: `http://localhost:8099/contact-sheets/trusted-benchmark.html` loaded the Trusted Benchmark contact sheet and all 27 v0.109 images had non-zero dimensions.
- Non-pass evidence: the first full visual QA attempt hit the outer command timeout, and the exact rerun found an unnecessary final return-to-hub click in the v0.109 capture group. The final screenshot had already been captured; the fix removed only that end-of-test cleanup dependency.
