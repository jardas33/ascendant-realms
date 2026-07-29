# v0.340 Barrosan Secondary Environment Kit and Terrain Truth Gate

## Executive result

v0.340 is an isolated, opt-in secondary-environment kit and terrain-truth review slice. The actual Godot PLAYER renders now show a covered grass valley, recessed watercourse, connected roads, a seated crossing, a closed granite barn volume, a timber/stone shed, wall-kit variants, a trough, and restrained vegetation around the frozen House 02 anchor.

This is ready for human visual review, not an automatic production approval. The v0.339 human rejection is retained: v0.339 remains an empty-showroom reference point and is not called production-ready.

## Scope and baseline

- Base HEAD: `471d17cd3ca9a5f124bc18128f0175b3d4616da7`
- Branch: `codex/v0215-v0226-recovery`
- Prototype scene: `desktop-spikes/godot-salto/scenes/review/V0340BarrosanSecondaryEnvironmentKitReview.tscn`
- Blender source: `art-source/blender/v0340/barrosan_secondary_environment_kit.blend`
- Exported kit: `desktop-spikes/godot-salto/assets/v0340/barrosan_secondary_environment_kit.glb`
- Runtime manifest: `artifacts/runtime/v0340/v0340-barrosan-secondary-environment-kit-runtime.json`
- Default-runtime integration: false

The work is limited to visual prototype geometry, opt-in capture tooling, evidence packaging, and validation. It does not convert the full game or replace accepted runtime scenes.

## Frozen lineage and human decision carried forward

The v0.338 House 02 Blend and GLB are frozen and were instantiated without modification:

- Blend SHA-256: `3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6`
- GLB SHA-256: `ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89`

The v0.339 decision remains explicit: the prior hamlet scene was rejected internally as an empty asset showroom/generic diorama and was not promoted. v0.340 adds environmental context around that frozen anchor so the kit can be judged at RTS scale.

## Authored kit

The Blender generator is repository-authored and exports a single isolated GLB. It contains the seven requested family groups:

1. Granite agricultural barn with lower stone level, upper rubble wall, slate roof halves, ridge, timber entrance/vents, and grounding rubble.
2. Timber/stone shed lean-to with retaining base, timber back, posts, roof, open storage bay, and firewood.
3. Dry-stone wall kit with long, short, low, corner, end-cap, gateway, elevation-following, and partially collapsed variants.
4. Granite trough with rim, water basin, and overflow drain.
5. Rural timber/stone crossing with abutments, deck boards, rails, and posts.
6. Highland vegetation with authored trunks, layered canopies, reeds/grass, ferns, weeds, sapling, rocks, and bank dressing.
7. Terrain/road/water kit with elevated grass land, raised agricultural edges, muddy bank transitions, a sinuous recessed watercourse, compacted earth road, worn-stone track, and entrance paths.

The geometry contract was repaired during this checkpoint: planar terrain/ribbon winding is upward-facing, cuboid/stone winding is consistently outward-facing, and roof slabs use horizontal dimensions pitched across the building width rather than vertical plates. These are source-level fixes in the v0.340 generator only.

## Terrain truth

The actual Godot capture proves:

- the land surface covers the complete camera frustum around the representative sector;
- the river is below the bank transitions and is non-rectangular;
- the crossing is seated across the water rather than floating as a translucent debug pad;
- the road and secondary paths are continuous across the review slice;
- the agricultural edge and bank treatment create visible elevation separation;
- hard debug guides are hidden in PLAYER mode and available through `V0340_MODE=DEBUG_REVIEW`.

## Materials and visual hierarchy

The kit uses restrained Barrosan materials: dark rubble granite, local granite variation, charcoal slate, weathered timber, dark iron, subdued grass, earth/stone paths, muddy banks, cool water, and muted highland foliage. Godot applies a small opt-in presentation hierarchy after import so grass, road, water, granite, slate, timber, and vegetation remain distinguishable at gameplay scale.

The render is deliberately low-poly and documentary rather than a finished AAA asset pass. House 02 remains the quality anchor; the kit is being judged for material vocabulary, silhouette, scale, adjacency, and truth of environment rather than texture density.

## Camera, PLAYER mode, and DEBUG_REVIEW mode

The review scene uses the inherited stable orthographic oblique RTS camera plus direct top-down and four oblique capture angles. It does not add free camera navigation, zoom redesign, movement, route following, or gameplay input.

