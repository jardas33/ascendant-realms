# Asset Prompt Templates

Date: 2026-05-10  
Status: future asset-spec planning only. No images were generated, downloaded, committed, or imported.

## Purpose

These templates are safe starting briefs for future Ascendant Realms visual asset work. They are not instructions to generate assets during v0.8.1. Any future generated, purchased, commissioned, or manually created asset must be tracked in `src/game/assets/visualAssetManifest.ts` with source, license, production eligibility, scale, readability, and review metadata.

## Global Rules For Every Future Asset

- Original IP only.
- Do not copy Warcraft, Warlords Battlecry, or any other protected franchise, faction, unit, building, terrain, UI, map, symbol, logo, lore, music, sound, or specific art style.
- Do not use hidden copyrighted source images.
- Record tool, artist, source, prompt, license, review status, and whether the asset is allowed in production.
- Prefer readability from RTS camera distance over ornamental detail.
- Match `docs/ART_DIRECTION_2026_BIBLE.md`: original dark heroic fantasy, clear silhouettes, grounded terrain, tactile UI, and restrained tactical readability.
- Record intended world height, expected render height, scale class, usage, replacement priority, and screenshot QA target after generation.
- Keep browser prototype imports small. Do not commit large binary assets without explicit approval.

## Metadata To Record After Generation

For every future asset candidate, record:

- `id`
- `filePath`
- `category`
- `displayName`
- `currentStatus`
- `sourceType`
- `licenseStatus`
- `usage`
- `usedBy`
- `visualFamily`
- `scaleClass`
- `intendedWorldHeightPx`
- `currentRenderHeightPx`
- `silhouetteReadability`
- `styleConsistency`
- `replacementPriority`
- `allowedInProduction`
- `needsReview`
- prompt/source notes
- reviewer/date
- screenshot QA target

## Template 1 - Cinderfen Terrain Style Frame

Use for:

- Future terrain style-frame exploration.
- Not a direct tile import unless separately approved.

Prompt:

```text
Create an original dark heroic fantasy RTS terrain style frame for a wet ashland region called Cinderfen. Show blackened causeways, wet ash mud, shallow reflective blackwater, dead reeds, ember-lit stones, ruined road markers, and cinder fog. The view should be readable from a top-down or high 2.5D RTS camera, with clear passable roads, blocked swamp edges, and capture-site clear space. Original IP only. Do not imitate or copy Warcraft, Warlords Battlecry, or any protected franchise, faction, terrain, UI, map, unit, building, symbol, color scheme, or art style. No logos, no recognizable copyrighted references, no characters.
```

Output expectations:

- One wide style frame.
- No UI.
- No characters.
- High readability of road, water, swamp, and blocked edges.
- Palette should support future units and health bars.

Metadata reminder:

- Record source/tool/artist, license status, prompt text, review status, terrain family, and whether it is reference-only or candidate production direction.

## Template 2 - Cinderfen Road / Causeway Tile

Use for:

- Future road/causeway material exploration.
- Possible modular terrain-kit planning.

Prompt:

```text
Design an original RTS road/causeway tile concept for Cinderfen: a blackened raised causeway crossing wet ash marsh, with broken stone or charred timber edges, muddy margins, dead reeds, subtle ember flecks, and clear gameplay-readable edges. Orthographic or high 2.5D camera feel. The tile should read as passable terrain at small RTS scale and should connect cleanly to straight, bend, fork, and broken variants. Original IP only. Do not copy or closely imitate any protected game, franchise, terrain kit, map, UI, or art style.
```

Output expectations:

- Transparent background if delivered as a tile/sprite.
- Include optional notes for straight, curve, fork, and edge variants.
- Avoid decorative clutter that could be mistaken for units or capture sites.

Metadata reminder:

- Record intended tile/world size, usage, visual family, replacement priority, license/source, and screenshot QA target.

## Template 3 - Cinder Shrine / Capture-Site Concept

Use for:

- Future Cinder Shrine landmark direction.
- Capture-site identity exploration.

Prompt:

