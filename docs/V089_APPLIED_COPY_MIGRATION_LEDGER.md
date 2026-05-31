# v0.89 Applied Copy Migration Ledger

Checkpoint: v0.89 Controlled Display-Copy Migration Batch A

## Source Approval

- Direction lock source: `docs/V079_EMMANUEL_APPROVAL_LEDGER.md`.
- Runtime string source: `docs/V080_RUNTIME_FACING_STRING_INVENTORY.json`.
- Migration map source: `docs/V080_DISPLAY_COPY_MIGRATION_MAP.md`.
- Batch discipline source: `docs/V080_SAFE_COPY_BATCHES.md`.

## Applied Visible Copy

| Old visible copy | New visible copy | Applied where | Stable IDs preserved |
| --- | --- | --- | --- |
| The Free Marches | Barrosan Freeholds | faction display, reputation reward copy, item flavor, main-menu emblem alt text, campaign choice/event copy, visual manifest display families | `free_marches` |
| Border Marches | The Barrosan Marches | Chapter 1 title, campaign shell header, rival result consequence, chapel/regional stewardship copy | `border_marches`, all node IDs |
| Border Village | Salto Outskirts | first campaign node display name, first-battle onboarding/results copy, lock reasons, e2e/visual-test expectations | `border_village` |
| Sylvan Concord | Rootbound Concord | faction display and manual-reference emblem display copy | `sylvan_concord` |
| Aether Surge | Lume Surge | campaign modifier display name, battlefield event display name/short label, battle floating message, Act 1 pacing copy | `mission_aether_surge`, `aether_surge` |

## Explicitly Preserved

- Runtime/internal title remains `Ascendant Realms`.
- Save version remains `CURRENT_SAVE_VERSION = 2`.
- Resource display `Aether` remains unchanged.
- Hero tactical resource `Mana` remains unchanged.
- `Aether Well Ruins`, `Aether Lens`, `Aether Flow`, `Aether-Touched`, Aether site names, and Aether resource rewards remain unchanged.
- Stable IDs, serialized IDs, map IDs, node IDs, site IDs, class IDs, unit IDs, building IDs, item/relic IDs, save fields, and package folder naming remain unchanged.

## Runtime Files Touched

- `src/game/data/factions.ts`
- `src/game/data/campaignChapters.ts`
- `src/game/data/borderMarchesNodes.ts`
- `src/game/data/cinderfenRoadNodes.ts`
- `src/game/data/campaignModifiers.ts`
- `src/game/data/battlefieldEvents.ts`
- `src/game/data/act1CampaignSpine.ts`
- `src/game/data/items.ts`
- `src/game/data/rivalRewards.ts`
- `src/game/assets/visualAssetManifest.ts`
- `src/game/core/FirstExperienceGuidance.ts`
- `src/game/core/RivalRules.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/scenes/CampaignMapScene.ts`
- `src/game/scenes/HeroCreationScene.ts`
- `src/game/scenes/MainMenuScene.ts`

## Test/Package Files Touched

- Content validation now asserts approved display-copy changes and protected IDs.
- Existing unit and e2e expectations now use Salto Outskirts, Barrosan Freeholds, The Barrosan Marches, and Lume Surge where applicable.
- Playtest package metadata and package verification now include the v0.89 closeout documents.