PLAYER mode is clean and unlabelled. It shows the terrain, buildings, roads, water, crossing, vegetation, and prototype units with HUD/minimap context. DEBUG_REVIEW mode preserves deterministic technical labels and measurement guides for dimensions, family IDs, contact, clearance, and terrain evidence. Mode selection is controlled by `V0340_MODE` and does not mutate game state.

## Units and grounding

The scene reuses the opt-in authored true-3D worker, Defender, and Reserve Support fixture units. The worker is explicitly kept visible for the wide proof frame, and the crossing capture shows a Defender-scale unit seated against the deck/rail geometry. Selection rings are inherited opt-in presentation elements; no gameplay selection or unit state is changed.

## Evidence and review pack

The capture command produces 42 actual Godot OpenGL renders and a 504-frame continuous route capture. The route moves only the review camera; it does not move units or gameplay objects.

Exact upload pack:

`artifacts/manual-review/v0340-barrosan-secondary-environment-kit/UPLOAD_TO_CHAT/`

It contains exactly eleven canonical upload files, including the primary environment board, barn/shed board, wall board, terrain/road board, crossing/trough board, vegetation board, technical board, H264 video, readme, and compact evidence summary. The visual boards are built from actual rendered PNGs rather than title-card placeholders. The pack records a five-sample black-frame rejection report, non-blank image checks, decoded frame count, and camera-change evidence.

Full per-capture evidence is retained at:

`artifacts/manual-review/v0340-barrosan-secondary-environment-kit/full-evidence/`

## Technical and gameplay preservation

No movement, pathfinding, route following, combat, attacks, damage, HP loss, projectiles, death/despawn, AI, waves, fog gameplay, economy/resource mutation, pressure mutation, save mutation, or stable-ID change is present. The accepted v0.287-v0.339 chain remains untouched. The true default runtime remains unchanged and v0.340 is not integrated into it.

The frozen House 02 source is not edited. v0.334, v0.337, and v0.338 source lineage is preserved. No third-party or protected-game assets were imported; the v0.340 visible kit is authored in Blender in-repository.

## Commands

- Author: `npm run blender:generate:salto-v0340-barrosan-secondary-environment-kit`
- Capture: `npm run godot:capture:salto-v0340-barrosan-secondary-environment-kit`
- Pack: `npm run godot:pack:salto-v0340-barrosan-secondary-environment-kit`
- Dedicated validator: `npm run godot:validate:salto-v0340-barrosan-secondary-environment-kit`

## Validation evidence

The dedicated validator checks the frozen v0.338 hashes, v0.340 scene/source/GLB, opt-in/default-runtime contract, geometry/material family tokens, camera contract, terrain/water/road truth, UV/LOD/collision metadata, 42 screenshot renders, 504-frame H264 video, exact eleven-file upload pack, compact-summary hashes, and forbidden gameplay coupling.

The retained validator ladder was run using valid historical-evidence modes rather than weakening old scope guards: v0.304-v0.310 at the v0.318 checkpoint with their retained evidence, v0.320 at its own checkpoint with its retained evidence, v0.326-v0.328 at their historical checkpoints with the retained v0.322 media, and v0.333 at its own checkpoint after regenerating its missing local capture root and 1,500-sample benchmark. Canonical current validators v0.311-v0.319, v0.321-v0.325, v0.329-v0.339, and v0.259 also pass. The resulting retained evidence is: v0.304-v0.339 pass, v0.259 pass. Repository tests/build/content/art/runtime/artifact checks, `npm run godot:all`, and `git diff --check` pass. Any Godot import sidecar changes from validation are restored individually when they are unrelated to this isolated checkpoint.

## Human review gate

The automated result is `READY FOR HUMAN BARROSAN SECONDARY ENVIRONMENT KIT REVIEW`, with `humanReviewRequired=true` and `automatedVisualApproval=false`. The scene is a feasibility/truth gate. It must not be described as a production-ready full Salto environment until a human accepts the rendered evidence and a later, explicitly scoped conversion checkpoint is authorized.

## Final state target

After local validation, commit and push to `codex/v0215-v0226-recovery`, wait for the exact pushed SHA GitHub Actions run, confirm success, and leave the repository clean and synchronized with origin.
