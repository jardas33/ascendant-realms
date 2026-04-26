# Battle Asset Prompt Guide

The battle scene now supports real Phaser image assets for units, heroes, buildings, and resource-site cores.

Save generated files in the exact folders and filenames below, then run:

```bash
npm run assets:refresh
```

Refresh the browser after the manifest is rebuilt. The runtime preference is:

1. dedicated battle sprite, if present
2. existing concept art or portrait fallback, if present
3. simple Phaser shape fallback

## Current Sprite Requirement

The game currently expects a single static PNG per unit, hero, or building. Do not generate animation sheets yet.

Movement is handled by the game code moving the image across the map. The current renderer loads battle assets as normal Phaser images, not as multi-frame sprite sheets. For the files in this guide, each prompt should produce one centered subject in one pose.

Use phrases like:

```text
single-frame static battle sprite, one pose only, not an animation sheet, not a sprite strip, no frame grid, no multiple poses
```

Later, when we add walk/attack/death animations in code, the prompt should change to a multi-frame sprite strip format. A future movement strip would be requested separately, for example:

```text
Create one horizontal 8-frame walking animation sprite strip for the same character, transparent background, exact 8 slots in one row, each frame 256x256, same facing direction, same scale, same bottom-center foot anchor, consistent costume and silhouette across every frame, no scenery, no labels, no frame numbers, no poster composition.
```

## Global Rules For Every Prompt

Use these rules in every image-generation request:

- Original IP only. Do not use Warlords Battlecry names, logos, characters, factions, screenshots, UI, or copyrighted assets.
- Single subject only.
- Single-frame static sprite only for the current game.
- Transparent PNG background.
- No text, letters, labels, watermark, UI frame, scenery, poster composition, character sheet, multiple poses, animation sheet, sprite strip, frame grid, or ground tile.
- Three-quarter top-down RTS camera, like a readable browser strategy game piece.
- Center the subject with 12-16 percent padding.
- Clear silhouette, restrained fantasy realism, painterly but crisp.
- Must still read at 48x48 or 64x64 in the game.
- Keep lighting consistent: cool blue-green shadows, muted gold highlights, dark iron and worn silver materials.

## Best General Prompt Template

Replace the bracketed subject and facing direction.

```text
Create a production-ready 2D battle sprite for an original fantasy RTS/RPG browser game.

Subject: [SUBJECT].

Style and camera: three-quarter top-down RTS perspective, [FACING DIRECTION], centered full-body or full-building game sprite, readable at small in-game scale, painterly fantasy realism with crisp edges and strong silhouette, cool blue-green shadows, muted gold highlights, worn silver and dark iron material language.

Technical requirements: single-frame static PNG, one pose only, not an animation sheet, not a sprite strip, no frame grid, transparent PNG background, one subject only, 512x512 for units and heroes or 768x768 for buildings, 12-16 percent empty transparent padding, no baked ground shadow, no scenery, no ground plane, no UI frame, no text, no letters, no logo, no watermark, no multiple poses, no concept sheet, no cropped body, no poster art.
```

## Priority 1: Player Army

Save these in `public/assets/manual/units`.

### `militia_unit_sprite.png`

```text
Create a production-ready 2D battle sprite for an original fantasy RTS/RPG browser game.

Subject: a Free Marches militia fighter with spear, round shield, padded jack, deep blue cloth strip, and worn silver helmet.

Style and camera: three-quarter top-down RTS perspective, facing right, centered full-body game sprite, readable at 48x48, painterly fantasy realism with crisp edges and strong silhouette, cool blue-green shadows, muted gold highlights, worn silver and dark iron material language.

Technical requirements: single-frame static PNG, one pose only, not an animation sheet, not a sprite strip, no frame grid, transparent PNG background, one subject only, 512x512, 12-16 percent empty transparent padding, no baked ground shadow, no scenery, no ground plane, no UI frame, no text, no letters, no logo, no watermark, no multiple poses, no concept sheet, no cropped body, no poster art.
```

