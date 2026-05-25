# v0.22 Emmanuel Retest Checklist

Date: 2026-05-24

Package target: clean `ascendant-realms-private-playtest-<v0.22 commit>`.

## Resource Site Worker Assignment

- Capture a resource site.
- Train or select a Worker.
- Select the Worker and assign them to the friendly captured site with the Resource Sites command or right-click.
- Confirm the Worker travels to the site if not already nearby.
- Confirm Worker order text shows `Returning to Site` while traveling and `Working Site` when active.
- Select the site and confirm it shows base income, Worker slot, Worker bonus, and boosted income.
- Wait for an income tick and confirm resources increase by base income plus the Worker bonus.
- Move the Worker away and confirm the site returns to baseline-only income.
- Reassign the Worker to another captured site and confirm the old site loses the boost while the new site gains it.

## Invalid Assignment Cases

- Try assigning to a neutral resource site: should be blocked or shown as needing capture first.
- Try assigning to an enemy resource site: should be blocked or shown as enemy controlled.
- Stand a Worker near a captured site without issuing assignment: no bonus should start.
- Kill or remove the Worker after assignment: assignment should clear.
- Let the site become enemy/neutral: assignment should clear.

## Regression Checks

- Worker construction still requires explicit Build/Resume Construction.
- Worker repair still requires explicit Repair.
- Move-away still pauses/clears construction and repair work intent according to the current order model.
- Explicit Worker attack still damages enemy buildings.
- Burn/status marker remains a clear labeled status marker, not a health-bar dot.
- No harvesting, cargo, drop-off, or enemy Worker mining behavior is present.

## Future UI Note

Attack cursor should eventually use crossed swords. Repair/build/finish construction should eventually use a hammer. v0.22 adds no new cursor art.
