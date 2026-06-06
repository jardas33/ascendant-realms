# v0.134 Restart Integrity Report

The v0.134 gate proves reset integrity through Results-screen UI, not direct state reset.

Required reset checks:

- Restart from Results resets to a fresh battle.
- Return to Title, then Start Salto Review and Start Battle, resets to a fresh battle.
- Objective resets to selecting Aster.
- Selection is empty.
- Mine ownership resets.
- Worker assignment resets.
- Barracks restoration resets.
- Recruit queue and Militia spawn reset.
- Ashen countdown and wave state reset.
- Lume restoration and Results state reset.
- HUD/minimap posture is present without routine editor work.
- No duplicate wave or Militia spawn is allowed.

Acceptance evidence:

- `restart-integrity-report.json` status must be `PASS_V0134_RESTART_INTEGRITY`.
- Required reset checks must pass from the restarted public scene state.
- `no-softlock-proof.json` must pass.
- `no-shortcut-proof.json` must pass.
