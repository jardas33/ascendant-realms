# v0.115 Consolidated Performance Report

This report consolidates the trusted browser-performance evidence from v0.109 through v0.114. It does not add optimizations, gameplay changes, save changes, stable-ID changes, art changes, engine changes, desktop work, multiplayer work, or content.

## Source Matrix

| Checkpoint | Primary docs | Primary artifacts | Takeaway |
| --- | --- | --- | --- |
| v0.108 | [benchmark report](V0108_BROWSER_BATTLE_BENCHMARK_REPORT.md), [representative profile](V0108_REPRESENTATIVE_BATTLE_PROFILE.md) | [summary](../artifacts/benchmarks/v0108/battle-benchmark-summary.json), [scenario results](../artifacts/benchmarks/v0108/scenario-results.json) | The first representative battle harness exposed serious browser lag but needed a stronger methodology. |
| v0.109 | [protocol](V0109_TRUSTED_BROWSER_BENCHMARK_PROTOCOL.md), [root-cause matrix](V0109_ROOT_CAUSE_MATRIX_REPORT.md), [execution modes](V0109_EXECUTION_MODE_COMPARISON.md) | [trusted summary](../artifacts/performance/v0109/trusted-benchmark-summary.json), [root-cause matrix](../artifacts/performance/v0109/root-cause-matrix.json), [execution comparison](../artifacts/performance/v0109/execution-mode-comparison.json) | Trusted production-preview sampling confirmed serious browser lag in Tier M and related rows. |
| v0.110 | [phase profiler spec](V0110_BATTLE_LOOP_PHASE_PROFILER_SPEC.md), [density report](V0110_DENSITY_SCALING_REPORT.md), [browser gate](V0110_BROWSER_PERFORMANCE_GATE.md) | [phase summary](../artifacts/performance/v0110/phase-profiler-summary.json), [density report](../artifacts/performance/v0110/density-scaling-report.json), [gate](../artifacts/performance/v0110/trusted-browser-gate.json) | Gate was RED; movement/pathing, status/combat, HUD DOM, and density all remained relevant. |
| v0.111 | [browser controls](V0111_BROWSER_CONTROL_BASELINES.md), [machine classification](V0111_MACHINE_PRESSURE_CLASSIFICATION.md), [post-restart retest](V0111_EMMANUEL_POST_RESTART_RETEST.md) | [browser controls](../artifacts/performance/v0111/browser-control-baselines.json), [clean profile](../artifacts/performance/v0111/clean-profile-benchmark.json), [environment comparison](../artifacts/performance/v0111/environment-comparison.json), [latest host snapshot](../artifacts/performance/host-snapshots/2026-06-03T22-26-46-316Z/host-snapshot.json) | Host pressure is unlikely; game code dominates. |
| v0.112 | [scheduler map](V0112_BATTLE_LOOP_SCHEDULER_MAP.md), [allocation audit](V0112_HOT_PATH_ALLOCATION_AUDIT.md), [idle matrix](V0112_IDLE_COST_MATRIX.md), [parity](V0112_PARITY_REPORT.md) | [allocation audit](../artifacts/performance/v0112/allocation-audit.json), [idle matrix](../artifacts/performance/v0112/idle-cost-matrix.json), [parity](../artifacts/performance/v0112/parity-summary.json) | Safe allocation and idle-work reductions did not eliminate the fixed battle-shell cost. |
| v0.113 | [spatial profile](V0113_SPATIAL_QUERY_PROFILE.md), [path dedup spec](V0113_PATH_REQUEST_DEDUP_SPEC.md), [parity](V0113_TARGET_ACQUISITION_PARITY_REPORT.md), [spatial-index decision](V0113_SPATIAL_INDEX_DECISION_REPORT.md) | [query profile](../artifacts/performance/v0113/query-profile.json), [old/new comparison](../artifacts/performance/v0113/old-new-comparison.json), [parity](../artifacts/performance/v0113/parity-summary.json) | Exact-semantics spatial/pathing work preserved behavior but did not create representative gate recovery. |
| v0.114 | [render audit](V0114_RENDER_LIFECYCLE_AUDIT.md), [DOM boundary](V0114_CANVAS_DOM_BOUNDARY_REPORT.md), [delta](V0114_PERFORMANCE_DELTA_REPORT.md), [visual parity](V0114_VISUAL_PARITY_REPORT.md) | [lifecycle audit](../artifacts/performance/v0114/lifecycle-audit.json), [before/after delta](../artifacts/performance/v0114/before-after-delta.json), [visual parity](../artifacts/performance/v0114/visual-parity.json) | Renderer churn is bounded, but Tier M frame time remains far outside AMBER. |

