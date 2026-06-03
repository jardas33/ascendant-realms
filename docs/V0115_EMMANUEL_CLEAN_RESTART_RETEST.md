# v0.115 Emmanuel Clean-Restart Retest

Use this packet after a normal machine restart. Do not change OS settings, browser settings, extensions, user profile data, or repository files while running it.

## Steps

1. Restart the machine normally.
2. Let the machine settle for 5 minutes after login.
3. Run the no-recording benchmark first: `npm run perf:trusted:preview`.
4. Run a host snapshot: `npm run perf:host-snapshot`.
5. Run the blank-page control through `npm run perf:controls:preview`.
6. Confirm the Phaser empty-scene control in the same `npm run perf:controls:preview` output.
7. Run a clean Tier M pass: `npm run perf:trusted:clean-profile`.
8. Run a normal Tier M pass: `npm run perf:trusted:preview`.
9. Compare Lume modes with the trusted report evidence: Hidden, Auto, and Always.
10. Run a short second pass of `npm run perf:trusted:preview` after the first normal pass.
11. Export the consolidated report with `npm run perf:trusted:report`.
12. Send Emmanuel the command results plus the newest files under `artifacts/performance/host-snapshots/` and `artifacts/performance/v0109/`.

## Plain Language Findings To Check

If blank page and true Phaser empty scene stay near 60 FPS while Tier M stays near 2-3 FPS, the browser environment is not the main blocker.

If clean-profile Tier M and normal Tier M look similar, browser extensions/profile state are not the main blocker.

If Lume Hidden, Auto, and Always are all still slow, Lume presentation mode is not enough to rescue the browser prototype by itself.

If the second no-recording pass is much better than the first, note the warm machine state and send both outputs. Do not average away the difference.

If host pressure is high after restart, stop and report the host snapshot instead of approving art integration.

## Send Back

- The newest host snapshot folder path.
- The `perf:trusted:preview` output before and after the short second pass.
- The `perf:trusted:clean-profile` output.
- Any obvious machine pressure signs during the run.
- Whether the RED gate still matches the clean-restart evidence.
