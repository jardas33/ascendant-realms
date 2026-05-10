# v0.8.1 Existing Asset Inventory Audit

Date: 2026-05-10  
Scope: current asset folders, current runtime asset manifest, source references, and visual-asset usage before adding the v0.8.1 visual metadata gate.

## Purpose

This audit records what Ascendant Realms currently has before any new visual asset manifest or screenshot QA workflow is added. It is intentionally inventory-only.

No assets were moved, deleted, renamed, generated, downloaded, replaced, or added. No gameplay, maps, units, factions, rewards, save data, campaign progression, renderer behavior, enemy pressure behavior, desktop packaging, engine switching, or graphics overhaul work is included.

## Evidence Inspected

- `public/assets/`
- `public/assets/final/`
- `public/assets/manual/`
- `public/assets/manifests/assetManifest.json`
- `public/assets/README.md`
- `tools/manual-asset-pipeline/*`
- `src/game/assets/AssetKeys.ts`
- `src/game/assets/AssetLoader.ts`
- `src/game/assets/AssetManifestTypes.ts`
- `src/game/scenes/BootScene.ts`
- `src/game/scenes/AssetGalleryScene.ts`
- `src/game/entities/Unit.ts`
- `src/game/entities/Building.ts`
- `src/game/entities/CaptureSite.ts`
- `src/game/ui/hudPanels/HeroHudPanel.ts`
- `src/game/scenes/*` menu/result/campaign asset references
- `src/game/styles/*.css`
- v0.8 visual foundation docs

Extra check:

```text
npm run assets:validate: PASS
Registry assets: 62
File-backed assets found: 62
Runtime fallback coverage: ok
```

## Asset Folder Structure

Current file counts and approximate sizes:

| Folder | Files | Approx size |
| --- | ---: | ---: |
| `public/assets/` | 1 | 0.00 MB |
| `public/assets/final/buildings/` | 10 | 7.40 MB |
| `public/assets/final/units/` | 15 | 3.90 MB |
| `public/assets/manifests/` | 1 | 0.03 MB |
| `public/assets/manual/` | 2 | 0.57 MB |
| `public/assets/manual/buildings/` | 10 | 18.87 MB |
| `public/assets/manual/icons/` | 16 | 24.11 MB |
| `public/assets/manual/portraits/` | 4 | 8.35 MB |
| `public/assets/manual/splash/` | 1 | 2.06 MB |
| `public/assets/manual/ui/` | 16 | 8.27 MB |
| `public/assets/manual/units/` | 15 | 21.55 MB |

Notes:

- `public/assets/runtime/` is not present.
- `public/assets/placeholders/` is not present.
- The runtime can fall back to Phaser shapes and CSS when an image is missing, but all current registry entries are file-backed.
- The manual folders are much larger than the final folders because they preserve larger source/reference images.

## Manifest Summary

`public/assets/manifests/assetManifest.json` currently has 62 entries:

| Category | Count |
| --- | ---: |
| `portrait` | 4 |
| `ui` | 4 |
| `ability_icon` | 9 |
| `faction_emblem` | 3 |
| `splash` | 1 |
| `resource_icon` | 4 |
| `ui_kit` | 12 |
| `unit_concept` | 3 |
| `building_concept` | 4 |
| `unit_sprite` | 12 |
| `building_sprite` | 6 |

By manifest source:

| Source | Count |
| --- | ---: |
| `manual` | 37 |
| `final` | 25 |

The current manifest is a runtime availability manifest. It records path, category, display name, source folder, required flag, preferred dimensions, and load priority. It does not yet record production status, license status, source provenance, replacement priority, silhouette readability, style consistency, or screenshot QA linkage.

## Asset Categories Found

### Units

Runtime/final unit sprites exist for:

- Warlord hero battle sprite.
- Arcanist hero battle sprite.
- Shepherd hero battle sprite.
- Militia.
- Ranger.
- Acolyte.
- Raider.
- Hexer.
- Brute.
- Enemy commander.
- Wild hound.
- Stone imp.

Concept/reference entries exist for:

- Militia concept.
- Ranger concept.
- Acolyte concept.

Manual source duplicates exist for the same battle sprites and concepts. These are not currently selected by the runtime manifest when a corresponding `final` processed sprite exists.

### Heroes

Hero visuals are split between:

- Manual portraits for Warlord, Arcanist, and Shepherd.
- Final battle sprites for Warlord, Arcanist, and Shepherd.

Runtime usage:

- Hero portraits are used in hero creation, campaign map, skirmish setup, hero progression, and selected hero HUD.
- Hero battle sprites are preloaded by `BootScene` and used by `Unit`/`Hero` rendering through `unitBattleAssetIds`.

