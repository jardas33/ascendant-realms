# v0.114 Canvas-DOM Boundary Report

Canvas work remains in Phaser scenes and entity views. DOM work remains in HUD/minimap/status/result/campaign shells.

| Case | HUD view models | DOM patches | DOM created | DOM destroyed | Detached DOM |
| --- | ---: | ---: | ---: | ---: | ---: |
| v0114_phaser_empty | 4 | 0 | 0 | 0 | 0 |
| v0114_tier_s | 5 | 1 | 430 | 430 | 0 |
| v0114_tier_m_idle | 5 | 1 | 444 | 444 | 0 |
| v0114_tier_m_moving | 4 | 1 | 622 | 639 | 0 |
| v0114_tier_m_combat | 4 | 0 | 0 | 0 | 0 |
| v0114_tier_l_stress | 4 | 0 | 0 | 0 | 0 |
| v0114_fog_heavy | 5 | 1 | 444 | 444 | 0 |
| v0114_lume_auto | 5 | 1 | 444 | 444 | 0 |
| v0114_lume_always | 4 | 0 | 0 | 0 | 0 |
| v0114_label_heavy | 5 | 1 | 334 | 334 | 0 |
| v0114_notification_heavy | 8 | 4 | 2488 | 2488 | 0 |
| v0114_hud_minimal | 4 | 1 | 334 | 334 | 0 |
| v0114_hud_standard | 4 | 1 | 334 | 334 | 0 |
| v0114_results_transition | 0 | 0 | 393 | 0 | 0 |
| v0114_campaign_map | 0 | 0 | 480 | 0 | 0 |

HUD volatile regions now skip identical attribute/body replacements; full stable markup changes still use the existing replacement path with scroll-state restore.

No art, gameplay, balance, AI, pathing, fog simulation, saves, stable IDs, engine posture, desktop, multiplayer, content, public benchmark posture, or v0.115 work changed.
