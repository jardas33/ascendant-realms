# v0.26 Enemy Base Development Spec

Date: 2026-05-26

## Mission

Extend the v0.24-v0.25 enemy resource-site layer into controlled enemy base development. The enemy should convert site control and battle resources into a stronger camp posture without adding visible enemy Workers, classic harvesting, new buildings, new maps, or a construction rewrite.

## Base Model

v0.26 uses an abstract base-stage model backed by existing spawned enemy structures:

| Stage | Trigger | Runtime meaning |
| --- | --- | --- |
| Outpost | Opening time, low site control, or low stockpile | Capture neutral sites, train small squads, keep pressure light. |
| Fortified Camp | Meaningful site control, improved sites, base threat, or midgame time | Protect the enemy base and valuable sites, begin conservative tech, form mixed squads. |
| War Camp | Late time plus healthy economy/site control | Coordinate stronger pressure while keeping a defensive reserve. |

The model is battle-runtime only and does not save persistent enemy base state.

## Existing Role Mapping

The enemy evaluates existing structures as roles:

- Enemy Stronghold: Command Hall/base hub role for core fortification.
- Enemy Barracks: Barracks military role and abstract hexfire support role.
- Enemy Watchtower: Watchtower defensive role when a map already spawns one.

The enemy does not place new structures in v0.26. If a role is missing, the planner can record that the role is unavailable, but it does not spawn or rebuild it through fake construction.

## Defensive Priorities

Defense priority order:

1. Enemy base under direct approach.
2. Upgraded or high-income enemy-owned resource sites under player threat.
3. Normal enemy-owned sites under player threat.
4. Routine expansion or raids.

While the base is threatened, the enemy should not send all available units away. Raids and expansion plans should leave a small reserve when the enemy is fortifying or escalating.

## Economy Thresholds

Enemy base development can advance when one or more of these are true:

- enemy controls at least two resource sites,
- enemy controls an improved resource site,
- enemy has a healthy resource stockpile after normal training pressure,
- the battle has reached mid or late timing,
- player units threaten the enemy base or a high-value site.

These thresholds should pace behavior. They should not grant free units or global stat buffs.

## Fairness And Readability

- No classic harvesting, cargo, drop-off, or visible enemy Worker economy.
- No enemy construction placement.
- No instant mass fortification.
- No nonstop attacks while the player is responding to site pressure.
- Status text may say "Enemy is fortifying" or "Enemy defending site" when useful, but alerts must remain cooldown-paced and not spam the battle log.

## Deferrals

- Full enemy construction AI.
- Visible enemy Workers.
- New enemy buildings, factions, maps, unit roster, or art.
- Save migration for enemy base state.
- Broad pathing, formation, Patrol, or global balance rewrites.