### Buildings

Runtime/final building sprites exist for:

- Command Hall.
- Barracks.
- Mystic Lodge.
- Watchtower.
- Enemy Stronghold.
- Enemy Barracks.

Concept/reference entries exist for:

- Command Hall concept.
- Barracks concept.
- Mystic Lodge concept.
- Watchtower concept.

Manual source duplicates exist for the same building sprites and concepts. These should be treated as source/reference material until the new metadata manifest can classify them explicitly.

### Terrain And Backgrounds

There are no runtime terrain tiles, terrain materials, map-background images, road tiles, water tiles, fog textures, or Cinderfen terrain art assets.

Current battle maps are still rendered procedurally with Phaser graphics. Roads, water/swamp, blockers, boundaries, capture-site grounds, and map dressing are not file-backed assets.

Menu/result backgrounds exist as manual UI assets:

- Main Menu Background.
- Victory Screen Background.
- Defeat Screen Background.

The key art splash image exists under `public/assets/manual/splash/`, but it is not used by current runtime screens.

### Capture Sites And Icons

Capture sites currently use:

- Procedural capture-site rings and ground marks.
- Resource icons from the manifest for Crowns, Stone, Iron, and Aether.
- Labels and ownership/tint feedback.

There is no dedicated Cinder Shrine landmark art yet. `crown_shrine_icon` is used as a resource/capture-site icon, not as a full environmental shrine asset.

### UI

Runtime/manual UI assets exist for:

- Main menu background.
- Battle HUD panel.
- Victory screen background.
- Defeat screen background.
- Panel frame.
- Button idle/hover/pressed frames.
- Resource counter frame.
- Divider ornament.
- Tooltip frame.
- Minimap frame.
- Ability slot frame.
- Inventory slot frame.
- Victory panel frame.
- Defeat panel frame.

`AssetLoader.applyUiKitCssVariables()` maps these to CSS variables when available. CSS falls back to normal styling if a UI-kit asset is missing.

### Portraits

Manual portrait assets exist for:

- Warlord Hero Portrait.
- Arcanist Hero Portrait.
- Shepherd Hero Portrait.
- Enemy Commander Portrait.

Enemy commander portrait is mostly future-facing and result/rival-facing; the enemy commander battle sprite is used in battle.

### Audio

No audio files were found under `public/assets/`. Audio systems exist in code, but this audit found no file-backed music, ambience, UI sounds, combat sounds, or voice assets.

### Manual And Reference Assets

Manual/reference assets include:

- Human-readable source PNGs under `public/assets/manual/`.
- Prompt book files: `public/assets/manual/ASSET_PROMPT_BOOK.md` and `.json`.
- `tools/manual-asset-pipeline/assetRegistry.ts`, which currently acts as the desired asset registry for the manual asset pipeline.

These files are useful, but they do not yet provide the production-grade source/license/status metadata requested for v0.8.1.

## Assets Actually Used By Runtime

Battle preload:

- `BootScene` loads `assetManifest.json`.
- `BootScene` queues only `BATTLE_TEXTURE_ASSET_IDS`.
- That set covers hero portraits, hero battle sprites, resource icons, unit sprites/concepts, and building sprites/concepts.

Entity rendering:

- `Unit` uses `unitBattleAssetIds(unitId)` and falls back through candidates, for example sprite then concept/portrait.
- `Building` uses `buildingBattleAssetIds(buildingId)` and falls back through candidates, for example sprite then concept.
- `CaptureSite` uses `resourceIconAssetId(resourceId)`.

DOM/UI usage:

- Main menu, campaign map, skirmish setup, settings, asset gallery, hero creation, hero progression, and results scenes use `AssetLoader.screenStyle()` for backgrounds.
- Hero panels use `AssetLoader.portraitStyle()`.
- Ability buttons use `AssetLoader.imageHtml()` with `abilityIconAssetId()`.
- Main menu uses the Free Marches emblem.
- UI-kit images are exposed as CSS variables and consumed by CSS border-image rules.

Asset Gallery:

- `AssetGalleryScene` displays every current manifest entry and verifies image load state in the browser.

## Assets Present But Apparently Unused

The audit found 87 image files on disk and 62 manifest entries. The 25 image files not referenced by the current runtime manifest are manual originals for battle sprites and concept art where a processed `final` asset exists:

- 10 manual building/concept files under `public/assets/manual/buildings/`.
- 15 manual unit/concept files under `public/assets/manual/units/`.

These are not accidental junk. They appear to be preserved source/reference files for `assets:process-battle-sprites`, while the runtime manifest prefers `public/assets/final/` outputs.

