# v0.21 Worker Repair Foundation Spec

Date: 2026-05-24
Status: implementation spec

## Baseline

- Starting commit: `1ae687e`, `Checkpoint v0.20.1 tech tree closeout and polish`.
- Starting package: `ascendant-realms-private-playtest-1ae687e`.
- v0.18.3 Worker construction assignment, pause/resume, and base-cluster pathing stability remain protected.
- v0.20.1 architecture remains: Command Hall trains Workers only and owns core tech; Workers build Barracks, Mystic Lodge, and Watchtower; Barracks, Mystic Lodge, and Watchtower own their current production/tech/defense roles.

## Scope

Add the first safe Worker repair action for completed friendly buildings.

Included:

- Worker repair orders for damaged friendly completed buildings.
- Worker repair range checks against the building footprint.
- Repair progress only while the Worker is alive and near the target.
- Explicit move and attack orders pause repair intent.
- Reissuing Repair or moving the Worker back into range resumes repair.
- Existing UI surfaces for Worker repair buttons, order summary, building HP, damaged/full-health status, and no-cost repair copy.
- Focused unit/UI and hosted browser coverage.

Not included:

- Harvesting or resource dropoff.
- Repair resource cost.
- Enemy repair AI.
- Enemy construction AI.
- Multiple-worker repair acceleration.
- New maps, factions, units, buildings, runtime art/assets, save migration, broad AI/pathing rewrites, global rebalance, Patrol, or formations.

## Repair Rules

- Only Workers can repair.
- Only alive player Workers can receive repair orders.
- Only alive, friendly, completed buildings can be repaired.
- Enemy buildings cannot be repaired.
- Incomplete buildings remain construction sites and cannot be repaired.
- Full-health buildings do not start repair; UI/status reports that they are already repaired.
- Repair restores building HP slowly over time.
- v0.21 repair has no resource cost; resource-cost repair is deferred until the economy model exists.
- A single Worker can repair a target. Multiple-worker acceleration is deferred.

## Worker Intent

Repair uses its own Worker intent state, separate from ordinary move/attack and separate from construction assignment.

- Repair command sets active repair intent and moves the Worker to a valid footprint-adjacent approach point if needed.
- While active and out of range, repair may auto-approach the target.
- Explicit move or attack pauses repair intent and prevents magnet-style auto-return.
- If the Worker returns to valid range with the paused repair target still valid, repair resumes.
- Reissuing Repair clears ordinary attack/move intent and resumes repair.

## UI Requirements

- Selected Worker shows Repair commands for completed friendly buildings.
- Damaged building repair buttons show target, HP, no-cost status, and the requirement that the Worker stay nearby.
- Full-health targets are disabled and marked already repaired/full health.
- Selected Worker order summary shows active or paused repair.
- Selected completed buildings show HP and Repair status.
- Incomplete buildings keep construction status and do not expose repair as a replacement action.

## Deferrals

- Repair resource costs.
- Repair upgrades.
- Multi-Worker acceleration.
- Enemy repair/construction AI.
- Persistent repair state across saves.
- New repair VFX, sounds, or art.
