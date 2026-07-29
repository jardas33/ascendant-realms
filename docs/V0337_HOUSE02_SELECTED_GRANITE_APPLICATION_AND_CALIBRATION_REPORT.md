# v0.337 House 02 Selected Granite Application and Barrosan Material Calibration

## Scope and human decision

v0.337 is an isolated, opt-in material-application study for the frozen Barrosan House 02 asset. It applies the selected human decision from v0.336: **Material 3 / candidate_a**, the photo-scanned Poly Haven `stone_wall` rubble source, as a calibrated derivative on the existing House 02 wall and foundation material slots.

The outcome is intentionally not an automatic art approval:

> READY FOR HUMAN HOUSE 02 SELECTED-GRANITE APPLICATION REVIEW

The first v0.337 visual pass was rejected internally because warm lighting and a pale calibration pushed the wall toward cream/yellow. The pass was corrected with a cooler, lower-exposure neutral calibration and a neutral primary review key. The current images are the corrected evidence; the warm view remains a separate diagnostic only.

## Base and preservation boundary

- Base HEAD: `0e5c998b7f3c0a709ade35159422923bcb2eecfe`
- Branch: `codex/v0215-v0226-recovery`
- Frozen source Blend: `art-source/blender/v0334/barrosan_house_gold_02.blend`
- Frozen source GLB SHA-256: `f85cf2e7a448015638455f5de5cd49c18b085cbb1103a1fd5dfa8f7706d24be5`
- Frozen imported resource SHA-256: `b3be51e7d6e52fdfb829400afafbf26e9e0f9983b902b8ccba83f38306bba531`
- Derived Blend: `art-source/blender/v0337/barrosan_house_02_selected_granite.blend`
- Derived GLB: `desktop-spikes/godot-salto/assets/v0337/barrosan_house_02_selected_granite.glb`
- Derived Blend SHA-256: `517a9aaa6d9debe2bcf8047de774bdfa252e0376709b2ddafa0c7f9cc72bfe79`
- Derived GLB SHA-256: `ad700395cf0fbc7e396d0f1ef7babff3710f01ce268b34c9720e2d70b24c5dbb`

The v0.334 source Blend, GLB, import record, and imported-resource evidence remain unchanged from the base. House 02 geometry, roof, chimney, stairs, landing, doors, windows, openings, foundations, LODs, collision, default runtime, gameplay, saves, stable IDs, and state semantics remain frozen.

## Selected source and provenance

The selected source is `art-source/materials/v0335/candidates/candidate_a`, derived from the vendored CC0 Poly Haven `stone_wall` source. The source page and license are recorded in `art-source/materials/v0335/v0335-source-provenance.json`. Candidate B remains rejected; candidate C is not selected; no Material 1 relief geometry is used.

Source map hashes are recorded in `art-source/materials/v0337/selected_granite/v0337-selected-granite-lineage.json` and are checked against candidate_a. The calibrated map set is copied byte-for-byte into the Godot project asset directory.

Visible source-scale metrics retained from v0.335 are 118 visible stones, 0.27 m median stone height, and 0.52 m P90 stone height. These are authenticity aids, not an automated winner decision.

## Calibration and material application

The v0.337 calibration is deterministic and derivative-only:

- wall albedo: saturation 0.18, contrast 0.94, cool neutral tint `(0.84, 0.91, 1.02)`, exposure 0.78
- dressed wall albedo: saturation 0.16, restrained cool tint, exposure 0.84
- foundation albedo: saturation 0.14, darker cool contact variant, exposure 0.68
- normal: source OpenGL normal preserved; Blender/Godot strength 0.42
- roughness: bounded to 8-bit 185..246, approximately 0.73..0.965
- height: retained and bounded to 28..228 for evidence/future use; parallax disabled
- AO: retained as a calibrated evidence input; not baked into albedo

Four deterministic wall-specific UV mapping variants are used for front, rear, left, and right wall faces. The v0.334 UV layout is preserved; target texel density remains approximately 220..240 px/m. No geometry, openings, roof, stairs, or footprint is changed. Slate remains the frozen `V0334_Weathered_Slate` material.

## Architecture and derived lineage

`art-source/blender/v0337/v0337-architecture-fingerprint-comparison.json` records `architectureEqualBeforeExport: true` and `materialSlotChangesOnly: true`. It compares mesh object names, counts, transforms, bounds, openings, and roof-plane equations before export. Preservation flags cover architecture, roof, chimney, stair/landing, and openings.

The derived opt-in review scene is:

`desktop-spikes/godot-salto/scenes/review/V0337BarrosanHouse02SelectedGraniteReview.tscn`

The capture command is:

`npm run godot:capture:salto-v0337-house-02-selected-granite`

The pack-only command is:

`npm run godot:pack:salto-v0337-house-02-selected-granite`

