# v0.107 Asset Dimension Contracts

Status: planning-only dimension and runtime-slot contract. No candidate files or runtime asset paths are approved.

## Contract Rules

Every planned asset must define:

- asset ID;
- v0.105/v0.88 registry mapping;
- known v0.106 runtime slot IDs;
- category;
- source concept format;
- future runtime candidate format posture;
- canvas size and aspect ratio;
- camera rule;
- transparency requirement;
- pivot posture;
- safe crop;
- silhouette rule;
- RTS-scale thumbnail size;
- maximum visual noise;
- animation posture;
- mip/downscale posture;
- fallback behavior;
- visual QA scenario;
- human approval questions.

The machine-readable source is `docs/V0107_SALTO_VERTICAL_SLICE_MANIFEST.json`.

## Asset Table

| Asset ID | Registry mapping | Runtime slots | Canvas | Camera |
| --- | --- | --- | --- | --- |
| `v0107_salto_environment_style_frame` | `v088_salto_environment_style_frame` | terrain ground/road/water/ford/quarry/shrine/ruin | 1920x1080, 16:9 | high three-quarter RTS environment |
| `v0107_battlefield_style_frame` | `v088_battlefield_style_frame` | terrain, fog, capture, objective, minimap markers | 1920x1080, 16:9 | high three-quarter RTS battlefield |
| `v0107_hud_frame` | `v088_hud_frame_style_frame` | HUD, command panel, minimap frame | 1920x1080, 16:9 | flat orthographic UI board |
| `v0107_results_frame` | `v088_hud_frame_style_frame` | Results frame | 1920x1080, 16:9 | flat debrief board |
| `v0107_lume_style_frame` | `v088_lume_link_style_frame` | Lume endpoint/link/transition | 1920x1080, 16:9 | high three-quarter one-link view |
| `v0107_campaign_map_style_frame` | `v088_salto_environment_style_frame`, `v088_hud_frame_style_frame` | campaign background/route/chapter/node frames | 1920x1080, 16:9 | flat campaign-shell composition |
| `v0107_barrosan_worker_concept` | `v088_barrosan_worker_concept_sheet` | Barrosan Worker | 1600x1200, 4:3 | orthographic-feeling concept sheet |
| `v0107_barrosan_militia_concept` | `v088_barrosan_militia_concept_sheet` | Barrosan Militia | 1600x1200, 4:3 | orthographic-feeling concept sheet |
| `v0107_barrosan_ranger_concept` | `v088_barrosan_ranger_concept_sheet` | Barrosan Ranger | 1600x1200, 4:3 | orthographic-feeling concept sheet |
| `v0107_barrosan_hero_concept` | `v088_barrosan_hero_concept_sheet` | Barrosan Hero, hero frame | 1600x1200, 4:3 | grounded commander concept sheet |
| `v0107_barrosan_command_hall` | `v088_barrosan_command_hall_concept_sheet` | Command Hall, stronghold frame | 1600x1200, 4:3 | isometric-friendly building sheet |
| `v0107_barrosan_barracks` | `v088_barrosan_barracks_concept_sheet` | Barracks | 1600x1200, 4:3 | isometric-friendly building sheet |
| `v0107_barrosan_mine` | `v088_barrosan_mine_concept_sheet` | Mine, quarry terrain | 1600x1200, 4:3 | building/resource sheet |
| `v0107_barrosan_shrine` | `v088_barrosan_shrine_concept_sheet` | Shrine, shrine terrain | 1600x1200, 4:3 | building/shrine sheet |
| `v0107_ashen_enemy_contrast_sheet` | `v088_ashen_enemy_concept_sheet` | Ashen Raider/Brute/Hexer/Commander | 1600x1200, 4:3 | orthographic-feeling contrast sheet |

## Thumbnail And Crop Requirements

- Style frames must read at 320x180 contact-sheet scale.
- Units must read at 64x64, except the hero also gets a 96x96 review.
- Buildings and resource landmarks must read at 96x96.
- Concept sheets may use a neutral sheet background, but any future runtime crop must use transparent-background posture and a separately approved runtime integration gate.
- Safe crops must preserve role-defining silhouettes: Worker tools, Militia shield/weapon, Ranger ranged line, hero cloak/oath motif, Command Hall roof/entrance, Barracks mustering shape, mine mouth/supports, shrine stones/accent, Ashen contrast silhouettes.

## Fallback Requirements

Every asset keeps a current fallback owner:

- Terrain/resource/road/ford/ruin: `BattleSceneMapRenderer`, `CaptureSite`.
- Unit/building silhouettes: `PlaceholderBattlefieldPresentation`, `Unit`, `Building`.
- Lume: `LumeNetworkRendering`.
- HUD/Results/campaign: current CSS/DOM renderers and view models.

Missing art must never block runtime.
