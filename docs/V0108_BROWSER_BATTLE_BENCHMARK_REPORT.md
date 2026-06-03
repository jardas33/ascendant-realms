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

- benchmark_battle_tier_s_smoke: FPS avg 2.8, 1% low 2.14, p95 466.7 ms, units 21, DOM 647, launch 6547 ms, action 368.3 ms.
- benchmark_battle_tier_m_representative: FPS avg 2.35, 1% low 1.88, p95 533.2 ms, units 41, DOM 662, launch 8452 ms, action 367.3 ms.
- benchmark_battle_tier_l_stress: FPS avg 1.82, 1% low 1.67, p95 599.9 ms, units 63, DOM 681, launch 8677 ms, action 470.5 ms.
- benchmark_battle_lume_hidden: FPS avg 2.94, 1% low 2.5, p95 400 ms, units 41, DOM 662, launch 6276 ms, action 309.8 ms.
- benchmark_battle_lume_auto: FPS avg 2.47, 1% low 2.07, p95 483.3 ms, units 41, DOM 662, launch 6419 ms, action 420.9 ms.
- benchmark_battle_lume_always: FPS avg 1.89, 1% low 1.33, p95 749.9 ms, units 41, DOM 662, launch 6480 ms, action 606.4 ms.
- benchmark_battle_fog_heavy: FPS avg 2.86, 1% low 2.5, p95 400 ms, units 41, DOM 655, launch 5613 ms, action 333.8 ms.
- benchmark_battle_notification_heavy: FPS avg 2.29, 1% low 1.71, p95 583.3 ms, units 41, DOM 662, launch 6830 ms, action 362.9 ms.
- benchmark_battle_minimap_interaction: FPS avg 2.91, 1% low 2.61, p95 383.3 ms, units 41, DOM 679, launch 5541 ms, action 366.7 ms.
- benchmark_battle_results_transition: FPS avg 6.55, 1% low 2, p95 499.9 ms, units 0, DOM 227, launch 5547 ms, action 257.8 ms, Results 363 ms.

## Stress Lane

Tier L stress evidence is present in the latest artifact set. Treat it as private/local-only regression-hunting evidence.
