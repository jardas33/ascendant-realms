# v0.17.4 Emmanuel 532007d Tutorial Retest Intake

Date: 2026-05-23
Package tested: `ascendant-realms-private-playtest-532007d`
Route: Tutorial
Result: MIXED

## Passed

- Create-unit and upgrade costs are clearly visible now.
- Selected side-panel Hide/Show works.
- Neutral troop contact near the Stone Imp / Wild Hound setup did not reproduce in this attempt; player troops, Stone Imp, and Wild Hound attacked and were attacked.
- The enemy-base attack visual text did not reproduce in this attempt.

## Issue

1. Rangers can get stuck right after production.
   - A couple of newly produced Rangers remained near the player Barracks / Command Hall cluster.
   - They did not move even when the player tried to send them elsewhere.
   - Screenshots show several Rangers clustered beside the Barracks and Command Hall after production.

## Scope Decision

This is a narrow v0.17.4 production-spawn/movement follow-up after the green v0.17.3 contact/UI baseline.

- Fix newly trained units that spawn near building footprints and then cannot answer move orders.
- Preserve the v0.17.3 cost display, side-panel Hide/Show, neutral-contact, and enemy-base path-warning fixes.
- Do not implement worker construction.
- Do not add units, buildings, maps, factions, runtime art/assets, save migrations, global balance changes, or broad pathing rewrites.
- Do not change Tutorial enemy pacing further unless separately justified.
