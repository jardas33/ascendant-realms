# v0.61 Pre-Battle Deployment Implementation Report

## Summary

v0.61 separates the saved Retinue roster from the small group the player deploys into the next eligible campaign battle. Deployment stays optional, session-launch scoped, and managed through the existing Campaign Map Retinue Camp panel.

## Runtime Changes

- Added `retinueDeploymentIds` to campaign saves with backward-compatible normalization.
- Base deployment cap is two selected Retinue units.
- Training Yard II adds one deployment slot.
- Campaign Map Retinue cards now show `Deploy`, `Reserve`, or `Deployment Full`.
- Campaign battle launches use selected Retinue units only.
- Old saves without `retinueDeploymentIds` default to the first active Retinue units up to the cap, preserving previous auto-deploy behavior.

## UI Scope

- Existing Retinue Camp panel shows roster count, deployment count, role identity, rank, XP, kills, survival/deployment counters, and deployment controls.
- No new army-management screen, drag-and-drop deployment board, permanent control groups, or deployment positioning editor was added.

## Verification Notes

- Unit tests cover deployment caps, toggles, selection filtering, dismissal cleanup, and old-save defaults.
- Hosted Retinue proxy coverage exercises deploy/reserve toggles and selected Retinue battle spawn.
- Required hosted deep-battle, hosted smoke, hosted deep-campaign-pressure, visual QA, controls, and Act 1 telemetry passed.