### `ranger_unit_sprite.png`

```text
Create a production-ready 2D battle sprite for an original fantasy RTS/RPG browser game.

Subject: a frontier ranger with short bow, hooded blue-gray cloak, leather armor, travel pack, and practical boots.

Style and camera: three-quarter top-down RTS perspective, facing right, centered full-body game sprite, readable at 48x48, painterly fantasy realism with crisp edges and strong silhouette, cool blue-green shadows, muted gold highlights, worn silver and dark iron material language.

Technical requirements: single-frame static PNG, one pose only, not an animation sheet, not a sprite strip, no frame grid, transparent PNG background, one subject only, 512x512, 12-16 percent empty transparent padding, no baked ground shadow, no scenery, no ground plane, no UI frame, no text, no letters, no logo, no watermark, no multiple poses, no concept sheet, no cropped body, no poster art.
```

### `acolyte_unit_sprite.png`

```text
Create a production-ready 2D battle sprite for an original fantasy RTS/RPG browser game.

Subject: a young chapel acolyte with simple vestments, small lantern focus, travel satchel, and soft green-white magic glow.

Style and camera: three-quarter top-down RTS perspective, facing right, centered full-body game sprite, readable at 48x48, painterly fantasy realism with crisp edges and strong silhouette, cool blue-green shadows, muted gold highlights, worn silver and dark iron material language.

Technical requirements: single-frame static PNG, one pose only, not an animation sheet, not a sprite strip, no frame grid, transparent PNG background, one subject only, 512x512, 12-16 percent empty transparent padding, no baked ground shadow, no scenery, no ground plane, no UI frame, no text, no letters, no logo, no watermark, no multiple poses, no concept sheet, no cropped body, no poster art.
```

## Priority 2: Heroes

Save these in `public/assets/manual/units`.

### `warlord_hero_battle_sprite.png`

```text
Create a production-ready 2D battle sprite for an original fantasy RTS/RPG browser game.

Subject: a Free Marches warlord hero in practical worn silver plate over a dark gambeson, deep blue weathered cloak, muted gold command sash, and a raised banner spear.

Style and camera: three-quarter top-down RTS perspective, facing right, centered full-body hero game sprite, readable at 64x64, painterly fantasy realism with crisp edges and strong silhouette, cool blue-green shadows, muted gold highlights, worn silver and dark iron material language.

Technical requirements: single-frame static PNG, one pose only, not an animation sheet, not a sprite strip, no frame grid, transparent PNG background, one subject only, 512x512, 12-16 percent empty transparent padding, no baked ground shadow, no scenery, no ground plane, no UI frame, no text, no letters, no logo, no watermark, no multiple poses, no concept sheet, no cropped body, no poster art.
```

### `arcanist_hero_battle_sprite.png`

```text
Create a production-ready 2D battle sprite for an original fantasy RTS/RPG browser game.

Subject: an arcanist battlefield hero in layered charcoal travel robes, bronze clasps, ember-lit aether focus stones, ink-stained gloves, and one compact glowing hand.

Style and camera: three-quarter top-down RTS perspective, facing right, centered full-body hero game sprite, readable at 64x64, painterly fantasy realism with crisp edges and strong silhouette, cool blue-green shadows, muted gold highlights, worn silver and dark iron material language.

Technical requirements: single-frame static PNG, one pose only, not an animation sheet, not a sprite strip, no frame grid, transparent PNG background, one subject only, 512x512, 12-16 percent empty transparent padding, no baked ground shadow, no scenery, no ground plane, no UI frame, no text, no letters, no logo, no watermark, no multiple poses, no concept sheet, no cropped body, no poster art.
```

### `shepherd_hero_battle_sprite.png`

