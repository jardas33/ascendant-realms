# v0.25 Emmanuel Retest Checklist

Date: 2026-05-25

Package target: clean `ascendant-realms-private-playtest-<v0.24-v0.25 commit>`.

## Enemy Resource Site Strategy

1. Start a normal skirmish or early campaign battle with several resource sites.
2. Let the opening breathe long enough for enemy expansion.
3. Confirm enemy units can move toward and contest or capture a neutral resource site.
4. Capture an enemy-held site if practical and watch whether the enemy sends a small retake squad later.
5. Confirm enemy site pressure uses existing movement/capture behavior, not instant ownership flips.

## Enemy Site Upgrades

1. Let the enemy hold at least one resource site for a while.
2. Confirm the enemy can improve a captured site to Level 2 after a delay.
3. Select the enemy site and confirm Level 2/improved-site copy is readable.
4. Confirm the enemy does not instantly upgrade every site.
5. Confirm neutral and player-owned sites are not upgraded by the enemy.

## Economy Pressure Raids

1. Capture and upgrade a player resource site.
2. Assign a Worker to the site if practical.
3. Watch for periodic enemy raid pressure against that site.
4. Confirm raids are readable and periodic, not constant every-tick chaos.
5. If the player has a much stronger nearby force, confirm weak raids can regroup instead of suiciding forever.

## Worker-Slot Handling

1. Treat enemy Worker-slot bonuses as abstract logistics only.
2. Confirm no enemy Worker units, cargo, harvesting route, or drop-off loop appears.
3. Capture an enemy improved/logistics site and confirm enemy abstract logistics clears with site loss.
4. Confirm player Worker assignment/upgrades from v0.22/v0.23 still behave as before.

## Regression Watch

- Worker construction still requires explicit Build/Resume Construction.
- Worker repair still requires explicit Repair.
- Explicit Worker attack still damages valid enemy buildings.
- Neutral/enemy/full sites still reject player Worker assignment clearly.
- Site loss still clears player Worker slots and resets site level.
- No new maps, factions, runtime art, save migration, Patrol, formations, or broad pathing rewrite should be present.
