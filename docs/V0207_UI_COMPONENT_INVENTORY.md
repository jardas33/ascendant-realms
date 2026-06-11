# v0.207 Salto UI Component Inventory

## Global Shell

| Component | Purpose | Future Implementation Notes |
| --- | --- | --- |
| Salto HUD root | Isolated opt-in battle HUD container | Must be created only by the review launcher until explicitly promoted. |
| UI theme | Shared colors, StyleBoxFlat frames, button states | Keep procedural and code-authored. Do not import reference UI assets. |
| Material trim | Iron/bronze divider and panel border language | Use Godot StyleBoxFlat and small procedural SVG icons first. |

## Information Regions

| Component | Required States | Notes |
| --- | --- | --- |
| Resource ledger | Crowns, Stone, Iron, Aether, population, capped/low states | Compact top-center row, not a floating debug label. |
| Objective panel | Mine conversion, Worker assignment, Barracks restoration, Militia training, Ashen defense, Lume restore | Left-side stack with a clear primary objective. |
| Event log | Progress feedback, warnings, completed steps | Keep short and scannable; no verbose tutorial paragraphs in battle. |
| Alert rail | Ashen pressure, hostile sighting, invalid command | Ember accent only when tactically meaningful. |

## Tactical Regions

| Component | Required States | Notes |
| --- | --- | --- |
| Minimap | Terrain, roads, river, bridge, camera, friendly, hostile, objective | Bottom-left anchor; should correlate with shell-v2 topology. |
| Selection panel | Aster, Worker, Barracks restoring/restored, Militia, Ashen target | Bottom-center, with portrait/identity area and stats. |
| Command panel | Move, attack, work, restore, train, research, disabled states | Bottom-right grouped tabs; commands must show clear availability. |
| Tooltip lane | Hovered command, disabled reason, selected-object hint | Above bottom panels, compact and non-overlapping. |

## Validation Expectations

- Every component has a deterministic visual state in the v0.208 comparator.
- Live bindings in v0.209+ must fail closed to the prior procedural HUD if optional style assets are missing or invalid.
- Default procedural launcher and all prior launchers remain unchanged.