```text
Create an original fantasy RTS capture-site landmark for Cinderfen: an ember-lit shrine built from black stone and ash-glass, with a readable silhouette from a high 2.5D RTS camera, subtle ritual glow, wet marsh ground contact, and space for a non-dominant capture boundary. The landmark should feel old, dangerous, and sacred without using any existing franchise symbols. Original IP only. Do not copy Warcraft, Warlords Battlecry, or any protected shrine, faction, icon, symbol, terrain, UI, or art style.
```

Output expectations:

- Transparent background for runtime sprite candidates.
- Include optional neutral/player/enemy ownership state notes, but do not add faction logos.
- Must remain readable around 64 to 96 px rendered height if adapted for the browser prototype.

Metadata reminder:

- Record scale class `capture-site`, intended/current render height, source/license, allowed production status, and screenshot target `cinderfen-crossing-shrine-desktop.png`.

## Template 4 - Ashen Stronghold Concept

Use for:

- Future hostile base/stronghold visual identity.

Prompt:

```text
Design an original enemy stronghold concept for a dark heroic fantasy RTS faction presence in Cinderfen. Use blackened timber, hard stone, ember-lit slits, harsh road-guard geometry, and a strong hostile silhouette readable from a top-down or high 2.5D RTS camera. It should feel like a fortified outpost controlling marsh roads, not a copied building from any existing franchise. Original IP only. Do not imitate Warcraft, Warlords Battlecry, or any protected faction, building, icon, banner, architecture, UI, terrain, or color scheme.
```

Output expectations:

- Transparent background if intended as a sprite.
- Ground contact/foundation indication.
- No logos or protected symbols.
- Preserve room for health bars and labels in the prototype.

Metadata reminder:

- Record building scale, footprint notes, current replacement target, source/license, and screenshot QA target.

## Template 5 - Player Hero Concept

Use for:

- Future Aster/player hero visual exploration.
- Not for immediate runtime replacement unless scale sheet is approved.

Prompt:

```text
Create an original dark heroic fantasy RTS/RPG hero concept for a battlefield commander named Aster. The character should have a strong command silhouette, readable weapon/standard or leadership pose, grounded armor, and clear team-friendly identity at small RTS scale. Style should be original, readable, and suitable for a future 2.5D or desktop-quality RTS/RPG, with a transparent background if delivered as a cutout. Do not copy or imitate Warcraft, Warlords Battlecry, or any protected hero, faction, armor, weapon, portrait, icon, logo, or art style.
```

Output expectations:

- Transparent background for sprite/cutout candidates.
- Include full-body front or three-quarter pose.
- Include notes for battlefield silhouette and portrait adaptation.
- Must be readable around 80 to 90 px in current prototype scale if adapted.

Metadata reminder:

- Record scale class `hero`, intended/current render height, source/license, visual family, silhouette readability, and production eligibility.

## Template 6 - Militia Concept

Use for:

- Future baseline infantry role definition.

Prompt:

```text
Create an original fantasy RTS militia unit concept for Ascendant Realms. The unit should read as a common frontline soldier from a high 2.5D RTS camera, with a simple shield/spear or sword silhouette, modest armor, grounded colors, and clear distinction from hero and ranger units. Transparent background if delivered as a sprite/cutout. Original IP only. Do not copy or imitate any protected unit, faction, armor set, weapon silhouette, game style, icon, or franchise.
```

Output expectations:

- Transparent background for sprite/cutout candidates.
- Full-body pose with readable weapon silhouette.
- Avoid excessive detail that disappears at small scale.
- Should fit common infantry render height around 44 to 50 px if adapted.

Metadata reminder:

- Record unit scale, role, visual family, source/license, replacement priority, screenshot target, and whether labels can eventually become less necessary.

## Template 7 - Ranger Concept

Use for:

- Future ranged unit role definition.

Prompt:

```text
Create an original fantasy RTS ranger unit concept for Ascendant Realms. The unit should read as a light ranged scout from a high 2.5D RTS camera, with clear bow or crossbow silhouette, lighter armor than militia, travel cloak or road-worn gear, and a grounded heroic-fantasy palette. Transparent background if delivered as a sprite/cutout. Original IP only. Do not copy or imitate any protected ranger, archer, faction, armor, weapon, icon, game style, or franchise.
```

