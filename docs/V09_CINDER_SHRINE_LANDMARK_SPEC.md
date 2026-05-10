# v0.9 Cinder Shrine Landmark Spec

Date: 2026-05-10  
Status: future landmark specification only. No art was generated, imported, downloaded, renamed, moved, deleted, replaced, or wired into runtime.

## Purpose

This document specifies the future Cinder Shrine and capture-site landmark direction for Cinderfen. The goal is to make the shrine read as a place in the world before any future art pass reduces reliance on rings, labels, icons, or objective-panel copy.

The current browser prototype remains unchanged. The current capture ring, progress ring, ownership color, label, objective text, and resource feedback are protected gameplay-readability tools until future art proves it can carry identity safely.

## Current Problem

The Cinder Shrine and related capture sites are tactically readable, but the readability is mostly symbolic.

Current state:

- `src/game/entities/CaptureSite.ts` renders a large capture ring using each site's gameplay radius.
- The current resource/capture icon core is 42 x 42 px.
- Common Cinderfen capture-site radii are roughly 74 to 84 world units.
- Ownership is primarily communicated through ring stroke color.
- Capture progress is a ring overlay.
- The Cinder Shrine is also explained by objective copy, status text, and the Shrine Attunement service.

Current problem:

- The capture site is readable but icon/ring-led.
- The shrine identity depends too much on text and the objective panel.
- The landmark itself is not memorable as an environmental object.
- The large ring carries more identity than the core object.
- The current icon can look like UI placed on terrain rather than a shrine in a wetland.

## Future Target

The future Cinder Shrine should be a small ember-lit shrine, waystone, or ritual marker that reads immediately from the default RTS camera.

Target read order:

1. Raised road/causeway route.
2. Cinder Shrine vertical landmark and controlled ember glow.
3. Ownership/capture ring and progress overlay.
4. Label and objective copy as confirmation.

Target qualities:

- original dark heroic fantasy landmark,
- blackened stone and ash-glass construction,
- wet ash ground contact,
- compact vertical silhouette,
- controlled ember cracks,
- readable ownership state,
- clear capture boundary retained as gameplay overlay,
- no copied franchise shrine, faction, symbol, UI, terrain, or art style.

## Required Variants

### Neutral

Meaning: unclaimed shrine, still dormant and contested.

Visual target:

- dark blackened stone,
- faint ember seams,
- cool wet ash base,
- no team-colored banner,
- ring can use resource/site color as current prototype support.

Readability goal: recognizable as the Cinder Shrine without feeling owned.

### Player-Controlled

Meaning: shrine currently belongs to the player.

Visual target:

- subtle player-friendly accent in the glow or small marker cloth,
- the same base shrine silhouette as neutral,
- no full repaint that hides the blackened material language,
- current green ownership ring remains allowed as gameplay confirmation.

Readability goal: owned-by-player at small size without relying only on label text.

### Enemy-Controlled

Meaning: shrine currently belongs to the enemy.

Visual target:

- hostile ember accent, small Ashen sigil-like shape that is original and non-franchise,
- darker heat cracks or red-orange slit light,
- no giant faction logo,
- current red ownership ring remains allowed as gameplay confirmation.

Readability goal: contested danger read without looking like an enemy stronghold.

### Active Surge State

Meaning: the Cinder Shrine surge has just triggered or the site is actively expressing its reward beat.

Visual target:

- brief, contained ember pulse,
- vertical warmth from the core stones,
- pale aether glint is allowed if it stays subtle,
- capture progress and objective feedback must stay legible.

Readability goal: noticeable reward moment that does not obscure pressure warnings, ownership, unit clusters, or health bars.

### Depleted / Claimed State

Meaning: first-capture surge is no longer available for that side or the special beat has already resolved.

Visual target:

- glow cools back to low ember seams,
- cracked stones remain visible,
- no dimming that makes the shrine look neutral if it is owned,
- ownership overlay remains the main gameplay truth.

Readability goal: site remains valuable as a capture site without falsely advertising another surge.

## Gameplay Requirements

