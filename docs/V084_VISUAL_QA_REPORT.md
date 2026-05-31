# v0.84 Visual QA Report

Status: passed.

## Scope

v0.84 visual QA focuses on the guided private Aether Well Lume demo:

- compact private demo ribbon;
- progressive Lume tracker;
- Lume focus controls;
- battlefield link/endpoint readability;
- Finish Demo path after the first Linked Ward activation;
- no overlap at 1920x1080 and 1366x768.

## Planned Captures

- `v084-private-lume-hud-1920.png`.
- `v084-private-lume-active-1920.png`.
- `v084-private-lume-hud-1366.png`.

## Result

`npm run visual:qa` passed with 6 tests, 26 screenshots, 0 console errors, and 0 screenshot retries.

The v0.84 capture set covers the private Aether Well Lume demo at desktop and laptop playtest sizes, including the compact no-save/no-reward ribbon, progressive `LUME WARD` tracker, focus controls, active Lume link rendering, and post-activation Finish Demo path.

One earlier attempt captured the new Lume screenshots cleanly but failed later in an existing Cinderfen helper because the neutral brute had already been cleared. The helper now uses a test-only objective fallback when the brute is absent, and the full visual QA rerun passed.
