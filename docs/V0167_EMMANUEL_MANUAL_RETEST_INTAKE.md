# v0.16.7 Emmanuel Manual Retest Intake

Date: 2026-05-21

## Session

- Session id: `PT-20260521-EMMANUEL-V0166-CONTROLS-01`
- Build: `3737c16`
- Checkpoint: v0.16.6 hosted deep-battle first campaign training stabilization
- Package: `ascendant-realms-private-playtest-3737c16`
- Tester: Emmanuel
- Route: Tutorial
- Browser: Brave
- OS: Windows
- Result: MIXED

## Confirmed Working

- Guard Area is default.
- Hold Ground generally does not chase distant enemies.
- Hold Ground responds when directly attacked.
- Left-click enemy attack seems to work.
- Guard Area seems fine.
- Press Attack seems okay and not crazy infinite chasing.
- Drag-select across HUD/minimap works.
- Minimap click plus `H` hero-select does not leave the side panel stuck at `No Selection`.
- Tutorial defeat Results flow works.

## Broken Or Problematic

### Adjacent Melee Idle After First Enemy Dies

Manual report:

- Hero in Hold Ground killed one of two attacking Stone Imps.
- The second imp stood next to the hero without attacking.
- The hero also did not attack the second imp.
- The same pattern appears with other close enemy pairs: one attacks and dies, then the next adjacent enemy and the player unit can both idle.

Triage priority: high. Idle contact melee is a high-priority control regression under the v0.16 control triage guide.

### Enemy/Base Aggro Bug

Manual report:

- Emmanuel dragged many enemies close to the main building / Command Hall.
- Many enemies stood inside friendly territory doing nothing.
- Only ranged units seemed to attack.
- Melee enemies should not idle beside an enemy Command Hall/building when they have no better target.

Triage priority: high. This is a melee target-acquisition issue around valid hostile buildings, not a request to rebalance enemy waves or building durability.

### Retreat Still Partially Unreliable

Manual report:

- Usually units/heroes obey retreat or move-away commands.
- Near multiple enemies, some units stop obeying and keep fighting until they die.
- One time multiple units were ordered to retreat; most moved, but one unit stopped while the others moved.
- Possible causes include reacquisition timing, combat suppression expiry, collision, or terrain/pathing.

Triage priority: high if reproducible. Repeated snap-back or combat reacquisition overriding explicit move-away remains a high-priority control issue.

### Attack Cursor Hit Area / Readability

Manual report:

- A different attack cursor appears, but only when hovering a very specific tiny spot on the enemy.
- The attack cursor visual does not strongly communicate attack.
- Improve the hit/hover target tolerance if possible.
- Improve cursor clarity only with existing cursor/CSS/options; do not add runtime art assets.

Triage priority: high for hit tolerance, medium for visual clarity if existing cursor options are insufficient.

## Deferred Feature Request

Emmanuel said workers should be able to make constructions.

This is a future design feature request, not a v0.16.7 bugfix. v0.16.7 must not implement workers, builders, new construction units, new buildings, economy changes, or save changes.

## Scope Boundary

Use only the manual evidence above. Do not invent additional human feedback. Fix only narrow combat/contact, enemy building aggro, retreat priority, and attack hover tolerance issues that are confirmed or strongly evidenced by code audit and tests.
