# Ascendant Realms UI Art Kit

This file explains the dedicated UI art kit. These assets are optional, manual images. The game keeps working when they are missing.

## How It Works

1. The desired UI assets are listed in `tools/manual-asset-pipeline/assetRegistry.ts`.
2. `npm run assets:prompts` writes prompts into `public/assets/manual/ASSET_PROMPT_BOOK.md`.
3. You manually generate images in ChatGPT and put them in `public/assets/manual/ui`.
4. `npm run assets:refresh` updates `public/assets/manifests/assetManifest.json`.
5. The game exposes found UI-kit images to CSS variables.
6. CSS uses those images as optional frames, not full stretched backgrounds.

## Generate These First

| Asset | Filename | Folder | Used For |
| --- | --- | --- | --- |
| Reusable Panel Frame | `ui_panel_frame.png` | `public/assets/manual/ui` | Main panels, hero panel, side panel |
| Button Idle Frame | `ui_button_idle.png` | `public/assets/manual/ui` | Normal buttons |
| Button Hover Frame | `ui_button_hover.png` | `public/assets/manual/ui` | Hover/focus buttons |
| Button Pressed Frame | `ui_button_pressed.png` | `public/assets/manual/ui` | Pressed buttons |
| Resource Counter Frame | `ui_resource_frame.png` | `public/assets/manual/ui` | Crowns, Stone, Iron, Aether chips |
| Ornate Section Divider | `ui_divider_ornament.png` | `public/assets/manual/ui` | Section headers |
| Tooltip And Info Frame | `ui_tooltip_frame.png` | `public/assets/manual/ui` | Info boxes, status line, future tooltips |
| Minimap Frame | `ui_minimap_frame.png` | `public/assets/manual/ui` | Battle minimap shell |
| Ability Slot Frame | `ui_ability_slot_frame.png` | `public/assets/manual/ui` | Hero ability buttons |
| Inventory Slot Frame | `ui_inventory_slot_frame.png` | `public/assets/manual/ui` | Inventory rows, equipment rows, gallery cards |
| Victory Panel Frame | `ui_victory_panel_frame.png` | `public/assets/manual/ui` | Victory results and progression |
| Defeat Panel Frame | `ui_defeat_panel_frame.png` | `public/assets/manual/ui` | Defeat results |

## Free Procedural Starter Kit

Codex can create a local procedural starter set with no image API:

```bash
npm run assets:ui-kit
npm run assets:refresh
```

This creates the 12 PNG files listed above in `public/assets/manual/ui`. These are original prototype frames and slots, not final commercial art. Replace them later by putting better files with the same filenames in `public/assets/final/ui`.

## Good UI-Kit Images

- Transparent PNG when possible.
- Clear decorated corners.
- Repeatable top, bottom, left, and right edges.
- Transparent or very quiet center.
- No words, labels, numbers, or fake menu text.
- No full-screen UI mockup.
- No busy center texture.
- No copied game UI or franchise symbols.

## If Something Looks Wrong

If a frame looks stretched or too thick, the image may still be usable. Ask Codex to tune the CSS `border-image-slice` and `border-image-width` values for that specific asset.
