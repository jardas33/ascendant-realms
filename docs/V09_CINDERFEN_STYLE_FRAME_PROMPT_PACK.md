# v0.9 Cinderfen Style-Frame Prompt Pack

Date: 2026-05-10  
Status: prompt/specification pack only. No images were generated, downloaded, imported, committed, approved, or wired into runtime.

## Purpose

This prompt pack prepares safe future briefs for manual asset generation, commissioning, or internal art exploration after v0.9. It is deliberately source/license cautious and gameplay-readability driven.

Using these prompts later is not enough to ship an asset. Every future output still needs source/license metadata, manifest review, screenshot QA, human review, and a separate scoped implementation plan before runtime integration.

## Global Requirements For Every Prompt

Every future generation or art request must include:

- original IP only,
- no copying Warcraft, Warlords Battlecry, or any other protected franchise, faction, unit, building, terrain, UI, map, icon, symbol, logo, music, lore, or style-specific expression,
- no hidden copyrighted source images,
- no "in the style of" protected franchise or living artist,
- dark heroic fantasy RTS/RPG tone,
- top-down or high 2.5D RTS gameplay clarity,
- browser prototype readability notes,
- future desktop-quality production notes,
- scale/readability constraints,
- forbidden elements,
- output expectations,
- source/license metadata fields to fill immediately after creation,
- manifest update checklist,
- screenshot QA checklist.

## Metadata Fields To Fill After Any Future Output

- asset id
- prompt text
- generation tool, artist, vendor, or source
- generation date or creation date
- source files if any
- license terms
- allowed use
- reviewer and review date
- `currentStatus`
- `sourceType`
- `licenseStatus`
- `reviewStatus`
- `usage`
- `usedBy`
- `visualFamily`
- `scaleClass`
- `intendedWorldHeightPx` when relevant
- `currentRenderHeightPx` when relevant
- `silhouetteReadability`
- `styleConsistency`
- `replacementPriority`
- `allowedInProduction`
- `needsReview`
- screenshot QA targets
- source review notes

## Shared Manifest Update Checklist

- Add or update `src/game/assets/visualAssetManifest.ts` only when a concrete file or reference is approved for tracking.
- Use `usage: "docs-reference"` or `manual-reference` for style-frame/reference material.
- Use `usage: "unused"` for candidate files not wired into runtime.
- Use `usage: "runtime"` only in a later runtime-integration goal.
- Keep `allowedInProduction: false` until source/license proof and production review are complete.
- Keep `needsReview: true` for generated, unknown, external-reference, candidate, or unproven assets.
- Add `screenshotQaTargets` before any runtime replacement.
- Run `npm run validate:content` after any manifest edit.

## Shared Screenshot QA Checklist

- Run `npm run visual:qa` for future visual candidates that affect runtime or before/after review.
- Use human review; do not rely on pixel-perfect diffs.
- Confirm zero browser console errors.
- Confirm roads, shrines, units, buildings, labels, bars, rings, minimap, and HUD remain readable.
- Compare desktop and tablet battle screenshots for Cinderfen.
- Include mobile battle density when labels, bars, rings, or HUD relation changes.

## Prompt 1 - Cinderfen Terrain Material Style Frame

Prompt:

```text
Create an original dark heroic fantasy RTS/RPG terrain material style frame for Cinderfen, an ash-glass wetland battlefield. Show blackened raised causeways, wet charcoal ash mud, shallow reflective blackwater, deep swamp pools, dead reed beds, ruined basalt edging, controlled ember scorch marks, and cool blue-green cinder haze. The view must read from a top-down or high 2.5D RTS camera: roads obvious first, shrine/landmark space second, units and selection rings always above terrain noise. This is original IP only. Do not copy Warcraft, Warlords Battlecry, or any protected franchise terrain, map, faction, UI, symbol, color composition, or art style. No characters, no logos, no direct copyrighted references.
```

Browser prototype notes:

- current gameplay labels, bars, rings, minimap, and fog must remain readable,
- do not imply changed pathing, hazards, damage, stealth, or blockers.

Future desktop notes:

- can show richer wetness, lighting, and material layering,
- must still preserve RTS decision clarity.

Scale/readability requirements:

- road width should support group movement,
- terrain detail should stay lower priority than units,
- capture-site clear space must be visible.

Forbidden elements:

- generic dark sludge,
- saturated lava everywhere,
- franchise terrain lookalikes,
- unreadable ultra-detail,
- UI arrows or objective symbols baked into terrain.

Output expectations:

- one wide style frame or small material callout sheet,
- no runtime tile delivery unless separately approved,
- notes for road/water/mud/reed/fog/ruin/ember materials.

