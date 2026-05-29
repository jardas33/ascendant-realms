# v0.56 Patrol Implementation Report

## Summary

v0.56 adds a minimal Patrol command for living player combat units and heroes. Patrol is intentionally small: units move between their current position and a clicked patrol point, then continue using existing combat acquisition if enemies appear.

## Runtime

- Added `PatrolRules` for combat-unit eligibility.
- Added session-only patrol routes to `Unit`.
- Patrol starts from the HUD command button or `P` hotkey, then waits for a canvas destination click.
- Patrol reuses existing move and combat systems.
- Patrol cancels on explicit move, explicit attack, Stop, behavior-mode changes, Worker-style build/repair/site commands, and death.
- Workers do not patrol by default.

## UI

- Added compact Tactics commands for eligible combat selections.
- `Patrol` shows `Hotkey P`.
- `Stop` clears patrol and active combat-unit orders.
- Order summary shows `Patrolling` with a short behavior note.

## Save Format

No save-version bump and no new save fields were introduced. Patrol routes are battle-session state only.

## Verification

Targeted evidence:

- `npx tsc -p tsconfig.json --noEmit`
- focused Vitest coverage for patrol start, patrol cancellation, patrol leg advance, behavior-mode cancellation, order summary, and HUD command availability
- hosted deep-battle proxy confirming Patrol starts and cancels through real canvas pointer commands

Full checkpoint evidence also passed `npm test` (78 files / 591 tests), production build, content/art validation, smoke, controls, Act 1 telemetry, hosted deep-battle (28 tests), hosted smoke, hosted deep-campaign-pressure, visual QA, local release shards 1/3 through 3/3, package verification (155 checks), and `git diff --check`.

## Deferrals

- No patrol queue.
- No waypoint chains.
- No route editor.
- No enemy Patrol AI.
- No patrol persistence.
