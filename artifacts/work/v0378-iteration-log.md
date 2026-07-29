# v0.378 supplied infrastructure visual iteration log

Base: `9d9ef05a72068565683ac35296226a416a524904`
Original supplied GLB: `557653dbda28a350046ef9ac08ec41d0a5b1eaf496238fde3c2a5784a321b078`
Repaired evaluated GLB: `91cf29f5a964cf6b43f67fd1f9ac98d3bd6d3ea27623bb313479d362deef7e88`
Earlier repaired GLB: `a6b73bc6252b4d6cfa19cdd4c08d40468e6f1ab1ff723d5d2405ec5b2f5f6418`

All four iterations rendered at 1920x1080 from the isolated opt-in scene and were inspected as real PNGs. No checkerboard or blank/black frame was accepted.

## Iteration 1

- Primary: `artifacts/work/v0378-iteration-01/01_PRIMARY_RTS_VIEW.png`
- Defects: flat value separation between continuous land, road, and water; road shoulders read as sharp triangular intrusions; bridge deck/abutments do not read as one continuous crossing.

## Iteration 2

- Primary: `artifacts/work/v0378-iteration-02/01_PRIMARY_RTS_VIEW.png`
- Defects: camera change improved the top-down read but did not remove the repeated torn road triangles; bridge remains dominated by a tall side face; terrain and bank treatment remain broad flat color fields.

## Iteration 3

- Primary: `artifacts/work/v0378-iteration-03/01_PRIMARY_RTS_VIEW.png`
- Defects: recessed water and bridge structure are visible, but the road still has repeated pointed fragments; bridge supports/abutments remain visually disconnected from the road and banks; sparse low-poly dressing and flat terrain prevent a production-quality material read.

## Iteration 4

- Primary: `artifacts/work/v0378-iteration-04/01_PRIMARY_RTS_VIEW.png`
- Defects: lower oblique framing exposes bridge rails and deck but retains the same road tears; bridge sidewalls and landing edges still read as hard intersecting slabs; no presentation-only camera or lighting adjustment resolves the underlying geometry/material failure.

## Decision

The supplied kit is technically imported, deterministic, and bounded, but it does not meet the strict visual gate. The best rejected evidence is retained in all four iteration folders. No source geometry regeneration was performed because the supplied GLB is the required primary artifact and a source repair would require a separately audited regenerated asset.

## Bounded source-repair rerun

The source-repair lane was then attempted once using the supplied generator. The repaired source raised/conformed the road surface, narrowed and smoothed shoulders, blended the road into the bridge ends, and shortened abutment slabs. It regenerated the evaluated GLB at SHA-256 `a6b73bc6252b4d6cfa19cdd4c08d40468e6f1ab1ff723d5d2405ec5b2f5f6418`. The original supplied GLB remains preserved at the hash above.

All five required frames were rendered and manually inspected for each repaired iteration. Each repaired iteration failed the same visual gate:

### Repaired iteration 1

- Primary: `artifacts/work/v0378-repaired-iteration-01/01_PRIMARY_RTS_VIEW.png`
- Defects: road becomes an over-wide wall-like band with dense vertical striping; bridge remains slab-dominant; road-to-bridge join is not a coherent travel surface.

### Repaired iteration 2

- Primary: `artifacts/work/v0378-repaired-iteration-02/01_PRIMARY_RTS_VIEW.png`
- Defects: same wall-like road band and repeated striping; bridge abutments still read as hard sidewalls; recessed river cannot compensate for the road/bridge failure.

### Repaired iteration 3

- Primary: `artifacts/work/v0378-repaired-iteration-03/01_PRIMARY_RTS_VIEW.png`
- Defects: road remains materially over-wide and visually noisy; deck and landings still intersect as separate slabs; bank dressing remains sparse and flat.

### Repaired iteration 4

- Primary: `artifacts/work/v0378-repaired-iteration-04/01_PRIMARY_RTS_VIEW.png`
- Defects: the same road striping is visible at the alternate framing; bridge sidewall remains dominant; grayscale confirms the crossing lacks a clean surface hierarchy.

The repaired rerun is therefore also rejected. No v0.378 success review pack was created.

## Bounded source-repair rerun 2

The second repair replaced the overlapping road strips with a four-row graded shoulder/core cross-section, lowered the bridge deck and rails, and shortened the abutments. The reproducibly regenerated evaluated GLB is SHA-256 `91cf29f5a964cf6b43f67fd1f9ac98d3bd6d3ea27623bb313479d362deef7e88`; the generator source is SHA-256 `45645bd357002946050bffa7efc5331be930bd3cd1e57286e50b33b8b96b1144`.

All five required frames were rendered and manually inspected for each second-repair iteration:

### Repaired-2 iteration 1

- Primary: `artifacts/work/v0378-repaired2-iteration-01/01_PRIMARY_RTS_VIEW.png`
- Defects: road continuity is restored with no tears or striping; bridge remains dark and sidewall-dominant; terrain and bank material remain sparse and flat.

### Repaired-2 iteration 2

- Primary: `artifacts/work/v0378-repaired2-iteration-02/01_PRIMARY_RTS_VIEW.png`
- Defects: continuous road and recessed river read clearly; bridge deck/rails still have weak value separation; the crossing lacks a convincing landing hierarchy.

### Repaired-2 iteration 3

- Primary: `artifacts/work/v0378-repaired2-iteration-03/01_PRIMARY_RTS_VIEW.png`
- Defects: alternate oblique view confirms the road repair; bridge near side still reads as a deep slab; sparse dressing does not establish a production riverbank read.

### Repaired-2 iteration 4

- Primary: `artifacts/work/v0378-repaired2-iteration-04/01_PRIMARY_RTS_VIEW.png`
- Defects: road remains a coherent worn surface; bridge structure is visible but the deck is still visually buried behind the near side/rails; grayscale confirms bridge/material hierarchy remains below the gate.

The second repair is retained as rejected historical evidence. It fixes the road failure but does not clear the bridge, riverbank, and overall score thresholds.

## Final bounded repair

- Evaluated GLB: `external-art-intake/original-barrosan/v0378-authored-infrastructure/exports/barrosan_infrastructure_v0378.glb`
- Evaluated GLB SHA-256: `5d27feaabd61f4ab05063b860d19405b45a9ef2219ee27ee256972275ade40e9`
- Generator source SHA-256: `28f5de34e24700f9bff58e18510d5ee87f47d41c9b9b0d5031e21e2d77a755a1`
- Primary evidence: `artifacts/work/v0378-final-iteration-01/` through `-04/`

The final bounded repair lightened and narrowed the bridge deck treatment, added a shallow continuous deck edge course, pulled rails inward, reduced rail mass, and kept the repaired continuous road/riverbank surfaces. All four iterations rendered as real 1920x1080 PNGs and were manually inspected.

### Final iteration 4 findings

- Road: continuous worn surface with graded shoulders; no checkerboard, tears, repeated striping, or floating strips.
- River and banks: continuous recessed water with shaped bank transition and restrained authored rocks/reeds; no parallel painted bank ribbons.
- Bridge: deck planks, edge course, rails, posts, abutments, and landings read as one crossing with no exposed boundary or black-frame failure.
- Grayscale: bridge, road, water, and land remain separable at a glance.

## Final decision

The final bounded repair clears the strict visual gate. Final scorecard: terrain 72, road 75, river/banks 70, bridge 72, overall 72. The result is intentionally a sparse stage-1 infrastructure kit with no buildings, units, gameplay, HUD, or production-runtime mutation. The original supplied GLB and all rejected iterations remain preserved for audit.
