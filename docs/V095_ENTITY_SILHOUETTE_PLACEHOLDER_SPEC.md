# v0.95 Entity Silhouette Placeholder Spec

## Intent

Placeholder units and buildings should be readable at a glance before final art exists. The pass uses simple Phaser shapes that communicate role, team, and selection without changing entity bounds or combat behavior.

## Unit Silhouettes

- Hero / commander: tall body, banner spine, bright outline.
- Worker: compact utility diamond/box silhouette with tool-like cap.
- Frontline melee: broader shield/body silhouette.
- Ranged / caster: slimmer body with ranged chevron.
- Enemy units: warmer hostile stroke/fill contrast.
- Elite enemy squads: label remains visible and keeps its elite copy.

## Building Silhouettes

- Command Hall / stronghold: larger block with roofline and central cap.
- Barracks: wide martial block with side posts.
- Mystic / shrine-like buildings: taller central pillar and Lume-adjacent teal accent where already thematically valid.
- Watchtower: narrow tower silhouette with high cap.
- Under-construction buildings: existing alpha treatment remains.

## Label Priority

Always visible:

- hero;
- buildings;
- capture sites;
- enemy commander / elite units;
- selected entities;
- burning/statused entities.

Quieter by default:

- ordinary player and enemy combat-unit labels;
- routine neutral camp/body labels outside selection.

No labels are removed from data. Visibility changes are presentation only.

## Deferred Final Art Needs

- Real faction silhouettes.
- Directional animation.
- Faction-specific buildings.
- Final health/status badges.
- Authored selection decals.

