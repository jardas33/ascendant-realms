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

- benchmark_battle_tier_s_smoke: FPS avg 2.5, 1% low 2.22, p95 450 ms, units 21, DOM 641, launch 7451 ms, action 436.1 ms.
- benchmark_battle_tier_m_representative: FPS avg 2.12, 1% low 1.43, p95 700 ms, units 41, DOM 656, launch 8692 ms, action 409.9 ms.
- benchmark_battle_tier_l_stress: FPS avg 1.79, 1% low 1.71, p95 583.3 ms, units 63, DOM 675, launch 10158 ms, action 542.5 ms.
- benchmark_battle_lume_hidden: FPS avg 2.75, 1% low 2.31, p95 433.4 ms, units 41, DOM 656, launch 7223 ms, action 317.5 ms.
- benchmark_battle_lume_auto: FPS avg 2.47, 1% low 2.14, p95 466.7 ms, units 41, DOM 656, launch 7294 ms, action 347.5 ms.
- benchmark_battle_lume_always: FPS avg 1.82, 1% low 1.43, p95 700 ms, units 41, DOM 656, launch 9388 ms, action 586.2 ms.
- benchmark_battle_fog_heavy: FPS avg 2.89, 1% low 2, p95 499.9 ms, units 41, DOM 649, launch 5888 ms, action 365 ms.
- benchmark_battle_notification_heavy: FPS avg 2.24, 1% low 2.07, p95 483.3 ms, units 41, DOM 656, launch 7360 ms, action 472.7 ms.
- benchmark_battle_minimap_interaction: FPS avg 2.61, 1% low 2, p95 499.9 ms, units 41, DOM 673, launch 5762 ms, action 281.8 ms.
- benchmark_battle_results_transition: FPS avg 9.31, 1% low 2.61, p95 383.4 ms, units 0, DOM 227, launch 6043 ms, action 380 ms, Results 323 ms.

## Stress Lane

Tier L stress evidence is present in the latest artifact set. Treat it as private/local-only regression-hunting evidence.
