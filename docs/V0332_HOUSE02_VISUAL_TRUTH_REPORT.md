# v0.332 House 02 Visual Truth, Granite/Slate Rebuild and Evidence Report

## Executive verdict

**REJECTED INTERNALLY — GRANITE, SLATE, ROOF OR EVIDENCE TRUTH GATE FAILED.**

The checkpoint is implemented as an opt-in, evidence-integrity pass, but the unlabelled near three-quarter Godot render still reads as a stylized low-poly house with broad pale/flat wall panels rather than unmistakable weathered granite. The slate map and two-slope roof read materially better, and the source/import/benchmark evidence is now tied to the current GLB. The asset is not being called gold, production-ready, art-locked, or final.

## Scope and baseline

- Base HEAD: `ad0c73559645ee0ac76e963426ce3a21272674c4` (`v0.331 complete House 02 documentary roof and material closure`)
- Branch: `codex/v0215-v0226-recovery`
- Prototype path: `desktop-spikes/godot-salto/scenes/review/V0332BarrosanHouse02VisualTruth.tscn`
- Capture command: `npm run godot:capture:salto-v0332-house-02-visual-truth`
- Validator command: `npm run godot:validate:salto-v0332-house-02-visual-truth`
- The true default runtime is not referenced or changed.

## Why this pass was required

v0.331 had a concrete evidence defect: its benchmark reported the previous 15,644-triangle value while the current authored GLB contained 14,704 LOD0 triangles. Its visual capture also failed the granite/slate truth bar. v0.332 therefore makes the current Blender export and current Godot import the source of truth for hashes, material bindings, UV imagery, collision/wireframe evidence, and performance evidence.

## Documentary architecture and alignment

The accepted documentary lineage is retained: Path A exterior-stair archetype, primary 30987, supplements 30985, 30986, and França10. The model remains an authored functional/proportional interpretation. The primary alignment board traces the real reference relationship against the current front/elevation and oblique captures; it is not claimed as an exact reconstruction.

## Architecture and roof truth

The House 02 source retains a rectangular inhabited mass, useful lower agricultural floor, domestic upper floor, agricultural opening, upper door, recessed windows, grounded stone stair, landing, two principal gable roof slopes, ridge, eaves, verge pairs, one chimney, and flashing. No secondary roof crown, eyebrow, floating rail, or named triangular roof ornament was added. The large pale gable readings remain a visual rejection risk because they do not yet communicate as convincing granite masonry at gameplay scale.

## Granite, slate, timber and opening materials

v0.332 authored new image-backed maps under `art-source/materials/v0332/`:

- granite albedo, roughness, and normal;
- slate albedo, roughness, and normal;
- timber albedo and roughness;
- a v0.332 numbered square checker.

The GLB contains the V0332 material slots and embedded image references. The material record stores Blender, GLB, Godot material names, map paths, resolutions, and SHA256 values. The imported render verifies that slate has a visible overlapping course rhythm and that recessed openings/timber are present. Granite image binding is technically present, but the wall result still averages toward broad flat panels in the unlabelled visual; that is why the visual truth gate is rejected rather than self-approved.

## UV and evidence integrity

The Blender output contains one UV channel, zero reported overlap, zero out-of-bounds coordinates, and an actual exported UV SVG plus rasterized UV PNG. The numbered checker captures are applied through the GLB UV channel, not a screen-space overlay. The current v0.332 record explicitly labels its calculation method and preserves the underlying UV segments outside the compact upload summary.

## Current asset and imported benchmark

- Current GLB SHA256: `2b49c03aef0d5c378503c362937c3f3b44241f395c505cd6cb69814b8cdf6575`
- LOD0: 7 objects, 14,704 triangles
- LOD1: 6,464 triangles
- LOD2: 1,612 triangles
- Collision: 36 triangles across 3 objects
- Godot benchmark: current loaded GLB, 1,500 samples, 20-second measurement, no screenshot dumping or video encoding, 14,704 visible triangles
- Turntable: 288 real Godot frames, H.264 1280x720, 24 fps, 12 seconds, unique source-frame ratio 1.0

The Godot imported-resource record derives its `.scn` path from the current `.glb.import` file and records the imported resource hash. The benchmark and manifest both point to the current GLB SHA rather than the stale v0.331 count.

## Review pack

`artifacts/manual-review/v0332-house02-visual-truth/UPLOAD_TO_CHAT/`

The upload pack has exactly ten files. The full-evidence directory contains visual-quality, technical-isolation, three-way before/after, and black/frozen-frame rejection evidence. Real rendered images are used for the visual-quality boards; schematic/dimension annotations are labelled as authored evidence rather than substituted for renders.

## Preservation and hard boundaries

Preserved: House 01 source and runtime, accepted v0.331 documentary/reference records, current gameplay/runtime semantics, stable IDs, saves, true default runtime, and all no-gameplay/no-movement/no-pathfinding/no-combat/no-economy/no-resource boundaries. No production-wide asset conversion, settlement integration, animation system, or gameplay state was added.

## Validation and CI

The dedicated v0.332 validator checks current GLB/import hashes, material-image binding records, LOD/collision budgets, roof anchors, actual UV/wireframe/collision inputs, current-GLB benchmark consistency, exact ten-file pack, media, preservation, and no-gameplay anchors. It passed with `humanReviewRequired: true`, preserving the honest internal rejection instead of auto-approving the visual result.

Local validation passed before closeout:

- `node tools/godot/saltoV0332House02VisualTruthTool.mjs`
- `node tools/godot/saltoV0331BarrosanHouse02Tool.mjs validate`
- `node tools/godot/saltoV0330BarrosanHouse02Tool.mjs validate`
- clean-state retained validators v0.329, v0.328, v0.327, and v0.326
- `npm test -- --reporter=dot` (122 files, 887 tests)
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run validate:runtime-art-slots`
- `npm run godot:validate:salto-experimental-artifact-retention`
- `npm run godot:validate:salto-barrosan-ui-state-invariant`
- `npm run godot:all`
- `git diff --check`

The implementation commit `7294f760913448ac530a4eaee2c607c27845fdce` was pushed to `codex/v0215-v0226-recovery`. GitHub Actions run `29622592670` (`CI Release Matrix Dry Run`) completed successfully for that exact SHA. The final report-only closeout update is intentionally kept separate so the report records the already-verified implementation CI result; its own exact-SHA run is recorded in the final handoff after this update.

## Known limitation and safest next step

The safe next checkpoint is not a gameplay or renderer rewrite. It is a narrowly isolated House 02 wall-material truth repair: preserve the current source/import contract, fix the exported wall UV/material scale so the granite albedo visibly reads as irregular masonry in the unlabelled Godot render, recapture, and rerun the same truth gate. Until that happens, v0.332 remains internally rejected.