- Ownership must be readable at small size.
- The ring can remain as a gameplay overlay.
- Capture progress ring can remain as a gameplay overlay.
- The landmark must still be visible without its label.
- The landmark must not hide units inside or near the capture radius.
- The landmark must not overlap health bars, labels, projectiles, pressure warnings, or objective text.
- The landmark should work in minimap/overview language if needed later, but the minimap can remain diagrammatic for now.
- The shrine should not imply new interactable mechanics, damage zones, building placement, workers, construction, harvest, or permanent campaign reward.
- Any future visual replacement must preserve current capture radius, capture timing, first-capture surge behavior, Shrine Attunement behavior, pressure-warning ordering, and save compatibility unless a separate gameplay goal explicitly changes them.

## Visual Language

Core materials:

- blackened basalt stone,
- ash-glass chips or fractured reflective stone,
- wet ash base,
- ember cracks,
- old ruin plinth edges,
- small charred timber or black iron bindings if needed.

Shape language:

- compact vertical silhouette,
- broken waystone or small shrine cluster,
- low plinth that sits inside the capture ring,
- asymmetric but readable outline,
- no giant statue, no altar copied from known RTS/RPG franchises, no skull-spike shorthand.

Light language:

- cold wet Cinderfen ambient base,
- small warm ember core,
- ownership accents are secondary to gameplay overlays,
- active surge may pulse but should never become a full-screen VFX event.

Ground contact:

- visible wet ash at the base,
- small broken stone ring or plinth edge,
- mud/reed transition that helps the landmark sit in the map,
- no floating icon treatment.

Original-IP guardrails:

- no Warcraft, Warlords Battlecry, Diablo, Elder Scrolls, or other protected shrine lookalikes,
- no copied factions, symbols, banners, unit motifs, maps, terrain kits, UI, music, lore, or names,
- no direct copyrighted reference ingestion,
- no prompt that asks for "in the style of" a living artist or protected franchise.

## Prompt Template - Concept Art

```text
Create an original dark heroic fantasy RTS concept sheet for the Cinder Shrine, a compact ember-lit capture-site landmark in an ash-glass wetland called Cinderfen. Use blackened basalt stone, wet ash ground contact, fractured ash-glass chips, small ember cracks, and a readable vertical waystone silhouette. It must read from a top-down or high 2.5D RTS camera as an important capture site, while leaving room for a gameplay ownership ring and progress overlay. Original IP only. Do not copy Warcraft, Warlords Battlecry, or any protected shrine, faction, symbol, building, UI, terrain, map, lore, or art style. No logos, no copied franchise shapes, no characters.
```

Output expectations:

- 3 to 5 silhouette options,
- neutral/player/enemy/active/depleted notes,
- clear top-down or high 2.5D readability,
- no direct runtime asset delivery unless separately approved later.

## Prompt Template - Transparent-Background Sprite

```text
Design an original transparent-background RTS sprite candidate for the Cinder Shrine landmark. Compact blackened stone waystone shrine with wet ash base, subtle ember cracks, small vertical silhouette, no copied symbols, no existing franchise influence, readable at about 64 to 96 px rendered height from a high 2.5D camera. Leave visual space for an external capture ring, progress ring, label, and ownership color overlay. Original IP only; no Warcraft, Warlords Battlecry, protected faction marks, copied UI icons, or copyrighted reference ingestion.
```

Output expectations:

- transparent background,
- centered sprite,
- clean silhouette at small size,
- no baked-in capture ring unless specifically requested for a non-runtime reference,
- source/tool/artist/license fields must be recorded immediately after creation.

## Prompt Template - 2.5D / Isometric Landmark

```text
Create an original 2.5D isometric-style Cinder Shrine landmark for a dark heroic fantasy RTS/RPG battlefield. The shrine is a small black basalt and ash-glass waystone cluster on wet ash, with ember-lit cracks and a low ruined plinth. It should be readable from an overhead or high 2.5D camera, not a close-up illustration. Keep the silhouette compact, vertical, non-franchise, and compatible with current RTS capture-ring overlays. No copied game, no Warcraft, no Warlords Battlecry, no protected symbols, no existing faction architecture, no logo.
```

