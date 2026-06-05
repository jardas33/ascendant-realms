# v0.132 Objective State Monotonicity Audit

Actual objective regression: `false`

## Monotonic Order

1. `select_aster`
2. `move_to_quarry` as the legacy internal step for moving Aster to `West Stone Cut Mine`
3. `capture_hold_quarry` as the legacy internal step for converting `West Stone Cut Mine`
4. `worker_mine_or_shrine` or `worker_assign_mine`
5. `restore_barracks`
6. `queue_militia` or `train_militia`
7. `prepare_ashen_pressure` or `defeat_wave`
8. `restore_lume_link`
9. `review_results`

## Repair

The scene now blocks lower-rank objective transitions during the player-facing battle path. Re-clicking Aster, selecting the Worker, duplicate movement events, or repeated hover/select events cannot push the tutorial from Objective 3 back to Objective 2.

## Evidence

The v0.132 headed smoke writes `objective-monotonicity.json` under `artifacts/desktop-spikes/godot-salto/v0132/`. The validator requires `PASS_OBJECTIVE_MONOTONICITY_PROOF` and fails if `actualObjectiveRegressionDetected` is true.