Source/license metadata to fill: all fields from "Metadata Fields To Fill After Any Future Output".

Manifest update checklist: track as `category: "reference"` or `terrain`, `usage: "docs-reference"` until approved.

Screenshot QA checklist: compare future interpretation against `cinderfen-crossing-desktop.png`, `cinderfen-crossing-tablet.png`, `cinderfen-watch-desktop.png`, and pressure screenshots.

## Prompt 2 - Cinderfen Raised Road / Causeway

Prompt:

```text
Design an original Cinderfen raised road/causeway material for a dark heroic fantasy RTS/RPG. The road is a blackened causeway across wet ash marsh, built from basalt slabs, charred timber braces, compacted ash, broken stone edging, muddy margins, dead reeds, and subtle wet glints. It must be readable from a top-down or high 2.5D gameplay camera as passable terrain, with modular straight, bend, fork, and broken-edge thinking. Original IP only; do not copy Warcraft, Warlords Battlecry, protected terrain kits, maps, UI, faction symbols, or art styles.
```

Browser prototype notes:

- preserve current route readability and lane expectations,
- avoid art that implies bridges, destructible roads, or pathing changes.

Future desktop notes:

- can include modular material variants, edge height, wet shadows, and road-to-shrine transitions.

Transparent background requirement:

- required only if delivered as tile/decal candidates; style frames can be opaque reference images.

Scale/readability requirements:

- main road reads stronger than side paths,
- edge detail cannot look like units, pickups, capture sites, or projectiles.

Forbidden elements:

- painted guide strokes,
- glowing lane arrows,
- franchise road motifs,
- over-dense pebbles that hide infantry.

Output expectations:

- straight, bend, fork, broken-edge, and flooded-edge notes,
- optional tile/decal variants if approved later,
- no runtime-ready file unless separate asset workflow approves it.

Metadata, manifest, and screenshot QA:

- fill all metadata fields,
- track as terrain/reference candidate only,
- QA against Crossing, Watch, tablet, and pressure screenshots.

## Prompt 3 - Cinder Shrine Landmark

Prompt:

```text
Create an original Cinder Shrine capture-site landmark for Cinderfen, a compact ember-lit waystone shrine made from blackened basalt, ash-glass fractures, wet ash ground contact, small ruined plinth edges, and controlled ember cracks. It must read from a top-down or high 2.5D RTS camera as a capture-site landmark before labels are read, while leaving room for separate gameplay ownership ring, progress ring, label, and objective feedback. Dark heroic fantasy RTS/RPG tone. Original IP only; no Warcraft, no Warlords Battlecry, no protected shrine, faction symbol, UI icon, terrain kit, map, logo, or art style.
```

Browser prototype notes:

- current ring and label remain allowed,
- landmark should not hide units inside capture radius.

Future desktop notes:

- can have richer light/shadow and state VFX, but base silhouette must remain stable.

Transparent background requirement:

- required for sprite/cutout candidates.

Scale/readability requirements:

- larger than the current 42 px icon identity,
- smaller than production buildings,
- readable without a label in shrine screenshot.

Forbidden elements:

- giant faction logos,
- copied altars or shrine shapes,
- skull-spike shorthand,
- capture ring baked into runtime sprite unless only a reference mockup.

Output expectations:

- 3 to 5 silhouette options or one refined landmark,
- transparent background for sprite candidates,
- state notes for neutral/player/enemy/active/depleted.

Metadata, manifest, and screenshot QA:

- fill all metadata fields,
- use `scaleClass: "capture-site"`,
- QA against `cinderfen-crossing-shrine-desktop.png`, pressure, tablet, and mobile density reference.

## Prompt 4 - Cinder Shrine Ownership States

Prompt:

```text
Create an original Cinder Shrine ownership-state sheet for a dark heroic fantasy RTS/RPG: neutral, player-controlled, enemy-controlled, active surge, and depleted/claimed. Keep the same compact black basalt and ash-glass shrine silhouette in every state. Use subtle state accents only: dormant ember seams for neutral, player-friendly accent for player, hostile ember accent for enemy, contained pulse for active surge, cooled seams for depleted. Gameplay ownership ring and progress ring remain separate overlays. Original IP only; do not copy Warcraft, Warlords Battlecry, protected faction marks, shrine symbols, UI, VFX, or art style.
```

Browser prototype notes:

- ownership must remain clear with current ring colors,
- active surge cannot obscure pressure/status feedback.

Future desktop notes:

- can include richer VFX callouts, but state transitions must remain readable at RTS scale.

