# v0.8.2 Asset Source And License Audit

Date: 2026-05-10  
Scope: current visual asset manifest and asset folders. This audit does not move, delete, rename, generate, download, replace, or approve assets.

## Evidence Inspected

- `src/game/assets/visualAssetManifest.ts`
- `src/game/assets/VisualAssetManifestTypes.ts`
- `public/assets/`
- `public/assets/final/`
- `public/assets/manual/`
- `public/assets/manifests/assetManifest.json`
- `public/assets/README.md`
- `public/assets/manual/ASSET_PROMPT_BOOK.md`
- `docs/V081_EXISTING_ASSET_INVENTORY_AUDIT.md`
- `docs/V081_INITIAL_VISUAL_ASSET_MANIFEST.md`
- `docs/ASSET_PIPELINE_PLAN.md`
- `docs/V082_ASSET_SOURCE_LICENSE_REVIEW_PLAN.md`

Important interpretation:

- The existing runtime asset manifest uses `source: "manual"` or `source: "final"` to describe folder priority, not legal source or license.
- `public/assets/README.md` states a future policy for original, commissioned, permissively licensed, or generated assets with clear commercial rights. It does not prove that every current image has production-safe source records.
- `ASSET_PROMPT_BOOK.md` describes a manual ChatGPT image-generation workflow. That is useful provenance context, but it does not prove which current images came from that workflow, which prompts were accepted, what edits happened, or whether each asset has production-safe review.
- This audit therefore keeps unknown-source assets unknown unless explicit evidence exists.

## Manifest Counts

The current visual asset manifest contains 89 entries.

### By `sourceType`

| sourceType | Count |
| --- | ---: |
| `manual` | 87 |
| `original` | 2 |

No entries currently use `generated`, `purchased`, `unknown`, or `external-reference`.

Audit read:

- `manual` currently means "present in the local manual/final asset folders," not "legally reviewed."
- The two `original` entries are `asset_prompt_book` and `procedural_battle_terrain`.
- The absence of `generated` does not prove no images were generated. It only means generation method is not proven in the manifest.

### By `licenseStatus`

| licenseStatus | Count |
| --- | ---: |
| `owned` | 2 |
| `unknown` | 87 |

No entries currently use `generated-review-needed`, `licensed`, `reference-only`, or `do-not-ship`.

Audit read:

- Current image assets are conservatively treated as unknown-license.
- No image asset is production-approved.
- The owned entries are a prompt/reference document and procedural terrain code metadata, not finished visual art.

### By `currentStatus`

| currentStatus | Count |
| --- | ---: |
| `placeholder` | 1 |
| `prototype` | 52 |
| `reference` | 36 |

No entries are marked `candidate`, `final`, or `deprecated`.

Audit read:

- The manifest avoids the dangerous mistake of treating `public/assets/final/` as production-final.
- Runtime image art is mostly prototype or reference/fallback material.
- Procedural battle terrain is correctly marked as placeholder.

### By `usage`

| usage | Count |
| --- | ---: |
| `runtime` | 60 |
| `manual-reference` | 27 |
| `docs-reference` | 2 |

No entries currently use `unused` or `test-only`.

Audit read:

- Runtime coverage is broad, but runtime does not equal production safety.
- Manual-reference entries exist to protect source/reference material from accidental cleanup.
- Docs-reference entries are not runtime assets.

## Runtime Assets With Unknown License

There are 59 runtime assets with `licenseStatus: "unknown"`. All have `needsReview: true` and `allowedInProduction: false`.

Groups:

- Hero battle sprites: Warlord, Arcanist, Shepherd.
- Unit sprites: Militia, Ranger, Acolyte, Raider, Hexer, Brute, Enemy Commander, Wild Hound, Stone Imp.
- Unit concept fallbacks: Militia, Ranger, Acolyte.
- Building sprites: Command Hall, Barracks, Mystic Lodge, Watchtower, Enemy Stronghold, Enemy Barracks.
- Building concept fallbacks: Command Hall, Barracks, Mystic Lodge, Watchtower.
- Portraits: Warlord, Arcanist, Shepherd, Enemy Commander.
- Ability icons: Rally Banner, Cleave, War Cry, Firebolt, Arcane Burst, Blink, Heal, Blessing, Sanctify Ground.
- Resource and capture-site icons: Crown Shrine, Stone Quarry, Iron Vein, Aether Well.
- Faction emblem: Free Marches.
- UI assets: Main Menu Background, Battle HUD Panel, Victory Screen Background, Defeat Screen Background, panel frame, button frames, resource frame, divider, tooltip frame, minimap frame, ability slot frame, inventory slot frame, victory panel frame, defeat panel frame.

Consequence:

- These assets can remain prototype runtime assets because validation flags them honestly.
- They should not be marked production-safe without source/license evidence.
- They should be the main target for future source confirmation or replacement.

## Runtime Assets With `needsReview`

All 60 runtime entries have `needsReview: true`.

- 59 are unknown-license image assets.
- `procedural_battle_terrain` is `sourceType: "original"` and `licenseStatus: "owned"`, but still needs review because it is a critical placeholder visual debt item and not production art.

This is the right posture for v0.8.2: runtime-visible does not mean source-safe or visually final.

## Candidate Or Final Assets

No entries are currently marked `candidate` or `final`.

This is justified because:

- No image asset has complete source/license evidence.
- No image asset has explicit production approval.
- The current visual language is still prototype-level and inconsistent.

Recommendation:

- Keep `final` unused until source/license evidence and screenshot review support it.
- Consider introducing `sourceReviewNotes` before any asset is promoted.

## Reference And Manual Assets That Must Not Ship

The following non-runtime assets are reference/manual material and should not ship as production art unless they are explicitly reviewed, reclassified, and intentionally wired:

