# v0.377 visual iteration log

Checkpoint: v0.377 reference-driven terrain, road, riverbank and bridge production proof
Base: `1a2f17c09d41f621631aeba0d82e0b10ce8f5104`
Scope: Stage 1 infrastructure only. No buildings, units, mine, camp, HUD, gameplay, or default-runtime mutation.

## Iteration 01 — rejected

- Mismatch: the terrain appeared as a regular checker/grid across the full land plane.
- Mismatch: road geometry read as pointed ribbon fragments instead of embedded worn surfaces.
- Mismatch: riverbank transitions were continuous graphic bands with too little contact dressing.
- Action: kept as rejected baseline evidence; no success claim.

## Iteration 02 — rejected

- Mismatch: additional bank rubble did not change the dominant checker/grid failure.
- Mismatch: bridge was readable, but the surrounding land still looked like a flat board.
- Mismatch: water and bank value separation was too bright and graphic compared with the reference.
- Action: added more bank contact dressing, but retained the failure for comparison.

## Iteration 03 — rejected

- Mismatch: bridge landing reeds and stones were present but could not overcome the material/grid failure.
- Mismatch: road bends still produced faceted pointed wedges.
- Mismatch: grayscale hierarchy was dominated by repeated terrain facets.
- Action: rejected; moved to structural mesh/material repair.

## Iteration 04 — rejected

- Mismatch: shelf outcrops improved local depth but not the repeated terrain pattern.
- Mismatch: the road/river relationship remained too diagrammatic.
- Mismatch: overall density and natural rock/reed contact remained below the reference gate.
- Action: rejected; no packaging as a pass.

## Iteration 05 — rejected and invalidated by stale import evidence

- Source correction: removed regular material alternation, muted the palette, smoothed land/water mesh shading, and replaced the three-vertex road ribbon topology with stable two-edge road quads.
- Capture result: the first capture still loaded the pre-correction Godot imported scene and reproduced the checker/grid.
- Action: rejected as stale-cache evidence; the capture tool was repaired to refresh the isolated Godot import before every v0.377 capture.

## Iteration 06 — final candidate, visual gate failed

- Improvement: refreshed Godot import produced a continuous, non-checker terrain plane with readable height and shadows.
- Improvement: river is visibly recessed, bank slopes are present, and bridge deck, rails, supports, and abutments read correctly.
- Improvement: road topology is now continuous through the crossing after a small terrain-following lift.
- Remaining mismatch: terrain is still too smooth and sparse versus the reference; road shoulders remain broad graphic surfaces; river/bridge contact lacks the dense irregular wet stones, reeds, and worn edge variation required for production acceptance.
- Decision: honest blocker. Route C remains technically feasible, but this Stage 1 candidate is not accepted as production-ready visual evidence.

## Black-frame and evidence rejection

- No black or blank frame was accepted.
- The first comparison-board format mismatch was repaired by converting both images to RGBA8 before blitting.
- Iterations 01–04 remain visibly rendered but rejected for the checker/grid defect.
- Iteration 05 remains visibly rendered but rejected because it used a stale Godot import cache.
- Iteration 06 is the best current rendered candidate and is the only candidate considered for the final visual decision.
