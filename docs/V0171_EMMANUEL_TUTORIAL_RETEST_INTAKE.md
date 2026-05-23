# v0.17.1 Emmanuel Tutorial Retest Intake

Date: 2026-05-23
Checkpoint target: v0.17.1 tutorial drag polish, incoming damage feedback, and beginner pacing

## Tested Build

- Package: `ascendant-realms-private-playtest-171ba86`
- Build: `171ba86`
- Route: Tutorial
- Browser/OS: Emmanuel local test
- Result: MIXED

## Pass

- Tutorial box options mostly work.
- Hide/Show works.
- Reset works.
- Tutorial guidance seems fine.
- Combat sanity seems fine.
- Results flow works; Complete Tutorial goes to the winning screen.

## Issues

### 1. Tutorial Box Drag Area Too Narrow

Current behavior: the Tutorial objective panel only drags when hovering and holding the `Proving Grounds` title text.

Expected behavior: the player should be able to drag by holding any non-button part inside the Tutorial box/panel.

Constraints:

- Buttons must remain clickable.
- Buttons must not start drag.
- Drag remains session-only and does not write save data.
- Drag must not block HUD, minimap, or battle commands outside the panel.

### 2. Incoming Damage Feedback Is Unclear

Current behavior: player damage inflicted on enemies is visible, but damage enemies inflict on the hero or friendly units is not clearly readable.

Expected behavior: enemy damage to player-controlled hero/units should be visibly readable using existing feedback systems/assets only.

Constraints:

- Use existing floating text/combat feedback systems.
- Do not add runtime art/assets.
- Respect settings such as disabled floating text.

### 3. Tutorial Enemy Ramps Too Fast

Current behavior: enemy army buildup in the Tutorial can become huge too quickly for inexperienced players.

Expected behavior: Tutorial-only enemy escalation/pressure should be slower or more forgiving.

Constraints:

- Do not globally nerf enemy AI.
- Do not change campaign/skirmish balance.
- Keep Tutorial winnable for beginners without making it empty.

## v0.17.1 Scope Decision

This is a narrow Tutorial polish checkpoint after v0.17. It does not implement worker construction, start v0.18, add units/buildings/maps/factions, rewrite AI/pathing, change save format, add runtime art/assets, or weaken tests.
