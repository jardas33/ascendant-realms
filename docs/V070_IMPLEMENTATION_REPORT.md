# V070 Implementation Report - Tactical Plan Selection

## Summary

v0.70 adds three launch-local tactical plans: Guarded Advance, Resource Push, and Champion Hunt. A player can select one plan from the campaign node details panel before eligible campaign battles. If no choice is made, Guarded Advance is the safe default.

## Runtime Changes

- Added `TACTICAL_PLANS` data, validation, recommendations, and focused rule tests.
- Added `tacticalPlanId` to battle launch requests only as launch/session data.
- Added non-stacking tactical launch modifiers:
  - Guarded Advance: Call Retinue cost is reduced from 75 to 60 Crowns.
  - Resource Push: battle starts with +35 Crowns and +20 Stone.
  - Champion Hunt: hero starts with +6% maximum Mana.
- Added campaign plan selection buttons with selected/recommended copy.
- Added battle-start HUD/status copy for the active tactical plan.

## Save Format

- No save-version bump.
- No hero or campaign save field was added.
- Retry/Results can carry the launch request, but campaign persistence remains unchanged.

## Verification

- Focused tactical plan, launch request, runtime resource, and Retinue reinforcement tests passed.
- Full checkpoint verification is tracked in `LLM_GAME_HANDOFF.md` and `DEVELOPMENT_CHECKPOINT.md`.
