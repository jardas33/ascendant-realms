# v0.375 Original Barrosan Visual Iteration Log

The six iterations below are real Godot renders from the isolated world-only v0.375 scene. Each iteration produced four 1920x1080 PNGs and was inspected with the image viewer before the next decision.

| Iteration | Change under test | Evidence | Result |
| --- | --- | --- | --- |
| 01 | First original Blender-authored kit: terrain, recessed stream, bridge, roads, settlement, resource yard, camp, nature, temporary scale units | `artifacts/work/v0375-iteration-1/` | Coherent low-poly sector; too pale, too wide, and units too small |
| 02 | Stronger earth/slate/water values, tighter gameplay framing, larger scale units | `artifacts/work/v0375-iteration-2/` | River/bridge and unit scale improved; open terrain still uniform |
| 03 | Restrained directional-light calibration and meadow tuft dressing | `artifacts/work/v0375-iteration-3/` | Shadows remained readable; material hierarchy still below production bar |
| 04 | Main Hall civic detail, Barracks chimney, granite courses, landmark refinement | `artifacts/work/v0375-iteration-4/` | Best balanced wide view; buildings remain intentionally simple |
| 05 | Closer 2.5D framing test | `artifacts/work/v0375-iteration-5/` | Strong tactical crop, but edge dressing and building identity still limited |
| 06 | Final framing compromise and gate review | `artifacts/work/v0375-iteration-6/` | Best final candidate; gate remains failed on attractiveness, terrain, and Barrosan identity |

## Final self-review scorecard

Scores are 0-10 and are evidence-based, not build-based.

| Category | Score |
| --- | ---: |
| Attractiveness | 6.5 |
| Closeness to strongest recovered historical target | 5.5 |
| Immediate RTS readability | 7.5 |
| Camera / framing | 8.0 |
| Terrain credibility | 6.2 |
| River / water readability | 8.0 |
| Bridge credibility | 8.0 |
| Building volume | 6.5 |
| Unit readability | 6.5 |
| Lighting / shadows | 7.0 |
| Barrosan identity | 6.5 |
| Technical feasibility | 8.5 |
| Maintainability | 8.0 |
| Performance risk | 8.0 |
| Asset burden | 8.0 |
| Animation burden | 9.0 |
| Suitability for full Salto conversion | 6.5 |

Gate result: **BLOCKED — V0375 ORIGINAL BARROSAN VISUAL QUALITY GATE NOT MET**

The prototype proves the technical route: original geometry exports, imports, renders, and frames cleanly in an isolated opt-in scene. It does not yet prove production-ready art direction. The largest remaining gap is authored visual richness and faction-specific identity, not scene wiring or gameplay integration.
