# v0.17.3 Emmanuel e448d18 Tutorial Retest Intake

Date: 2026-05-23
Package tested: `ascendant-realms-private-playtest-e448d18`
Route: Tutorial
Result: MIXED

## Passed

- Incoming damage readability is fixed. Player-side direct damage now shows only the damage amount, not `HIT`.
- Beginner pressure feels better. Tutorial enemy buildup is now easier to survive and win against.
- Tutorial panel dragging and previous Hide/Show behavior remain usable.

## Issues

1. Brief adjacent neutral-contact idle.
   - A player troop stood next to a Stone Imp and a Wild Hound.
   - For a moment, all three appeared idle beside each other instead of attacking.
   - This looks like a remaining visible-contact reacquisition edge for non-hero troops near neutral melee units.

2. Path warning visual noise while attacking the enemy base.
   - When Aster attacked the enemy base, `No clear path. Moving as close as possible.` repeated over the combat area.
   - The message is useful for normal blocked movement, but it becomes visual clutter during an explicit attack order.

3. Bottom-right side panel can block the battlefield.
   - The selected unit/building panel sometimes covers important action.
   - It should be minimizable like the Tutorial objective panel.

4. Production and upgrade costs are not clear enough.
   - Clicking or reviewing create-unit / upgrade options should make costs readable.
   - Existing command buttons need clearer cost text without changing production rules.

## Scope Decision

This is a narrow v0.17.3 polish/fix pass after the green v0.17.2 Tutorial baseline.

- Preserve the v0.17.2 incoming damage text fix.
- Preserve the v0.17.2 Tutorial-only beginner pacing.
- Do not implement worker construction.
- Do not add units, buildings, maps, factions, runtime art/assets, save migrations, or global balance changes.
- Do not rewrite combat, movement, pathing, production, or economy architecture.
