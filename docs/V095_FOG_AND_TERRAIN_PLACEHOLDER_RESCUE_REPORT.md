# v0.95 Fog And Terrain Placeholder Rescue Report

## Terrain Direction

The map renderer remains deterministic and content-driven. v0.95 uses existing terrain zones, roads, capture-site positions, and map dimensions to add readability layers:

- subtle grass patches and ground scuffs;
- stronger road beds with lighter center wear;
- clearer buildable pads with contained grid/anchor marks;
- water edges, ripples, and shallow highlights;
- blocked-ground shadows and stone breaks;
- capture-site ground auras kept behind entities and labels.

These are Phaser graphics primitives only. No runtime assets or generated art were added.

## Fog Direction

Fog-of-war simulation is unchanged. v0.95 only adjusts cell presentation:

- unseen fog is still darker than explored fog;
- explored fog is softer and less opaque;
- cell corners and strokes are reduced to avoid visible checkerboard seams;
- minimap fog uses the same color family but lighter opacity for legibility.

## Deferred

- Authored terrain tiles.
- Fog shaders, noise textures, and post-processing.
- Final roads, water, cliffs, props, vegetation, ruins, and biome palettes.
- Persistent user fog-style settings.

