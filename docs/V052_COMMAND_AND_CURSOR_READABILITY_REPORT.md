# v0.52 Command and Cursor Readability Report

## Runtime Scope

v0.52 keeps the existing input model and command surfaces. It adds a small cursor-intent derivation layer and tighter command disabled-reason metadata. It does not add force clicks, DOM fallbacks for world interactions, custom cursor art, new abilities, new orders, Patrol, formations, or save data.

## Cursor Affordances

- Hostile hover with selected player units: native `crosshair`, intent `attack`, label `Attack target`.
- Incomplete friendly building with a live selected Worker: native `copy`, intent `build`, label `Build or continue construction`.
- Damaged friendly completed building with a live selected Worker: native `copy`, intent `repair`, label `Repair damaged building`.
- Captured resource site with a live selected Worker and an available slot: native `alias`, intent `assign`, label `Assign Worker to resource site`.
- Invalid Worker targets such as full-health friendly buildings or non-assignable sites: native `not-allowed`, intent `invalid`, label `Invalid target`.
- Empty terrain and normal movement stay on the default cursor.

## Command Clarity

- Existing build, train, research, repair, site assignment, and site upgrade buttons now expose `data-command-state`.
- Locked command buttons can expose `data-disabled-reason` using the same short reason shown in the panel.
- Worker repair full-health copy now reads `Full health` / `No repair needed`.
- Resource-site assignment distinguishes `Capture before assigning` from `Worker slots full`.
- Hero ability buttons expose `data-ability-reason` for ready, cooldown, Mana, and locked states.
- Mana copy uses `Mana` consistently in button labels.

## Hosted Coverage

Hosted deep-battle coverage now checks:

- Attack hover cursor intent and readable label.
- Worker build cursor over an incomplete friendly building.
- Worker repair cursor over a damaged friendly building.
- Worker assignment cursor over a captured resource site.
- Hero Rally Banner cooldown reason metadata.

## Known Limits

Native CSS cursors are deliberately simple. A crossed-swords cursor would require custom art and remains future work.