```text
Create a production-ready 2D battle sprite for an original fantasy RTS/RPG browser game.

Subject: a Shepherd holy field commander in travel-worn cream and moss-green vestments over light armor, ashwood staff, healer satchel, chapel charms, and quiet protective resolve.

Style and camera: three-quarter top-down RTS perspective, facing right, centered full-body hero game sprite, readable at 64x64, painterly fantasy realism with crisp edges and strong silhouette, cool blue-green shadows, muted gold highlights, worn silver and dark iron material language.

Technical requirements: single-frame static PNG, one pose only, not an animation sheet, not a sprite strip, no frame grid, transparent PNG background, one subject only, 512x512, 12-16 percent empty transparent padding, no baked ground shadow, no scenery, no ground plane, no UI frame, no text, no letters, no logo, no watermark, no multiple poses, no concept sheet, no cropped body, no poster art.
```

## Priority 3: Enemy Army

Save these in `public/assets/manual/units`.

### `raider_unit_sprite.png`

```text
Create a production-ready 2D battle sprite for an original fantasy RTS/RPG browser game.

Subject: an Ashen Covenant raider with soot-black leather, ember red cloth, hooked blade, light shield, and aggressive forward posture.

Style and camera: three-quarter top-down RTS perspective, facing left, centered full-body game sprite, readable at 48x48, painterly fantasy realism with crisp edges and strong silhouette, ember red accents against cool dark shadows, blackened iron and burnt bronze material language.

Technical requirements: single-frame static PNG, one pose only, not an animation sheet, not a sprite strip, no frame grid, transparent PNG background, one subject only, 512x512, 12-16 percent empty transparent padding, no baked ground shadow, no scenery, no ground plane, no UI frame, no text, no letters, no logo, no watermark, no multiple poses, no concept sheet, no cropped body, no poster art.
```

### `hexer_unit_sprite.png`

```text
Create a production-ready 2D battle sprite for an original fantasy RTS/RPG browser game.

Subject: an Ashen Covenant hexer caster in dark ragged robes with violet ember magic, burnt bronze mask fragments, and a crooked ritual staff.

Style and camera: three-quarter top-down RTS perspective, facing left, centered full-body game sprite, readable at 48x48, painterly fantasy realism with crisp edges and strong silhouette, violet-orange magic accent against cool dark shadows, blackened iron and burnt bronze material language.

Technical requirements: single-frame static PNG, one pose only, not an animation sheet, not a sprite strip, no frame grid, transparent PNG background, one subject only, 512x512, 12-16 percent empty transparent padding, no baked ground shadow, no scenery, no ground plane, no UI frame, no text, no letters, no logo, no watermark, no multiple poses, no concept sheet, no cropped body, no poster art.
```

### `brute_unit_sprite.png`

```text
Create a production-ready 2D battle sprite for an original fantasy RTS/RPG browser game.

Subject: a heavy Ashen Covenant brute with blackened iron plates, ember red wraps, oversized maul, hunched shoulders, and thick armored silhouette.

Style and camera: three-quarter top-down RTS perspective, facing left, centered full-body game sprite, readable at 56x56, painterly fantasy realism with crisp edges and strong silhouette, ember red accents against cool dark shadows, blackened iron and burnt bronze material language.

Technical requirements: single-frame static PNG, one pose only, not an animation sheet, not a sprite strip, no frame grid, transparent PNG background, one subject only, 512x512, 12-16 percent empty transparent padding, no baked ground shadow, no scenery, no ground plane, no UI frame, no text, no letters, no logo, no watermark, no multiple poses, no concept sheet, no cropped body, no poster art.
```

### `enemy_commander_unit_sprite.png`

```text
Create a production-ready 2D battle sprite for an original fantasy RTS/RPG browser game.

Subject: an Ashen Covenant commander with soot-black lamellar armor, ember red battle cloth, jagged shoulder silhouette, burnt bronze mask fragments, and a cruel command blade.

Style and camera: three-quarter top-down RTS perspective, facing left, centered full-body hero-like game sprite, readable at 64x64, painterly fantasy realism with crisp edges and strong silhouette, ember red accents against cool dark shadows, blackened iron and burnt bronze material language.

Technical requirements: single-frame static PNG, one pose only, not an animation sheet, not a sprite strip, no frame grid, transparent PNG background, one subject only, 512x512, 12-16 percent empty transparent padding, no baked ground shadow, no scenery, no ground plane, no UI frame, no text, no letters, no logo, no watermark, no multiple poses, no concept sheet, no cropped body, no poster art.
```

