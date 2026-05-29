# v0.56 Patrol Foundation Spec

## Goal

Add a minimal, session-only Patrol command for combat-capable player units and heroes that improves army control without replacing behavior modes or rewriting pathing.

## Command Rules

- Patrol can be started from a small HUD command button or the P hotkey.
- Valid patrol units are living player units/heroes that are not Workers and have combat stats.
- Patrol creates a route between the unit's current position and the clicked patrol destination.
- The unit moves to the patrol destination, then returns to the origin, repeating while alive.
- Existing combat acquisition remains responsible for engaging enemies during patrol.
- Patrol is session-only and not saved.

## Cancellation Rules

Patrol is cancelled by:

- explicit move or attack commands,
- Stop/clear command through Escape selection changes,
- behavior-mode changes,
- Worker build/repair/resource-site orders,
- construction/repair/site commands if a future selectable unit can receive them,
- death or scene shutdown.

## UI Copy

- Button label: `Patrol`.
- Button detail: `Hotkey P`.
- Pending copy: `Patrol: click a destination`.
- Order summary: `Patrolling - Moving between the patrol point and origin; fights nearby enemies by current behavior.`

## Safety

- Tutorial does not require Patrol.
- Patrol does not alter AI, balance, saves, campaign rewards, or ability hotkeys.
- If no valid combat units are selected, Patrol shows a short disabled reason instead of starting.

## Deferrals

- No patrol queue.
- No waypoint chains.
- No visible route editor.
- No enemy Patrol AI.
- No patrol persistence.
