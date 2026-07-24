# v0.378 supplied infrastructure visual iteration log

Base: `9d9ef05a72068565683ac35296226a416a524904`
Original supplied GLB: `557653dbda28a350046ef9ac08ec41d0a5b1eaf496238fde3c2a5784a321b078`
Repaired evaluated GLB: `a6b73bc6252b4d6cfa19cdd4c08d40468e6f1ab1ff723d5d2405ec5b2f5f6418`

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
