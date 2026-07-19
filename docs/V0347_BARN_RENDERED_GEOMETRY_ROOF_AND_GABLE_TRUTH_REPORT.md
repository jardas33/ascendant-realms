# v0.347 Barn Rendered Geometry, Roof, and Gable Truth Repair

Outcome: **READY FOR HUMAN V0347 BARN RENDERED-GEOMETRY REVIEW**

Automated visual approval remains false and human review remains required. v0.346 remains rejected by human review and is not marked gold, accepted, or production-ready.

## Scope

v0.347 is an isolated visual derivative of the frozen v0.346 barn source. It repairs the rendered geometry that metadata alone failed to describe: roof dominance, measured pitch, world-space transforms, end-gable visibility, and House02 slate material display. It does not modify the accepted runtime, gameplay, state chain, saves, stable IDs, or default presentation.

## Base and rejection carried forward

- Branch: `codex/v0215-v0226-recovery`
- Base HEAD: `185f1536246b2705425c70adb5e2a5eaa454d9c6`
- v0.346 source: `art-source/blender/v0346/barn_house02_silhouette_roof_pitch.blend`
- v0.346 remains the rejected human-review candidate.
- Exact rejection carried forward: `REJECTED BY HUMAN REVIEW — V0.346 PASSES PACKAGING AND DECLARED ROOF METRICS, BUT THE RENDERED BARN STILL HAS AN OVERSIZED ROOF, TOWER-LIKE MASS, NON-GRANITE-READING GABLES AND A SMOOTH GENERIC ROOF MATERIAL THAT DOES NOT MATCH HOUSE02`

## Root cause and geometry method

The v0.346 visual mesh was inspected before removal. Its object scale was `1,1,1`, but its parent/world translation and final rendered bounds were not sufficient evidence of a correct roof silhouette. The v0.347 generator records that matrix and bounds, measures the v0.346 roof faces in world space, then removes the old roof/gable faces and bakes the retained wall mesh into world coordinates before rebuilding the roof.

The v0.346 actual source pitch is recorded in `art-source/blender/v0347/v0347-barn-rendered-geometry-metrics.json`; no declared metadata is trusted. The final v0.347 world-space result has two principal slopes, one straight ridge, a measured 20 degree pitch on both slopes, eave world Z `3.94`, ridge world Z `5.88542`, and final roof rise approximately 34 percent of total building height. Final bounds are recorded for Blender and Godot.

## What changed

- Added `art-source/blender/v0347/barn_rendered_geometry_truth.blend` as a new derivative only.
- Added `desktop-spikes/godot-salto/assets/v0347/barn_rendered_geometry_truth.glb` as the isolated exported candidate.
- Baked the retained wall mesh to world-space vertices and applied unit scale.
- Rebuilt exactly two roof slopes and one straight ridge at 20 degrees.
- Reduced verge/eave overhang and exposed both end-gable solids at the rendered boundary so the side view verifies the gable geometry.
- Kept both gables as solid granite geometry derived from the accepted granite material lineage.
- Reused frozen House02 `V0334_Weathered_Slate` directly, with an explicit active UV contract applied after mesh joining so the Godot render shows the slate tile pattern rather than a smooth generic sheet.
- Preserved the lower agricultural double door, subordinate upper loading opening, rear service opening, wall material, and worker scale.
- Added exact-five source capture tooling, an exact-six-file upload pack, a dedicated validator, and the v0.347 report.

## What did not change

- No runtime scene, gameplay, accepted state chain, save path, stable ID, movement, pathfinding, route following, combat, damage, HP, projectile, death, AI, wave, economy, resource, or pressure behavior.
- No modification to frozen House02, v0.343, v0.344, v0.345, or v0.346 source files.
- No default runtime integration.
- No video, title-card-only evidence, embedded reference image, or copied third-party asset.

## Rendered visual gate

The five actual Godot source renders were inspected before technical packaging:

1. `01_front_three_quarter.png` shows a broad horizontal agricultural mass, lower entrance, upper opening, granite walls, textured slate roof, and natural ground contact.
2. `02_direct_front_orthographic.png` verifies the compact front/eave proportion and intact openings.
3. `03_direct_side_gable.png` verifies the solid granite end gable, two roof planes, straight ridge, and restrained pitch.
4. `04_roof_close_up.png` verifies the actual House02 slate tile pattern and roof-edge treatment.
5. `05_true_matched_front_512x256.png` is a true direct render comparison with frozen House02 on the left and v0.347 on the right, each panel 256x256.

The pass is based on rendered geometry and material evidence, not generator metadata. The earlier v0.346 failure mode—oversized/tower-like rendered mass, non-granite gable reading, and smooth generic roof—is not carried forward in the v0.347 source set.

## Source, scene, and commands

- Blender generator: `tools/blender/generateV0347BarnRenderedGeometryTruth.py`
- Blender command: `npm run blender:generate:salto-v0347-barn-rendered-geometry-truth`
- Isolated Godot scene: `desktop-spikes/godot-salto/scenes/review/V0347BarnRenderedGeometryTruth.tscn`
- Godot fixture: `desktop-spikes/godot-salto/scripts/v0347_barn_rendered_geometry_truth.gd`
- Capture command: `npm run godot:capture:salto-v0347-barn-rendered-geometry-truth`
- Pack command: `npm run godot:pack:salto-v0347-barn-rendered-geometry-truth`
- Dedicated validator: `tools/godot/saltoV0347BarnRenderedGeometryTruthTool.mjs`
- Validator command: `npm run godot:validate:salto-v0347-barn-rendered-geometry-truth`
- Review pack: `artifacts/manual-review/v0347-barn-rendered-geometry-truth/UPLOAD_TO_CHAT/`

## Evidence contract

The pack contains exactly six files: four rendered PNG boards, `00_READ_ME_FIRST.md`, and `compact-evidence-summary.json`. It contains exactly four PNG files and no video. The five raw source renders remain under `artifacts/runtime/v0347/screenshots/` for provenance and validator inspection.

The summary records final world-space slopes, v0.346 actual source geometry, final bounds, final hashes, opening roles, frozen source hashes, exact file counts, true comparison dimensions, and default-runtime isolation.

## Preservation and validation

The dedicated validator checks frozen v0.346 and House02 hashes, v0.347 lineage, measured source and final geometry, two-slope/one-ridge truth, pitch and roof-height limits, complete granite gables, House02 slate lineage and active UV contract, opening roles, isolated scene/tooling, five real source captures, true 512x256 comparison, exact six-file pack, no video, no gold/approval claim, no third-party provenance, no gameplay coupling, and no default-runtime integration.

The retained v0.346 validator remains available and frozen sources remain hash-identical. Full local validation for closeout is recorded after the commit in the final CI evidence section.

## Human review status

This is a human-review candidate only. The outcome appears once at the top of this report; it is not an automated approval, and no gold status is asserted for v0.347.