## Priority 4: Neutral Camps

Save these in `public/assets/manual/units`.

### `wild_hound_unit_sprite.png`

```text
Create a production-ready 2D battle sprite for an original fantasy RTS/RPG browser game.

Subject: a lean territorial fantasy wild hound with tawny fur, dark mane, sharp ears, and low lunging posture.

Style and camera: three-quarter top-down RTS perspective, facing left, centered full-body creature game sprite, readable at 44x44, painterly fantasy realism with crisp edges and strong silhouette, natural muted browns against cool dark shadows.

Technical requirements: single-frame static PNG, one pose only, not an animation sheet, not a sprite strip, no frame grid, transparent PNG background, one creature only, 512x512, 12-16 percent empty transparent padding, no baked ground shadow, no scenery, no ground plane, no UI frame, no text, no letters, no logo, no watermark, no multiple poses, no concept sheet, no cropped body, no poster art.
```

### `stone_imp_unit_sprite.png`

```text
Create a production-ready 2D battle sprite for an original fantasy RTS/RPG browser game.

Subject: a squat stone imp with cracked gray rock body, pale quarry dust highlights, tiny ember eyes, and chunky clawed hands.

Style and camera: three-quarter top-down RTS perspective, facing left, centered full-body creature game sprite, readable at 44x44, painterly fantasy realism with crisp edges and strong silhouette, gray stone material against cool dark shadows.

Technical requirements: single-frame static PNG, one pose only, not an animation sheet, not a sprite strip, no frame grid, transparent PNG background, one creature only, 512x512, 12-16 percent empty transparent padding, no baked ground shadow, no scenery, no ground plane, no UI frame, no text, no letters, no logo, no watermark, no multiple poses, no concept sheet, no cropped body, no poster art.
```

## Priority 5: Player Buildings

Save these in `public/assets/manual/buildings`.

### `command_hall_building_sprite.png`

```text
Create a production-ready 2D building sprite for an original fantasy RTS/RPG browser game.

Subject: a Free Marches stone command hall with timber supports, deep blue banners, a watch platform, and practical frontier defenses.

Style and camera: three-quarter top-down RTS perspective, centered full-building game sprite with clear rectangular footprint, readable at 96x82, painterly fantasy realism with crisp edges and strong silhouette, cool blue-green shadows, muted gold highlights, worn silver and dark iron material language.

Technical requirements: single-frame static PNG, one pose only, not an animation sheet, not a sprite strip, no frame grid, transparent PNG background, one building only, 768x768, 12-16 percent empty transparent padding, no baked ground shadow, no scenery, no ground plane, no UI frame, no text, no letters, no logo, no watermark, no concept sheet, no cropped building, no poster art.
```

### `barracks_building_sprite.png`

```text
Create a production-ready 2D building sprite for an original fantasy RTS/RPG browser game.

Subject: a compact Free Marches barracks with training yard, weapon racks, blue pennants, stone base, and timber roof.

Style and camera: three-quarter top-down RTS perspective, centered full-building game sprite with clear rectangular footprint, readable at 82x64, painterly fantasy realism with crisp edges and strong silhouette, cool blue-green shadows, muted gold highlights, worn silver and dark iron material language.

Technical requirements: single-frame static PNG, one pose only, not an animation sheet, not a sprite strip, no frame grid, transparent PNG background, one building only, 768x768, 12-16 percent empty transparent padding, no baked ground shadow, no scenery, no ground plane, no UI frame, no text, no letters, no logo, no watermark, no concept sheet, no cropped building, no poster art.
```

### `mystic_lodge_building_sprite.png`