Additional future-facing manifest assets:

- `ascendant_realms_key_art` is present in the manifest but not currently used by a runtime screen.
- Ashen Covenant and Sylvan Concord emblems are manifest entries with future-facing use; Free Marches is currently used by the main menu.

Do not delete these assets in v0.8.1. They need classification in the visual asset manifest rather than cleanup.

## Assets Referenced By Docs Only

Docs and pipeline files reference future asset categories that do not yet exist as runtime files:

- Terrain tiles/materials.
- Cinderfen road/causeway art.
- Cinder Shrine/capture-site landmark art.
- VFX.
- Audio.
- Portrait variants.
- Future desktop/2.5D/3D assets.

These are planning references, not shipped runtime assets.

## Unclear Source Or Status

The current folder names provide only coarse status:

- `manual` means manually placed source/reference files.
- `final` means processed/preferred runtime files for units/buildings/concepts.

What remains unclear per asset:

- Whether the asset is owned, generated with review needed, licensed, or source-unknown.
- Whether the asset is placeholder, prototype, candidate, or final.
- Whether the asset is safe for production.
- Whether the asset requires legal/source review.
- Whether an asset is meant to be runtime, manual reference, docs reference, unused, or test-only beyond the current manifest's broad usage copy.

Until v0.8.1 metadata exists, no asset should be treated as production-final merely because it lives in `public/assets/final/`.

## Placeholder Assessment

Likely placeholder/prototype areas:

- All procedural terrain, roads, water/swamp, fog visuals, boundaries, and map dressing.
- Capture-site rings and resource-icon landmarks.
- Unit and building sprites, despite being file-backed, because style consistency and source/license metadata are not yet proven.
- UI-kit frames, because they support prototype readability but are not a final UI system.
- Menu and results backgrounds, because they are useful but not yet connected to a complete production art direction.

The safest default for the upcoming manifest is: current visuals are `prototype` or `candidate`, not `final`, unless a future human/legal/art review proves otherwise.

## Assets Closer To Final

The most production-adjacent current assets are:

- `public/assets/final/units/*_sprite.png`
- `public/assets/final/buildings/*_sprite.png`
- Processed `final` concepts for militia/ranger/acolyte and player buildings.
- UI-kit assets that currently improve the prototype surface.

Even these should be marked as review-needed until source/license metadata and visual consistency notes are attached.

## Likely Scale Mismatch Suspects

From the v0.8 scale audit and current runtime usage:

- Hero sprites render around 82.65 px target height, while enemy commander renders around 65.7 px unless treated as a normal unit.
- Common infantry render around 43.8 to 47.45 px; source sprites may still feel cutout-like against procedural terrain.
- Brute and large enemy scale is readable but not yet governed by a full silhouette sheet.
- Building sprites are footprint-scaled and readable, but their source proportions and ground contact are not authored together with terrain.
- Capture-site icons are 42 x 42 inside much larger 74 to 86 world-unit capture rings, making sites icon-led rather than landmark-led.
- UI-kit assets are used at several CSS border-image slice values, so future replacements need slice metadata and screenshot QA.

## Assets That Should Not Be Changed Until Manifest Exists

Do not change these before v0.8.1 metadata/validation is in place:

- `public/assets/manifests/assetManifest.json`
- `tools/manual-asset-pipeline/assetRegistry.ts`
- `public/assets/final/units/*`
- `public/assets/final/buildings/*`
- `public/assets/manual/units/*`
- `public/assets/manual/buildings/*`
- `public/assets/manual/icons/*`
- `public/assets/manual/ui/*`
- `public/assets/manual/portraits/*`
- Menu/result backgrounds.
- Resource icons used by capture sites.
- UI-kit frames mapped through CSS variables.

Reason: these assets are intertwined with runtime fallbacks, CSS variables, the asset gallery, manual source preservation, and current e2e coverage. They need manifest classification first, not ad hoc cleanup.

## Phase 1 Recommendation

Proceed with a new v0.8.1 visual asset manifest schema that sits beside the existing runtime manifest rather than replacing it immediately.

The new manifest should add:

- Source and license status.
- Placeholder/prototype/candidate/final classification.
- Runtime/manual/docs/unused/test usage classification.
- `usedBy` references.
- Scale class and render-height metadata.
- Silhouette readability and style consistency ratings.
- Replacement priority.
- `allowedInProduction` and `needsReview`.
- Future screenshot QA linkage.

Content validation should later verify the metadata without forcing asset moves, deleting manual originals, or turning screenshot QA into brittle pixel testing.
