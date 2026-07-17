# v0.329 Barrosan House Visual Authenticity, Domestic Readability and Material Refinement

## Outcome

**READY FOR HUMAN BARROSAN HOUSE VISUAL-AUTHENTICITY REVIEW**.

The rendered result is materially improved over v0.328: the white inspection slab and repeated perimeter quoins are removed, the lower floor reads as agricultural/work space, the upper course is warm plaster, domestic openings have depth and non-black timber interiors, and the dominant roof/chimney/stair structure is retained.

## Scope and base

- Base HEAD: `211ba81024b55255df0ba9ac25aeebe315209a88` (accepted v0.328).
- Branch: `codex/v0215-v0226-recovery`.
- Source: `art-source/blender/v0327/barrosan_house_gold_01.blend`.
- Export: `desktop-spikes/godot-salto/assets/v0327/barrosan_house_gold_01.glb`.
- Review scene: `desktop-spikes/godot-salto/scenes/review/V0329BarrosanHouseReview.tscn`.
- Launch/capture: `npm run godot:capture:salto-v0329-barrosan-house-visual-authenticity`.

This is the same authored house continued in place. It is not settlement integration, a full asset replacement, or a runtime/gameplay change.

## Visual-authenticity pass

The agricultural lower floor has one principal heavy double-leaf door and one side work door, with lintels, thresholds, timber and iron details. The domestic upper floor has three framed openings with sills, lintels, shutters and timber interior proxies; no pure-black opening is used. The upper entrance remains connected to the authored stair and landing.

The four repeated quoin runs were replaced with low damp foundation courses. The lower wall remains granite-dominant and work-oriented; the upper masonry course uses one muted warm-plaster material slot so the house no longer reads as a single defensive stone block. Granite is macro/coarse with fewer bright repeated rectangles. The former bright white review ground is now a muted earth/grass surface.

## Roof and architectural identity

The simple dominant roof remains two continuous closed principal slate planes with continuous ridge and eaves, restrained overlap-course lips, closed gables, and a grounded chimney with slate flashing. No parapet, arrow-slit treatment, black strip, or fortress crown was added. The stair, landing and upper entry remain grounded and readable in the review views.

## Materials, openings and UV

The export uses seven locally authored deterministic material slots, within the hard eight-material budget: granite, foundation, slate, timber, iron, muted earth review ground, and warm plaster. Textures are repository-generated; no protected third-party game asset was imported.

The exported UVMap reports 261 consolidated islands, zero overlap, zero out-of-bounds coordinates, 8% maximum density deviation, one UV channel, complete exported UV evidence, and checker views for the full asset and roof/wall close-up. The SVG is `artifacts/runtime/v0329/barrosan-house-gold-01-uv-layout.svg`.

## Technical budgets

- LOD0: 6,068 vertices / 11,092 triangles / 7 render objects / 7 estimated draw calls.
- LOD1: 2,736 vertices / 4,412 triangles.
- LOD2: 1,227 vertices / 1,063 triangles.
- Collision: 24 vertices / 36 triangles.
- Invalid normals: 0; non-manifold edges: 0; unapplied transforms: 0; hidden duplicate geometry: 0.
- Godot import succeeded; LOD switching and collision visibility checks passed.

## RTS readability and evidence

The HUD-free review scene uses a controlled orthographic RTS camera and a neutral muted-highland environment. Real non-headless OpenGL captures cover ordinary RTS, near/normal/far scale, all elevations, roof identity, materials/openings, LODs, collision, wireframe and a 288-frame H.264 turntable. The direct visual inspection rejected blank/title-card-only evidence; the wide `ordinary_rts.png` is a real rendered house view.

The exact upload pack is `artifacts/manual-review/v0329-barrosan-house-visual-authenticity/UPLOAD_TO_CHAT/` and contains ten files. Full evidence is in `full-evidence/`, including visual-quality and technical-isolation contact sheets plus `43_black-frame-rejection-report.md`.

## Preservation

This checkpoint is opt-in and standalone. The accepted v0.328/v0.327 lineage, true default runtime, gameplay/state chain, movement, pathfinding, combat, AI, economy, resources, saves, stable IDs, and production integration remain unchanged. The v0.303 fallback/debug layer remains intact. No protected game assets were imported and no large unapproved asset dump was added.

## Validator and local evidence

Dedicated validator: `npm run godot:validate:salto-v0329-barrosan-house-visual-authenticity` (`tools/godot/saltoV0329BarrosanHouseTool.mjs`). Focused aliases cover reference board, fortress-cue audit, agricultural/domestic identity, stair/upper-door connectivity, opening depth, black-opening regression, roof regression, granite repetition, RTS/near-normal-far/grayscale evidence, UV islands/completeness/checker/overlap/bounds/density, object/draw-call/LOD budgets, benchmark, continuous media, exact file count, manifest consistency and preservation.

The dedicated v0.329 gate passes with the measured metrics above. Retained v0.328 through v0.303 validators and v0.259 UI-invariant validation, npm test/build, content/art/runtime checks, artifact retention, `npm run godot:all`, and `git diff --check` are part of final closeout evidence.

## CI and final state

Exact commit, GitHub Actions run, and final clean/synced repository state are appended after commit/push and exact-SHA CI completion. No v0.330 work is included.
