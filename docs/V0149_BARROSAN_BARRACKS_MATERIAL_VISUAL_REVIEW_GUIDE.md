# v0.149 Barracks Material Visual Review Guide

Status: final private comparator screenshots are produced by `npm run godot:barracks-material:capture`.

One-click wrapper:

```text
GODOT_BARROSAN_BARRACKS_MATERIAL_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat
```

Capture command:

```text
npm run godot:barracks-material:capture
```

Expected review evidence:

```text
artifacts/desktop-spikes/godot-salto/v0149/evidence/visual-review-guide.md
artifacts/desktop-spikes/godot-salto/v0149/evidence/barracks-material-screenshot-manifest.json
artifacts/desktop-spikes/godot-salto/v0149/evidence/contact-sheet.svg
artifacts/desktop-spikes/godot-salto/v0149/evidence/screenshots/
```

## Current Review Posture

- Selected derivative: `HYBRID_BARRACKS_LOCAL_768`.
- Selected hash: `2731c342024271b2babaac8681d33f060df83e30c47ce56722f9595cd8004ce3`.
- Gate result: `PASS_V0149_BARRACKS_MATERIAL_ORIGINAL_GATE`.
- The material reads as practical wet timber, stone, and dark metal on the simple procedural Barracks shell at normal RTS distance.
- The Worker context billboard coexists with the textured shell and remains readable in the private comparator captures.
- The 1024 source-diagnostic captures remain useful for close material and seam review, but the final performance recommendation is the 768 derivative. The source has visible panelized divisions; the `S_uv_tiling_seam_diagnostic` capture should be reviewed for repeat and seam risk before any future production discussion.
- This is a human review stop, not production approval.

Key captures:

```text
artifacts/desktop-spikes/godot-salto/v0149/evidence/screenshots/014_hybrid_barracks_local_768_l_paired_benchmark.png
artifacts/desktop-spikes/godot-salto/v0149/evidence/screenshots/020_hybrid_barracks_local_768_s_derivative_768_comparison.png
artifacts/desktop-spikes/godot-salto/v0149/evidence/screenshots/028_hybrid_barracks_local_768_m_wet_overcast_lighting_posture.png
artifacts/desktop-spikes/godot-salto/v0149/evidence/screenshots/030_hybrid_barracks_local_1024_s_uv_tiling_seam_diagnostic.png
artifacts/desktop-spikes/godot-salto/v0149/evidence/contact-sheet.svg
```

## Human Review Checks

- Does the material read as practical Barrosan foothold construction?
- Does it improve the simple 3D Barracks shell at gameplay distance?
- Which derivative is recommended and why?
- Are seams, stretching, shimmer, or visual mud visible?
- Is the lighting response convincing enough for the next hybrid step?
- Does the Worker billboard coexist well with the textured 3D shell?
- Did the selected derivative pass the original Tier L gate?
- Should the next milestone test Aster static billboard, a second structure/material slot, one bounded repair, or pause for a broader pipeline decision?

## Non-Approval Boundary

- Private comparator only.
- Not production approval.
- Not player-facing Salto integration.
- Not final Barracks architecture approval.
- Not final material-pack approval.
- Not final Godot selection.
- No v0.150 work.
