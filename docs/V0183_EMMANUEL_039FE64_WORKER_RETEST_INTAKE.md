# v0.18.3 Emmanuel 039fe64 Worker Retest Intake

Date: 2026-05-24
Package: `ascendant-realms-private-playtest-039fe64`
Build: `039fe64`
Manual route: Worker Construction / Tutorial or skirmish
Result: MIXED

## Manual Retest Pass

- Command Hall trains Worker only.
- Worker can build Barracks, Mystic Lodge, and Watchtower.
- Incomplete Barracks cannot train.
- Completed Barracks trains Militia and Ranger.
- Incomplete Mystic Lodge has no completed-building actions.
- Completed Mystic Lodge actions work.
- Incomplete Watchtower does not attack.
- Completed Watchtower behaves correctly.

## Manual Retest Fail

1. Worker move-away during construction is unreliable.
   - One time the Worker moved away correctly.
   - Another time, no matter how many move commands were issued, the Worker would not leave construction and kept being attracted back like a magnet.
2. Construction did not pause or stop when the Worker moved away.
   - Expected: assigned Worker must be alive and near the footprint for construction progress.
   - Actual: construction continued or never stopped.
3. Pathing around buildings and construction sites is poor.
   - Units including Worker often got stuck near Command Hall, Barracks, Mystic Lodge, and Watchtower.
   - Sometimes units also seemed stuck elsewhere on the map, like they were blocked by invisible rocks.
   - Screenshot evidence: a unit near the base/building cluster would not move to attack an enemy.

## v0.18.3 Bugfix Scope

Fix Worker construction assignment, construction pause/resume, and building-cluster pathing bugs only.

Hard exclusions:

- No v0.19 feature work.
- No harvesting.
- No repair.
- No multiple-worker acceleration.
- No enemy construction AI.
- No new units, buildings, maps, or factions.
- No save migration.
- No runtime art/assets.
- No broad global rebalance.
- No Patrol or formations.
- No assertion weakening.
- No force clicks.
- No DOM fallback for canvas/world clicks.

## Acceptance Targets

- Explicit player move commands override construction assignment temporarily.
- Worker is not auto-pulled back to construction after a player move-away order.
- Construction progresses only while the assigned Worker is alive and within valid work range.
- Moving the Worker away pauses progress and keeps the building incomplete/disabled.
- Moving the Worker back into range resumes progress.
- Existing completed/incomplete Barracks, Mystic Lodge, and Watchtower behavior remains unchanged.
- Units and Workers can move out of a Command Hall + Barracks + Mystic Lodge + Watchtower cluster.
- A unit near the base cluster can move to attack an enemy without getting stuck on invisible blockers.
