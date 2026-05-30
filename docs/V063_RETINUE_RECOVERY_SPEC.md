# v0.63 Retinue Recovery Spec

## Goal

Make Retinue survivor continuity matter after battle without turning the game into a roster-management layer.

## Status Model

- `Ready` is saved as Retinue status `active`.
- `Deployed` is derived from `campaign.retinueDeploymentIds`; it is not a new save field.
- `Recovering` is saved as Retinue status `recovering` with `recoveryMissionsRemaining`.
- `Lost` units are removed from the roster after battle. Legacy or future lost entries normalize away rather than staying deployable.

## Recovery Rules

- A deployed Retinue unit that survives an eligible campaign battle at or below 35% HP enters Recovering.
- Recovering lasts for one eligible first-clear campaign progression step.
- Recovering units cannot deploy or reinforce until they return Ready.
- Existing Recovering units tick only on first-clear campaign progression, not on replay.
- New recovery from the just-finished battle does not immediately tick down in the same results flow.
- Dead Retinue units are removed from roster and deployment selection.
- Tutorial and no-reward battles do not alter Retinue status.

## Save Compatibility

- No save-version bump.
- Old saves without recovery fields load as Ready Retinue units.
- Legacy `wounded` Retinue status loads as `recovering` with one mission remaining.
- Unknown unit ids, invalid unit types, invalid ranks, duplicate ids, and `lost` status entries normalize away safely.
- Deployment ids still select only Ready active units up to the existing cap.

## UI Scope

- Campaign Retinue Camp shows Ready, Deployed, and Recovering states.
- Recovering units show a short disabled reason instead of being silently omitted.
- Results shows survived, lost, entering recovery, and returning Ready.

## Deferrals

- No injury table.
- No healer, infirmary, or recovery currency.
- No permanent squad traits.
- No individual unit equipment or skill tree.
