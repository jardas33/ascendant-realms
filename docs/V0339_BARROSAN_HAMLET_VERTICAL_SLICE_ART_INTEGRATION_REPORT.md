# v0.339 Barrosan Hamlet Vertical-Slice Art Integration Report

## Executive outcome

v0.339 is an isolated, opt-in Barrosan hamlet vertical slice for human visual review. The checkpoint integrates the frozen v0.338 House 02 gold-candidate GLB without modification with a repository-authored secondary asset family. Automated validation establishes technical readiness; human visual approval remains required.

## Scope and decision gate

This is a game-scale art integration slice, not a gameplay or production-wide settlement conversion. The representative sector is the East bridge / Field Barracks / river-crossing area. The slice is intentionally removable and does not alter the accepted runtime.

## Base and frozen anchors

- Base HEAD: `a880884b8dae83ee5d843019fb3c309dfab4ea3c`
- Branch: `codex/v0215-v0226-recovery`
- Frozen v0.338 Blend SHA-256: `3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6`
- Frozen v0.338 GLB SHA-256: `ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89`

## Prototype scene and commands

Scene: `desktop-spikes/godot-salto/scenes/review/V0339BarrosanHamletVerticalSliceReview.tscn`.

- Authored source generation: `npm run blender:generate:salto-v0339-barrosan-hamlet-vertical-slice`
- Godot capture and H.264 video: `npm run godot:capture:salto-v0339-barrosan-hamlet-vertical-slice`
- Upload pack: `npm run godot:pack:salto-v0339-barrosan-hamlet-vertical-slice`
- Dedicated validation: `npm run godot:validate:salto-v0339-barrosan-hamlet-vertical-slice`

The true default runtime remains unchanged because the scene is review-only, `prototypeOptIn` is true, and `defaultRuntimeIntegrated` is false.

## Visual composition

The slice contains the frozen House 02 anchor, a granite agricultural barn, timber-and-stone shed/lean-to, dry-stone wall kit, stone trough/washing structure, primary bridge road and secondary paths, river and crossing, embedded granite rocks, restrained highland vegetation, props, Worker figures, Defender, and Reserve Support. The composition is framed as an inhabited hamlet rather than a pedestal or empty board.

## Architecture and materials

The v0.339 secondary family is authored in `art-source/blender/v0339/barrosan_hamlet_vertical_slice_assets.blend` and exported to `desktop-spikes/godot-salto/assets/v0339/barrosan_hamlet_vertical_slice_assets.glb`. Its material vocabulary is weathered granite, slate, timber, dry earth, dark iron, and muted water. Roof, side, base, and contact geometry are separate authored forms. The v0.338 House 02 source and GLB are instanced unmodified.

## Terrain, roads, water, and crossing

The inherited true-3D highland terrain provides elevation, natural bank transitions, a river below the land plane, connected road ribbons, bridge deck/abutments/rails, and small watercourse detail. v0.339 adds contextual walls, crossing-side props, embedded stone, and secondary building mass without rebaking or moving accepted gameplay geometry.

## Units, scale, and entrances

Two repository-authored Worker figures plus Defender and Reserve Support remain grounded at fixed positions. Their silhouettes, contact shadows, and scale are judged against House 02, the barn, shed, roads, bridge, and entrances. Capture choreography changes only the camera; it does not move units or buildings.

## Lighting and cameras

Three deterministic lighting setups are captured: neutral overcast, cool daylight, and restrained warm directional. The gameplay camera is orthographic with a stable oblique RTS treatment. Evidence also includes far, near, 256-pixel, grayscale, direct top-down, and four oblique rotations.

## PLAYER and DEBUG_REVIEW

PLAYER captures are clean and contain no technical labels or debug pads. DEBUG_REVIEW-only captures expose collision/clearance and frozen-anchor evidence through a dedicated overlay. The mode is capture-only and does not change state, labels, gameplay, pressure, resources, saves, or stable IDs.

## HUD status

The existing minimal selected-card HUD is retained. The v0.339 capture manifest records no selected-card/global-instruction overlap. No broad HUD redesign was introduced.

## Evidence and video

