# v0.330 Barrosan House 02 Reference-Grounded Re-authoring

## Executive outcome

**READY FOR HUMAN REFERENCE-GROUNDED HOUSE 02 REVIEW**.

This checkpoint is a standalone, opt-in visual asset and documentary review slice. It is not a production gold lock, faction-completion claim, settlement integration, historical-accuracy claim, or full environment conversion.

## Scope and baseline

- Base HEAD: `253aea88d8cfea6be7fd409551aaf2d1b2d4cd9d` (accepted v0.329 closeout).
- Branch: `codex/v0215-v0226-recovery`.
- New source: `art-source/blender/v0330/barrosan_house_gold_02.blend`.
- New export: `desktop-spikes/godot-salto/assets/v0330/barrosan_house_gold_02.glb`.
- New review scene: `desktop-spikes/godot-salto/scenes/review/V0330BarrosanHouse02Review.tscn`.
- Launch/capture: `npm run godot:capture:salto-v0330-barrosan-house-02-reference-grounded`.
- Dedicated validator: `npm run godot:validate:salto-v0330-barrosan-house-02-reference-grounded`.

## Why a new House 02 was required

The v0.329 visual/evidence review rejected its underlying House 01 lineage as the intended documentary architecture: fortress/ruin massing, roof-edge crown, ambiguous upper access, repeated masonry cues, and a mood target being treated as architectural reference. House 01 is therefore frozen. House 02 is authored clean-room from a compact inhabited rural-house brief and a separate documentary register.

## Documentary references

The source register is `art-source/references/v0330/documentary/README.md` and contains one primary anchor plus three supplementary documentary sources, access/file date, location, title, URLs, license/source notes, and six independently observable cues.

