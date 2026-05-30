# v0.59 Tactical Combat Feedback Implementation Report

## Summary

v0.59 polishes tactical combat feedback through existing HUD and Results surfaces. It makes unit role, veteran rank, construction intent, group role mix, and Patrol/control-group interactions easier to read while preserving v0.54-v0.56 controls.

## Runtime

- Added selected-panel role summaries for single units, the hero, and selected groups.
- Added selected unit role tags, rank, XP progress, kill count, bonus summary, and battle-only veterancy state in one readable stat block.
- Added Worker construction order summaries: `Moving to Build`, `Building`, and `Construction Paused`.
- Preserved explicit attack, attack-move, move, repair, site assignment, Hold Ground, Guard Area, Press Attack, and Patrol order labels.
- Updated Results veteran summary copy to state that normal unit veterancy is battle-only.
- Extended hosted deep-battle proxy coverage so group/Patrol commands also see selected role/veteran summaries.

## Control Groups And Patrol

- Existing control groups remain session-only.
- Dead group members are still cleaned by the control-group system.
- Veteran units can be assigned and recalled without losing rank state.
- Patrol eligibility remains limited to living player combat units/heroes and continues to exclude Workers by default.

## Save Format

No save-version bump and no new save fields were introduced. Control groups, Patrol routes, role summaries, and normal battle-unit veterancy display are runtime/session surfaces.

## Verification

Focused verification passed:

- `npm test -- unitRoles SelectedEntityPanel UnitOrderSummary CommandPanel ControlGroupSystem PatrolRules ResultsViewModel contentValidation`

Full checkpoint verification is recorded in `DEVELOPMENT_CHECKPOINT.md` after release closeout.

## Deferrals

- No battle log.
- No floating role icons.
- No damage-type counter chart.
- No VFX or cursor art pipeline.