## View and evidence result

The corrected neutral primary views read as cool gray-blue irregular rubble with visible value variation, distinct dark slate, separate timber doors/windows, readable foundation, and preserved stairs/landing. The near views show actual stone scale and normal response without the first-pass cream cast. The direct top-down and orthographic views are retained as architecture diagnostics, not as intended player presentation.

Normal-only evidence is measured on the wall region `[120, 50, 1160, 700]`:

- mean absolute difference from the normal-disabled control: `2.5787`
- SSIM-style similarity: `0.994248`
- luminance standard deviation: `53.779`
- clipped white: `0.0%`
- clipped black: `0.0004%`

This passes the evidence threshold while keeping the material legible rather than crushed. UV checker views show the wall-specific mapping across front/rear and gables. Closeups show foundation contact, front wall, corner seam, lintel/sill/jamb, and stair landing.

## Continuous video and performance

The continuous file is `08_CONTINUOUS_V0337_HOUSE02_SELECTED_GRANITE.mp4`:

- H.264, 1280x720
- 24/1 fps
- 15.0 seconds
- 360 frames
- sampled black-frame rejection at frames 0, 90, 180, 270, and 359: all non-blank

The latest benchmark records approximately 74.98 average FPS, with debug overlays disabled. Visible triangle/render-object/material counts and frame-time traces remain in `artifacts/runtime/v0337/v0337-performance.json`. The v0.334 LOD triangle counts remain the source reference: LOD0 14,944, LOD1 6,570, LOD2 1,638; collision 36 triangles.

## Runtime and gameplay preservation

The runtime manifest records `prototypeOptIn: true`, `defaultRuntimeIntegrated: false`, `noGameplay`, `noMovement`, `noPathfinding`, `noCombat`, `noEconomy`, and `noResources`. The scene loads only the derived GLB for evidence. It does not instantiate the accepted settlement/runtime fixture and does not modify state, resources, pressure, stable IDs, saves, movement, pathfinding, combat, AI, or economy.

The existing v0.303 fallback/debug presentation and accepted v0.287-v0.336 lineage remain intact. No true-default runtime path is changed.

## Review pack

The exact canonical upload directory is:

`artifacts/manual-review/v0337-house02-selected-granite-application/UPLOAD_TO_CHAT/`

It contains exactly ten files: one README, seven actual-render evidence boards, one continuous MP4, and `compact-evidence-summary.json`. The compact summary is 5,915 bytes and includes byte/hash records for the nine upload payload files.

## Dedicated validator and retained validation

Dedicated validator:

`tools/godot/saltoV0337House02SelectedGraniteTool.mjs`

Command:

`npm run godot:validate:salto-v0337-house-02-selected-granite`

The dedicated validator covers the frozen source boundary, selected candidate and map hashes, derived architecture fingerprint, opt-in/default-runtime separation, Godot captures, PBR/normal evidence, video integrity, exact ten-file pack, and manifest hashes. It reports 57 checks and leaves visual approval to human review.

Retained validation was kept scope-locked. The current checkout passes the directly relevant v0.334, v0.335, and v0.336 validators, plus the v0.337 validator; the current v0.303 validator also passes. Exact historical v0.304-v0.306 validators pass at their own final checkpoint commits in clean temporary worktrees. Older retained validators remain unchanged and their accepted reports/ledgers are preserved; they are not rerun against this later material-only checkpoint because their historical scope guards reject later accepted files and their ignored historical capture roots are not part of a clean checkout. No retained validator was weakened.

The local closeout gates passed before commit: `npm test` (122 files, 887 tests), `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run validate:runtime-art-slots`, `npm run godot:validate:salto-experimental-artifact-retention`, `npm run godot:all`, the Godot v0.337 script parse check, and `git diff --check`. The dedicated v0.337 validator passed 57 checks; v0.336 passed 62, v0.335 passed 50, and v0.334 passed 30.

## CI and final repo state

The feature commit `b50768a3f94cd8050f4c9c4923163beaddd50ccc` was pushed and verified by GitHub Actions run `29655197631` (run number 493, `CI Release Matrix Dry Run`), which completed with `success` for that exact SHA. The documentation closeout commit `e746fad6cd1b81ceb16b24110b6b394f817364ea` was then pushed and verified by exact-SHA run `29655581700` (run number 494), also `success`. The final closeout must confirm the final documentation-evidence commit, its exact-SHA run, a clean working tree, and `0 ahead / 0 behind` on `codex/v0215-v0226-recovery`.

## Outcome

v0.337 is a derived selected-granite application asset ready for human House 02 review. It is not integrated into the true default runtime and does not claim automatic visual approval. The next human decision is whether the corrected candidate_a material is acceptable for a future full-house application; no full-house application is included in v0.337.