Output expectations:

- Transparent background for sprite/cutout candidates.
- Weapon silhouette must remain visible at small scale.
- Avoid high-detail costume noise that harms role readability.
- Should fit common ranged render height around 44 to 50 px if adapted.

Metadata reminder:

- Record scale class `infantry`, role, visual family, source/license, screenshot target, and style consistency against militia and hero.

## Template 8 - Enemy Raider Concept

Use for:

- Future hostile light enemy silhouette.

Prompt:

```text
Create an original enemy raider concept for a dark heroic fantasy RTS/RPG. The raider should be a fast hostile foot unit with a sharp, lean silhouette, rough marsh-road gear, ember-dark materials, and clear enemy identity without using copied faction symbols. It must read from a high 2.5D RTS camera and remain distinct from brute and caster enemies. Transparent background if delivered as a sprite/cutout. Original IP only. Do not copy or imitate Warcraft, Warlords Battlecry, or any protected raider, grunt, faction, armor, weapon, icon, color scheme, or game art style.
```

Output expectations:

- Transparent background for sprite/cutout candidates.
- Strong hostile silhouette at small scale.
- No protected insignia.
- Should fit common enemy render height around 44 to 50 px if adapted.

Metadata reminder:

- Record enemy visual family, source/license, intended render height, replacement priority, screenshot target, and relation to brute/caster silhouettes.

## Template 9 - UI Frame Style

Use for:

- Future UI style-frame direction.
- Not for a full UI redesign during visual foundation work.

Prompt:

```text
Design an original tactical fantasy RTS/RPG UI frame style for Ascendant Realms. The interface should feel tactile, readable, scalable, and command-focused, with restrained metal/stone/parchment-inspired surfaces, clear button states, compact panels, and readable typography areas. It should support desktop, tablet, and mobile layouts without ornamental clutter. Original IP only. Do not copy Warcraft, Warlords Battlecry, or any protected UI frame, icon set, menu layout, typography treatment, faction symbol, color scheme, or game style.
```

Output expectations:

- Style frame showing panel, button, disabled button, resource chip, objective panel, minimap frame, and status banner examples.
- No final layout implementation.
- Transparent/background-separated elements if asset extraction is intended later.

Metadata reminder:

- Record UI category, asset family, source/license, accessibility/readability review, viewport targets, and whether it is reference-only or candidate.

## Template 10 - Resource Icons

Use for:

- Future resource/capture icon replacement.

Prompt:

```text
Create an original resource icon set for a dark heroic fantasy RTS/RPG: crowns, stone, iron, and aether. Icons should be simple, readable at small UI sizes, distinct in shape and color, and suitable for resource bars, capture sites, rewards, and minimap-adjacent UI. Transparent background, centered composition, consistent lighting and outline treatment. Original IP only. Do not copy or imitate any protected game resource icons, currency symbols, faction marks, UI style, or franchise assets.
```

Output expectations:

- Transparent PNG or vector-ready concept if approved later.
- One icon each for crowns, stone, iron, aether.
- Readable at 24 px and 42 px.
- Consistent edge treatment and contrast.

Metadata reminder:

- Record icon category, file paths, source/license, usage surfaces, intended sizes, screenshot targets, and whether the icons are allowed in production.

## Future Use Workflow

1. Choose one template.
2. Confirm the target asset id and replacement priority from `src/game/assets/visualAssetManifest.ts`.
3. Generate, commission, or manually create only after approval.
4. Record source/license metadata immediately.
5. Add or update manifest entry.
6. Run `npm run validate:content`.
7. Run `npm run visual:qa`.
8. Review before/after screenshots.
9. Commit only approved assets and metadata.

## v0.8.1 Decision

These templates prepare future art work without performing it. They do not authorize generated assets, downloaded assets, broad UI redesign, Cinderfen map rework, unit replacement, desktop graphics, engine switching, or gameplay changes.
