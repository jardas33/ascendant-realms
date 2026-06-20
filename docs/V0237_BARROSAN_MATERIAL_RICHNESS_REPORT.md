# v0.237 Barrosan Material Richness, Foliage, and Inhabited Detail Report

Milestone verdict: `PASS`

Overall finish classification: substantially richer stylized low-poly production art, not final hand-textured environment art.

## Asset revision

- Blender used: yes, Blender 5.1.2.
- New Blender source: `art-source/blender/v0237/salto_barrosan_material_richness.blend`.
- New runtime GLB: `desktop-spikes/godot-salto/assets/v0237/salto_barrosan_material_richness.glb`.
- v0.237 GLB: 5,132,168 bytes.
- Existing v0.236 GLB modified: no; retained SHA-256 `1AD8462C9CC1084BE678177CA8A829D8D2F6D8742DF6615EAB2B645284CAB7AC`.
- v0.237 GLB SHA-256: `EC36A297C9D4B9E77AB8EEEF52435D0C7FC07D04551126FDA4BF5C42DF545528`.
- Isolated Godot scene: `res://scenes/salto_barrosan_material_richness.tscn`.
- Art-bible addendum: `docs/art/V0236_BARROSAN_FACTION_ART_BIBLE.md`.

## Exact implementation counts

- New or changed material families: 16.
- Blender-authored building-detail objects added over v0.236: 123.
- Vegetation modules added: 7.
- Vegetation instances composed: 46.
- New inhabited prop modules: 6.
- Prop/detail instances added to the composed scene: 20.
- Terrain/road/river surfaces changed: 24.
- Square terrain modules placed: 0.
- Panel-style road modules placed: 0.

## Material richness

- All four corrected pitched roofs retain their central ridges, two descending planes, overhangs, ridge caps and fascia boards.
- Restrained tile-row accents and richer ridge strips create visible roof construction rhythm at RTS distance.
- Broad plaster repairs, hairline crack accents, stone chips, timber pegs/brackets and dark contact dirt add construction history without dissolving the building silhouettes.
- Road-center scars, yard wear and threshold dirt make movement and occupation visible.
- Lume remains bright cyan but localized to extraction details; it does not flood the mine or overpower the overview.

## Terrain and vegetation

- Ten broad terrain patches introduce shallow terrace cues, grass islands and trampled transitions.
- Eight road-wear patches strengthen route history without changing route shape or collision.
- Six damp bank patches blend stone, moss and river edges.
- The vocabulary now includes round bushes, wind-shaped bushes, grass clumps, reeds, young trees, broad mature trees and low moss.
- Vegetation is clustered at the perimeter, quiet terrain pockets and riverbanks, leaving landmark yards, roads and the bridge readable.

## Inhabited landmark detail

- Barracks/workshop: plank stacks, awning, crates, barrels, carts and retained weapon/training equipment create a credible working military yard.
- Keep/base: paired guard posts, entrance lamps, stronger threshold treatment and civic clutter reinforce a defended public entrance.
- Mine/Lume: ore carts, workbench, planks, storage, rubble and crystal fragments strengthen the extraction role and portal grounding.

## Honest visual assessment

The v0.237 full overview is clearly richer than v0.236. Roof rhythm and wall construction read before zooming in, terrain transitions are less empty, and the vegetation vocabulary gives the island a temperate frontier identity. The scene feels inhabited, but the clustering remains disciplined enough that the three landmarks, main road, bridge and river stay immediately legible. The milestone therefore passes.

This is still not final shipped environment art. Surfaces remain geometry- and color-driven rather than using bespoke hand-painted texture maps, tree species are deliberately limited, and final production lighting could add more subtle atmospheric depth. The pass establishes a stronger beauty baseline; it does not pretend to be AAA final art.

## Evidence

Exact review pack:

`artifacts/manual-review/v0237-barrosan-material-richness-foliage/`

It contains the v0.236 overview baseline, eight v0.237 captures, before/after contact sheet and candid report.

## Boundaries

Gameplay, saves, economy, selection, pathing, commands, minimap logic, objectives, production logic, AI, collision, browser runtime, runtime-art slots and default launcher remain unchanged.

Stop after v0.237. Do not begin v0.238.
