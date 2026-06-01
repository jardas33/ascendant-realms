# v0.97 Selection Feedback Spec

Status: implemented.

## Goal

Make the current selection state easier to read without changing selection rules, drag selection, control groups, combat, saves, or unit stats.

## Scope

v0.97 adds presentation support only:

- Single hero, unit, Worker, building, enemy, and capture-site selections get a compact focus card.
- Multi-unit selections show a concise squad focus card and preserve role/order summaries.
- Enemy inspection is read-only and distinct from player command selection.
- Player building selection rings use stronger shape/border contrast.
- Control groups and drag selection continue to use existing selection IDs and filters.

## Selection States

| State | Presentation | Command posture |
| --- | --- | --- |
| Hero selected | Champion focus card, current order, role identity, behavior controls | Existing hero commands and ability buttons only |
| Worker selected | Utility focus card, Worker role/capability summary | Existing build, repair, site assignment, move, attack, behavior commands |
| Combat unit selected | Unit focus card, role, veterancy, order | Existing movement, attack, Patrol, behavior commands |
| Squad selected | Squad focus card, selected count, roles, orders, control groups | Commands apply only to selected player units |
| Player building selected | Building focus card, queue/rally/repair summary | Existing building actions and rally behavior |
| Enemy unit/building inspected | Enemy/read-only focus card | No player behavior controls exposed |
| Capture site selected | Site focus card with ownership tone | Existing site upgrade/assignment rules |

## Guardrails

- No stable IDs changed.
- No save fields added.
- No gameplay rules, combat balance, pathing, or command eligibility changed.
- Enemy inspection does not add enemy units to control groups or player unit command flows.
- Drag-select remains player unit/hero only.

## Tests

- Unit coverage verifies enemy marquee exclusion and read-only inspection.
- HUD panel coverage verifies hero/unit/Worker/enemy focus copy and command availability boundaries.
- Hosted coverage verifies hero, Worker, squad, building, and enemy inspection focus states.
- Visual QA captures the v0.97 focus cards at 1920x1080, 1600x900, and 1366x768.
