# v0.146 Runtime-Art Pipeline Scorecard

Status: qualitative engineering scorecard from the isolated comparator.

Scoring is 1 to 5 per category, with 5 best. Higher animation/content burden scores mean lower burden and safer production feasibility.

| Approach | Modern 2026 ceiling | Salto / Barrosan fit | RTS unit readability | Environment richness | VFX potential | Animation burden | Content burden | AI-first operability | Maintainability | Performance risk | Migration risk | Next-slot fit | Total / 60 | Posture |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| `HYBRID_3D_WORLD_BILLBOARD_UNITS` | 5 | 5 | 4 | 5 | 5 | 4 | 4 | 4 | 4 | 4 | 4 | 5 | 53 | Recommended next single-slot experiment |
| `ORTHO_3D_MESH` | 5 | 4 | 4 | 5 | 5 | 2 | 2 | 4 | 3 | 3 | 3 | 4 | 44 | Fallback comparator |
| `BILLBOARD_2D_ATLAS` | 3 | 3 | 5 | 2 | 3 | 3 | 3 | 4 | 3 | 5 | 3 | 2 | 39 | Deferred for next slot |

## Recommendation Logic

`HYBRID_3D_WORLD_BILLBOARD_UNITS` best balances modern terrain/architecture ambition with RTS-distance unit readability and manageable production scope. It fits the locked Salto environment references because the world can carry Barrosan material richness while the unit lane stays readable and cheaper to iterate.

`ORTHO_3D_MESH` remains the fallback comparator because it has the strongest material, lighting, and animation ceiling. Its risk is production burden: full 3D units, animation states, and unit silhouette polish can consume the next experiment before the team learns enough.

`BILLBOARD_2D_ATLAS` is deferred for the next single slot. It has clear performance and distance-readability strengths, but a pure atlas posture is less convincing for Salto terrain richness, architecture identity, and directional combat readability once production art begins.

This scorecard is not a final engine selection and is not runtime-art integration approval.
