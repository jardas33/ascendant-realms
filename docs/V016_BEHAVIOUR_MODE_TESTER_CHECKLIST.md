# v0.16 Behaviour Mode Tester Checklist

Date: 2026-05-19

Use this checklist while playing the v0.16 private package. Mark each item as `pass`, `issue`, or `not tested`.

## Setup

- Build commit recorded.
- Route recorded.
- Session id recorded.
- Tutorial or First Claim path started.

## Behaviour Modes

- Newly selected hero/unit shows `Guard Area`.
- `Hold Ground` button changes the current mode copy.
- `Guard Area` button changes the current mode copy.
- `Press Attack` button changes the current mode copy.
- Group selection can receive a shared mode.
- Mixed group mode copy is readable if seen.

## Hold Ground

- Does not chase a clearly distant idle enemy.
- Attacks a hostile already in contact or immediate melee range.
- Still obeys an explicit attack command.
- Still obeys an explicit move-away command.

## Guard Area

- Feels like the normal balanced default.
- Responds to nearby threats.
- Does not look like map-wide chasing.
- Explicit attack and move commands still work.

## Press Attack

- Pursues more strongly than Guard Area.
- Does not chase across the whole map.
- Still respects move-away/retreat intent.
- Does not break attack hover or left-click attack.

## Attack Intent

- Hovering a valid enemy with a controllable unit selected shows attack intent.
- Left-clicking that enemy issues an attack order.
- Moving the pointer away clears attack intent.
- Empty left-click does not issue an attack command.

## Retreat And Snap-Back

- Move-away command is visibly obeyed.
- Unit does not immediately glue back to the same target.
- Repeated move-away commands do not create a snap-back loop.
- Nearby enemies can still chase or damage the unit.

## HUD / Minimap / Tutorial

- Drag-select works when crossing the side HUD.
- Drag-select cleanup works when releasing over HUD/minimap.
- Minimap movement still works after using behaviour buttons.
- Pressing `H` refreshes the hero panel after HUD/minimap interaction.
- Complete Tutorial routes to no-save/no-reward Results.
- Losing Tutorial routes to no-save/no-reward Results.
- Retry Tutorial and Return to Main Menu still work.
