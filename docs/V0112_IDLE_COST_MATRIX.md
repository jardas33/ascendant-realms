# v0.112 Idle Cost Matrix

Private browser measurements separating fixed idle cost from movement, combat, and UI increments. Rows are no-save Playtest Hub scenarios.

| Case | Posture | Launch | FPS avg | p95 frame | Top phase | HUD/s | Minimap/s | Units | DOM |
| --- | --- | --- | ---: | ---: | --- | ---: | ---: | ---: | ---: |
| v0112_empty_battle_shell | fixed-idle | v0110_empty_static | 2.7 | 500.1 | Scene/update total | 0 | 0 | 14 | 678 |
| v0112_static_entities | fixed-idle | v0110_static_hud_minimal | 2.7 | 516.7 | Scene/update total | 0 | 0 | 14 | 678 |
| v0112_static_entities_hud | incremental-ui | v0110_static_hud_minimal | 2.7 | 516.7 | Scene/update total | 0.4 | 0.4 | 14 | 678 |
| v0112_one_hero_idle | fixed-idle | perf_selected_hero | 2.7 | 583.4 | Scene/update total | 0.4 | 0.4 | 14 | 679 |
| v0112_tier_m_idle | fixed-idle | benchmark_battle_tier_m_representative | 2.5 | 483.4 | Scene/update total | 0.4 | 0.4 | 41 | 829 |
| v0112_tier_m_moving | incremental-movement | benchmark_battle_minimap_interaction | 2.5 | 566.7 | Scene/update total | 0.4 | 0.4 | 41 | 844 |
| v0112_tier_m_combat | incremental-combat | benchmark_battle_tier_m_representative | 2.5 | 500 | Scene/update total | 0.4 | 0.4 | 41 | 829 |
| v0112_tier_m_ui_hidden | incremental-ui | benchmark_battle_tier_m_representative | 2.5 | 500 | Scene/update total | 0 | 0 | 41 | 829 |
