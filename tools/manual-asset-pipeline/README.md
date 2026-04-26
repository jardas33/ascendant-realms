# Manual Asset Pipeline

This folder contains a no-API art workflow for Ascendant Realms.

It does not generate images automatically. It only creates prompts, builds a manifest from image files you manually place in `public/assets`, and validates that the game can safely fall back when art is missing.

## Commands

```bash
npm run assets:prompts
npm run assets:ui-kit
npm run assets:process-battle-sprites
npm run assets:refresh
```

`assets:ui-kit` creates a free local procedural starter set for the 12 dedicated UI-kit PNG files. It does not call any image API.

`assets:process-battle-sprites` creates cleaned copies of manual unit and building PNGs in `public/assets/final`. It removes flat edge-connected backgrounds, normalizes the canvas size, and leaves the original manual files untouched.

`assets:refresh` processes battle/concept sprites, builds the manifest, and then validates it, so validation cannot accidentally read an older manifest.

## Files

- `artStyleBible.ts`: the visual identity and safety rules for all prompts.
- `assetRegistry.ts`: the master list of assets the project wants.
- `generatePromptBook.ts`: writes `public/assets/manual/ASSET_PROMPT_BOOK.md` and `.json`.
- `processBattleSprites.ts`: writes non-destructive cleaned battle/concept sprite copies into `public/assets/final`.
- `buildAssetManifest.ts`: scans `final`, then `manual`, then `placeholders`.
- `validateAssets.ts`: checks the manifest and prints a clear report.

## Filenames

The prompt book gives an exact recommended filename, such as `warlord_hero_portrait.png`.
That exact name is best for source control and future publishing.

For non-coder friendliness, the manifest builder also recognizes human-readable filenames such as `Warlord Hero Portrait.png` when the image is in the correct folder.

## Asset Priority

1. `public/assets/final`
2. `public/assets/manual`
3. `public/assets/placeholders`
4. Phaser and CSS runtime fallbacks

Missing art is okay. The game should never crash because an image is missing.

## UI Art Kit Notes

The `ui_` assets are reusable interface parts:

- panel frames
- button states
- resource frames
- dividers
- tooltip frames
- minimap frame
- ability slot frame
- inventory slot frame
- victory and defeat panel frames

These assets should usually be transparent PNGs with quiet or transparent centers. The game uses them through CSS frame rules, so the safest results have decorated corners, repeatable edges, and no text baked into the image.
