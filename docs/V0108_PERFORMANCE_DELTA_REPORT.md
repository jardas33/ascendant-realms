# v0.108 Performance Delta Report

This compares v0.108 representative benchmark scenarios with the closest v0.103/v0.104 private profiler scenarios when a meaningful comparison exists. It is local deterministic QA evidence, not cross-machine benchmark proof.

| v0.108 scenario | Comparison | v0.103 p95 | v0.104 p95 | v0.108 p95 | v0.108 units | v0.108 DOM | Notes |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| benchmark_battle_tier_s_smoke | perf_battle_baseline | 466.7 | 700 | 550 | 21 | 647 | Representative composed battle versus ordinary baseline. |
| benchmark_battle_tier_m_representative | perf_battle_baseline | 466.7 | 700 | 583.3 | 41 | 662 | Representative composed battle versus ordinary baseline. |
| benchmark_battle_tier_l_stress | perf_large_unit_cluster | 450 | 466.6 | 649.9 | 63 | 674 | Private/local stress only. |
| benchmark_battle_lume_hidden | perf_lume_hidden | 383.4 | 483.3 | 400 | 41 | 662 | Lume overlay comparison. |
| benchmark_battle_lume_auto | perf_lume_auto | 483.3 | 549.9 | 466.6 | 41 | 662 | Lume overlay comparison. |
| benchmark_battle_lume_always | perf_lume_always | 416.6 | 516.7 | 599.9 | 41 | 662 | Lume overlay comparison. |
| benchmark_battle_fog_heavy | perf_fog_heavy_camera | 566.7 | 466.6 | 416.7 | 41 | 655 | Closest available private profiler comparison. |
| benchmark_battle_notification_heavy | perf_notification_heavy | 383.3 | 416.6 | 600 | 41 | 662 | Closest available private profiler comparison. |
| benchmark_battle_minimap_interaction | perf_minimap_interaction | 466.7 | 433.3 | 416.6 | 41 | 679 | Closest available private profiler comparison. |
| benchmark_battle_results_transition | perf_results_disclosure | 333.3 | 733.4 | 383.3 | 0 | 227 | Battle-to-Results transition adds latency evidence. |

## Interpretation

- Direct scenario IDs do not all match because v0.108 measures a representative composed battle profile rather than only the older isolated private profiler states.
- Lume Hidden/Auto/Always, fog-heavy, notification-heavy, minimap interaction, and Results transition retain closest v0.103/v0.104 comparison anchors.
- Tier L stress is private/local only and should not be treated as CI acceptance.
