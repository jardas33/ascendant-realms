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

- benchmark_battle_tier_s_smoke: FPS avg 2.7, 1% low 1.82, p95 550 ms, units 21, DOM 647, launch 7594 ms, action 274.8 ms.
- benchmark_battle_tier_m_representative: FPS avg 2.16, 1% low 1.71, p95 583.3 ms, units 41, DOM 662, launch 7318 ms, action 271.3 ms.
- benchmark_battle_tier_l_stress: FPS avg 1.97, 1% low 1.54, p95 649.9 ms, units 63, DOM 674, launch 9833 ms, action 645.1 ms.
- benchmark_battle_lume_hidden: FPS avg 2.91, 1% low 2.5, p95 400 ms, units 41, DOM 662, launch 6412 ms, action 338.8 ms.
- benchmark_battle_lume_auto: FPS avg 2.5, 1% low 2.14, p95 466.6 ms, units 41, DOM 662, launch 7106 ms, action 454.4 ms.
- benchmark_battle_lume_always: FPS avg 1.92, 1% low 1.67, p95 599.9 ms, units 41, DOM 662, launch 7773 ms, action 501.1 ms.
- benchmark_battle_fog_heavy: FPS avg 2.86, 1% low 2.4, p95 416.7 ms, units 41, DOM 655, launch 5903 ms, action 291.4 ms.
- benchmark_battle_notification_heavy: FPS avg 2.31, 1% low 1.67, p95 600 ms, units 41, DOM 662, launch 6058 ms, action 284.2 ms.
- benchmark_battle_minimap_interaction: FPS avg 2.83, 1% low 2.4, p95 416.6 ms, units 41, DOM 679, launch 5721 ms, action 286.8 ms.
- benchmark_battle_results_transition: FPS avg 6.99, 1% low 2.61, p95 383.3 ms, units 0, DOM 227, launch 5599 ms, action 266.8 ms, Results 259 ms.

## Stress Lane

Tier L stress evidence is present in the latest artifact set. Treat it as private/local-only regression-hunting evidence.
