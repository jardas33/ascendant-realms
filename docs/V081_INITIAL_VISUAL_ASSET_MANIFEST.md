# v0.8.1 Initial Visual Asset Manifest

Date: 2026-05-10  
Scope: first populated visual metadata manifest for current Ascendant Realms assets.

## What Was Added

Added:

- `src/game/assets/visualAssetManifest.ts`

The manifest is TypeScript metadata only. It does not alter the current runtime asset loader, Phaser preload list, CSS variables, entity rendering, map rendering, campaign data, save data, or gameplay behavior.

## Manifest Coverage

The initial manifest includes 89 entries:

- 62 entries corresponding to the current runtime asset manifest.
- 25 manual source/reference duplicates that are present on disk but not selected by the runtime manifest because processed `final` copies exist.
- 1 procedural terrain placeholder entry for the current Phaser-generated battle map art.
- 1 prompt-book/reference entry for the existing manual asset pipeline prompt book.

This means the visual metadata manifest now covers both the assets the game currently sees and the important source/reference files that should not be casually deleted or ignored.

## Categories Covered

Current manifest categories include:

- Hero sprites.
- Unit sprites.
- Building sprites.
- Unit concepts.
- Building concepts.
- Portraits.
- Ability icons.
- Resource/capture-site icons.
- Faction emblems.
- UI backgrounds.
- UI frames.
- Splash/key art.
- Procedural terrain placeholder.
- Reference metadata.

No audio, VFX, terrain tile, road/causeway tile, or Cinder Shrine landmark art file exists yet. Those remain future asset categories, not v0.8.1 additions.

## Source And License Policy

The manifest is intentionally conservative:

- Current manually placed or processed image assets are generally marked with `sourceType: "manual"` and `licenseStatus: "unknown"`.
- v0.8.2 adds `reviewStatus` and `sourceReviewNotes` so unknown-source images can be distinguished from owned prototype-only metadata.
- Current unknown-license image assets are marked `reviewStatus: "needs-source-proof"`.
- Runtime image assets with unknown license are marked `needsReview: true`.
- Current runtime image assets are generally not marked `allowedInProduction`.
- Locally authored procedural terrain and the prompt book are marked as owned/source-known and `reviewStatus: "approved-for-prototype"`, but procedural terrain remains a `placeholder` with `replacementPriority: "critical"`.

This avoids treating the existing `public/assets/final/` folder name as proof of production-final art.

## Status Policy

Most current runtime art is marked as:

- `prototype` for currently useful in-game assets.
- `candidate` only when future review could plausibly promote it.
- `reference` for manual source files, concept/fallback art, key art, and prompt documents.
- `placeholder` for procedural terrain.

No entry is marked `final` in this phase.

No entry is marked `reviewStatus: "approved-for-production"` in v0.8.2 because the current file-backed image assets still lack explicit source/license evidence.

## Runtime Groups

### Battle Sprites

The manifest covers:

- Warlord, Arcanist, and Shepherd battle sprites.
- Militia, Ranger, Acolyte, Raider, Hexer, Brute, Enemy Commander, Wild Hound, and Stone Imp sprites.
- Command Hall, Barracks, Mystic Lodge, Watchtower, Enemy Stronghold, and Enemy Barracks sprites.
- Militia/Ranger/Acolyte and player-building concept fallback entries.

These entries point to `public/assets/final/` and list `BootScene`, `Unit`, or `Building` as the main runtime users.

### UI And Menu Assets

The manifest covers:

- Main Menu Background.
- Battle HUD Panel.
- Victory and Defeat backgrounds.
- The 12 UI-kit frame assets used by CSS variables.

These entries list `AssetLoader`, scene files, or CSS files as `usedBy` references.

### Icons And Portraits

The manifest covers:

- Hero portraits.
- Enemy Commander portrait.
- Hero ability icons.
- Resource/capture-site icons.
- Faction emblems.

`crown_shrine_icon` is classified as a `capture-site-icon` with high replacement priority because Cinder Shrine salience remains a visual watchpoint and the current site identity is too icon-led.

## Manual Source References

The 25 manual source/reference images under `public/assets/manual/buildings/` and `public/assets/manual/units/` now have unique `manual_source_*` manifest ids.

These entries are:

- `usage: "manual-reference"`
- `currentStatus: "reference"`
- `replacementPriority: "low"`
- `needsReview: true`

They exist to protect source/reference files from accidental cleanup before a future asset-pruning review.

## Scale Metadata

Known current render-height metadata is included for runtime sprites where v0.8 scale audit values exist:

| Group | Current metadata |
| --- | --- |
| Hero sprites | 82.65 px target height |
| Militia/Raider | 47.45 px target height |
| Ranger/Acolyte/Hexer/Wild Hound | 43.8 px target height |
| Brute | 58.4 px target height |
| Enemy Commander | 65.7 px target height |
| Stone Imp | 51.1 px target height |
| Command Hall | 116.44 px sprite max height |
| Barracks/Enemy Barracks | 90.88 px sprite max height |
| Mystic Lodge | 88.04 px sprite max height |
| Watchtower | 102.24 px sprite max height |
| Enemy Stronghold | 124.96 px sprite max height |
| Resource/capture icons | 42 px rendered icon size |

These values are review metadata only. They do not drive runtime scale, collision, pathfinding, selection, capture radius, camera, minimap, or balance.

## Replacement Priorities

High or critical replacement priorities are currently used for:

- Procedural battle terrain and roads: `critical`.
- Cinder Shrine / crowns capture-site icon: `high`.
- Enemy commander sprite: `high`.
- Enemy stronghold sprite: `high`.
- Main menu/results backgrounds: `high`.

These priorities reflect visual debt, not a v0.8.1 instruction to replace art now.

## What Was Not Added

This phase did not add:

- New art.
- Generated art.
- Downloaded art.
- New maps.
- New units.
- New factions.
- New gameplay.
- New rewards.
- Save changes.
- Campaign progression changes.
- Desktop packaging.
- Engine switching.
- Screenshot tests.
- Pixel comparisons.

## Next Step

Phase 4 should add validation around this manifest:

- Unique ids.
- Valid enum values.
- Runtime file existence.
- Review flags for unknown-license runtime assets.
- No `final` asset with unknown source/license.
- Positive scale metadata when present.
- Non-empty `usedBy` for runtime assets.
- Deprecated assets not used by runtime.

If clean, this validation should become part of `npm run validate:content` so future art additions cannot bypass metadata review.
