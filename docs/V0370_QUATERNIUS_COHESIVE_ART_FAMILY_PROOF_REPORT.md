# v0.370 Quaternius Cohesive Art-Family Proof

## Executive result

The revised v0.370 proof passes as an isolated visual feasibility checkpoint.
Actual Quaternius meshes now provide one coherent authored family for the
settlement, bridge composition, props, nature, and characters. The rendered
PLAYER images are materially stronger than the v0.368 procedural board: roofs,
walls, side faces, trees, rocks, grounded human silhouettes, bridge rails, and
contact shadows are all visible in the same frame.

This is a visual target sandbox, not production integration.

## Scope and preservation

- Base branch: `codex/v0215-v0226-recovery`
- Base prior checkpoint: `0e488088ed7e683b8a6d6f2d4f6d44f53c795443`
- Isolated scene: `desktop-spikes/godot-salto/scenes/v0370_quaternius_visual_proof.tscn`
- Root node: `AscendantRealmsQuaterniusVisualProof`
- Launch: `npm run godot:play:quaternius-proof`
- Capture: `npm run godot:capture:quaternius-proof`

The scene is reachable only through explicit v0.370 command-line flags. The
accepted v0.368 scene and script were not modified. No gameplay, movement,
pathfinding, route following, combat, damage, HP, AI, waves, economy,
resources, pressure, stable IDs, saves, or default-runtime behavior changed.

## Asset family and composition

Selected source roots:

- `external-art-intake/quaternius/medieval-village-megakit/`
- `external-art-intake/quaternius/fantasy-props-megakit/`
- `external-art-intake/quaternius/ultimate-modular-men/`
- `external-art-intake/quaternius/stylized-nature-megakit/`

The derived intake is under
`desktop-spikes/godot-salto/assets/third_party/quaternius/v0370/`. The exact
selected files, texture dependencies, approximate bounds, provenance, and
rejections are recorded in `docs/V0370_QUATERNIUS_SELECTED_ASSET_MANIFEST.md`.

The bridge is composed from imported dark timber floors, fence railings,
fence extensions, and authored stairs. The settlement uses imported plaster
walls, round-tile roofs, doors, windows, floors, carts, crates, and barrels.
The resource site uses imported rocks, a whetstone, crate, and wagon. The
hostile camp uses authored fence, cart, barrel, and crate composition. The
terrain bed, recessed stream, banks, and organic route are small engine-
authored support meshes; no primitive character or placeholder building is
used in the PLAYER captures.

## Visual evidence

The five clean PLAYER captures are in
`artifacts/manual-review/v0370-quaternius-cohesive-art-family-proof/`.

- Wide and RTS views establish the full composition and oblique camera.
- Close detail establishes building volume, roof/side separation, human scale,
  props, and grounded shadows.
- Bridge contact establishes deck, rails, stairs, road contact, and the dark
  recessed stream below the crossing.
- Hostile camp establishes a composed authored prop vocabulary without a
  debug-colored territory polygon.
- The comparison sheet places the strongest available v0.368 rendered
  baseline beside the new Quaternius render.

The images were inspected at full size. They are real rendered frames, not
title cards or blank/black placeholders. The former pale gaps were repaired by
adding a low irregular continuous terrain bed beneath the separated land
patches; water remains visibly recessed above that bed and below the land.

## Verdict and limitations

Verdict: **proceed with Route C as the visual direction study, with one later
Barrosan material pass before production integration.**

The proof is substantially better than v0.368 and demonstrates technical
feasibility. It is not yet the final Ascendant Realms art direction: the
Quaternius palette is brighter and more toy-like than the desired weathered
Barrosan highland language, and the engine-authored terrain treatment is still
provisional. Those are controlled art-direction follow-ups, not reasons to
weaken this isolated proof or alter the accepted runtime.

Bounded gameplay proof was not connected because this checkpoint is a visual
target sandbox and the accepted production loop must remain untouched.

## Validation

Dedicated command: `npm run godot:validate:quaternius-proof`.

The validator checks the isolated scene and routing, selected-intake size and
provenance files, the five real captures, the <=10-file review pack, absence
of primitive/capsule/debug-label substitutions, the v0.368 isolation boundary,
and the required launch/capture commands.

Local proof also includes the Quaternius smoke and capture commands, followed
by the repository build/content/art/runtime checks and `git diff --check`.

## Review pack

`artifacts/manual-review/v0370-quaternius-cohesive-art-family-proof/`

The pack is intentionally capped at nine files: five clean PLAYER PNGs, one
comparison image, the selected-asset manifest, compact runtime JSON, and this
README. No video was added because it would not add evidence beyond the five
inspected renders.
