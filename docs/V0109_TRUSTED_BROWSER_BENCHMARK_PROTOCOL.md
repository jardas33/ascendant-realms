# v0.109 Trusted Browser Benchmark Protocol

Status: private benchmark methodology only. It does not choose an engine, start a port, add art, change saves, alter stable IDs, change combat, or change campaign progression.

## Phase 1 - Launch

- Measure navigation start, hub ready, battle HUD ready, scene ready, first rendered frame, and first responsive interaction separately.

## Phase 2 - Settle

- Warm up for 5000 ms by default.
- No FPS score is produced during warm-up.
- visibilityState, viewport, browser user agent, server mode, overlay state, and screenshot state are recorded.
- screenshotsDuringSample=false is recorded for trusted timing lanes; visual QA screenshots happen outside the sample window.

## Phase 3 - Steady-State Sample

- Sample for 10000 ms by default.
- requestAnimationFrame deltas are collected inside the page and retained in ignored raw-frame artifacts.
- Report FPS average, 1% low, p50/p95/p99/max, thresholds above 16.7/33.3/50/100/250/500 ms, long tasks, counters, rates, DOM nodes, and memory when supported.

## Phase 4 - Interaction Sample

- Measure hero selection, Worker selection, building selection, minimap click, Lume visibility toggles, Results disclosure, reset, and return-to-hub separately.

## Phase 5 - Report

- Keep launch latency, settle duration, steady-state metrics, interaction latency, and transition latency in separate report sections.