```text
Create a production-ready 2D building sprite for an original fantasy RTS/RPG browser game.

Subject: a small frontier mystic lodge with chapel-stone foundation, hanging aether lanterns, blue cloth, and a simple ritual circle.

Style and camera: three-quarter top-down RTS perspective, centered full-building game sprite with clear rectangular footprint, readable at 72x62, painterly fantasy realism with crisp edges and strong silhouette, cool blue-green shadows, muted gold highlights, worn silver and dark iron material language.

Technical requirements: single-frame static PNG, one pose only, not an animation sheet, not a sprite strip, no frame grid, transparent PNG background, one building only, 768x768, 12-16 percent empty transparent padding, no baked ground shadow, no scenery, no ground plane, no UI frame, no text, no letters, no logo, no watermark, no concept sheet, no cropped building, no poster art.
```

### `watchtower_building_sprite.png`

```text
Create a production-ready 2D building sprite for an original fantasy RTS/RPG browser game.

Subject: a sturdy Free Marches watchtower with stone base, timber archer platform, small blue banner, and defensive railings.

Style and camera: three-quarter top-down RTS perspective, centered full-building game sprite with tall readable silhouette, readable at 48x72, painterly fantasy realism with crisp edges and strong silhouette, cool blue-green shadows, muted gold highlights, worn silver and dark iron material language.

Technical requirements: single-frame static PNG, one pose only, not an animation sheet, not a sprite strip, no frame grid, transparent PNG background, one building only, 768x768, 12-16 percent empty transparent padding, no baked ground shadow, no scenery, no ground plane, no UI frame, no text, no letters, no logo, no watermark, no concept sheet, no cropped building, no poster art.
```

## Priority 6: Enemy Buildings

Save these in `public/assets/manual/buildings`.

### `enemy_stronghold_building_sprite.png`

```text
Create a production-ready 2D building sprite for an original fantasy RTS/RPG browser game.

Subject: an Ashen Covenant enemy stronghold with blackened stone, ember red banners, burnt bronze spikes, smoky ritual furnace, and jagged battlements.

Style and camera: three-quarter top-down RTS perspective, centered full-building game sprite with clear rectangular footprint, readable at 104x88, painterly fantasy realism with crisp edges and strong silhouette, ember red accents against cool dark shadows, blackened iron and burnt bronze material language.

Technical requirements: single-frame static PNG, one pose only, not an animation sheet, not a sprite strip, no frame grid, transparent PNG background, one building only, 768x768, 12-16 percent empty transparent padding, no baked ground shadow, no scenery, no ground plane, no UI frame, no text, no letters, no logo, no watermark, no concept sheet, no cropped building, no poster art.
```

### `enemy_barracks_building_sprite.png`

```text
Create a production-ready 2D building sprite for an original fantasy RTS/RPG browser game.

Subject: an Ashen Covenant barracks with black timber, rough volcanic stone, ember red cloth strips, crude weapon racks, and burnt bronze braces.

Style and camera: three-quarter top-down RTS perspective, centered full-building game sprite with clear rectangular footprint, readable at 82x64, painterly fantasy realism with crisp edges and strong silhouette, ember red accents against cool dark shadows, blackened iron and burnt bronze material language.

Technical requirements: single-frame static PNG, one pose only, not an animation sheet, not a sprite strip, no frame grid, transparent PNG background, one building only, 768x768, 12-16 percent empty transparent padding, no baked ground shadow, no scenery, no ground plane, no UI frame, no text, no letters, no logo, no watermark, no concept sheet, no cropped building, no poster art.
```

## Quickest Visible Upgrade

Generate these first:

1. `warlord_hero_battle_sprite.png`
2. `militia_unit_sprite.png`
3. `ranger_unit_sprite.png`
4. `command_hall_building_sprite.png`
5. `enemy_stronghold_building_sprite.png`
6. `raider_unit_sprite.png`

Those six will make the opening battle immediately feel much less placeholder-like.

