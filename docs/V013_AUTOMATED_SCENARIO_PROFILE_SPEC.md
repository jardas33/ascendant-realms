# v0.13 Automated Scenario Profile Spec

Date: 2026-05-18

Purpose: define deterministic automated scenario profiles that group the existing simulator scripts and Stronghold/retinue rows into route-level evidence views.

These profiles are automated evidence profiles, not human tester reports.

## Implementation Shape

Profile definitions live in:

- `src/game/playtest/ScenarioLabProfiles.ts`

The generated profile catalog is:

- `PLAYTEST_SCENARIO_PROFILES.md`
- `PLAYTEST_SCENARIO_PROFILES.json`

Each profile records:

- route assumptions
- player behavior model
- Stronghold/retinue profile rows
- behavior scripts
- battle nodes
- risk appetite
- objective priority
- retreat/survival bias
- expected strengths
- expected weaknesses
- watchpoint relevance
- route markers
- automation notes

## Profiles

| Profile | Behavior model | Watchpoint purpose |
| --- | --- | --- |
| Baseline Cautious | Safe Beginner with no Stronghold/retinue power. | Normal careful baseline, early defeats, pressure fairness. |
| No-Retinue | Safe Beginner through non-retinue Stronghold paths. | Campaign fairness without carried veteran power. |
| One-Veteran | Safe Beginner with one Veteran Militia or one Veteran Ranger. | Whether one veteran helps without dominating. |
| Mixed-Veterans | Safe Beginner and Fast Army with mixed veterans. | Experienced-player carryover without max stacking. |
| Retinue + Training Yard II | All three scripts through the stacked retinue/Training Yard II path. | Strongest earned-power watchpoint. |
| Greedy Economy | Greedy Economy across the full profile matrix. | Resource/value risk and conversion/timeouts. |
| Fast Army | Fast Army across the full profile matrix. | Speed, Cinderfen clear time, and route dominance risk. |
| Pressure-Ignoring | Fast Army on pressure-enabled Cinderfen nodes. | Whether pressure can be bypassed or is too late to matter. |
| Objective-Rush | Fast Army on Ashen/Cinderfen with baseline and stacked profiles. | Whether objective rushing trivializes watchpoint nodes. |
| Safe Beginner | Safe Beginner across the full profile matrix. | Structural fairness reference. |

## Determinism Rules

- Profiles are typed data only.
- Profiles reuse existing simulator scripts and Stronghold profile rows.
- Profiles do not modify runtime battle code.
- Profiles do not create new maps, factions, units, art, or save fields.
- Profiles do not claim human behavior was observed.
- If a profile is only a proxy, its automation notes must say so.

## Known Proxy Limits

Pressure-Ignoring and Objective-Rush currently reuse Fast Army behavior because the simulator does not model human attention or warning dismissal. That is acceptable for automated evidence, but the output must still say that human noticeability remains unknown.
