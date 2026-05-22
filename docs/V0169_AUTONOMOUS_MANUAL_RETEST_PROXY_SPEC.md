# v0.16.9 Autonomous Manual-Retest Proxy Spec

Date: 2026-05-22

## Purpose

Provide deterministic automated coverage for the exact v0.16.7 manual retest items while Emmanuel is away. This is not human feedback, does not replace manual retest, and must not invent player sentiment.

## Proxy Coverage Map

| Manual retest item | Automated proxy |
| --- | --- |
| Guard Area default | `guard_area_default_local_defence` control-lab scenario plus hosted behaviour gauntlet side-panel assertions. |
| Hold Ground does not chase distant idle enemies | `hold_ground_distant_threat_refusal` and `combat_edge_mode_difference_matrix`. |
| Two adjacent melee enemies: first dies, second must not idle forever | `manual_proxy_hold_ground_adjacent_followup`, `post_kill_adjacent_reacquisition`, and hosted manual combat contact regression. |
| Melee enemies beside Command Hall/building attack locally | `enemy_melee_building_aggro`, `combat_edge_building_aggro_matrix`, and hosted manual combat contact regression. |
| Retreat near multiple enemies starts and is not instantly cancelled | `move_away_suppression`, `manual_proxy_group_retreat_resume`, and hosted behaviour gauntlet. |
| Combat resumes after suppression expires | `move_away_suppression` and `manual_proxy_group_retreat_resume`. |
| Attack cursor appears over enemy body/edge | `attack_hover_tolerance_boundary` plus hosted behaviour gauntlet and manual combat contact regression. |
| Empty nearby terrain does not show attack intent | `attack_hover_tolerance_boundary` plus hosted manual combat contact regression. |
| Left-click enemy attack remains intentional | hosted behaviour gauntlet left-click attack assertion. |
| Drag-select over HUD/minimap works | hosted behaviour gauntlet marquee-over-HUD/minimap assertions. |
| Minimap click plus `H` does not leave stale `No Selection` | hosted behaviour gauntlet minimap click plus hero-select assertion. |
| Tutorial defeat/Results still works | smoke tutorial Results and hosted Results defeat coverage. |

## New v0.16.9 Deterministic Scenarios

- `manual_proxy_hold_ground_adjacent_followup`
- `manual_proxy_group_retreat_resume`
- `combat_edge_hero_three_melee_followup`
- `combat_edge_two_friendlies_three_enemies`
- `combat_edge_building_aggro_matrix`
- `combat_edge_mode_difference_matrix`

## Limits

- This is automated system evidence only.
- It does not claim human feel, fun, readability, or final UX quality.
- It does not change runtime behaviour.
- It does not add worker construction, features, content, art, balance tuning, or save data.

