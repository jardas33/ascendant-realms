# v0.109 Profiler Method Audit

Old sample window: 1200 ms.
Old execution mode: dev-server headless Playwright with SwiftShader args.
Old profiler overlay: visible profiler panel updates every ~500 ms while sampling.

## Findings

| Item | Finding | Risk | v0.109 Response |
| --- | --- | --- | --- |
| FPS average | Computed as 1000 divided by mean rAF delta from the collected frame list. | medium | Keep the calculation, but use a longer warm sample and retain raw intervals. |
| 1% low | Computed from the slowest 1% of frame deltas, with tiny samples often reducing to one frame. | high | Use a 10 second default sample so 1% low is not just one launch/settle stall. |
| Frame percentiles | p50/p95/p99/max use sorted rAF deltas from the active profiler window. | medium | Keep percentile math but separate launch, warm-up, steady-state, and transitions. |
| Sample duration | The v0.103/v0.104/v0.108 automated lanes used 1200 ms by default. | high | Default v0.109 warm-up is 5000 ms and steady-state sample is 10000 ms. |
| Launch contamination | The v0.108 runner starts the profiler after battle load plus a short 250 ms wait, then immediately performs an action and sometimes a Results transition inside the same sample. | high | Measure launch, settle, steady-state, interaction, and transition as separate phases. |
| rAF source | Frame deltas are collected inside the page with requestAnimationFrame. | low | Keep in-page rAF sampling and retain raw intervals under ignored artifacts. |
| Headless mode | Automated v0.108 evidence uses headless Chromium. | medium | Record execution mode and compare preview headless, dev headless, optional headed, and manual mode. |
| Visibility state | The old reports do not record document.visibilityState. | medium | Require and report visibilityState for every trusted sample. |
| Dev vs production | v0.108 benchmark runs against a Vite dev server. | high | Use production preview as the primary automated lane and dev server as secondary evidence. |
| Screenshots | The benchmark runner does not screenshot, but visual QA separately captures screenshots for scenario review. | low | Report screenshotsDuringSample=false for benchmark lanes and keep visual QA outside timing windows. |
| Profiler panel overhead | The old profiler panel is visible and updates while it samples. | high | Default trusted samples run with profiler overlay off and compare overlay on as a root-cause case. |
| Debug counters | Debug HUD counters can add DOM/layout work when HUD Debug is active. | medium | Treat HUD Debug as a separate diagnostic comparison. |
| Settle time | The old 250 ms settle wait is too short for a composed battle after launch. | high | Use a configurable warm-up, default 5000 ms, with no FPS score during warm-up. |
| Sample size | A one-frame stall can dominate a 1200 ms sample and make FPS appear implausibly low. | high | Use raw intervals plus threshold counts to distinguish single stalls from sustained low cadence. |
| Machine/load effects | Local Playwright, SwiftShader, browser install, and concurrent local load can distort absolute metrics. | medium | Report mode, browser, user agent, capabilities, and compare relative root-cause cases. |

## Conclusion

The earlier 2-3 FPS evidence should be treated as mixed and methodologically weak until v0.109 trusted samples separate launch/settle/transition work from steady-state frame timing.
