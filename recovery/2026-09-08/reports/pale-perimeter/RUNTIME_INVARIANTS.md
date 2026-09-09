# Runtime invariants

- `COLLISION_CHANGED=false`
- `NAVIGATION_CHANGED=false`
- `CAMERA_BOUNDS_CHANGED=false`
- `SPAWN_LOGIC_CHANGED=false`
- `BUILDING_POSITIONS_CHANGED=false`
- `RESOURCE_POSITIONS_CHANGED=false`
- `TERRAIN_CHANGED=false`
- `ROAD_PATH_LANGUAGE_CHANGED=false`
- `VEGETATION_CHANGED=false`
- `ASTRA_COMPOSITION_CHANGED=false`
- `MINIMAP_CHANGED=false`
- `FOG_CHANGED=false`
- `UNIT_ART_CHANGED=false`

The selected experiment removed a presentation-only composition entry. The
wall asset remains in the project, and the separate outer wall remains in the
composition. Both the baseline and candidate manifests report 1920x1080,
Godot 4.6.3, pitch -55, zoom 40, and a successful rendered frame.
