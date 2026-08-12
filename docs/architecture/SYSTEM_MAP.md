# System map

```text
src/game/data + types
        ↓
campaign / rules / save / progression
        ↓
battle runtime → entities / AI / pathfinding / combat / economy
        ↓
presentation → HUD / selection / minimap / alerts / command feedback
        ↓
Phaser/Vite browser runtime

production/ascendant-realms-godot
        ↓
opt-in scenes, art/visual qualification, capture and validation tools
```

## Important areas

| Area | Location | Contract |
| --- | --- | --- |
| Battle orchestration | `src/game/battle` | state, objectives, pressure, results |
| Entities | `src/game/entities` | unit/building/hero identity and commands |
| Navigation | `src/game/pathfinding` | walkability and path requests |
| AI | `src/game/ai` | strategic pressure and enemy behavior |
| UI | `src/game/ui` | selected cards, HUD, minimap, alerts, feedback |
| Save | `src/game/save` | persistence and stable-ID compatibility |
| Art metadata | `src/game/art`, `src/game/assets` | provenance and runtime-slot policy |
| Godot lane | `production/ascendant-realms-godot`, `tools/godot` | opt-in visual/qualification work |

The browser runtime remains the behavior baseline unless a future decision explicitly changes that contract.
