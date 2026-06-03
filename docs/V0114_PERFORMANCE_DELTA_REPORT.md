# v0.114 Performance Delta Report

Before evidence comes from v0.110/v0.112 renderer/HUD/fog/minimap hot-path findings. After evidence comes from v0.114 private render-lifecycle counters.

| Case | FPS avg | p95 frame | Graphics created | Text created | DOM patches | Minimap snapshots | Retained |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| v0114_phaser_empty | 2.7 | 500 | 0 | 0 | 0 | 0 | 705 |
| v0114_tier_s | 2.5 | 533.4 | 0 | 2 | 1 | 2 | 851 |
| v0114_tier_m_idle | 2.5 | 500 | 0 | 0 | 1 | 2 | 887 |
| v0114_tier_m_moving | 2.5 | 566.6 | 0 | 0 | 1 | 3 | 888 |
| v0114_tier_m_combat | 2.4 | 550 | 0 | 0 | 0 | 2 | 888 |
| v0114_tier_l_stress | 2.5 | 549.9 | 0 | 0 | 0 | 2 | 926 |
| v0114_fog_heavy | 2.5 | 533.3 | 0 | 0 | 1 | 2 | 881 |
| v0114_lume_auto | 2.5 | 533.4 | 0 | 0 | 1 | 2 | 888 |
| v0114_lume_always | 2.5 | 516.7 | 0 | 0 | 0 | 2 | 888 |
| v0114_label_heavy | 2.7 | 516.7 | 17 | 17 | 1 | 2 | 705 |
| v0114_notification_heavy | 2.4 | 583.3 | 0 | 0 | 4 | 2 | 888 |
| v0114_hud_minimal | 2.7 | 566.6 | 0 | 0 | 1 | 2 | 707 |
| v0114_hud_standard | 2.8 | 583.3 | 0 | 0 | 1 | 2 | 707 |
| v0114_results_transition | 11.4 | 166.7 | 0 | 0 | 0 | 0 | 393 |
| v0114_campaign_map | 9.8 | 200.1 | 0 | 0 | 0 | 0 | 480 |

Implemented optimizations: static-terrain-geometry-cache, volatile-hud-dom-diff, command-marker-graphics-text-pool, capture-ring-label-no-op-guard, health-bar-no-op-guard, minimap-due-or-dirty-cache.

No art, gameplay, balance, AI, pathing, fog simulation, saves, stable IDs, engine posture, desktop, multiplayer, content, public benchmark posture, or v0.115 work changed.
