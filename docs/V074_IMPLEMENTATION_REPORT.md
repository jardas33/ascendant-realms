# V074 Implementation Report - Adaptive Pressure And Readability

## Summary

v0.74 makes the event layer doctrine-aware and plan-aware while keeping pressure conservative. Raider missions lean toward site threats, Fortress and Warband pressure lean toward hold-line or elite pushes, Hunter pressure can favor elite/Retinue threats, and tactical plans can lightly shorten matching objectives without forcing outcomes.

## Runtime Changes

- Added doctrine and mission-type weighting for event selection.
- Added modifier hooks for Enemy Patrols, Fortified Enemy, and Aether Surge.
- Added tactical-plan support notes:
  - Guarded Advance supports Hold the Line and Reinforcement Window.
  - Resource Push supports Site Under Threat.
  - Champion Hunt supports Elite Strike and Aether Surge.
- Kept one active major event at a time and capped the battle event count.
- Added readable after-action copy that names active events, completed/failed outcomes, and plan-supported objectives.
- Extended hosted deep-campaign proxy coverage for Tutorial protection, Site Under Threat, Elite Strike, plan support, and Results summaries.

## Save Format

- No save-version bump.
- No new persistent save fields.
- Adaptive pressure state is derived from existing content and launch-local tactical plan state.
- Unknown or missing event ids are validation errors in content, not save migration concerns.

## Verification

- Focused event, HUD, Results, validation, and hosted proxy tests were added.
- Full checkpoint verification is tracked in `LLM_GAME_HANDOFF.md` and `DEVELOPMENT_CHECKPOINT.md`.
