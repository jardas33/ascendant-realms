# v0.16.13 bd26de3 Retest Intake

Date: 2026-05-23

Package retested: `ascendant-realms-private-playtest-bd26de3`
Build: `bd26de3`
Route: Tutorial / Proving Grounds
Result: FAIL

## Manual Finding

The v0.16.12 package still failed the stationary adjacent melee retest:

- In Tutorial, the hero was in Hold Ground beside two Stone Imps.
- Before combat started, the hero and imps could stand beside each other idle until the hero was moved again.
- After the first imp died, the second imp and hero could again stand adjacent and idle until the hero was moved again.

This means v0.16.12 improved some contact cases but did not cover the visible Stone Imp contact boundary Emmanuel hit in the package.

## Scope Decision

This is a v0.16.x bugfix follow-up only. It does not start v0.17 and does not change worker construction, maps, units, buildings, factions, balance stats, saves, runtime art, or broad pathing/AI behavior.

