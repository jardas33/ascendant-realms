# v0.16.9 Combat Edge-Case Matrix

Date: 2026-05-22

## Matrix

| Edge case | Coverage |
| --- | --- |
| 1 hero vs 2 melee enemies after first kill | Existing `post_kill_adjacent_reacquisition` and v0.16.7 unit/e2e tests. |
| 1 hero vs 3 melee enemies after first kill | New `combat_edge_hero_three_melee_followup`. |
| Hold Ground adjacent post-kill response | New `manual_proxy_hold_ground_adjacent_followup`. |
| Hold Ground distant idle refusal | Existing `hold_ground_distant_threat_refusal` plus new `combat_edge_mode_difference_matrix`. |
| 2 friendly units vs 3 enemies | New `combat_edge_two_friendlies_three_enemies`. |
| Melee enemy building aggro | Existing `enemy_melee_building_aggro` plus new `combat_edge_building_aggro_matrix`. |
| Ranged enemy building aggro | New focused `CombatSystem` unit test, `lets enemy ranged units target a nearby Command Hall without requiring melee contact`. |
| Group retreat near multiple enemies | Existing `move_away_suppression` plus new `manual_proxy_group_retreat_resume`. |
| Combat resumes after suppression expires | Existing `move_away_suppression` plus new `manual_proxy_group_retreat_resume`. |
| Hold / Guard / Press differences | Existing mode scenarios plus new `combat_edge_mode_difference_matrix`. |
| Hover/click tolerance vs empty terrain | Existing `attack_hover_tolerance_boundary`, `CollisionSystem` tests, and hosted manual combat contact regression. |

## Result

The matrix is green at deterministic-system level:

```text
npm test -- CombatSystem.test.ts ControlBehaviourScenarioLab.test.ts
PASS: 2 files, 29 tests.

Focused repeat:
same command repeated 5 times.
PASS: 5/5, no flakes.

npm run playtest:controls
PASS: 18 scenarios, 18 pass rows, 0 fail rows.

npm run playtest:controls:extended
PASS: 90/90 pass rows.

npm run playtest:controls:verify
PASS: 1658 checks.
```

## Non-Goals

- No runtime gameplay changes.
- No damage, HP, leash, wave, or stat tuning.
- No new units or buildings.
- No broad AI/pathing rewrite.
- No worker construction implementation.
