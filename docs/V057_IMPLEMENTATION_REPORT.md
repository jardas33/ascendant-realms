# v0.57 Army Veterancy Implementation Report

## Summary

v0.57 exposes the existing live-battle unit veterancy loop more clearly without adding a new permanent army roster or save migration. Combat units already gain battle XP from damage, kills, and victory survival; this pass makes the scope and results copy more explicit.

## Runtime

- Preserved the existing `unitVeterancy` XP, rank, rank-up, stat-bonus, and battle-summary rules.
- Kept rank bonuses modest: Seasoned and Veteran are small HP/damage increases, while Elite adds a small armor bonus.
- Clarified selected-unit copy so normal trained units show as battle-only veterancy units.
- Clarified Results copy so battle XP and existing Retinue Camp recruitment are distinct.
- Added coverage that control groups recall veteran units without stripping rank state.

## Save Format

No save-version bump and no new save fields were introduced. Ordinary trained-unit veterancy remains live battle state plus Results summary state. Existing retinue save normalization remains unchanged and continues to ignore unknown unit/rank data safely.

## Verification

Focused verification passed:

- `npm test -- unitRoles SelectedEntityPanel UnitOrderSummary CommandPanel ControlGroupSystem PatrolRules ResultsViewModel contentValidation`

Full checkpoint verification is recorded in `DEVELOPMENT_CHECKPOINT.md` after release closeout.

## Deferrals

- No new permanent army roster.
- No enemy veterancy.
- No unit naming, traits, equipment, or injury system.
