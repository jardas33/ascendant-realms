# v0.63 Retinue Recovery Implementation Report

## Summary

v0.63 adds a conservative battle-to-battle recovery state to the existing Retinue roster. Low-HP survivors can be marked Recovering for one eligible campaign progression step, while destroyed Retinue units are still removed from the roster.

## Runtime Changes

- Added save-safe Retinue status handling for `active` and `recovering`.
- Kept legacy `wounded` saves loadable by normalizing them to `recovering`.
- Dropped invalid or explicit lost Retinue entries during save normalization.
- Added low-HP survivor recovery when a participating Retinue unit survives at or below 35% HP.
- Added one-step recovery expiry only on eligible first-clear campaign progression.
- Kept replay and Tutorial/no-reward routes from instantly recovering or mutating Retinue state.

## Save Format

- No save-version bump.
- Added optional `recoveryMissionsRemaining` on Retinue entries.
- Old saves without status or recovery fields still default to Ready/active.
- Recovering units are removed from deployment ids and cannot launch until Ready.

## Verification Notes

- Focused Retinue/save/results/HUD/package tests passed.
- The focused hosted Retinue reinforcement/recovery proxy passed against a rebuilt production preview.
- Full checkpoint verification is tracked in the handoff and checkpoint docs.
