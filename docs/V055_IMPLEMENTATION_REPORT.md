# v0.55 Formation-Aware Movement Implementation Report

## Summary

v0.55 adds lightweight group destination spacing for multi-unit move and attack-move commands. It keeps the existing movement/pathing systems intact and only chooses safer per-unit destination targets before issuing the normal command.

## Runtime

- Added `createFormationMoveTargets` as a pure helper.
- Multi-unit move commands keep the first selected unit on the clicked point.
- Additional units receive conservative offsets around the clicked point.
- Offsets are accepted only when they stay inside the map and avoid alive building footprints.
- Unsafe offsets gracefully fall back to smaller offsets or the clicked point.
- Worker build, repair, resource-site assignment, explicit attacks, rally points, retreat, and unit pathfinding remain unchanged.

## UI

- Multi-unit move feedback can say `Group move accepted`.
- Multi-unit attack-move feedback can say `Group attack-move accepted`.
- The implementation intentionally avoids a formation editor, facing controls, rank controls, or a new command surface.

## Save Format

No save-version bump and no new save fields were introduced. Formation-aware target offsets are command-time battle state only.

## Verification

Targeted evidence:

- `npx tsc -p tsconfig.json --noEmit`
- focused Vitest coverage for separated destinations, blocked-terrain fallback, and building-footprint fallback
- hosted deep-battle proxy confirming selected combat units do not all receive identical move targets when space allows

Full checkpoint evidence also passed `npm test` (78 files / 591 tests), production build, content/art validation, smoke, controls, Act 1 telemetry, hosted deep-battle (28 tests), hosted smoke, hosted deep-campaign-pressure, visual QA, local release shards 1/3 through 3/3, package verification (155 checks), and `git diff --check`.

## Deferrals

- No saved formations.
- No collision reservation or flow-field rewrite.
- No enemy formation AI.
- No per-role positioning beyond simple offsets.
