# v0.22 Implementation Report

Date: 2026-05-24

## Scope

v0.22 adds a narrow Worker assignment foundation for captured resource sites. It does not add classic carry/drop-off harvesting, enemy worker mining AI, enemy construction AI, new maps, factions, units, buildings, runtime art, save migration, broad pathing changes, global rebalance, Patrol, or formations.

## Runtime Changes

- Capture sites now own one runtime Worker assignment slot.
- Workers have a resource-site assignment order separate from move, attack, build, repair, and construction.
- Explicit Worker assignment can be issued from the Worker command panel or by right-clicking a friendly captured site with a selected Worker.
- Proximity alone does not assign a Worker or start bonus income.
- Assigned Workers travel to the site and become `Working Site` when in range.
- Moving, attacking, building, repairing, or assigning elsewhere clears the old assignment.
- Worker death, missing Worker state, or lost site control clears the assignment.
- Baseline site income is preserved; assigned Workers add a small 20% rounded bonus to that site's existing resource tick.

## UI Changes

- Worker command panel includes a Resource Sites section.
- Resource-site commands show base income, Worker bonus, interval, filled slot state, and neutral/enemy invalid reasons.
- Capture sites can be selected and show a resource-site panel with control, resource type, base income, Worker slot, Worker bonus, boosted income, and status.
- Worker order summary now distinguishes `Returning to Site` from `Working Site`.

## Tests Added

- ResourceSystem unit coverage for neutral/enemy rejection, explicit assignment, no proximity assignment, travel before bonus, income boost, recall/move stop, attack stop, reassignment, Worker death, and site loss.
- Unit command-state coverage proving move/attack/build/repair override resource assignment.
- HUD command-panel and selected-site panel coverage.
- Unit order summary coverage for resource-site assignment states.
- Hosted deep-battle regression: capture Crown Shrine, train Worker, assign Worker, verify panel and bonus income, recall Worker, verify baseline-only income.

## Tutorial Impact

The Tutorial still teaches capture-site passive resources. v0.22 does not require Tutorial progression changes, rewards, or persistence changes. Future tutorial copy may mention Worker site assignment after the player has learned Worker construction/repair.

## Retest Focus

Use the clean v0.22 package. Confirm a Worker only boosts a resource site after explicit assignment, that neutral/enemy sites cannot be assigned, that moving or reassigning the Worker stops the old boost, and that v0.21 Worker build/repair/attack behaviours still remain distinct.
