# v0.104 Visual QA Report

## Status

Complete.

```text
npm run visual:qa - PASS, 18 tests, 189 screenshots, 0 browser console errors, 0 screenshot retries.
npm run visual:review-pack - PASS, 189 screenshots, 7 contact sheets, target viewports 1920x1080 / 1600x900 / 1366x768.
```

Fresh artifacts:

- `visual-qa/latest/index.md`
- `artifacts/visual-review/latest/index.html`
- `artifacts/visual-review/latest/review-manifest.json`
- `artifacts/visual-review/latest/README.md`

## Added Screenshot Coverage

The v0.104 visual QA group `v0104-hud-density-performance` adds 17 screenshots:

- `v0104-public-battle-minimal-1366.png`
- `v0104-public-battle-minimal-1600.png`
- `v0104-public-battle-minimal-1920.png`
- `v0104-profiler-disabled-1366.png`
- `v0104-profiler-enabled-1366.png`
- `v0104-private-hud-minimal-selected-hero-1366.png`
- `v0104-worker-minimal-1366.png`
- `v0104-building-minimal-1366.png`
- `v0104-private-hud-standard-1366.png`
- `v0104-private-hud-standard-1600.png`
- `v0104-private-hud-debug-1366.png`
- `v0104-private-hud-debug-1920.png`
- `v0104-urgent-alert-minimal-1366.png`
- `v0104-lume-auto-minimal-1366.png`
- `v0104-lume-hidden-minimal-1366.png`
- `v0104-lume-always-standard-1366.png`
- `v0104-tutorial-guidance-minimal-1366.png`

Expected full visual QA count is now 189 screenshots.

## Review Focus

- Public Minimal has no private density controls.
- Private Standard preserves full-detail review posture.
- Private Debug exposes counters without obscuring core controls.
- Minimal keeps Worker/building commands, urgent alerts, Lume posture, tutorial guidance, and minimap readable.