- `ashen_covenant_emblem`
- `sylvan_concord_emblem`
- `ascendant_realms_key_art`
- 25 `manual_source_*` entries for unit and building source/reference files

Runtime concept fallbacks also need caution:

- `militia_unit_concept`
- `ranger_unit_concept`
- `acolyte_unit_concept`
- `command_hall_concept`
- `barracks_concept`
- `mystic_lodge_concept`
- `watchtower_concept`

These concept/fallback entries are technically runtime-loaded today, but they should not be treated as final in-battle art. They are useful for fallback coverage and asset-gallery visibility only.

## Highest-Risk Assets

### Legal/Source Risk

Highest legal/source risk is any runtime-visible image with unknown license. The most visible unknown-license groups are:

- Hero portraits and battle sprites.
- Player and enemy unit sprites.
- Player and enemy building sprites.
- Ability icons and resource/capture-site icons.
- Main menu, victory, and defeat backgrounds.
- UI frame assets used across menus, HUD, inventory, minimap, and results.

Why:

- They are visible in normal play or menus.
- Their exact origin/license evidence is not present in the manifest.
- Future sharing, store pages, desktop packaging, or commercial use would need source proof or replacement.

### Visual/Production Risk

Highest visual replacement priority:

- `procedural_battle_terrain`: critical replacement priority; owned/original but clearly placeholder.
- `crown_shrine_icon`: high replacement priority; Cinder Shrine remains icon/ring-led.
- `enemy_commander_unit_sprite`: high replacement priority; commander visual scale/style remains a watchpoint.
- `enemy_stronghold_building_sprite`: high replacement priority; stronghold identity is important and not final.
- `main_menu_background`, `victory_screen_background`, `defeat_screen_background`: high replacement priority; these shape the product presentation.

## Safest Assets

From a source/license standpoint, the safest entries are:

- `asset_prompt_book`: `sourceType: "original"`, `licenseStatus: "owned"`, docs-reference only.
- `procedural_battle_terrain`: `sourceType: "original"`, `licenseStatus: "owned"`, runtime metadata for code-generated terrain.

Important caveat:

- `procedural_battle_terrain` is source-safe but visually unsafe for production. It remains `placeholder`, `replacementPriority: "critical"`, `allowedInProduction: false`, and `needsReview: true`.
- No current file-backed image asset is source/license-safe enough for production approval.

## Assets Needing User Or Source Confirmation

Highest-priority source confirmation should start with runtime-visible, high-impact assets:

1. Main menu background.
2. Victory and defeat backgrounds.
3. Hero portraits.
4. Hero battle sprites.
5. Militia/Ranger/Acolyte player unit sprites.
6. Raider/Hexer/Brute/Enemy Commander sprites.
7. Command Hall, Barracks, Watchtower, Mystic Lodge, Enemy Stronghold, Enemy Barracks sprites.
8. Crown Shrine and other resource icons.
9. Ability icons.
10. UI-kit frame assets.
11. Manual source duplicates for any asset being considered for replacement or pruning.

For each, the user or asset author should confirm:

- Whether the asset was generated, manually drawn, purchased, commissioned, or sourced elsewhere.
- Which prompt/tool/license/source applies.
- Whether the asset can remain in a public prototype.
- Whether it can ship commercially later.
- Whether it should be replaced before a v0.9 style-frame sprint.

## Recommended Manifest Refinements

1. Add `sourceReviewNotes` to each visual asset entry.
   - Reason: current `notes` mixes visual debt, usage, and source/license implications.
   - The new field can capture "No source proof yet," "Prompt-book workflow suspected but unverified," or "Owned procedural code."

2. Add `reviewStatus` as a constrained field if it does not create too much churn.
   - Suggested values: `approved-for-prototype`, `approved-for-production`, `needs-source-proof`, `generated-review-needed`, `reference-only`, `do-not-ship`, `deprecated`.
   - This would make audit language machine-checkable.
   - If that is too broad for v0.8.2, keep review status in docs and use `sourceReviewNotes` first.

3. Reclassify manual source/reference assets more explicitly.
   - Current manual source entries use `licenseStatus: "unknown"`, which is honest but does not distinguish "source file with unknown legal status" from "runtime art with unknown legal status."
   - A future pass could use `sourceReviewNotes` to clarify this without changing validation behavior.

4. Keep all unknown-license runtime assets `needsReview: true` and `allowedInProduction: false`.
   - Do not weaken this rule.

5. Consider requiring notes or source-review notes for:
   - `needsReview: true`
   - `replacementPriority: "critical"`
   - `allowedInProduction: true`
   - `currentStatus: "final"`

6. Do not mark any current image as `final`.
   - There is no current source/license evidence that justifies production approval.

## Validation Implications

Validation should continue allowing honest unknowns, but it should make unsafe ambiguity hard to miss.

Safe v0.8.2 hardening candidates:

- `needsReview: true` should require a useful note or `sourceReviewNotes`.
- `replacementPriority: "critical"` should require a note.
- `allowedInProduction: true` should require a safe license status and non-unknown source type.
- `currentStatus: "final"` should require safe source/license and `allowedInProduction: true`.
- `currentStatus: "candidate"` should require source-review notes when source or license remains unknown.
- Runtime manual/reference concept fallbacks should be explicitly noted as fallback/reference, not final art.

Avoid:

- Validation that blocks current honest unknown assets.
- Validation that forces asset moves.
- Validation that assumes the `final` folder name is legal proof.

## Audit Decision

No current asset should be promoted to production-safe status in Phase 2.

The next safest implementation step is a conservative manifest metadata refinement that adds source-review notes and possibly a lightweight review-status field, while keeping all unknown-license runtime image assets review-needed and not allowed in production.