Transparent background requirement:

- required for sprite or state overlay candidates.

Scale/readability requirements:

- same footprint across states,
- state accents readable without changing capture radius perception.

Forbidden elements:

- giant state banners,
- state shapes that look like new objectives,
- full recolors that hide material identity.

Output expectations:

- five state concepts on one sheet,
- clear labels on the sheet only,
- source/license metadata attached to the whole output and any extracted states.

Metadata, manifest, and screenshot QA:

- fill all metadata fields per state if split into files,
- QA shrine capture, pressure, tablet, and future before/after screenshots.

## Prompt 5 - Ashen Stronghold

Prompt:

```text
Design an original Ashen stronghold for a Cinderfen dark heroic fantasy RTS/RPG battlefield. It is the largest enemy base target: black basalt base, scorched timber upper mass, black iron braces, hard angular roofline, ember-lit command slits, wet ash foundation, and a hostile silhouette readable from a top-down or high 2.5D camera. Leave room for browser prototype health bar, label, and selection ring. Original IP only; do not copy Warcraft, Warlords Battlecry, or any protected fortress, faction, symbol, UI, terrain, map, color scheme, or art style.
```

Browser prototype notes:

- preserve current enemy stronghold footprint and perceived target role,
- no implied new armor, damage, construction, workers, or reward behavior.

Future desktop notes:

- can include stronger foundation, lighting, damage states, and road relationship later.

Transparent background requirement:

- required for sprite candidates.

Camera notes:

- high 2.5D or orthographic-like RTS angle compatible with current battle art.

Scale/readability requirements:

- command/stronghold tier,
- dominant but not oversized beyond current gameplay footprint,
- health bar space above roofline.

Forbidden elements:

- copied fortress profiles,
- giant logo,
- protected faction motifs,
- visual details that look like extra units.

Output expectations:

- concept or sprite candidate with footprint notes,
- source/license metadata before any manifest entry.

Metadata, manifest, and screenshot QA:

- `category: "building-concept"` or `"building-sprite"`,
- QA against Cinderfen Watch, Crossing, pressure, and defeat context screenshots.

## Prompt 6 - Ashen Barracks / War Camp

Prompt:

```text
Design an original Ashen barracks or war camp for a dark heroic fantasy RTS/RPG. It should read as enemy production from a top-down or high 2.5D camera: long low war-camp mass, charred beams, guarded entry, black iron binding, basalt stones, subtle ember forge or ritual slit glow, weapon-rack shapes, and wet ash ground contact. Smaller than the stronghold and distinct from player buildings. Original IP only; no Warcraft, no Warlords Battlecry, no protected barracks, faction, UI, symbol, terrain kit, map, or art style.
```

Browser prototype notes:

- preserve current enemy barracks role and size band,
- no visible workers or new production mechanics.

Future desktop notes:

- can include more authored staging yard and faction construction language later.

Transparent background requirement:

- required for sprite candidates.

Scale/readability requirements:

- production-building tier,
- readable entrance/staging shape,
- label/bar compatibility.

Forbidden elements:

- stronghold-like silhouette,
- neutral camp confusion,
- copied military huts or faction marks.

Output expectations:

- concept or sprite candidate,
- no extra units baked into the image,
- footprint and render-height notes.

Metadata, manifest, and screenshot QA:

- fill all metadata fields,
- QA against Watch/pressure/Crossing screenshots and future selected-building view.

## Prompt 7 - Ashen Watchtower

Prompt:

```text
Design an original Ashen watchtower concept for Cinderfen road pressure in a dark heroic fantasy RTS/RPG. Use a tall narrow black timber and basalt silhouette, black iron braces, guarded sight slot, small ember lantern, wet ash footing, and causeway-facing threat geometry. It must read as a tower from a high 2.5D gameplay camera while staying distinct from capture shrines and strongholds. Original IP only; no Warcraft, no Warlords Battlecry, no protected tower silhouette, faction symbol, terrain, UI, map, or art style.
```

Browser prototype notes:

- no current enemy tower replacement is authorized,
- prompt output is a future reference unless building data and implementation scope are separately approved.

Future desktop notes:

- can support future threat readability and road-control composition.

Transparent background requirement:

- required for sprite candidates.

Scale/readability requirements:

- tall/narrow, smaller footprint than production,
- must leave health bar/label room if used as a gameplay building.

Forbidden elements:

- beacon that looks like a capture site,
- over-wide production silhouette,
- protected tower profiles.

Output expectations:

- concept reference or sprite candidate,
- threat/readability notes,
- no runtime import.

Metadata, manifest, and screenshot QA:

