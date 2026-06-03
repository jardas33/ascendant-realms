# v0.113 Spatial Query Profile

Private Playtest Hub profile for spatial queries, target acquisition, and path-request reuse. Rows are no-save diagnostics and do not add public controls.

| Case | Posture | Launch | FPS avg | p95 frame | Path req | Path hits | Target scans | Entities visited | Dist calcs | Top phase |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| v0113_hero_only | hero-only | perf_selected_hero | 2.7 | 633.3 | 0 | 0 | 0 | 0 | 0 | Scene/update total |
| v0113_hero_worker | hero-worker | perf_selected_worker | 2.7 | 549.9 | 0 | 0 | 0 | 0 | 0 | Scene/update total |
| v0113_five_troops | five-troops | perf_selected_squad | 2.7 | 516.7 | 0 | 0 | 0 | 0 | 0 | Scene/update total |
| v0113_tier_s | tier-s | benchmark_battle_tier_s_smoke | 2.5 | 566.7 | 2 | 0 | 609 | 27550 | 523 | Scene/update total |
| v0113_tier_m_idle | tier-m-idle | benchmark_battle_tier_m_representative | 2.5 | 533.3 | 0 | 0 | 0 | 0 | 0 | Scene/update total |
| v0113_tier_m_moving | tier-m-moving | benchmark_battle_minimap_interaction | 2.4 | 550 | 2 | 0 | 0 | 0 | 0 | Scene/update total |
| v0113_tier_m_combat | tier-m-combat | benchmark_battle_tier_m_representative | 2.4 | 583.3 | 57 | 0 | 1078 | 86310 | 947 | Scene/update total |
| v0113_tier_l_idle | tier-l-idle | benchmark_battle_tier_l_stress | 2.4 | 516.6 | 0 | 0 | 0 | 0 | 0 | Scene/update total |
| v0113_tier_l_moving | tier-l-moving | benchmark_battle_tier_l_stress | 2.4 | 549.9 | 4 | 0 | 0 | 0 | 0 | Scene/update total |
| v0113_tier_l_combat | tier-l-combat | benchmark_battle_tier_l_stress | 2.4 | 566.6 | 110 | 0 | 1680 | 193228 | 1400 | Scene/update total |
| v0113_ai_paused | ai-paused | benchmark_battle_tier_m_representative | 2.4 | 566.7 | 57 | 0 | 1078 | 86310 | 947 | Scene/update total |
| v0113_path_requests_paused | path-requests-paused | benchmark_battle_tier_m_representative | 2.5 | 516.6 | 0 | 0 | 1131 | 90045 | 957 | Scene/update total |
| v0113_combat_paused | combat-paused | benchmark_battle_tier_m_representative | 2.4 | 516.7 | 2 | 0 | 0 | 0 | 0 | Scene/update total |
| v0113_static_entities | static-entities | v0110_static_hud_minimal | 2.7 | 533.4 | 0 | 0 | 0 | 0 | 0 | Scene/update total |

Rows measured: 14.
