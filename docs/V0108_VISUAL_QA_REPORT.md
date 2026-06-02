# v0.108 Visual QA Report

Status: verified on 2026-06-02 with `npm run visual:qa` and `npm run visual:review-pack`.

## Added Coverage

v0.108 adds representative benchmark captures for:

- Tier S smoke.
- Tier M representative.
- Tier L stress.
- Tier M Lume Hidden.
- Tier M Lume Auto.
- Tier M Lume Always.
- Tier M fog-heavy.
- Tier M notification-heavy.
- Tier M minimap interaction.
- Tier M Results transition.

The capture set spans 1920x1080, 1600x900, and 1366x768 desktop viewports. These are human-review screenshots, not pixel-perfect approval or final art evidence.

## Verified Harness Shape

- Visual QA: 213 screenshots.
- Browser console errors: 0.
- Screenshot retries: 0.
- Visual review pack: 213 screenshots and 9 contact sheets.
- Representative Benchmark contact sheet: present in `artifacts/visual-review/latest/contact-sheets/representative-benchmark.html`.
