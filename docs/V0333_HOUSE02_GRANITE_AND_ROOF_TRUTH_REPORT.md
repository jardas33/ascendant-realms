# v0.333 House 02 Granite and Roof Truth Report

## Outcome

**REJECTED INTERNALLY — HOUSE STILL DOES NOT READ AS GRANITE OR FALSE ROOF FORMS REMAIN**

This is an intentionally human-gated result. The v0.333 source, import, evidence, and validator close the technical checkpoint, but they do not claim automated visual approval. The current render now shows a real stone-block rhythm and the false long-façade cross-gables are removed; the human gate remains rejected because the normal/full-lighting material read is still too pale and regular to call authoritative granite without further art direction.

## Scope

v0.333 is limited to the opt-in House 02 visual-evidence path. It repairs the v0.332 material diagnosis, removes the rejected front/rear false cross-gable forms, refines slate and limited stone relief, and closes the documentary/UV/collision/dimension/benchmark evidence gaps. It does not integrate House 02 into the settlement or change gameplay.

Branch: `codex/v0215-v0226-recovery`
Base HEAD: `42b643f56b9fe94f7b82634ad841f6b59a93a70c`
Source generator: `tools/blender/generate_v0333_barrosan_house_02.py`
Godot review scene: `desktop-spikes/godot-salto/scenes/review/V0333BarrosanHouse02GraniteRoof.tscn`

## Human review of v0.332 and exact diagnosis

The unlabelled v0.332 diagnostics were captured with the same imported asset, camera, and lighting. The maps were authored and bound, but the wall still rendered as a broad flat panel. Inspection of the source and imported result identified the concrete cause: v0.332 joined box primitives and then ran Blender `bpy.ops.uv.smart_project`, creating many tiny per-face UV islands. Long wall faces therefore sampled nearly constant portions of the granite image. This was not treated as a generic contrast or normal-strength problem.

v0.333 applies coherent house-scale wall/side UV mapping after material merge, retains a single exported `UVMap`, and records the diagnosis in `artifacts/runtime/v0333/barrosan-house-02-blender-metrics.json` and `barrosan-house-02-material-record.json`. The UV raster fallback was also repaired so the pack contains visible authored UV lines when cairosvg is unavailable.

## Architecture and roof truth

- Front and rear long elevations remain continuous; the false front/rear cross-gables are not generated.
- Only the two short-end triangular gable walls remain.
- The principal roof is exactly two long slopes with one ridge, front/rear eaves, end verges, and one grounded chimney.
- Roof continuity anchors are recorded as `continuousRidge`, `continuousEaves`, `continuousVerges`, and `principalRoofSlopeCount: 2`.
- Front, rear, left, right, top, roof, and turntable captures are included in the runtime evidence.
- Slate is authored as smaller staggered courses with restrained variation and non-black values.

## Granite, timber, openings, stair, and foundation

The continuous base wall remains a bounded low-poly mesh. The repaired granite albedo uses smaller irregular stone cells, darker but thinner joints, subdued grey/cool/warm mineral variation, and restrained damp/lichen variation. Limited merged low-relief stones, corners, lintels, sills, threshold, and foundation pieces preserve a practical object/triangle budget. The render now visibly shows masonry rhythm at near and normal views and still reads as a stone house at thumbnail scale, but full-lighting value remains too pale/regular for a READY result.

Timber remains dark aged brown with directional authored texture; windows remain recessed with dark interiors and timber frames; the lower agricultural doors remain heavier and recessed; the upper door remains connected to the exterior stair and landing. The functional chain remains ground -> stair -> landing -> upper door.

## Documentary source and trace evidence

The source register remains `art-source/references/v0331/documentary/README.md`. The pack retains primary reference 30987, supplements 30985 and 30986, and the França10 supplement with explicit uncertainty/licence language. The generated trace/overlay is documentary vocabulary evidence, not a claim of exact reconstruction. The report and pack use the phrase **functional and proportional documentary interpretation**. No documentary pixels, mesh, or protected-game assets are copied into runtime.

## UV, import, dimensions, and performance evidence

The v0.333 source/export records one `UVMap`, 450 islands, zero overlap, and zero out-of-bounds coordinates. Meaningful density groups are recorded for front/rear/left/right walls, both roof slopes, timber, doors, windows, and stair/landing; the reported maximum density deviation is 11%.

Godot import records normal-map import as Non-Color with filtering and mipmaps enabled. The source GLB is currently `desktop-spikes/godot-salto/assets/v0333/barrosan_house_gold_02.glb`, SHA-256 `11ab9e82df092c5d15d0a508624508c425efd0323f7f8a7066cbe3d2b4403dab`.

Recorded dimensions are metres: overall width 9.96, depth 6.24, height 7.26, eave 4.52, ridge 6.20, chimney top 7.26, human figure 1.75, lower door 2.32, upper door 1.65, sill 3.14, stair rise 0.25, stair run 0.44, landing 2.00.

LOD0 is 14,944 triangles / 7 objects; LOD1 is 6,570 triangles; LOD2 is 1,638 triangles. Collision is isolated at 36 triangles / 3 objects. The runtime benchmark stores exactly 1,500 frame-time samples and a full graph rather than a single aggregate.

## Review pack and commands

The exact ten-file upload pack is:

`artifacts/manual-review/v0333-house02-granite-roof/UPLOAD_TO_CHAT/`

Full evidence, including visual and technical contact sheets and the black/frozen-frame report, is under:

`artifacts/manual-review/v0333-house02-granite-roof/full-evidence/`

Generate source:

`npm run blender:generate:salto-v0333-house-02-granite-roof`

Capture and build pack:

`npm run godot:capture:salto-v0333-house-02-granite-roof`

Dedicated validator:

`npm run godot:validate:salto-v0333-house-02-granite-roof`

The pack contains real imported Godot renders, diagnostics, front/rear/side/top proof, visible UV evidence, actual wireframe/collision/LOD evidence, a 12-second H.264 turntable, and contact sheets. The ten-file pack is not title-card-only. `humanReviewRequired` remains true and `automatedVisualApproval` remains false.

## Preservation

Preserved unchanged:

- accepted v0.332 runtime and all earlier accepted gameplay/state chains;
- true default runtime and gameplay semantics;
- House 01 isolation;
- no settlement integration;
- no movement, pathfinding, route following, combat, damage, HP, AI, waves, fog gameplay, economy, resources, stable-ID, or save changes;
- current GLB/benchmark consistency and bounded LOD/collision strategy.

## Validation and CI

Dedicated v0.333 validator: PASS, with human-review rejection intentionally retained. The retained v0.332 and v0.331 validators, project tests/build/content/art/runtime checks, artifact-retention validation, `npm run godot:all`, and `git diff --check` are run as part of the v0.333 closeout before commit. Exact commit and GitHub Actions evidence are recorded in the final closeout after push.

## Recommended next decision

Do not call this House 02 gold or production-ready. If the human reviewer rejects the pale/regular full-lighting read, the safest next slice is a narrow granite material/lighting revision only: preserve the current UV and roof topology repair, darken and mineralize the authored stone response, and re-run the same diagnostics. Do not start House 03 or settlement integration.