- Primary anchor: [30989 Montesinho — A beautiful stone house](https://commons.wikimedia.org/wiki/File:30989_Montesinho_A_beautiful_stone_house_(54963502273).jpg), Panegyrics of Granovetter, 2024-02-20, Montesinho, CC BY-SA 4.0.
- Masonry supplement: [30991 Montesinho masonry](https://commons.wikimedia.org/wiki/File:30991_Montesinho_masonry_(54963321936).jpg), used only for stone rhythm and lintel/sill cues.
- Porch/function supplement: [30987 Rustic porch in Montesinho](https://commons.wikimedia.org/wiki/File:30987_Rustic_porch_in_Montesinho_(54961581200).jpg), used only for the stair/landing, timber, slate, and lower-storage relationship.
- Official documentary account: [ICNF Parque Natural de Montesinho](https://www.icnf.pt/conservacao/rnapareasprotegidas/parquesnaturais/pnmontesinho), used as research text for granite, slate, timber, two-floor agricultural/domestic function, and stair/balcony construction.

The references are documentary only. No protected-game asset, House 01 mesh, House 01 generator, or House 01 texture is imported.

## Architectural brief and authored result

House 02 is a compact rectangular two-storey rural house with granite-dominant walls, a lower agricultural/storage floor, an upper domestic floor, two upper domestic windows, one principal agricultural door, a side work door, a real upper timber door, a parallel exterior stone stair, a real landing, a simple continuous pitched slate roof, and one grounded masonry chimney. It intentionally has no tower, crenellation, defensive crown, secondary triangular roof masonry, or fortress silhouette.

Artist-estimated greybox dimensions are 9.6 m principal length, 5.8 m depth, lower body approximately 2.55 m, upper domestic course approximately 1.95 m, and a 1.75 m human-scale proxy. These are reference-grounded authoring proportions for human review, not a claim that the documentary photograph was metrically surveyed.

## Materials, UV, LOD, and collision

The authored material vocabulary is weathered granite, dark foundation, slate, timber, and recessed window material. The real UV channel is `UVMap`; Blender Smart Project packing is applied to the exported meshes. Godot captures show a UV-driven checker in two asset rotations. The checker shader samples `UV` and contains no `SCREEN_UV` or screen-space overlay.

- LOD0: 15,644 triangles, 5 grouped render objects.
- LOD1: 6,880 triangles, 5 grouped render objects.
- LOD2: 1,716 triangles, 5 grouped render objects.
- Collision: 36 triangles across 3 simple volumes.
- Exported UV evidence: 600 islands, 0 overlap, 0 out-of-bounds, 12% maximum density deviation.
- Mesh integrity: invalid normals 0, non-manifold count 0, unapplied transform count 0, hidden duplicate geometry 0.

## Godot review sector and camera

The opt-in review scene adds a small representative context without touching the accepted runtime: split elevated grass terraces, a recessed river below land level, embedded road slabs, a timber bridge with stone abutments/rails, a small support shed, three static scale units, and the imported House 02. The primary camera is controlled orthographic oblique RTS; a direct top-down comparison is captured separately. No input, movement, navigation, combat, AI, economy, production, pressure, save, or stable-ID system is present.

## Review evidence

The review pack is `artifacts/manual-review/v0330-barrosan-house-02-reference-grounded/`.

The exact upload set under `UPLOAD_TO_CHAT/` contains ten files: documentary board, anchor-to-greybox/final comparison, v0.329-to-House-02 comparison, elevations/plan/human scale, architectural function, materials/real UV checker, technical isolation board, continuous H.264 turntable, read-me, and compact summary. The full-evidence directory contains real visual-quality and technical-isolation contact sheets plus `43_black-frame-rejection-report.md`. The visual-quality sheet uses rendered images rather than title cards; the historical target is marked as a separate comparison reference and is not in the documentary source board.

## Performance and evidence safeguards

The benchmark was run after a 5-second warm-up for more than 20 seconds with screenshot/video/debug overlays disabled: 1,500 samples, approximately 75 FPS average/median, minimum approximately 66 FPS, and zero repeated >50 ms spikes. The capture manifest maps every screenshot to a 1280x720 real Godot render, and the turntable contains 120 decoded frames at 24 FPS with unique-frame ratio 1.0. Blank-frame rejection is recorded in the full-evidence report.

The validator rejects missing documentary metadata, fewer than four sources, missing primary anchor, House 01 imports, prior-generator imports, mood-target substitution, screen-space checker evidence, out-of-range geometry, missing real captures, non-exact upload count, self-approval claims, and preservation failures. It compares House 01 Blender/GLB hashes against the accepted base blob and verifies the opt-in scene’s no-gameplay anchors.

## What changed

- Added a clean-room Blender House 02 source and GLB export.
- Added a separate documentary reference register and source board.
- Added a standalone Godot review scene with river, banks, road, bridge, support shed, static units, and oblique/top-down camera captures.
- Added real UV checker rotation A/B captures, LOD/collision captures, benchmark evidence, turntable media, black-frame report, dedicated validator, package commands, and exact ten-file upload pack.

## What did not change

- House 01 source/GLB, accepted runtime scenes, state chain, pressure behavior, stable IDs, saves, default runtime, gameplay, movement, pathfinding, route following, combat, damage, HP, projectiles, death/despawn, AI, waves, fog gameplay, economy, resources, production, and settlement integration were not changed.
- No full asset replacement or full Salto conversion was attempted.
- v0.329 remains the fallback/proof lineage; v0.330 is opt-in and isolated.

## Validation evidence

- Dedicated v0.330 validator: passed.
- v0.330 Blender generator and Godot import/capture/pack: passed.
- Exact ten-file upload count: passed.
- Documentary-source count, primary-anchor, clean-room, architecture, LOD/collision, real-UV, benchmark, review-pack, and preservation aliases: all invoke the dedicated validator.
- Retained v0.329 dedicated validator: passed with `npm run godot:validate:salto-v0329-barrosan-house-visual-authenticity`.
- `npm test`: passed (122 test files, 887 tests).
- `npm run build`: passed.
- `npm run validate:content`: passed.
- `npm run validate:art-intake`: passed.
- `npm run validate:runtime-art-slots`: passed (52 slots).
- `npm run godot:validate:salto-experimental-artifact-retention`: passed.
- `npm run godot:all`: passed, including the Windows package lane.
- `git diff --check`: passed.

## Recommendation and v0.331 boundary

**READY FOR HUMAN REFERENCE-GROUNDED HOUSE 02 REVIEW**. Human review should judge whether this compact authored vocabulary is a credible Barrosan domestic asset before any production roster expansion or runtime integration.

Proposed next checkpoint, only after human acceptance: **v0.331 House 02 human-review decision and opt-in asset intake gate** — record the human verdict, provenance/license acceptance, and a narrow intake decision without integrating the asset into the true default runtime.

## CI and final repository state

Implementation commit: `2e3076a1b3a42e9791c79a6cc4d1f59ee11c74db`.

Exact-SHA GitHub Actions: [run 29604761936](https://github.com/jardas33/ascendant-realms/actions/runs/29604761936) completed successfully for `2e3076a1b3a42e9791c79a6cc4d1f59ee11c74db`.

The report closeout documentation is being pushed after that verified implementation run. Final repository state is required to remain clean and synced on `codex/v0215-v0226-recovery`, 0 ahead / 0 behind, with no changes to the accepted runtime or House 01 asset.
