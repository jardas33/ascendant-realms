# v0.171 Character Integration Freeze Decision

Status: `PASS_V0171_CHARACTER_INTEGRATION_FREEZE`

Decision: freeze character-slot expansion after the five selected opt-in slots.

## Selected Frozen Slots

| Slot | Runtime posture |
| --- | --- |
| Worker | Active normal-slice opt-in |
| Barracks material | Active normal-slice opt-in |
| Militia | Active normal-slice opt-in |
| Aster | Active normal-slice opt-in |
| Ashen Raider | Active normal-slice opt-in |

## Rationale

- The five-slot posture is technically valid, fail-closed, and benchmark-green.
- The character billboards now read more clearly than the remaining environment shell.
- Adding a sixth character slot would not address the current player-facing weakness.
- The largest visual bottleneck is the procedural battlefield foundation: terrain, roads, river, bridge, site markers, structure shell, and review framing.
- Artifact hygiene now needs bounded retention discipline, not broader character expansion.

## Required Next Direction

The next phase should focus on the environment foundation:

- Procedural world-shell hierarchy.
- Road, river, bridge, and site-marker readability.
- Terrain palette and material planning.
- Bounded terrain-material comparator readiness.

The five-slot art path remains experimental and opt-in. The default launchers remain procedural. Do not add a sixth character slot without a later explicit prompt that reopens the character-slot boundary.
