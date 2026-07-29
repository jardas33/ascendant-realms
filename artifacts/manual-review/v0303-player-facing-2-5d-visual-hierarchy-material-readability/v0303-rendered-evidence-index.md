# v0.303 Rendered Evidence Index

The committed numbered proof cards remain contract/index evidence. The files below are genuine non-headless Godot viewport captures, not title cards. PLAYER v0.303 frames have mean RGB approximately `(67.4, 76.2, 49.5)`; DEBUG_REVIEW frames have mean RGB approximately `(71.3, 80.0, 52.7)`. The v0.302 baseline frames have mean RGB approximately `(68.5, 77.3, 50.3)`.

Implementation change for every row: **no**. This clarification adds evidence only.

| Claim | Actual rendered screenshot filename | Mode | What is visibly demonstrated |
|---|---|---|---|
| PLAYER final overview | `rendered-player-v0303/02_v0303_player_overview.png` | PLAYER | Full Salto battlefield, oblique orthographic framing, river, bridge, roads, buildings, units, HUD, and minimap. |
| Before/after PLAYER comparison | `rendered-player-v0302-baseline/02_v0302_player_overview.png` → `rendered-player-v0303/02_v0303_player_overview.png` | PLAYER | Same opt-in fixture before and after the v0.303 material hierarchy pass. |
| Grass versus road separation | `rendered-player-v0303/04_v0303_player_grass_road.png` and `rendered-player-details/terrain_bridge_detail.png` | PLAYER | Muted grass base versus deliberate earth road surfaces. |
| Road versus bridge separation | `rendered-player-v0303/05_v0303_player_road_bridge.png` and `rendered-player-details/terrain_bridge_detail.png` | PLAYER | Continuous roads meet a warmer, raised bridge deck and landings. |
| River versus land separation | `rendered-player-v0303/06_v0303_player_river_land.png` and `rendered-player-details/terrain_bridge_detail.png` | PLAYER | Cool vertical water channel remains distinct from green/brown land. |
| Bridge surface readability | `rendered-player-v0303/07_v0303_player_bridge_surface.png` | PLAYER | Bridge deck, landings, and support silhouette are readable across the river. |
| Building-pad separation | `rendered-player-v0303/08_v0303_player_building_pads.png` | PLAYER | Occupied-ground pads separate structures from the base terrain. |
| Main Hall roof/side/base hierarchy | `rendered-player-v0303/09_v0303_player_main_hall_material.png` and `rendered-player-details/building_detail.png` | PLAYER | Main Hall reads as a structure with roof, side mass, and grounded base. |
| Field Barracks roof/side/base hierarchy | `rendered-player-v0303/10_v0303_player_field_barracks_material.png` and `rendered-player-details/barracks_detail.png` | PLAYER | Barracks volume and warmer roof treatment remain identifiable. |
| Smaller-building hierarchy | `rendered-player-v0303/11_v0303_player_smaller_buildings.png` | PLAYER | Secondary structures remain quieter than the main building roster. |
| Building roof/side/base volume | `rendered-player-v0303/12_v0303_player_building_volume.png` and `rendered-player-details/building_detail.png` | PLAYER | Shared volume language is visible across the building group. |
| Aster terrain separation | `rendered-player-v0303/13_v0303_player_aster_separation.png` and `rendered-player-details/unit_grounding_detail.png` | PLAYER | Aster silhouette and grounding treatment separate her from the road/terrain. |
| Defender terrain separation | `rendered-player-v0303/14_v0303_player_defender_separation.png` | PLAYER | Defender remains readable against the terrain and structure field. |
| Reserve Support terrain separation | `rendered-player-v0303/15_v0303_player_reserve_separation.png` | PLAYER | Reserve Support remains visible without a dominant halo. |
| Unit silhouettes | `rendered-player-v0303/16_v0303_player_unit_silhouettes.png` | PLAYER | Unit silhouettes remain distinct at overview scale. |
| Unit grounding and shadows | `rendered-player-v0303/17_v0303_player_unit_shadows.png` and `rendered-player-details/unit_grounding_detail.png` | PLAYER | Contact shadows ground units without dark gameplay-zone blobs. |
| Building shadow consistency | `rendered-player-v0303/18_v0303_player_building_shadows.png` and `rendered-player-details/building_detail.png` | PLAYER | Building shadows follow the same restrained value direction. |
| Aster selection treatment | `rendered-player-v0303/19_v0303_player_selection_aster.png` | PLAYER | Aster selection remains obvious and restrained. |
| Defender selection treatment | `rendered-player-v0303/20_v0303_player_selection_defender.png` | PLAYER | Defender selection remains readable in the same visual language. |
| Reserve Support selection treatment | `rendered-player-v0303/21_v0303_player_selection_reserve.png` | PLAYER | Reserve Support selection remains visible without obscuring the unit. |
| Field Barracks selection treatment | `rendered-player-v0303/22_v0303_player_selection_barracks.png` | PLAYER | Barracks selection aligns with the structure footprint and HUD. |
| DEBUG_REVIEW proof labels | `rendered-debug-v0303/01_v0303_debug_proof_labels.png` | DEBUG_REVIEW | Accepted proof labels remain visible in the review presentation. |
| DEBUG_REVIEW route/support/integration/pressure evidence | `rendered-debug-v0303/02_v0303_debug_route_segments.png`, `03_v0303_debug_support_presence.png`, `04_v0303_debug_integration_visual.png`, `05_v0303_debug_pressure_evidence.png` | DEBUG_REVIEW | The retained five-segment route, support presence, integration visual, and pressure evidence remain separately visible. |

## Capture provenance

- v0.303 PLAYER source: `artifacts/desktop-spikes/godot-salto/v0303/player-facing-2-5d-visual-hierarchy-material-readability/real-player/screenshots/`
- v0.303 DEBUG_REVIEW source: `artifacts/desktop-spikes/godot-salto/v0303/player-facing-2-5d-visual-hierarchy-material-readability/real-debug/screenshots/`
- v0.302 PLAYER baseline source: `artifacts/desktop-spikes/godot-salto/v0302/player-facing-2-5d-depth-foundation/real-player-current/screenshots/`
- Capture path: non-headless Godot Windows renderer with the existing opt-in PLAYER or DEBUG_REVIEW flag.
- Runtime implementation, gameplay semantics, state, positions, pressure, resources, and true-default behavior were not changed.
