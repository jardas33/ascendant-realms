# v0.121 Godot Procedural 2.5D Visual Foundation Spec

Status: procedural placeholder spike only.

v0.121 improves the existing Godot `2_5D_ORTHOGRAPHIC_PLACEHOLDER` mode with repository-driven procedural primitives. It does not import artwork, generate images, create final materials, change browser runtime behavior, choose Godot finally, or start a full port.

## Visual Target

The target is an original modern top-down RTS/RPG presentation that can evoke the spirit of a super-cool 2026 evolution of classic hero-led strategy games while remaining Ascendant Realms' own IP, factions, lore, assets, UI, mechanics, and visual identity.

The 2.5D pass focuses on:

- Fixed high-angle orthographic camera with RTS readability framing.
- Subtle terrain height bands, readable road strip, ford/water posture, quarry, shrine, ruin, Command Hall, Barracks, and enemy structure silhouettes.
- Procedural hero, Worker, Militia, Ranger, and Ashen silhouette differentiation.
- Directional light, restrained shadow posture, fog posture, and Lume endpoint/link VFX placeholders.
- Capture-site markers, selected-entity feedback, compact HUD, resource row, selected hero card, objective summary, and minimap/orientation placeholder.

## Authorized Boundaries

- Procedural Godot primitives only.
- No downloaded, generated, imported, or final artwork.
- No runtime art path or asset registry change.
- No browser gameplay, balance, AI, pathing, save, stable-ID, reward, campaign, or content changes.
- No manual Godot editor scene assembly.
- No final engine selection.

## Shared Contract

Both 2D control and 2.5D modes continue to use the same generated fixture IDs, S/M/L workload counts, input contract, benchmark contract, Results contract, read-only save posture, and exact `linked_ward` multiplier of `0.92`.
