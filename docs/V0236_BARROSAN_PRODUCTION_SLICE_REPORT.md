# v0.236 Barrosan Faction Art Bible and Production-Quality Slice Report

Milestone verdict: `PASS`

Overall finish classification: coherent low-poly production direction, not final shipped environment art.

## Art bible

The first faction-standard document is tracked at:

`docs/art/V0236_BARROSAN_FACTION_ART_BIBLE.md`

It defines Barrosan frontier identity, building-role silhouettes, roof construction, a named color/material palette, minimum detail and grounding rules, terrain integration, lighting/camera guidance and structural separation from future Ashen, Sylvan, Stone and Arcane factions.

The implementation follows that contract rather than applying an unstructured beauty pass.

## Asset revision

- Blender used: yes, Blender 5.1.2.
- New Blender source: `art-source/blender/v0236/salto_barrosan_production_slice.blend`.
- New runtime GLB: `desktop-spikes/godot-salto/assets/v0236/salto_barrosan_production_slice.glb`.
- v0.236 GLB: 3,337,620 bytes, 394 meshes.
- Existing v0.235 GLB modified: no.
- Existing v0.233R GLB modified: no.
- Isolated Godot scene: `res://scenes/salto_barrosan_production_slice.tscn`.

## Exact implementation counts

- Building modules changed: exactly 3.
- Existing material families retuned: 21.
- New material variants: 14.
- New or changed materials total: 35.
- Blender-authored building detail objects added: 98.
- Reusable role-prop modules added: 6.
- Prop/detail module instances added to the composed scene: 18.
- Organic runtime surfaces: 154.
- Road ribbon segments: 87.
- River ribbon segments: 18.
- Square terrain modules placed: 0.
- Panel-style road modules placed: 0.

## Visual result

- Keep/base: formal steps, ordered stone courses, gate emphasis, paired civic banners and restrained red/gold identity improve civic and defensive authority.
- Barracks/workshop: facade repairs, shutters, timber variation, tools, weapon racks, training posts, cart, logs and storage produce a clear working military yard.
- Mine/Lume: reinforced portal, extraction supports, pulleys, stone piles and controlled crystal clusters produce a specific industrial-mystic role.
- Roofs: all four corrected v0.235 ridge-to-eave assemblies remain intact, with aged terracotta variation and dark eaves.
- Terrain: the visible square terrain grid is removed in favor of one continuous island and broad organic grass/dirt patches.
- Roads: variable-width layered ribbons connect the three landmarks and bridge without bright rectangular panels.
- River: a shaped, segmented channel with layered bank depth and restrained glint passes beneath the retained bridge.

## Honest visual assessment

The v0.236 scene is clearly richer, less toy-like and more art-directed than v0.235. The improvement is visible in the full RTS overview, not only in close crops, and the art bible directly explains the implemented shapes, colors, materials and role clutter. The bounded milestone therefore passes.

This is not final production environment art. It still uses untextured low-poly geometry, a small vegetation vocabulary and simple flat-shaded surface treatment. The next eventual art phase would need bespoke texture work, more vegetation/edge species and more sophisticated terrain blending—but v0.237 is not authorized or started here.

## Evidence

Exact review pack:

`artifacts/manual-review/v0236-barrosan-art-bible-production-slice/`

The pack contains the required v0.235 baseline, seven v0.236 captures, before/after sheet, art-bible summary contact sheet and candid report.

## Boundaries

Gameplay, saves, economy, selection, pathing, commands, minimap logic, objectives, production logic, AI, collision, browser runtime, runtime-art slots and default launcher remain unchanged.

Stop after v0.236. Do not begin v0.237.
