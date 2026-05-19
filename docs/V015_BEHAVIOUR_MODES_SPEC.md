# v0.15 Behaviour Modes Spec

Date: 2026-05-18  
Status: v0.15 implemented foundation, with patrol and persistence deferred

## Purpose

v0.15 adds an original, small RTS control layer for unit intent. The goal is not to copy another RTS UI or AI model. The goal is to make the current Ascendant Realms prototype clearer when selected units are moving, attacking, holding, guarding, pressing, or repositioning.

This spec uses original terminology and current HUD styling. It does not add maps, factions, units, runtime art, save fields, or gameplay-number tuning.

## Implemented Modes

| Mode | Player-facing description | Runtime intent in v0.15 | HUD label |
| --- | --- | --- | --- |
| Hold Ground | Stay near the current point. Attack only immediate threats or enemies directly attacking this unit. | Player units do not chase distant opportunistic targets. They still attack enemies inside effective weapon/contact range and can respond to direct attackers inside the normal guard leash. | `Hold Ground` |
| Guard Area | Balanced default. Defend nearby space and respond to close threats. | Matches the previous default player idle acquisition leash. Explicit move, attack, and attack-move commands take priority. | `Guard Area` |
| Press Attack | More assertive pursuit inside a local leash. | Player units can acquire targets beyond the default guard leash, but still only inside a bounded local radius. This is not map-wide chasing. | `Press Attack` |

Default mode: `Guard Area`.

## Explicit Move Commands

Normal move orders override behaviour-mode target acquisition while the unit is actively preserving move-away intent.

- `commandMove(..., false)` clears explicit attack target state.
- A short move-order suppression window prevents immediate reacquisition.
- The suppression window is honored for the full update frame in which it expires, so a retreat cannot be overwritten on the same tick.
- If the unit remains in immediate melee/contact range after the grace window, combat can resume. Retreat is not invulnerability.
- If pathing cannot fully reach the clicked point, the existing movement system reports that no clear path exists and moves as close as possible.

## Explicit Attack Commands

Explicit attack commands override behaviour modes.

- Right-click attack keeps working.
- Left-click attack is valid only when a controllable player unit or group is selected and the hovered world entity is targetable.
- The attack order stores a readable target label for selected-unit order copy when available.
- `commandAttack(...)` uses attack-move style pursuit toward that specific target until the target dies, becomes invalid, or another explicit order replaces it.

## Attack-Move Commands

Attack-move remains separate from persistent behaviour mode.

- Attack-move is route-specific.
- It uses the existing attack-move acquisition leash.
- Behaviour modes do not turn a normal move into attack-move.

## Target Reacquisition

Behaviour mode only affects opportunistic player-unit target acquisition.

- Buildings keep their existing attack range behavior.
- Enemy units keep their existing enemy AI and aggro behavior.
- Player units with explicit attack orders, attack-move orders, or immediate in-range enemies can still fight.
- Hold Ground can still attack direct attackers and immediate contact threats.
- Press Attack uses a larger bounded search radius, not unlimited pursuit.

## Enemy Chase

v0.15 does not weaken enemy pursuit or damage.

- Enemies can still chase and attack retreating player units.
- Enemy AI does not receive player behaviour modes.
- No enemy combat stats, wave timing, or pressure plan values changed.

## HUD Presentation

The selected unit panel now shows:

- current order summary;
- current behaviour mode;
- `Hold`, `Guard`, and `Press` text buttons using existing HUD button styling;
- `Mixed` when a selected group has more than one mode;
- command feedback when a mode is applied.

No external icons, copied layouts, new art, or visual-overhaul treatment are used.

## Group Application

When multiple player units are selected, a behaviour mode command applies to all alive selected player units.

- A homogeneous group shows the shared mode.
- A mixed group shows `Mixed`.
- Applying a mode to a mixed group normalizes every selected unit to that mode.

## Persistence Decision

Behaviour modes are session-only in v0.15.

Reasons:

- The current save format has no unit-level behaviour-mode field.
- Persisting mode state would require a save schema and migration decision.
- The requested foundation can be safely tested without persistence.

Result: no save migration, no save-version change, and no persisted behaviour-mode data.

## Deferred

Deferred from v0.15:

- Patrol routes.
- Escort/follow-anchor behaviour.
- Return-to-anchor memory after Guard Area pursuit.
- Per-squad saved stance presets.
- New icons or art.
- Save persistence.
- Broad pathfinding, formation, or AI rewrite.

Patrol remains design-only because it needs route state, route feedback, interruption rules, and stronger path visualization before it can be robust.

