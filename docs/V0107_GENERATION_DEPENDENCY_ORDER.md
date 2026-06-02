# v0.107 Generation Dependency Order

Status: deterministic order only. This document does not authorize image generation by itself.

## Reference Frames First

| Order | Asset | Reason |
| --- | --- | --- |
| 1 | `v0107_salto_environment_style_frame` | Anchors Salto highland mood, material language, road/ford/quarry/shrine/ruin context, and negative space. |
| 2 | `v0107_battlefield_style_frame` | Converts the mood into playable battlefield readability. |
| 3 | `v0107_hud_frame` | Establishes compact desktop UI frame language. |
| 3b | `v0107_results_frame` | Required Results coverage, paired with the HUD frame rather than a separate UI-kit approval. |
| 4 | `v0107_lume_style_frame` | Defines one restrained Lume link after battlefield readability is known. |
| 5 | `v0107_campaign_map_style_frame` | Frames Salto mission launch and return context after environment and HUD direction are known. |

## Barrosan Readability Second

| Order | Asset | Reason |
| --- | --- | --- |
| 6 | `v0107_barrosan_worker_concept` | Worker readability is the first unit proof because tools and utility posture set Barrosan scale. |
| 7 | `v0107_barrosan_militia_concept` | Frontline silhouette contrasts against Worker. |
| 8 | `v0107_barrosan_ranger_concept` | Ranged silhouette contrasts against Worker and Militia. |
| 9 | `v0107_barrosan_hero_concept` | Hero scale is reviewed only after ordinary unit silhouettes are grounded. |

## Buildings Third

| Order | Asset | Reason |
| --- | --- | --- |
| 10 | `v0107_barrosan_command_hall` | Establishes the main Barrosan building mass. |
| 11 | `v0107_barrosan_barracks` | Must contrast Command Hall as a practical mustering space. |
| 12 | `v0107_barrosan_mine` | Adds resource infrastructure and quarry language. |
| 13 | `v0107_barrosan_shrine` | Adds local ancient shrine language after Lume and Command Hall references exist. |

## Contrast Fourth

| Order | Asset | Reason |
| --- | --- | --- |
| 14 | `v0107_ashen_enemy_contrast_sheet` | Ashen silhouettes are reviewed against the grounded Barrosan unit set. |

## Integration Only After Review

| Order | Milestone | Rule |
| --- | --- | --- |
| 15 | runtime candidates chosen | Human review may choose candidates, but this still does not approve runtime loading. |
| 16 | separate runtime integration milestone | Only a future explicit checkpoint may crop, process, validate, and wire runtime art. |

## Determinism

`npm run art:packet:salto-slice` exports this order into `artifacts/art-review/salto-slice-packet/generation-order.md` and tests reject order drift or dependency cycles.