- track as reference/candidate only,
- QA with Cinderfen Watch and pressure views if ever integrated.

## Prompt 8 - Cinderfen Environmental Prop Sheet

Prompt:

```text
Create an original Cinderfen environmental prop sheet for a dark heroic fantasy RTS/RPG wetland: dead reed clumps, charred stumps, broken basalt road markers, drowned ruin fragments, ash-glass shards, wet stones, scorched plinth scraps, small non-interactable ember stones, and mud-bank details. Props must support roads, water edges, shrine bases, and Ashen outposts without hiding units or looking like capture sites, enemies, resource pickups, or blockers. Original IP only; no copied franchise props, terrain kit, map symbols, UI icons, or art style.
```

Browser prototype notes:

- decorative only unless separate map/renderer goal approves placement,
- must not imply harvest, cover, damage, or blockers.

Future desktop notes:

- can become modular set dressing after terrain and landmark identity are stable.

Transparent background requirement:

- required for prop sprites/cutouts.

Scale/readability requirements:

- below units/buildings in visual priority,
- prop silhouettes should stay small and edge-focused.

Forbidden elements:

- interactable-looking icons,
- ring shapes,
- unit-sized props,
- high-contrast clutter in command spaces.

Output expectations:

- sheet of small props with scale notes,
- optional grouping by road, water, shrine, outpost.

Metadata, manifest, and screenshot QA:

- track as `terrain` or `reference`,
- QA against Crossing and Watch screenshots before placement.

## Prompt 9 - Cinderfen Minimap / Material Readability Reference

Prompt:

```text
Create an original Cinderfen minimap and material readability reference for a dark heroic fantasy RTS/RPG. Show how blackened causeways, ash mud, shallow blackwater, deep swamp, capture sites, enemy base areas, fog states, and pressure routes could map to clear diagrammatic colors and markers. Keep it gameplay-readable and not painterly. Original IP only; do not copy Warcraft, Warlords Battlecry, protected minimap UI, map layout, faction markers, symbols, or color scheme.
```

Browser prototype notes:

- minimap remains diagrammatic,
- do not imply changed map layout or new markers.

Future desktop notes:

- can guide eventual minimap material/marker hierarchy after terrain replacement.

Transparent background requirement:

- not required unless marker icons are separately requested later.

Scale/readability requirements:

- capture sites and buildings outrank units,
- fog states remain distinct,
- roads readable at minimap scale.

Forbidden elements:

- copied minimap frame/marker language,
- pixel-perfect map recreation from another game,
- ornate art that weakens tactical scan.

Output expectations:

- reference sheet, not runtime UI,
- color/marker callouts,
- no actual Cinderfen map rewrite.

Metadata, manifest, and screenshot QA:

- track as reference only,
- QA against all battle screenshots if future minimap visuals change.

## Prompt 10 - UI / Background Mood Frame

Prompt:

```text
Create an original Ascendant Realms Cinderfen UI/background mood frame for a dark heroic fantasy RTS/RPG. It should support the ash-glass wetland identity with restrained blackened stone, wet ash, cold blue-green haze, controlled ember accents, compact command-focused UI surfaces, and readable tactical hierarchy. It must not redesign the full interface or copy protected UI frames, icons, typography, layouts, faction symbols, menus, or color schemes from Warcraft, Warlords Battlecry, or any other franchise.
```

Browser prototype notes:

- no full UI redesign,
- current HUD density, labels, and accessibility remain protected,
- frame is a mood/reference only.

Future desktop notes:

- can inform eventual UI art direction after gameplay surfaces stabilize.

Transparent background requirement:

- only required for extracted UI components in a later approved UI asset pass.

Scale/readability requirements:

- compact command interface,
- button text and status information must remain readable on desktop, tablet, and mobile.

Forbidden elements:

- ornate frames that crowd the playfield,
- copied RTS UI layouts,
- excessive parchment/beige or one-note purple/blue gradient identity,
- UI that hides objectives, minimap, selected-unit panel, or battle status.

Output expectations:

- one mood frame with panel/resource/status/button examples,
- no CSS or runtime implementation,
- no final UI asset approval.

Metadata, manifest, and screenshot QA:

- track as UI/reference only,
- QA future UI changes across main menu, campaign map, tutorial, mobile tutorial, results, inventory, and asset gallery screenshots.

## Use Policy

These prompts are ready for a later approved art workflow, but v0.9 does not use them to generate anything. A future user or artist must choose one prompt, record metadata immediately, keep outputs out of runtime until approved, update manifest entries conservatively, validate content, run screenshot QA, and commit only reviewed materials.
