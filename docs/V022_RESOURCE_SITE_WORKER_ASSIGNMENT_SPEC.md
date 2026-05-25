# v0.22 Resource Site Worker Assignment Spec

Date: 2026-05-24

## Mission

Add the first resource-economy expansion after the v0.21.x Worker intent work by letting Workers explicitly support already captured resource sites. This is not classic villager harvesting.

## Design Direction

Ascendant Realms keeps its current site-control economy:

- Captured resource sites continue to provide baseline passive income.
- A selected Worker can be explicitly assigned to a friendly captured resource site.
- The Worker travels to the site and becomes Working/Assigned once in range.
- While the assigned Worker is alive, assigned, and in range, that site adds a small income bonus to its normal tick.
- Proximity alone never assigns a Worker and never starts the bonus.
- Moving, attacking, building, repairing, or assigning elsewhere recalls/reassigns the Worker and stops the old site bonus.
- If the site is lost, neutralized, or otherwise invalid, assignment ends.
- v0.22 starts with one Worker slot per resource site.

## Why Not Carry/Drop-Off Harvesting

The current game already teaches contested map control through capture sites and passive battle resources. Full carry/drop-off harvesting would add a new worker loop, drop-off infrastructure, pathing pressure, economy balance, and UI rules all at once. That would compete with the v0.21 Worker construction/repair intent model and risk turning this checkpoint into a broad economy rewrite.

The safer foundation is site-control plus Worker assignment: it deepens the existing mine/resource-site system, keeps the player's strategic choice on captured territory, and creates a future bridge to richer economy play without adding hauling, cargo, depot rules, or enemy worker mining AI.

## Rules

- Assignable target: alive friendly captured resource site.
- Invalid targets: neutral site, enemy site, destroyed/invalid site, or a site whose one Worker slot is filled by another Worker.
- Worker requirement: alive player Worker.
- Range requirement: Worker must be within the site's capture radius for the bonus to apply.
- Income: baseline income remains unchanged. Assigned Worker adds a conservative bonus equal to 20% of the site's normal tick, rounded, with a minimum of +1.
- Resource identity: the bonus uses the site's existing resource type.
- Enemy AI: unchanged. Enemy worker mining is not part of v0.22.
- Save data: unchanged. Assignment is battle-runtime state only.

## UI Requirements

Worker command panel:

- Lists resource sites in a Resource Sites group.
- Shows base income, Worker bonus, interval, and assignability status.
- Locks neutral/enemy/filled slots with a reason.

Selected resource site panel:

- Shows control state.
- Shows resource type.
- Shows base income.
- Shows Worker slot state.
- Shows Worker bonus.
- Shows boosted income.
- Shows invalid/uncaptured instruction when needed.

## Future UI Note

Future cursor polish should make command intent clearer with crossed-swords for attack and hammer for repair/build/finish construction. v0.22 adds no runtime art assets and no cursor art.
