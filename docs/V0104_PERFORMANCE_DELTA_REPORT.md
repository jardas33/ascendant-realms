# v0.104 Performance Delta Report

## Status

PASS on 2026-06-02.

Commands:

- `npm run perf:profile:private`
- `npm run perf:report:private`

Artifact outputs:

- `artifacts/performance/v0104/performance-summary.json`
- `artifacts/performance/v0104/scenario-results.json`
- `artifacts/performance/v0104/performance-delta.md`
- `artifacts/performance/v0104/profiler-capability-report.json`

## Capability

- Scenario count: 20.
- Long-task observer: supported.
- Sample window: 1200 ms.
- Baseline checkpoint: v0.103.

## Top Cost Signals

From `artifacts/performance/v0104/performance-summary.md`:

1. `perf_results_disclosure`: p95 733.4 ms, HUD 0/s, minimap 0/s.
2. `perf_battle_baseline`: p95 700 ms, HUD 1/s, minimap 1/s.
3. `perf_lume_auto`: p95 549.9 ms, HUD 0/s, minimap 0/s.

## Delta Highlights

The generated delta report compares matching scenario IDs against committed v0.103 artifacts from `artifacts/performance/v0103/performance-summary.json`.

- `perf_selected_worker`: p95 683.3 ms -> 466.7 ms; HUD/minimap rates -2/s.
- `perf_fog_heavy_camera`: p95 566.7 ms -> 466.6 ms; HUD/minimap rates -2.22/s.
- `perf_lume_activation_pulse`: p95 583.3 ms -> 500 ms; HUD/minimap rates -2/s.
- `perf_label_heavy_site_cluster`: p95 433.3 ms -> 383.3 ms; HUD/minimap rates -2.9/s.
- `perf_lume_auto`: p95 483.3 ms -> 549.9 ms; HUD/minimap rates -2.4/s.
- `perf_battle_baseline`: p95 466.7 ms -> 700 ms; HUD/minimap rates -1.54/s.
- `perf_results_disclosure`: p95 333.3 ms -> 733.4 ms; HUD/minimap rates unchanged at 0/s.

New v0.104-only HUD-density scenarios:

- `perf_hud_debug`: p95 483.3 ms, HUD 0/s, minimap 0/s, DOM 527.
- `perf_hud_minimal`: p95 500 ms, HUD 0/s, minimap 0/s, DOM 508.
- `perf_hud_standard`: p95 500 ms, HUD 0/s, minimap 0/s, DOM 508.

## Interpretation

The evidence supports the targeted rendering changes for HUD/minimap rate reduction: matching battle scenarios now report lower HUD/minimap rates, usually 0/s or 1/s inside the 1200 ms sample. Absolute p95 frame time is mixed across scenarios, so v0.104 does not claim a universal FPS win.

## Evidence Warning

Private profiler output is local deterministic QA evidence. It is useful for relative shape and regression hunting, but it is not cross-machine benchmark proof.
