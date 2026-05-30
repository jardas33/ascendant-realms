# v0.58 Unit Role Identity Implementation Report

## Summary

v0.58 adds a small content-driven unit-role identity layer for existing units. The goal is readability: players can see what Militia, Rangers, Acolytes, Workers, and the hero are for without adding new units, art, factions, or a class system.

## Runtime

- Added `src/game/data/unitRoles.ts` with role labels, tags, summaries, and tactical hints.
- Added role validation through content validation.
- Added role/tag copy to selected unit stats.
- Added hero role identity copy to the hero selection panel.
- Added selected-group role mix copy for multi-unit selections.
- Updated training command descriptions to include unit role identity and tags.

## Role Identities

- Worker: utility / build / repair / site support.
- Militia: frontline / melee / holds ground.
- Ranger: ranged / focus fire / fragile.
- Acolyte: aether / support / special damage.
- Hero: commander / champion.

Enemy and neutral role entries are metadata/readability only. They do not change AI or stats.

## Save Format

No save-version bump and no new save fields were introduced. Role metadata is content-driven and derived at runtime.

## Verification

Focused verification passed:

- `npm test -- unitRoles SelectedEntityPanel UnitOrderSummary CommandPanel ControlGroupSystem PatrolRules ResultsViewModel contentValidation`

Full checkpoint verification is recorded in `DEVELOPMENT_CHECKPOINT.md` after release closeout.

## Deferrals

- No role-based passive tree.
- No formation editor.
- No squad manager.
- No new unit types.
