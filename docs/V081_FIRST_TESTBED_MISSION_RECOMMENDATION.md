# v0.81 First Testbed Mission Recommendation

Status: docs-only recommendation. No campaign node, map, copy, or runtime behavior was changed.

## Recommended Mission

Recommend `aether_well_ruins` as the first future Lume Site Network testbed.

Current node:

- File: `src/game/data/borderMarchesNodes.ts`
- Node id: `aether_well_ruins`
- Current display name: `Aether Well Ruins`
- Map: `broken_ford`
- Mission type: `control`
- Modifier: `mission_aether_surge`
- Enemy hero: `veyra_cinders`
- Act 1 spine step: `act1_aether_well_resource_control`

## Why This Mission Fits

`Aether Well Ruins` is already the Act 1 resource-control mission. Its current onboarding focus is:

- resource sites;
- Worker assignment;
- site upgrades;
- ability pacing;
- holding two sites when possible;
- rebuilding before pushing.

This is the right moment to add exactly one new territorial idea. The player has already cleared:

1. `border_village`: first campaign battle and basic site capture.
2. `old_stone_road`: base development and site economy under light pressure.

So a Lume link does not compete with the earliest core onboarding.

## Map Fit: `broken_ford`

`broken_ford` has four capture sites:

- `ford_toll`: central Crown site at the ford, high value and exposed.
- `west_stone_cut`: nearer Stone site, safer first anchor.
- `south_iron_cache`: side Iron route, useful but not ideal for first link.
- `north_aether_spring`: thematic Aether/Lume-adjacent site near the far lane.

The layout supports a readable progression:

1. Secure `west_stone_cut`.
2. Contest `ford_toll`.
3. Optionally extend toward `north_aether_spring`.

That teaches Lume as a road/land bond rather than a random site buff.

## Mission Comparison

| Mission | Verdict | Reason |
| --- | --- | --- |
| `Aether Well Ruins` | Recommended | Best mix of theme, site count, control mission pacing, and player readiness. |
| `Old Stone Road` | Not first | Uses `first_claim`, has clean sites, but it is still base-building onboarding. Lume would overload the second real battle. |
| `Bandit Hillfort` | Not first | Same map as Aether Well, but its focus is rival pressure and assault timing. Lume would compete with commander pressure. |
| `Ashen Outpost Finale` | Not first | Already has three finale phases, Captain Malrec, elite pressure, events, relic rewards, Retinue, and milestone Results. Too crowded. |
| `Border Village` | Not first | Too early and too tutorial-adjacent for a signature system prototype. |
| Cinderfen maps | Later | Thematic, but should not introduce the first Lume prototype after Act 1 unless Act 1 deliberately defers the signature system. |

## Terminology Recommendation

Future display-copy candidate:

- `Aether Well Ruins` -> `Lume Well Ruins`

Reason:

- It is direct, readable, and teaches the system name.
- It keeps the "well" mental model tied to living land-power.
- It avoids the softer but less system-specific `Old Spring Ruins`.

Do not perform this runtime display-copy migration during v0.81. Keep internal id `aether_well_ruins` unchanged.

## Initial Eligible Nodes

Recommended:

- `west_stone_cut`
- `ford_toll`
- `north_aether_spring`

Reasons:

- The player can start with a safer near-side site.
- The central site creates natural conflict.
- The far Aether/Lume-adjacent site gives a stretch goal.

Maximum:

- Three eligible sites.
- Two active links.

Initial runtime prototype should feel complete with only the first link active. The second link can be present as a stretch condition only if UI remains readable.

## Cognitive Load

Acceptable load:

- One new briefing sentence.
- One HUD row.
- One link objective.
- One Results line.

Do not add:

- a graph overlay;
- hero binding command;
- Worker Lume assignment;
- race variants;
- extra reward types;
- new resources;
- new buildings.

## Replay Posture

Replays can show the Lume objective again because it is battle-local. They must not duplicate first-clear campaign rewards, unique relic rewards, optional objective credit, or any future one-time Lume milestone credit. Existing replay reward rules should remain authoritative.

## Tutorial Posture

Tutorial / Proving Grounds should remain excluded. The first Lume testbed should appear only after the player already understands basic campaign battle flow.
