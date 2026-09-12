class_name WorldBlockerContract
extends RefCounted
## Shared collision-layer semantics for ground-unit world blocking.
## Keep the bit ownership in one place so movement and world owners cannot drift.

const GROUND_LAYER := 1
const UNIT_LAYER := 2
const BUILDING_BLOCKER_LAYER := 4
const RESOURCE_BLOCKER_LAYER := 8
const WORLD_BLOCKER_LAYER := 32

const NAVIGATION_LAYER := 1
const UNIT_WORLD_COLLISION_MASK := BUILDING_BLOCKER_LAYER | RESOURCE_BLOCKER_LAYER | WORLD_BLOCKER_LAYER

static func unit_world_collision_mask() -> int:
	return UNIT_WORLD_COLLISION_MASK
