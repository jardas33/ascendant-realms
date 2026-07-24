# v0.379 design notes

The design directly targets the defects visible in v0.378:

- **Flat uniform land:** replaced by one triangulated continuous terrain with hills, shelves, depressions and smooth deterministic micro-relief.
- **Road ribbon:** the road is encoded into the terrain height and vertex colours. There is no separate broad brown road plane in the GLB.
- **Clean graphic river edges:** the river valley is carved into the terrain with a dark wet-bank transition and water below the land.
- **Weak bridge hierarchy:** the bridge uses individual planks, under-beams, granite abutments, edge courses, restrained posts and two rail courses.
- **Even showroom scatter:** rocks, reeds and shrubs are clustered, with clear exclusions around the road core and bridge crossing.
- **Checkerboard or striping:** no checkerboard material system is used.

The included PNGs are schematics generated from the same source data. They are not substitutes for actual Godot captures.
