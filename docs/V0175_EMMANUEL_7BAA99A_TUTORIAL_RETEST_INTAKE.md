# v0.17.5 Emmanuel 7baa99a Tutorial Retest Intake

Date: 2026-05-23
Package tested: `ascendant-realms-private-playtest-7baa99a`
Route: Tutorial
Result: MIXED

## Passed / Improved

- Rangers were not completely hard-stuck after production.
- Redirecting them in other directions could sometimes recover movement.
- This suggests the v0.17.4 trained-unit spawn and blocked-start recovery reduced the original hard production-stuck case.

## Issue

1. Rangers can still feel blocked by invisible terrain near the player base.
   - Several ranged units were trained and then given move orders.
   - They were not completely stuck, but sometimes stopped even though no visible object appeared to block the commanded area.
   - Sending them in a different direction could get them moving again.
   - Player read: "invisible rock" or invisible blocker in some places near the Barracks / Command Hall cluster.

## Scope Decision

This is a narrow v0.17.5 follow-up to v0.17.4. The root behavior is no longer trained-unit creation itself; it is the mismatch between coarse building-blocker path cells and exact visible open ground around the Tutorial base.

- Fix precise point walkability for visible open points that share a coarse static building cell.
- Preserve building center / padded footprint blocking.
- Preserve v0.17.4 trained-unit spawn placement and blocked-start recovery.
- Preserve the v0.17.3 cost display, side-panel Hide/Show, neutral-contact, and enemy-base path-warning fixes.
- Do not implement worker construction.
- Do not add units, buildings, maps, factions, runtime art/assets, save migrations, global balance changes, or broad formation/pathing rewrites.
- Do not change Tutorial enemy pacing further unless separately justified.
