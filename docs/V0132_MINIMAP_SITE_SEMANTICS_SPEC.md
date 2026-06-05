# v0.132 Minimap Site Semantics Spec

Status: `IMPLEMENTED`

## Markers

| Marker | Meaning |
| --- | --- |
| `minimap_objective_marker` | Current objective vicinity. |
| `minimap_west_stone_cut_mine_target` | `West Stone Cut Mine` as the canonical objective target. |
| `minimap_west_stone_cut_mine_control` | Controlled-state cue for the mine. |
| `minimap_hero_marker` | Aster. |
| `minimap_friendly_cluster` | Friendly staging area. |
| `minimap_shrine` | Shrine/Lume later objective. |
| `minimap_camera_viewport_indicator` | Current camera footprint. |

## Rule

The minimap should reinforce that `West Stone Cut Mine` is the target. It must not require the player to reconcile separate quarry and mine objectives during the same path.
