extends Resource
## The convex collision hulls of the building models, worked out once and
## shipped with the game (assets/cache/building_hulls.res). Working them out
## from the meshes took about three and a half seconds at the start of the
## first match of a session. Each entry carries a stamp of the mesh it was
## made from; a mesh that has changed since simply gets a fresh hull, so a
## stale file costs time, never correctness. Rebake with
## tests/bake_building_hulls.gd after changing a building model.
@export var entries: Dictionary = {}
