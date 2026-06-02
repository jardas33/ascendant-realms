# v0.103 Performance Baseline Report

## Evidence Type

This is local deterministic QA evidence from private fixtures. It is not human fun data and not cross-machine benchmark proof.

## Tooling

- Profiler: private/dev only, off by default.
- Command: `npm run perf:profile:private`
- Output: `artifacts/performance/v0103/` (ignored by git).

## Baseline Metrics

Command: `npm run perf:profile:private`

Result: PASS. The profiler completed 17 private scenarios and wrote ignored artifacts to `artifacts/performance/v0103/`.

Capability:

- Sample window: 1200 ms per scenario.
- Scenario count: 17.
- Long-task observer: supported.

Top local p95 cost signals from the final refreshed run:

1. `perf_selected_worker`: p95 683.3 ms, max 683.3 ms, HUD 2/s, minimap 2/s.
2. `perf_lume_activation_pulse`: p95 583.3 ms, max 583.3 ms, HUD 2/s, minimap 2/s.
3. `perf_fog_heavy_camera`: p95 566.7 ms, max 566.7 ms, HUD 2.22/s, minimap 2.22/s.

Representative counters:

- `perf_lume_hidden`: Lume links 0, DOM nodes 623.
- `perf_lume_auto`: Lume links 1, DOM nodes 623.
- `perf_lume_always`: Lume links 2, DOM nodes 623.
- `perf_label_heavy_site_cluster`: DOM nodes 483, HUD/minimap 2.9/s.
- `perf_campaign_map_interaction`: DOM nodes 314, HUD/minimap 0/s.

## Notes

- The profiler records only while explicitly active.
- Long-task evidence depends on browser support.
- The lab reuses existing maps, units, Lume state, Results fixtures, and private no-save isolation.
- Absolute FPS/frame times from this local Playwright run should not be compared across machines; use relative scenario shape and counters.
