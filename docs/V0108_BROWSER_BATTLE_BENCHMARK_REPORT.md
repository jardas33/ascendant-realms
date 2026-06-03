# v0.108 Browser Battle Benchmark Report

## Status

Latest generated report includes 10 scenario(s).

## Evidence Boundary

The harness uses the existing private browser profiler through Playwright. Results are useful for local regression shape and desktop acceptance discussion, not final hardware certification.

## Measured Fields

- FPS average and 1% low estimate.
- Frame-time p50, p95, p99, max, and threshold counts.
- Long-task observer support/count/duration.
- Display objects, units, buildings, sites, labels, rings, fog redraws, minimap refreshes, HUD refreshes, notifications, and DOM nodes.
- Battle launch, representative action, and Results transition latency.

## Latest Summary

- benchmark_battle_tier_s_smoke: FPS avg 2.55, 1% low 1.88, p95 533.3 ms, units 21, DOM 647, launch 7740 ms, action 257.3 ms.
- benchmark_battle_tier_m_representative: FPS avg 2.33, 1% low 1.62, p95 616.7 ms, units 41, DOM 662, launch 6980 ms, action 617.7 ms.
- benchmark_battle_tier_l_stress: FPS avg 1.8, 1% low 1.43, p95 700 ms, units 63, DOM 674, launch 10963 ms, action 427.4 ms.
- benchmark_battle_lume_hidden: FPS avg 2.88, 1% low 2.73, p95 366.7 ms, units 41, DOM 662, launch 6979 ms, action 364.6 ms.
- benchmark_battle_lume_auto: FPS avg 2.35, 1% low 1.76, p95 566.6 ms, units 41, DOM 662, launch 7394 ms, action 408.2 ms.
- benchmark_battle_lume_always: FPS avg 1.74, 1% low 1.54, p95 650 ms, units 41, DOM 662, launch 8249 ms, action 651.4 ms.
- benchmark_battle_fog_heavy: FPS avg 2.88, 1% low 2.5, p95 400 ms, units 41, DOM 655, launch 6535 ms, action 324.9 ms.
- benchmark_battle_notification_heavy: FPS avg 2.33, 1% low 1.94, p95 516.7 ms, units 41, DOM 662, launch 7005 ms, action 429 ms.
- benchmark_battle_minimap_interaction: FPS avg 2.88, 1% low 2.5, p95 400 ms, units 41, DOM 679, launch 6094 ms, action 279.7 ms.
- benchmark_battle_results_transition: FPS avg 7.96, 1% low 2, p95 500 ms, units 0, DOM 227, launch 6329 ms, action 221.5 ms, Results 438 ms.

## Stress Lane

Tier L stress evidence is present in the latest artifact set. Treat it as private/local-only regression-hunting evidence.
