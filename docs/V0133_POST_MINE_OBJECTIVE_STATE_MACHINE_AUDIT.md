# v0.133 Post-Mine Objective State Machine Audit

Status: `POST_MINE_OBJECTIVE_STATE_MACHINE_VERIFIED`

v0.133 audits and repairs the player-facing post-mine sequence after v0.132. The canonical objective order is:

1. `select_aster`
2. `move_to_west_stone_cut_mine`
3. `convert_west_stone_cut_mine`
4. `assign_worker_to_mine`
5. `restore_barracks`
6. `train_militia`
7. `prepare_ashen_pressure`
8. `defeat_ashen_wave`
9. `restore_lume_link`
10. `review_results`

Root cause: v0.132 ended correctly at Worker assignment, but the live player-facing loop did not advance Barracks construction, Militia recruitment, countdown, wave movement, combat, or Lume restoration through ordinary input and normal simulation. A separate box-select path could also request `prepare_ashen_pressure` before prerequisites were satisfied.

Repair:

- `set_onboarding_step` now canonicalizes aliases and rejects forward transitions when prerequisites are missing.
- Box selection records squad selection but no longer advances to Ashen pressure by itself.
- The v0.133 headed smoke includes a box-select no-skip probe before Barracks restoration.
- `post_mine_flow_status()` reports objective history, prerequisite guard evidence, no debug shortcut, no state injection, and no private-harness proof.

Verified evidence:

- `artifacts/desktop-spikes/godot-salto/v0133/objective-prerequisite-report.json`
- `artifacts/desktop-spikes/godot-salto/v0133/post-mine-trace.json`
- `artifacts/desktop-spikes/godot-salto/v0133/headed-post-mine-flow-smoke.json`
