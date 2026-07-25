# v0.382 clustered highland dressing iteration log

All three entries below are backed by real 1920x1080 Godot renders under `desktop-spikes/godot-salto/artifacts/work/v0382-iteration-01/`, `...-02/`, and `...-03/`. The accepted v0.380 GLB was loaded unchanged in every iteration.

## Iteration 1 — distribution cleanup

Render: `v0382-iteration-01/01_PRIMARY_RTS_VIEW.png`

Change: removed the v0.381 sparse/even distribution by starting a new isolated scene with five named geological groups and two asymmetrical highland masses. No riverbank props or approach props were added yet.

Three largest defects observed:

1. The river corridor still read too empty beside the bridge.
2. The bank had no readable moisture vegetation at gameplay distance.
3. The crossing was framed well but needed more purposeful context on both banks.

Correction carried into iteration 2: six bank clusters, each with tall grass, low grass, shrub, and two rock forms.

## Iteration 2 — vegetation masses and riverbanks

Render: `v0382-iteration-02/01_PRIMARY_RTS_VIEW.png`

Change: added three asymmetrical clusters to each bank and enlarged the grass/shrub scale to register against the bridge rail. Major masses remained visible and the bridge approach stayed open.

Three largest defects observed:

1. The primary camera left more negative space than necessary.
2. The bridge approaches lacked a small amount of human-use dressing.
3. The darker tree shadow on the lower-right mass needed a tighter final composition and neutralized fill.

Correction carried into iteration 3: tighter stable RTS framing, restrained approach fence/crate dressing, and final neutral-warm lighting balance.

## Iteration 3 — camera, scale, and polish

Render: `v0382-iteration-03/01_PRIMARY_RTS_VIEW.png`

Change: final primary uses an orthographic 22-unit oblique camera; bridge and river remain the focal corridor, both major masses and all six bank-cluster zones register, and approach dressing is limited to two fence fragments and one crate.

Final inspection result: bridge is unobscured enough to read as the focal crossing; river continuity is intact; clustered vegetation is visible at RTS scale; geological groups are grouped rather than evenly scattered; no map edge or translucent debug pad is present. The five required capture views and grayscale audit were inspected before packaging.

Gate result: `READY FOR HUMAN V0382 CLUSTERED HIGHLAND DRESSING REVIEW`.