Output expectations:

- angle compatible with current battlefield sprites,
- clear ground contact,
- no extreme perspective,
- no visual footprint that suggests a building or blocker.

## Prompt Template - Ownership States

```text
Create an original ownership-state sheet for the Cinder Shrine capture-site landmark: neutral, player-controlled, enemy-controlled, active surge, and depleted/claimed. Keep the same base silhouette across all states. Use subtle state accents only: dormant ember seams for neutral, player-friendly accent for player ownership, hostile ember accent for enemy ownership, contained pulse for active surge, cooled ember seams for depleted. The gameplay capture ring and progress ring remain separate overlays. Original IP only; no copied franchise shrine, symbol, faction, UI, or terrain style.
```

Output expectations:

- five labeled state concepts,
- same silhouette and footprint across states,
- ownership readable at small RTS scale,
- no state that can be confused with unit selection, projectile VFX, resource pickups, or objective arrows.

## Manifest Fields Required Later

Future Cinder Shrine entries must include, at minimum:

- `id`
- `filePath`
- `category: "capture-site-icon"` for direct replacement or `"reference"` for style-frame references
- `displayName`
- `currentStatus`
- `sourceType`
- `licenseStatus`
- `reviewStatus`
- `usage`
- `usedBy`
- `visualFamily: "cinderfen shrine"` or more specific state family
- `scaleClass: "capture-site"`
- `intendedWorldHeightPx`
- `currentRenderHeightPx`
- `silhouetteReadability`
- `styleConsistency`
- `replacementPriority: "high"` or `critical` if replacing the core Cinder Shrine identity
- `notes`
- `sourceReviewNotes`
- `allowedInProduction`
- `needsReview`
- `screenshotQaTargets`

Recommended future ids:

- `cinderfen_cinder_shrine_style_frame_reference`
- `cinderfen_cinder_shrine_neutral_candidate`
- `cinderfen_cinder_shrine_player_owned_candidate`
- `cinderfen_cinder_shrine_enemy_owned_candidate`
- `cinderfen_cinder_shrine_active_surge_candidate`
- `cinderfen_cinder_shrine_depleted_candidate`

Policy:

- Reference/style-frame entries stay `usage: "docs-reference"` or `manual-reference`.
- Candidate sprite entries stay `usage: "unused"` until runtime integration is separately approved.
- `allowedInProduction` remains `false` until source/license proof, manifest validation, screenshot QA, and human review are complete.
- Unknown-source assets must not be promoted.

## Screenshot QA Targets

Required current targets for future shrine work:

- `cinderfen-crossing-desktop.png`: shrine context and road approach.
- `cinderfen-crossing-shrine-desktop.png`: shrine after capture.
- `cinderfen-crossing-pressure-desktop.png`: shrine-related pressure warning context.
- `cinderfen-crossing-tablet.png`: ownership and HUD density at tablet size.
- `tutorial-mobile.png`: general battle label/bar density comparison.
- Future before/after shrine screenshots if runtime replacement begins.

Review questions:

- Can the site be identified as the Cinder Shrine without reading its label?
- Does the ownership state remain readable with the existing ring?
- Does the landmark stay visible under fog, pressure warnings, and unit clusters?
- Does active surge VFX support the reward beat without hiding objective or pressure feedback?
- Does the landmark avoid looking like a building, resource pickup, enemy tower, or road marker?
- Does it preserve route readability and capture-site radius comprehension?
- Are source/license metadata complete before commit?

## What This Spec Does Not Do

- No generated art.
- No image API calls.
- No imported art.
- No downloaded images.
- No runtime asset replacement.
- No runtime manifest entries.
- No capture-site radius change.
- No map data change.
- No new rewards, campaign progression, Shrine Attunement behavior, pressure behavior, or save version change.
- No broad BattleScene, CaptureSite, UI, minimap, or renderer rewrite.

## v0.9 Decision

The Cinder Shrine should become a landmark-first capture site in a future visual pass, but v0.9 only defines the target. Current rings, icons, labels, and objective copy remain valid prototype readability support.
