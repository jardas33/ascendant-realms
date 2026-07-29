# v0.321 TRUE 3D BARROSAN ART-DIRECTION LOCK

## Executive decision

**CONTINUE TRUE 3D BARROSAN DIRECTION — ONE TARGETED ART PASS REMAINS**

Presentation is **TRUE 3D GROUNDED STYLISED BARROSAN RTS**. The isolated benchmark materially improves the v0.320 blockout: it removes the diorama edge, builds a continuous highland terrain field, connects the roads to the bridge and doors, distinguishes four Barrosan building identities, uses articulated true-3D Worker/Militia assemblies with deterministic variants, adds inhabited props and vegetation, and replaces the temporary map label with an actual compact minimap. One targeted art pass remains for painterly surface breakup, finer architecture weathering, and animation polish before narrow production integration.

## Base and scope

- Base HEAD: `986fa07b4dd6400211cd150372b6f8f0747419ae` (v0.320 exact-CI baseline)
- Branch: `codex/v0215-v0226-recovery`
- Scene: `desktop-spikes/godot-salto/visual_vertical_slice/V0321BarrosanArtDirectionLock.tscn`
- Script: `desktop-spikes/godot-salto/scripts/v0321_barrosan_art_direction_lock.gd`
- Scope: isolated opt-in art-direction benchmark only.

v0.320 proved the strategic method—true 3D stylised RTS, orthographic oblique camera, no PLAYER billboards. v0.321 locks the Barrosan visual language around that method without touching the accepted runtime or gameplay.

## Visual implementation

- Camera: locked orthographic oblique projection with ordinary overview/gameplay/close bounds audited against a continuous `[-48, 48]` terrain field; no world edge is visible.
- Terrain: varied elevation, grass, packed soil, exposed riverbank rock, blended family patches, irregular occupied-ground aprons, stones, grass/riverbank detail and worn approaches.
- Roads and river: one connected packed-earth primary road, two footpaths, centre wear, bridge approach wear, a recessed wider animated river with darker water and bank vegetation.
- Bridge: thick timber deck, two granite abutments, deck joints, rail posts and caps, with approach connection and contact shadows.
- Architecture: four non-scaled identities—Hall/Manor, Field Barracks, Storehouse/Workshop, Worker Dwelling—with granite foundations, wall volume, plaster/stone variation, deep slate roofs, recessed openings, chimneys and identity props.
- Units: proportioned true-3D Worker and Militia assemblies with necks, shaped torsos, clothing/armour, limbs, boots, equipment and role materials. No billboards, atlas cells, cards or capsule units in PLAYER.
- Variation: three Worker hat/head variants, three clothing tones, three Militia helmet variants, two shield variants, narrow stable-ID height and idle-phase variation.
- Animation evidence: Worker idle/walk/work and Militia idle/walk/ready presentation scrubs; no root motion or gameplay movement.
- Lighting: restrained warm key, cooler ambient fill, softer readable shadows, filmic tone and subtle atmosphere.
- Storytelling: handcart, timber pile, three barrels, four crates, workshop storage, two stone walls, fence gate, chimney smoke cue and water-side reeds/stones.
- UI: compact resource strip, actual minimap with terrain/river/road/bridge/building/unit marks, compact selected card, readable command buttons; no evidence metadata in PLAYER.

## Evidence and comparison

The review pack compares recovered v0.141, the v0.319 fallback, the v0.320 true-3D blockout and the v0.321 benchmark with labels. The compact quality files are actual Godot-rendered images. `11_CONTINUOUS_PLAYER_RUNTIME.gif` is a genuine GIF with 48 frames, 12 seconds at 800x450, more than one unique frame hash, camera pan/zoom, and Worker/Militia state scrubs. Static files with the wrong extension are rejected by the validator.

Review pack: `artifacts/manual-review/v0321-true-3d-barrosan-art-direction-lock/`

## Scorecard

| Category | Score |
|---|---:|
| Art-style coherence | 86 |
| Barrosan identity | 84 |
| Terrain believability | 84 |
| Road/path integration | 83 |
| Riverbank/water | 85 |
| Architectural distinction | 84 |
| Material quality | 81 |
| Worker silhouette | 81 |
| Militia silhouette | 82 |
| Unit variation | 80 |
| Animation quality | 78 |
| Unit/world lighting match | 86 |
| Environmental storytelling | 82 |
| Gameplay readability | 85 |
| PLAYER UI | 84 |
| Atmosphere | 84 |
| v0.141 ambition comparison | 76 |
| Production-direction viability | 83 |
| Overall | 83 |

The scores support **CONTINUE**, not automatic adoption: animation quality and material/painterly breakup remain the contained gap.

## Preservation and validation

The v0.320 scene, v0.319 fallback, H3 static/animated adapters, default entry scene, accepted v0.287-v0.320 chain, stable IDs, saves, minimap data, pressure, gameplay, movement, pathfinding, combat, AI, economy, resources and production remain unchanged. The manifest and validator assert `defaultRuntimeChanged: false` and `gameplayChanged: false`; the v0.321 scene is not referenced by the default runtime.

Dedicated command: `npm run godot:validate:salto-true-3d-barrosan-art-direction-lock`

Capture command: `npm run godot:capture:salto-true-3d-barrosan-art-direction-lock`

Pack command: `npm run godot:pack:salto-true-3d-barrosan-art-direction-lock`

Validator: `tools/godot/saltoV0321BarrosanArtDirectionLockTool.mjs`

The retained v0.320-v0.303 validators were run against a clean accepted baseline because their scope guards correctly reject later checkpoint files; the v0.321 validator was then rerun with the restored working tree. v0.259 UI invariant, 887 tests, production build, content/art/runtime checks, artifact retention, `npm run godot:all`, and `git diff --check` passed. Implementation commit `c8503331bf25f014b9af9f10ef7814446287cebf` was pushed to this branch and exact-SHA GitHub Actions run `29410081601` completed with `success`. The final documentation update is kept on the same branch; after its push the repository is verified clean and synchronized at `0 ahead / 0 behind`.

## Recommended next checkpoint

v0.322 should be a narrow Barrosan surface-material and animation polish pass: authored roughness/normal breakup on the four principal buildings and terrain transitions, plus weight-shift/foot-placement refinement for the six required unit states. It should not integrate the scene broadly or add gameplay.
