# v0.134 Recovery Case Ledger

The v0.134 headed proof exercises recoverable mistakes in the packaged player-facing slice and requires each case to recover without soft-locking or regressing objectives.

Required cases:

- Click empty terrain before Aster: concise feedback is recorded and the player can still select Aster.
- Right-click before selecting a unit: `no_selection_move_rejected` feedback is recorded and the objective does not advance.
- Right-click a friendly unit: `friendly_right_click_ignored` feedback is recorded and the flow remains recoverable.
- Move Aster away during conversion: conversion does not soft-lock.
- Re-enter the capture ring: West Stone Cut Mine still becomes controlled.
- Miss Worker click once: the Worker can still be selected and assigned.
- Click Barracks before Worker selection: `barracks_not_ready` or equivalent guidance is recorded.
- Empty box-select during combat: defender selection is preserved or recovered.
- Reselect defenders: normal squad selection remains available.
- Attack with no valid selection: `attack_no_selection_auto_recover` feedback is recorded and combat can continue.

Acceptance evidence:

- `recovery-case-report.json` status must be `PASS_V0134_RECOVERY_CASES`.
- Every required case must have `passed: true`.
- Objectives must remain monotonic.
- Results must remain reachable through normal simulation.
