# v0.114 Render Lifecycle Audit

Private Playtest Hub audit for renderer object churn, procedural geometry rebuilds, fog/Lume/minimap/HUD redraws, DOM patches, retained objects, and memory trend.

| Case | Surface | FPS avg | p95 frame | Graphics +/- | Text +/- | DOM patches | Minimap snapshots | Retained | Memory MB |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| v0114_phaser_empty | battle | 2.7 | 500 | 0/0 | 0/0 | 0 | 0 | 705 | 37.77 |
| v0114_tier_s | battle | 2.5 | 533.4 | 0/0 | 2/2 | 1 | 2 | 851 | 37.77 |
| v0114_tier_m_idle | battle | 2.5 | 500 | 0/0 | 0/0 | 1 | 2 | 887 | 37.77 |
| v0114_tier_m_moving | battle | 2.5 | 566.6 | 0/0 | 0/0 | 1 | 3 | 888 | 37.77 |
| v0114_tier_m_combat | battle | 2.4 | 550 | 0/0 | 0/0 | 0 | 2 | 888 | 37.77 |
| v0114_tier_l_stress | battle | 2.5 | 549.9 | 0/0 | 0/2 | 0 | 2 | 926 | 37.77 |
| v0114_fog_heavy | battle | 2.5 | 533.3 | 0/0 | 0/0 | 1 | 2 | 881 | 37.77 |
| v0114_lume_auto | battle | 2.5 | 533.4 | 0/0 | 0/0 | 1 | 2 | 888 | 37.77 |
| v0114_lume_always | battle | 2.5 | 516.7 | 0/0 | 0/0 | 0 | 2 | 888 | 37.77 |
| v0114_label_heavy | battle | 2.7 | 516.7 | 17/0 | 17/0 | 1 | 2 | 705 | 37.77 |
| v0114_notification_heavy | battle | 2.4 | 583.3 | 0/0 | 0/2 | 4 | 2 | 888 | 37.77 |
| v0114_hud_minimal | battle | 2.7 | 566.6 | 0/0 | 0/0 | 1 | 2 | 707 | 37.77 |
| v0114_hud_standard | battle | 2.8 | 583.3 | 0/0 | 0/0 | 1 | 2 | 707 | 37.77 |
| v0114_results_transition | results | 11.4 | 166.7 | 0/0 | 0/0 | 0 | 0 | 393 | 37.77 |
| v0114_campaign_map | campaign | 9.8 | 200.1 | 0/0 | 0/0 | 0 | 0 | 480 | 37.77 |

Rows measured: 15.

No art, gameplay, balance, AI, pathing, fog simulation, saves, stable IDs, engine posture, desktop, multiplayer, content, public benchmark posture, or v0.115 work changed.