There are 31 deterministic screenshot captures in `artifacts/runtime/v0339/screenshots/` and an exact 504-frame, 21-second, 1280x720, 24 FPS H.264 video at `artifacts/runtime/v0339/08_CONTINUOUS_V0339_BARROSAN_HAMLET_VERTICAL_SLICE.mp4`. The canonical upload folder contains exactly the 11 named files required by the checkpoint. Full-evidence copies and proof notes are retained beside the upload pack.

## Scorecard and recommendation

The scorecard is intentionally a human-review aid rather than an automated visual approval: attractiveness 78, historical-target closeness 73, RTS readability 84, terrain credibility 82, bridge credibility 84, building volume 86, unit readability 80, lighting/shadows 79, Barrosan identity 86, technical feasibility 88, maintainability 83, performance risk 78, asset burden 82, animation burden 92, suitability for full Salto conversion 80. Composite feasibility score: 82/100.

Recommendation: **proceed with Route C as the production art-integration direction, subject to human review of the rendered pack**. The next work should be a bounded production conversion slice, not a gameplay change or an unreviewed full-map migration.

## Gameplay, state, and default-runtime preservation

No gameplay, state chain, movement, pathfinding, route following, combat, attacks, damage, HP, projectiles, death/despawn, AI, waves, fog gameplay, economy, resources, pressure behavior, saves, stable IDs, or production logic changed. No object transform is mutated by capture. The accepted v0.287-v0.338 chain is retained.

## Asset provenance and technical isolation

The secondary assets are repository-authored Blender geometry. No protected-game assets or large unapproved import were used. The frozen v0.338 House 02 asset remains a source anchor and is not edited. The prototype has its own scene, source, exported asset, capture, pack, validator, and report paths.

## Performance observations

The capture includes a dedicated performance/draw-call evidence frame and the runtime manifest records the 60 FPS target with no intended repeated spikes above 50 ms. Final numeric benchmark values are reported from the v0.339 runtime evidence produced by the capture command.

## Review pack

`artifacts/manual-review/v0339-barrosan-hamlet-vertical-slice/` contains the 31-capture full-evidence set, technical proof notes, black-frame rejection note, and the exact 11-file `UPLOAD_TO_CHAT` pack.

## Validation and CI

The dedicated v0.339 validator passes with 90 checks. The current/relevant green retained validators cover v0.338-v0.333, v0.332-v0.300 where their historical contracts are green, v0.259, and v0.269-v0.289 after recovery of their preserved real runtime captures. v0.304-v0.310 are retained visual-archaeology/prototype decision checkpoints: their tools intentionally report the documented historical style-gap, revise, pivot, or evidence-rejection outcomes rather than a false green approval. Those historical validators and evidence were not weakened or rewritten. v0.333 was also run in its historical base worktree and passed. The v0.339 validator, tests (887), production build, content/art/runtime checks, artifact retention, `npm run godot:all`, and `git diff --check` pass in the current recovery checkout.

The retained v0.269-v0.279 validators initially reported missing manual-review black-frame statistics. The preserved runtime manifests and rendered PNGs were found under `artifacts/desktop-spikes/godot-salto/v0269` through `v0279`; the existing v0.269-v0.279 pack builders were rerun against those PNGs to reconstruct the ignored manual-review packs and derive black-frame statistics from the real historical images. The validator sources were not changed or weakened. All v0.269-v0.279 validators now pass.

The old GitHub Actions artifacts remain expired/unavailable (runs 28487985427, 28478695860, and 28437921437 report zero retained artifacts), so the retained proof is explicitly sourced from the preserved local runtime manifests and PNGs, with reconstruction recorded here.

The v0.339 commit is ready for the required branch push. Exact-SHA GitHub Actions verification is performed after that push and recorded in the final handoff; this report does not claim remote success before it is observed.

## Limitations

Human visual approval remains required. This is a representative sector, not a full Salto conversion. Units remain authored static visual figures for this art checkpoint; no animation or gameplay system is added.

## Final repo state

Implementation is committed from base HEAD `a880884b8dae83ee5d843019fb3c309dfab4ea3c`; the final pushed SHA, Actions run, and clean synchronized repo state are recorded in the final handoff after remote verification.
