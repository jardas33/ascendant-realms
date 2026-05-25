# v0.23 Implementation Report

Date: 2026-05-25

## Scope

v0.23 adds a controlled resource-site upgrade and Worker slot expansion layer on top of v0.22. It preserves the current capturable site-control economy and does not add classic carry/drop-off harvesting, enemy Worker resource AI, enemy construction AI, new maps, factions, runtime art, save migration, broad pathing changes, global rebalance, Patrol, or formations.

## Runtime Changes

- Capture sites now have a battle-runtime level.
- Friendly captured sites start at Level 1 with one Worker slot.
- Friendly captured sites can be upgraded instantly to Level 2 for 120 Crowns and 80 Stone.
- Level 2 sites add a conservative 15% rounded upgrade income bonus, minimum +1.
- Level 2 sites unlock a second Worker slot.
- Worker assignment now tracks explicit slots while keeping legacy first-slot fields readable for existing UI and tests.
- Duplicate assignment of the same Worker is idempotent and does not fill extra slots.
- Full sites reject extra Worker assignment with command feedback.
- Worker move, attack, build, repair, reassignment, death, and site control loss clear the relevant assignment.
- Losing site control clears all Worker slots and resets the site to Level 1.

## UI Changes

- Selected resource sites show level, resource, base income, upgrade bonus, Worker slot usage, assigned Workers, Worker bonus, total income, and status.
- Selected friendly captured sites expose an Upgrade command using the existing command panel.
- Worker Resource Sites commands show level, slot usage, total tick income, and invalid reasons for neutral/enemy/full sites.
- Income floating text can include upgrade and Worker bonus details.

## Tests Added Or Expanded

- ResourceSystem coverage for Level 1 defaults, Level 2 upgrade cost/bonus/slots, invalid upgrade targets, duplicate assignment prevention, overfill rejection, and base + upgrade + Worker income.
- Command panel coverage for resource-site assignment slot copy and captured-site upgrade commands.
- Selected resource-site panel coverage for level, upgrade bonus, slot count, assigned Workers, and total income.
- Hosted deep-battle regression expanded to capture a site, assign a Worker, upgrade the site, assign a second Worker, verify the higher total income tick, and confirm site loss clears state.

## Tutorial Impact

No Tutorial requirement changes were made. Site upgrades remain optional economy depth; the Tutorial continues to be beginner-friendly and does not require upgraded sites or multiple assigned Workers.

## Retest Focus

Use the clean v0.23 package. Capture a resource site, assign one Worker, verify the v0.22 bonus still works, upgrade the site, assign a second Worker, verify slot/UI/income changes, confirm neutral/enemy sites cannot upgrade or accept Worker assignment, and confirm moving/reassigning/death/site loss clears the appropriate slot and boost.
