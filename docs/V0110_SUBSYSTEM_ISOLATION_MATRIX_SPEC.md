# v0.110 Subsystem Isolation Matrix Spec

The v0.110 Performance Lab ladder contains 22 private scenarios covering static, density, and subsystem rows.

## Scenarios

| Scenario | Category | Focus | Local only |
| --- | --- | --- | --- |
| v0110_empty_static | static | scene/update, HUD DOM | no |
| v0110_static_hud_minimal | static | HUD DOM, minimap | no |
| v0110_tier_s_density | density | density, movement/pathing | no |
| v0110_tier_m_density | density | density, AI, HUD DOM | no |
| v0110_tier_l_density | density | density scaling, long tasks | yes |
| v0110_simulation_paused | subsystem | simulation ceiling | no |
| v0110_ai_paused | subsystem | AI/strategy | no |
| v0110_path_paused | subsystem | movement/pathing | no |
| v0110_movement_paused | subsystem | movement | no |
| v0110_combat_paused | subsystem | combat | no |
| v0110_projectiles_paused | subsystem | projectiles | no |
| v0110_fog_simulation_paused | subsystem | fog simulation | no |
| v0110_fog_presentation_paused | subsystem | fog presentation | no |
| v0110_entity_graphics_hidden | subsystem | entity graphics | no |
| v0110_labels_hidden | subsystem | labels | no |
| v0110_capture_rings_minimal | subsystem | capture rings | no |
| v0110_lume_hidden | subsystem | Lume presentation | no |
| v0110_minimap_paused | subsystem | minimap | no |
| v0110_hud_dom_paused | subsystem | HUD DOM | no |
| v0110_notifications_suppressed | subsystem | notifications | no |
| v0110_camera_paused | subsystem | camera | no |
| v0110_profiler_overlay_on | subsystem | profiler overlay | no |

## Rules

- Every pause/hidden mode is private, session-only, and diagnostic.
- Paused modes isolate cost ceilings; they are not design decisions or balance changes.
- `linked_ward` remains unchanged at its existing 0.92 damage-taken multiplier.
