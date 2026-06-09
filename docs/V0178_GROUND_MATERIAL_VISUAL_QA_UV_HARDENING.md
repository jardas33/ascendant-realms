# v0.178 Ground Material Visual QA And UV Hardening

Status: `PASS_V0178_GROUND_MATERIAL_VISUAL_QA_UV_HARDENING`

v0.178 hardens only the existing Barrosan foothold ground-material opt-in path. It generates zero images, adds zero slots, keeps the selected v0.175 source and hash unchanged, and leaves the default launcher procedural.

## Selected Material

- Slot: `barrosan_foothold_ground_material_v0175`
- Approach: `GROUND_MATERIAL_LOCAL_1024`
- File: `artifacts/desktop-spikes/godot-salto/v0175/local-ground-material-slot/barrosan_foothold_ground_material_v0175_1024.png`
- SHA-256: `818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8`
- Source dimensions: `1024x1024`
- Previous player-slice UV scale: `0.72`
- Hardened player-slice UV scale: `0.56`
- Noise-control alpha: `0.48`
- Filter: linear with mipmaps

## Visual Repair

v0.177 proved integration but the selected material read as dark and high-frequency at review scale. v0.178 keeps the same one opt-in environment-material slot and applies only bounded presentation hardening:

- Reduced UV repetition from `0.72` to `0.56`.
- Reduced texture overlay opacity to `0.48`.
- Added a procedural value underlay beneath the texture overlay so the low-frequency terrain field remains legible.
- Preserved mipmapped linear filtering.
- Preserved the same two authorized foothold ground surfaces:
  - `v0173_terrain_mid_value_field`
  - `v0173_friendly_staging_value_field`

The material still reads as a textured terrain treatment rather than final environment art, but it no longer dominates the road, river, bridge, selection-ring, character, HUD, or minimap hierarchy.

## Windows-Side Review

Computer Use review covered the packaged v0.178 Godot window:

- Title screen: texture visible behind the overlay without swallowing the bridge or river.
- Briefing: terrain hierarchy remains readable beneath modal copy.
- Battle view: Aster, Worker pair, selection ring, roads, river, bridge, Barracks material, and minimap remain readable.
- Pan/zoom smoke: no new unacceptable shimmer or broad-map repetition was observed during the quick live review.

Capture evidence:

- `artifacts/desktop-spikes/godot-salto/v0178/capture/e1-ground-material-opt-in/screenshots/03_ground_material_normal_rts.png`
- `artifacts/desktop-spikes/godot-salto/v0178/capture/e1-ground-material-opt-in/screenshots/04_ground_material_close.png`
- `artifacts/desktop-spikes/godot-salto/v0178/capture/e1-ground-material-opt-in/screenshots/05_road_river_bridge_hierarchy.png`
- `artifacts/desktop-spikes/godot-salto/v0178/capture/e1-ground-material-opt-in/screenshots/08_combat_onset.png`
- `artifacts/desktop-spikes/godot-salto/v0178/capture/e1-ground-material-opt-in/screenshots/11_camera_max_zoom.png`

## Result

The v0.178 posture passes the bounded visual gate. Roads, river, bridge, units, rings, Barracks material, HUD, and minimap remain distinct. The default procedural launcher remains unchanged, browser runtime remains untouched, and character-slot integration remains frozen at five.
