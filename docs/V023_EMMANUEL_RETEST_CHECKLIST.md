# v0.23 Emmanuel Retest Checklist

Date: 2026-05-25

Package target: clean `ascendant-realms-private-playtest-<v0.23 commit>`.

## Resource Site Upgrade Flow

1. Capture a resource site.
2. Select the site and confirm it shows Level 1, base income, one Worker slot, and an Upgrade command.
3. Upgrade the site and confirm it becomes Level 2.
4. Confirm the site shows upgrade bonus, total income, and two Worker slots.
5. Confirm neutral/enemy sites cannot be upgraded and explain why.

## Worker Slots

1. Train or use two Workers.
2. Explicitly assign the first Worker to a friendly captured site.
3. Confirm proximity alone does not assign a Worker.
4. Confirm the first Worker shows Returning to Site then Working Site.
5. Upgrade the site.
6. Explicitly assign a second Worker.
7. Confirm both Worker slots are filled and the total income includes both Worker bonuses.
8. Try to assign a third Worker if available; the site should reject overfill clearly.

## Clearing And Reassignment

1. Move one assigned Worker away and confirm that Worker's slot/boost stops.
2. Reassign a Worker to another friendly captured site and confirm the old site's boost stops.
3. Kill or remove an assigned Worker if practical and confirm the slot clears.
4. Lose or neutralize the site and confirm all assignments clear and the site returns to Level 1.

## Regression Watch

- Baseline captured-site passive income still works without Workers.
- v0.22 Worker assignment still requires explicit command.
- Neutral/enemy sites reject Worker assignment.
- v0.21 Worker build, repair, and explicit attack remain distinct commands.
- Burn/status marker still reads as a status chip, not a broken health bar.

## Not In This Build

- No classic carry/drop-off harvesting.
- No enemy Worker mining AI.
- No enemy site upgrade AI.
- No new maps, factions, runtime art, or cursor art.
