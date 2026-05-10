# v0.8.1 Runtime Asset Usage Crosscheck

Date: 2026-05-10  
Scope: cross-check current runtime asset references against the new visual asset manifest.

## Purpose

This phase verifies that the new visual metadata manifest is not just a side document. It now covers the asset ids that the current runtime actually references through battle preload, entity rendering, DOM UI, ability icons, portraits, resource/capture-site icons, and CSS UI-kit variables.

No assets were moved, deleted, renamed, generated, downloaded, or replaced. No gameplay, maps, units, factions, rewards, save data, campaign progression, enemy pressure behavior, renderer behavior, desktop packaging, engine switching, or UI redesign changed.

## Files Inspected

- `src/game/assets/AssetKeys.ts`
- `src/game/assets/AssetLoader.ts`
- `src/game/assets/visualAssetManifest.ts`
- `src/game/data/validation/validateVisualAssets.ts`
- `src/game/scenes/BootScene.ts`
- `src/game/entities/Unit.ts`
- `src/game/entities/Building.ts`
- `src/game/entities/CaptureSite.ts`
- `src/game/ui/hudPanels/HeroHudPanel.ts`
- `src/game/scenes/MainMenuScene.ts`
- `src/game/scenes/*` menu/campaign/results asset references
- `src/game/styles/*.css`
- `public/assets/manifests/assetManifest.json`

## Runtime Asset Reference Sources

The validator now checks current runtime visual asset ids from:

- `BATTLE_TEXTURE_ASSET_IDS`
- All `ASSET_IDS.abilities`
- All keys from `UI_KIT_CSS_VARIABLES`
- `ASSET_IDS.factions.freeMarches`
- Main menu, victory, and defeat background ids

This covers:

- Battle entity textures.
- Hero portraits.
- Capture-site/resource icons.
- Ability icons.
- Main menu emblem.
- UI-kit frames and battle HUD panel.
- Main menu and results backgrounds.

## Validation Added

`src/game/data/validation/validateVisualAssets.ts` now rejects:

- Runtime visual asset ids referenced by code but missing from `VISUAL_ASSET_MANIFEST`.
- Runtime-referenced visual assets whose manifest entry is not marked `usage: "runtime"`.
- Missing runtime file paths when the CLI provides the file-existence callback.

The file-existence callback is provided by `tools/validateContent.ts`, so `npm run validate:content` checks asset files while the browser boot path stays free of Node filesystem imports and free of the visual metadata payload.

Additional test coverage was added to `src/game/data/contentValidation.test.ts`.

## Manifest-Covered Runtime Assets

The visual manifest covers all currently referenced runtime visual assets:

- 33 battle preload ids from `BATTLE_TEXTURE_ASSET_IDS`.
- 9 hero ability icon ids.
- 13 UI-kit/CSS variable ids, including the battle HUD panel.
- 1 runtime faction emblem id: `free_marches_emblem`.
- 3 runtime screen backgrounds: main menu, victory, defeat.

There are no known current runtime visual asset ids missing from the v0.8.1 visual metadata manifest.

## Runtime Assets Not Yet In Manifest

None found for the current explicit runtime references listed above.

Important caveat:

- Procedural battle terrain, roads, water/swamp, fog treatment, capture-site ground rings, and map dressing are not file-backed assets. They are represented by the `procedural_battle_terrain` metadata entry rather than by individual PNG assets.

## Manifest Entries Not Directly Runtime-Selected

The manifest also tracks non-runtime or not-currently-selected entries:

- 25 `manual_source_*` entries for manual unit/building source originals.
- `ascendant_realms_key_art`, which is reference/future-facing and not used by current screens.
- `asset_prompt_book`, a reference metadata document.
- Ashen Covenant and Sylvan Concord emblems as manual-reference identity assets.

These should remain in the manifest because they are important source/reference material or future-facing visual identity material, but they should not be mistaken for current gameplay runtime dependencies.

## Unknown Source Or License Assets

Most file-backed art still has conservative metadata:

- `sourceType: "manual"`
- `licenseStatus: "unknown"`
- `allowedInProduction: false`
- `needsReview: true`

This is intentional. The project does not yet have per-file source/license proof, so the manifest should force future review before any asset is promoted to `final` or production-ready.

## High-Priority Replacement Signals

Current high/critical replacement signals:

- `procedural_battle_terrain`: critical.
- `crown_shrine_icon`: high.
- `enemy_commander_unit_sprite`: high.
- `enemy_stronghold_building_sprite`: high.
- Main menu/results backgrounds: high.

These are review priorities only. No replacement work is authorized by this phase.

## Scale Mismatch Suspects

Known visual scale/readability suspects now represented in metadata:

- Player hero sprites are tracked around 82.65 px current target height.
- Enemy commander is tracked around 65.7 px, which remains a future hero/elite scale mismatch watchpoint.
- Common infantry and ranged/caster units sit around 43.8 to 47.45 px and still lean heavily on labels/bars for identity.
- Brute and Stone Imp scale metadata is present, but their future silhouette standards are not final.
- Buildings have current max sprite heights attached, but source proportions and terrain foundations are still not authored together.
- Resource/capture-site icons are tracked as 42 px assets inside much larger capture rings; Cinder Shrine remains too icon-led.

## Crosscheck Decision

The current crosscheck is strong enough for v0.8.1:

- Runtime references are covered.
- File existence is checked in the CLI gate.
- Metadata guardrails are tested.
- Manual source originals are preserved as manifest references.
- Procedural terrain is explicitly named as a placeholder asset debt item.

No additional source change is needed in this phase beyond the validation coverage already added.

## Next Step

Phase 6 should design a screenshot QA plan that uses this manifest as review context. Screenshot QA should remain manual-review oriented and non-brittle: no pixel-perfect comparisons, no large committed screenshot artifacts, and no visual changes unless a tiny layout/readability bug is obvious and safe.
