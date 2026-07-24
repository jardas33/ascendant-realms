# v0.377 Visual Acceptance Checklist

This checklist is for human and Codex review.

## Stage 1 — Terrain, road, river and bridge

A Stage-1 candidate passes only when all statements are true:

- [ ] The land has visible height variation and does not read as one plane.
- [ ] The gameplay-camera render hides all outer terrain boundaries.
- [ ] The road is embedded into the ground, width-varied and irregular.
- [ ] Road edges show stones, grass encroachment or worn transitions.
- [ ] The river is visibly recessed below surrounding land.
- [ ] Riverbanks have depth, wet-dark contact and irregular silhouettes.
- [ ] The river is not bounded by two continuous parallel colored lines.
- [ ] Water endpoints are outside the gameplay frame.
- [ ] The bridge has authored stone abutments or supports.
- [ ] The bridge deck connects naturally to both roads.
- [ ] Railings are consistent and do not float or duplicate.
- [ ] Rocks and reeds support bank composition rather than forming an even row.
- [ ] The result remains readable in grayscale.
- [ ] The clean render is visibly closer to reference 03 than v0.376.

## Automatic rejection

Reject the candidate when any statement is true:

- [ ] The scene still resembles a pale board.
- [ ] The road is a ribbon mesh placed above grass.
- [ ] The water is a flat cyan strip.
- [ ] Bank meshes form graphic outlines around the water.
- [ ] The bridge is a simple plank slab without integrated landings.
- [ ] More than 25% of the primary frame is low-information empty terrain.
- [ ] A validator passes but the render remains visibly artificial.
