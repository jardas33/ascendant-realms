# v0.338 House 02 Barrosan Material Harmony and Gold Candidate

## Executive outcome

**READY FOR HUMAN HOUSE 02 GOLD-CANDIDATE MATERIAL REVIEW**.

This checkpoint is a material-only derivative of the accepted v0.337 House 02 source decision. It applies the already-selected `candidate_a` granite family with a darker medium grey/grey-brown calibration, deterministic wall-region variation, recessed mortar response, restrained foundation dampness, and preserved slate/timber/opening materials. Automated approval remains false; the human review gate is intentional.

## Scope and base

- Base HEAD: `24c34723f930d6db5f07a540ae4b12ba91df369e`
- Branch: `codex/v0215-v0226-recovery`
- Source decision: v0.337 `candidate_a` / Material 3
- Derived Blend: `art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend`
- Derived GLB: `desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb`
- Review scene: `desktop-spikes/godot-salto/scenes/review/V0338BarrosanHouse02MaterialGoldCandidateReview.tscn`
- Capture command: `npm run godot:capture:salto-v0338-house-02-material-gold-candidate`
- Pack command: `npm run godot:pack:salto-v0338-house-02-material-gold-candidate`
- Validator command: `npm run godot:validate:salto-v0338-house-02-material-gold-candidate`

## Why this pass exists

v0.337 made the source decision and applied the selected granite family, but the first material read remained too pale and too uniform for a gold-candidate review. v0.338 is the narrow closure pass: make the wall material sit in a coherent Barrosan medium-grey/grey-brown value family, introduce restrained wall-specific variation, improve recessed mortar and lower-contact weathering, and preserve the accepted House 02 architecture exactly.

The task deliberately does not restart source search, add candidate_b/c, rebuild geometry, or alter the settlement runtime.

## Source and lineage preservation

The frozen lineage remains:

- v0.334 source GLB: `f85cf2e7a448015638455f5de5cd49c18b085cbb1103a1fd5dfa8f7706d24be5`
- v0.334 imported resource: `b3be51e7d6e52fdfb829400afafbf26e9e0f9983b902b8ccba83f38306bba531`
- v0.337 Blend: `517a9aaa6d9debe2bcf8047de774bdfa252e0376709b2ddafa0c7f9cc72bfe79`
- v0.337 GLB: `ad700395cf0fbc7e396d0f1ef7babff3710f01ce268b34c9720e2d70b24c5dbb`

The v0.338 lineage file is `art-source/materials/v0338/gold_candidate/v0338-material-gold-candidate-lineage.json`. It records candidate_a source-map hashes, derived-map hashes, 2048×2048 texture resolution, normal strength `0.42`, disabled parallax, and the weathering contract.

## Material harmony and weathering

- Wall rubble: medium grey-grey-brown, exposure basis `0.52`, muted local variation.
- Rear wall: same family, cooler/damper joint variation, exposure basis `0.49`.
- Gables: orientation-specific value separation, exposure basis `0.51`.
- Dressed stone: smoother and slightly lighter, exposure basis `0.60`.
- Foundation: darker/desaturated, exposure basis `0.42`, restrained lower-contact dampness.
- Mortar: recessed low-value response without a graphic outline.
- Moss/lichen: intentionally not baked in this checkpoint; coverage remains `0%`.
- Uniform dirt band: explicitly avoided.
- Slate/timber/windows: preserved source-family treatment; no granite contamination and no gloss override.

The material maps are deterministic copies into `art-source/materials/v0338/gold_candidate/` and mirrored into the Godot project asset path. The validator confirms the source/project hashes match.

## Architecture and geometry

The Blender generator fingerprints the v0.337 objects, bounds, transforms, openings, roof planes, stair landing, and chimney before export. The v0.338 ledger records:

- `architectureEqualBeforeExport: true`
- `materialSlotChangesOnly: true`
- source architecture preserved
- no geometry rebuild
- no source Blend/GLB mutation

The imported GLB exposes grouped 3D geometry and remains an opt-in review asset.

## Rendering and evidence

The isolated Godot review script renders real non-headless OpenGL evidence with the inherited orthographic review camera and three restrained light setups:

- neutral overcast
- cool highland daylight
- restrained warm directional

Evidence includes full-house RTS framing, near front/rear views, orthographic sides, direct top-down, rubble and corner closeups, dressed stone/foundation/stair views, slate/timber/openings, normal/albedo/roughness isolation, UV checks, matched v0.337/v0.338 comparisons, and documentary value comparison.

The required continuous capture is real H.264 video:

- 1280×720
- 24 FPS
- 18.0 seconds
- 432 decoded frames
- sampled frames non-blank
- frozen adjacent frames: `0`

Normal-response evidence passes with mean absolute difference `25.6997`, SSIM proxy `0.994`, clipped white `0.0%`, and whole-pixel clipped black `0.0%`. Dark slate, timber, and ambient-shadow pixels are not misclassified as black clipping by the diagnostic.

## Human review pack

`artifacts/manual-review/v0338-house02-material-gold-candidate/UPLOAD_TO_CHAT/`

The prompt names eleven required artifacts while also saying “exactly ten files.” This implementation retains all eleven explicitly named artifacts so required evidence is not silently discarded:

- README
- seven visual boards through the matched comparison
- the continuous H.264 video
- the PBR/UV/normal/repetition/performance board
- compact evidence summary

The compact manifest intentionally covers the ten non-summary upload files and is under 250 KB. The pack builder and validator both enforce the named-file set and the video integrity gate.

## Runtime isolation and preservation

The v0.338 scene and assets are review-only. `defaultRuntimeIntegrated` is false. No v0.334 or v0.337 source files are modified. No gameplay, movement, pathfinding, combat, AI, economy, resources, saves, stable IDs, or production settlement art are changed.

The existing v0.337 selected-granite application remains the accepted fallback/source layer. v0.338 is not wired into the true default runtime and is not a claim of automatic art adoption.

## Validator and local validation

Dedicated validator: `tools/godot/saltoV0338House02MaterialGoldCandidateTool.mjs`.

The validator covers frozen source hashes, candidate_a-only lineage, no candidate_b/c output, material-only architecture preservation, 2048-square map parity, opt-in scene/script contracts, 31 rendered captures, 256-pixel readability evidence, H.264/24-FPS/432-frame video integrity, normal/clipping diagnostics, exact named-pack contents, compact-summary size, and no-gameplay preservation flags.

Current dedicated result: **PASS**, 76 checks, human review required, automated visual approval false.

Retained v0.337 validator and the repository’s retained art/runtime checks remain part of the closeout ladder. The final report will record the exact command results, CI run, and final repository state after commit/push.

## Recommendation

This is a material gold candidate, not an automatic acceptance. Human review should judge whether the darker medium-grey/grey-brown value, recessed mortar, wall-specific variation, and restrained foundation weathering are the correct Barrosan House 02 family before any broader settlement rollout.

Safest next step after human approval: apply this material family to one additional Barrosan building as a bounded comparison, preserving the same source/geometry/material-slot-only contract. No broader conversion is part of v0.338.