## Metric Consolidation

| Row | FPS avg | p95 frame | Max frame | Long tasks | Source |
| --- | ---: | ---: | ---: | ---: | --- |
| v0.109 preview Tier M baseline | 2.5 | 533.4 ms | 600 ms | 58 | `production-preview-headless:baseline` |
| v0.109 preview Tier S | 3.2 | 433.3 ms | 449.9 ms | 70 | `production-preview-headless:tier-s` |
| v0.109 preview Tier L | 2.0 | 716.5 ms | 750.1 ms | 58 | `production-preview-headless:tier-l` |
| v0.109 campaign map | 10.6 | 183.3 ms | 366.7 ms | 5 | `production-preview-headless:campaign-map` |
| v0.109 Results transition | 3.1 | 400 ms | 433.3 ms | 69 | `production-preview-headless:results-transition` |
| v0.109 Lume Hidden | 2.6 | 466.7 ms | 583.2 ms | 61 | `production-preview-headless:lume-hidden` |
| v0.109 Lume Auto | 2.5 | 533.4 ms | 600 ms | 58 | refreshed baseline auto row |
| v0.109 Lume Always | 2.6 | 483.3 ms | 566.6 ms | 58 | `production-preview-headless:lume-always` |
| v0.111 blank page control | 60.1 | 16.7 ms | 16.8 ms | 0 | `blank-page-raf` |
| v0.111 simple DOM control | 60.1 | 16.7 ms | 16.8 ms | 0 | `simple-dom` |
| v0.111 simple canvas control | 60.1 | 16.8 ms | 16.8 ms | 0 | `simple-canvas` |
| v0.111 true Phaser empty scene | 60.0 | 16.8 ms | 16.8 ms | 5 | `phaser-empty-scene` |
| v0.111 preview campaign map | 8.5 | 266.7 ms | 549.9 ms | 4 | `campaign-map` |
| v0.111 preview Tier M | 2.4 | 566.6 ms | 583.3 ms | 50 | `tier-m-representative-battle` |
| v0.112 empty battle shell | 2.7 | 500.1 ms | 516.6 ms | 58 | `v0112_empty_battle_shell` |
| v0.112 Tier M moving | 2.5 | 566.7 ms | 583.3 ms | 56 | `v0112_tier_m_moving` |
| v0.113 Tier M combat | 2.4 | 600 ms | 616.7 ms | 55 | `v0113_tier_m_combat` |
| v0.113 Tier L combat | 2.4 | 566.6 ms | 616.7 ms | not primary | `v0113_tier_l_combat` |
| v0.114 Tier M combat | 2.4 | 566.6 ms | 599.9 ms | 55 | `v0114_tier_m_combat` |
| v0.114 Tier M moving | 2.4 | 633.3 ms | 633.3 ms | 59 | `v0114_tier_m_moving` |
| v0.114 campaign map | 9.0 | 216.7 ms | 383.3 ms | 6 | `v0114_campaign_map` |
| v0.114 Results transition | 11.3 | 166.7 ms | 183.4 ms | 18 | `v0114_results_transition` |

## Interpretation

Host pressure contribution: low. The controls and clean-profile evidence point away from the user's machine, browser profile, or extension state as the dominant automated cause.

Browser-environment contribution: not zero, but not enough to explain the gap alone. The browser handles empty and simple control surfaces at 60 FPS; the app-specific game and DOM surfaces fall far below that.

Phaser-empty contribution: the true Phaser empty control is healthy. Slow `empty/static` battle rows are better interpreted as fixed game-shell cost, not generic Phaser failure.

Battle fixed cost: high. Empty battle shell, static entities, and one-hero idle rows remain slow even without full representative combat pressure.

Density cost: high. Tier S, Tier M, and Tier L all stay below AMBER, with Tier L historically worst and Tier M still failing after bounded rescue work.

Pathing/spatial cost: still material. v0.113 shows large target and path counters, but the safe exact-semantics changes did not unlock representative duplicate path-cache hits.

Renderer cost: partially reduced. v0.114 cut object churn and bounded presentation work, but frame-time data still shows a severe bottleneck.

DOM cost: app-specific. Simple DOM is healthy; campaign map, Results, HUD, minimap, status, and notification surfaces remain part of the browser prototype's unresolved cost.

## Gate Conclusion

The consolidated gate is RED. The evidence supports stopping browser visual expansion, blocking runtime art integration, and moving a reviewed architecture or engine-spike discussion earlier.
