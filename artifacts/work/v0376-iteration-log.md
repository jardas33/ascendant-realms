# v0.376 Original Barrosan Art-Quality Pass — Iteration Log

Base: `5bd7d0de17fc3ba9b87c37f78b22a7281085343c`
Branch: `codex/v0215-v0226-recovery`
Prototype: `desktop-spikes/godot-salto/scenes/v0376_original_barrosan_art_quality_pass.tscn`

All four iterations below are real Godot captures at 1920x1080. Every frame was opened and inspected before the next iteration. The first pre-import capture was rejected and is not counted as visual evidence.

| Iteration | Focus | Evidence | Largest defects after inspection |
| --- | --- | --- | --- |
| 01 | Connected terrain, wider irregular landform, wet bank strips, embedded roads, clustered vegetation, first v0.376 material pass | `artifacts/work/v0376-iteration-01/` | Terrain still pale and planar; map edge visible; building roles still close; mine/camp need stronger functional identity |
| 02 | Building silhouette/material hierarchy: taller civic hall, entry porch/tower/bell frame, darker broad barracks, domestic side wing and military yard | `artifacts/work/v0376-iteration-02/` | Barracks separates better, but terrain transitions remain graphic patches; roads and banks still ribbon-like; secondary zones need authored storytelling |
| 03 | Gold extraction and hostile defense: granite mine face/portal/seams/hoist/cart/tool crate; pitched command canopy, watch posts, weapon rack, storage, fire, dead timber | `artifacts/work/v0376-iteration-03/` | Resource and camp read functionally, but the prototype still looks like a low-poly test scene; vegetation and material depth remain thin |
| 04 | Final value/framing calibration: tighter overview, reduced transition-patch scale, warm key/cool fill balance, moss/bush clusters | `artifacts/work/v0376-iteration-04/` | Better composition and contrast, but visible terrain boundary, pale uniform land, ribbon roads/banks, and simple building family remain critical gate defects |

## Rejected capture

The first capture attempt produced four uniform background frames because Godot had not imported the new GLB. These files are intentionally not treated as evidence. The import handshake was repaired by running the Godot editor import pass, then iteration 01 was captured again and inspected as real geometry.

Rejected first attempt: `artifacts/work/v0376-iteration-01/` was overwritten by the valid rerender; the failure is recorded in `artifacts/work/v0376-black-frame-rejection.md`.

## Final candidate

Best retained rejected evidence: `artifacts/work/v0376-iteration-04/`.

The prototype proves the isolated Blender-to-GLB-to-Godot route and improves the v0.375 baseline. It does not meet the requested production-art gate. No success review pack was created.
