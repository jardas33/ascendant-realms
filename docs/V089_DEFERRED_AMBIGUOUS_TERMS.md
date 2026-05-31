# v0.89 Deferred Ambiguous Terms

Checkpoint: v0.89 Controlled Display-Copy Migration Batch A

This checkpoint deliberately avoided ambiguous migrations. These terms remain for a later reviewed batch.

## Deferred Aether Terms

- `Aether` resource display name and resource key.
- `aether` save/resource key.
- `Aether Well Ruins` mission title.
- `Aether Well`, `North Aether Spring`, and other capture-site names.
- `Aether Lens`, `Cinder-Seer Lens`, and item lore that describes aether lenses.
- `Aether Flow`, `Aether-Touched`, `Aether Study I`, and other class/upgrade/item-affix terms.
- Cinderfen first-capture copy such as "one-time Aether surge"; this describes a resource reward, not the approved `Aether Surge` modifier/event label.

Reason: v0.80 marks Aether as taxonomy-sensitive. Batch A only approved the exact `Aether Surge` visible label where it overlaps with Lume opportunity/mana pacing.

## Deferred Marcher Terms

- `Marcher Camp`
- `Marcher Plate`
- `Marcher Contracts`
- historical references to "Marcher" as local camp/service identity

Reason: v0.89 approved Free Marches and Border Marches framing, but not every local "Marcher" noun. These may be Barrosan, Marcher, or another local label later.

## Deferred Class/Title Terms

- `Warlord`
- `Arcanist`
- `Shepherd`
- runtime title `Ascendant Realms`
- public title `JARDAS`

Reason: class-display migration and public title migration remain explicitly deferred.

## Deferred Asset/File Terms

- Prototype file paths such as `Free Marches Emblem.png`.
- Prototype file paths such as `Sylvan Concord Emblem.png`.
- Manual asset-pipeline prompt/source strings under `tools/manual-asset-pipeline/` that still describe prototype Free Marches and Sylvan Concord art direction.
- historical docs, old telemetry reports, and generated archive evidence that record previous checkpoint names.

Reason: this milestone must not rename files, imported assets, repository folders, historical evidence, or future-art prompt/source material outside the approved runtime-facing copy inventory. Only current player-facing runtime copy changed.

## Deferred Runtime IDs

All stable IDs remain unchanged, including `free_marches`, `sylvan_concord`, `border_marches`, `border_village`, `mission_aether_surge`, `aether_surge`, `aether_lens`, `maxMana`, map IDs, node IDs, site IDs, class IDs, unit IDs, building IDs, relic IDs, save fields, and `CURRENT_SAVE_VERSION`.
