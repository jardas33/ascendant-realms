# Ascendant Realms v0.379 — Authored Highland Infrastructure

This is an original, deterministic infrastructure kit created for the isolated Ascendant Realms visual pipeline.

It is intended to replace the visually rejected v0.378 flat-board presentation while preserving the successful Blender/GLB/Godot intake route.

## Included

- one continuous highland terrain mesh with smooth colour variation;
- a road embedded into the terrain through height shaping and vertex colour, not a floating ribbon;
- a carved, recessed, curved river valley;
- darker wet-bank transitions;
- one continuous water mesh below the land level;
- a timber bridge with individual deck planks, under-beams, edge courses, posts and two rail courses;
- granite abutments and footings;
- clustered low-poly rocks, reeds and shrubs;
- a deterministic Python source generator;
- schematic previews showing the exact layout and crossing profile.

## File hashes

- GLB SHA-256:   `9a2bdc63488f1a226deb6c312f4dd6fadde7fb93764e17ae58a73d077e5a2315`
- Generator SHA-256:   `071f91c776a8e19ebc0dabdd35d86280b70f319ad15e088630e843877f375e46`

## Technical conventions

- units: metres;
- up axis: Y;
- road crosses the river near world origin;
- bridge deck height: approximately 0.73 m in the authored local scene;
- terrain boundaries are intentionally larger than the intended gameplay camera and must remain outside the approved captures;
- vertex colours carry the terrain, road and bank material variation;
- no external textures or proprietary dependencies are required.

## Human-review intent

The GLB is not itself a final production environment. Codex must import it faithfully, establish a restrained oblique RTS camera, add lighting and capture the result without replacing the authored terrain with another procedural scene.
