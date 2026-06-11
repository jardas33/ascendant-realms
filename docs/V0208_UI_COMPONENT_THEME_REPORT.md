# v0.208 UI Component Theme Report

## Theme Materials

| Theme Surface | Implementation |
| --- | --- |
| Charcoal panel body | Code-authored `StyleBoxFlat` with dark opaque fill. |
| Wet-stone trim | Muted teal and gray-green borders for tactical UI. |
| Weathered bronze trim | Warm low-saturation borders for resource, build, and queue states. |
| Hostile pressure | Reserved ember red for Ashen alert and hostile minimap markers. |
| Disabled state | Lower-contrast borders and gray rail, never hidden text. |
| Queued state | Bronze rail with warm border and explicit queue copy. |

## Component Coverage

| Component | v0.208 Comparator Coverage |
| --- | --- |
| Resource strip | Crowns, Stone, Iron, Aether, population chips. |
| Objectives | Primary objective and progression detail. |
| Event log | Short recent-event stack. |
| Minimap | Terrain, road, river, bridge, camera, objective, friendly, hostile markers. |
| Selection panel | Portrait block, health bar, command buttons, status pip. |
| Production panel | Build, Train, Research tabs and card grid. |
| Alerts | Right-side alert card with info and hostile severity. |
| Tooltip | Compact tactical hint above the lower command band. |

## Originality Notes

The comparator does not import or trace the reference UI. It uses original Barrosan tactical material language and code-authored Godot controls. Icons are geometric procedural marks rather than copied glyphs.
