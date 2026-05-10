# v0.9 Unit And Building Scale Reference

Date: 2026-05-10  
Status: future scale reference only. No runtime scale, radius, footprint, camera, map, gameplay, save, asset, or renderer change is included.

## Purpose

This document defines future visual scale standards before replacing Cinderfen, unit, building, shrine, or architecture assets. It consolidates the current scale facts from `docs/V08_VISUAL_SCALE_READABILITY_AUDIT.md`, unit/building data, current render constants, manifest metadata, and screenshot QA findings.

The current prototype remains tactically readable because labels, health bars, selection rings, minimap markers, and objective copy carry a lot of identity. Future art should reduce that burden only after silhouettes and scale relationships are proven in screenshots.

## Current Scale Facts

| Current entity or system | Approximate current value |
| --- | ---: |
| Hero radius | 19 world units |
| Hero target render height | 82.65 px |
| Common infantry/ranger/caster target render height | 43.80 to 47.45 px |
| Brute target render height | 58.40 px |
| Enemy commander target render height | 65.70 px |
| Command Hall max sprite height | 116.44 px |
| Barracks max sprite height | 90.88 px |
| Mystic Lodge max sprite height | 88.04 px |
| Watchtower max sprite height | 102.24 px |
| Enemy Stronghold max sprite height | 124.96 px |
| Enemy Barracks max sprite height | 90.88 px |
| Capture-site resource icon size | 42 x 42 px |
| Common Cinderfen capture-site radii | 74 to 84 world units |
| Pathfinding cell size | 80 world units |
| Fog cell size in battle systems | 96 world units |
| Formation spacing | 34 world units |

Important current read:

- buildings are visibly larger than units,
- hero is clearly larger than common infantry,
- enemy commander is not yet at full hero visual scale,
- capture sites are large rings with small icons,
- terrain material scale is not authored together with units/buildings yet.

## Scale Class 1 - Hero

Current approximate render size:

- player hero: 82.65 px target render height,
- radius: 19,
- selection ring width uses hero-specific multiplier.

Future visual target:

- largest infantry-scale battlefield silhouette,
- 1.25x to 1.45x common infantry visual height,
- distinct command pose or weapon/banner read,
- not building-sized.

Silhouette priority: very high. Hero should be recognizable before label, but label can remain in the browser prototype.

Selection ring relationship:

- ring should frame the hero's ground contact, not the full cape/weapon silhouette,
- ring can remain wider than collision radius for usability.

Health bar/label relationship:

- health bar should sit above the silhouette without clipping tall gear,
- label remains useful until art can carry class/role identity.

Minimap relationship:

- hero marker should stay more important than common unit markers and below capture/building hierarchy.

Screenshot QA target:

- `tutorial-desktop.png`,
- `tutorial-mobile.png`,
- `cinderfen-crossing-tablet.png`.

Replacement priority: high for future production coherence, medium for immediate prototype need.

## Scale Class 2 - Infantry

Current approximate render size:

- militia: 47.45 px,
- raider: 47.45 px,
- wild hound: 43.80 px if treated as small-monster but visually near infantry scale.

Future visual target:

- baseline human or small combatant scale,
- role readable by body shape, weapon, shield, stance, and movement,
- visually below hero, commander, brute, and buildings.

Silhouette priority: high. Infantry clusters must remain readable over roads, ash mud, reeds, and shallow water.

Selection ring relationship:

- ring should remain compact and below feet,
- avoid source art that extends so far outside the ring that selection feels inaccurate.

Health bar/label relationship:

- health bars are still required in the browser prototype,
- future silhouettes should make labels less necessary, not obsolete immediately.

Minimap relationship:

- common units stay smallest minimap markers.

Screenshot QA target:

- `tutorial-desktop.png`,
- `cinderfen-crossing-shrine-desktop.png`,
- `cinderfen-watch-pressure-desktop.png`.

Replacement priority: medium-high because infantry define battlefield readability.

## Scale Class 3 - Ranged Infantry

Current approximate render size:

- ranger: 43.80 px,
- role currently relies on label, projectile, and HUD.

Future visual target:

- same body scale band as infantry,
- clearer bow/crossbow/ranged silhouette,
- weapon should remain visible from default camera.

Silhouette priority: high for role reading, especially inside selected groups.

Selection ring relationship:

- ring remains infantry-sized,
- bow/crossbow overhang should not make the unit feel larger than melee infantry.

Health bar/label relationship:

- label remains protected until weapon silhouette is proven readable,
- health bar should not cover the weapon read.

Minimap relationship:

- same as infantry unless a future UI pass defines role-specific markers.

Screenshot QA target:

- `tutorial-desktop.png`,
- `tutorial-mobile.png`,
- `cinderfen-crossing-tablet.png`.

Replacement priority: medium-high.

## Scale Class 4 - Brute / Large Unit

Current approximate render size:

- brute: 58.40 px,
- stone imp: 51.10 px,
- current brute is larger than common infantry but well below building scale.

Future visual target:

- 1.25x to 1.5x common infantry visual height,
- wider and heavier silhouette,
- should communicate durability/threat without becoming a mini-building.

Silhouette priority: high for threat reading.

Selection ring relationship:

- ring can be wider than infantry,
- must still fit under the unit without implying building footprint.

Health bar/label relationship:

- health bar can be slightly wider than infantry,
- label should not be the only threat signal.

Minimap relationship:

- can remain common enemy marker unless a future minimap hierarchy pass adds larger enemy markers.

Screenshot QA target:

- `cinderfen-watch-pressure-desktop.png`,
- `cinderfen-crossing-pressure-desktop.png`.

Replacement priority: medium-high for enemy identity.

## Scale Class 5 - Caster

Current approximate render size:

- acolyte: 43.80 px,
- hexer: 43.80 px.

Future visual target:

- same body scale band as infantry,
- role read through staff/hand pose, robe shape, projectile/VFX relation, or ritual gear,
- must not disappear into fog or swamp values.

Silhouette priority: high because caster threat and support roles need quick recognition.

Selection ring relationship:

- infantry-sized ring,
- spell props should not create footprint confusion.

Health bar/label relationship:

- label remains protected,
- future VFX must not hide bars in clusters.

Minimap relationship:

- same as common units unless future UI explicitly differentiates roles.

Screenshot QA target:

- `tutorial-desktop.png`,
- `cinderfen-watch-pressure-desktop.png`.

Replacement priority: medium.

## Scale Class 6 - Commander / Enemy Hero

Current approximate render size:

- enemy commander: 65.70 px,
- radius: 18,
- currently closer to large-unit scale than player hero scale.

Future visual target:

- elite/hero scale, visually closer to the player hero than to a brute,
- unique banner, weapon, armor, or ritual silhouette,
- readable as a named threat without becoming a building-scale boss.

Silhouette priority: very high.

Selection ring relationship:

- ring may need hero-like treatment in a future implementation, but v0.9 changes nothing,
- source art should document intended visual bounds.

Health bar/label relationship:

- health bar should be clear and slightly more prominent than common units,
- label/title remains protected for named threat readability.

Minimap relationship:

- enemy hero/commander marker should remain higher priority than common units.

Screenshot QA target:

- `cinderfen-watch-pressure-desktop.png`,
- future commander-centered pressure screenshot if runtime replacement begins.

Replacement priority: high.

## Scale Class 7 - Small Building

Current approximate render size:

- player watchtower: max sprite height 102.24 px with a 48 x 72 data size,
- no separate enemy watchtower building definition exists in current data.

Future visual target:

- small footprint, clear vertical or utility role,
- visibly larger than units but below production/command buildings,
- tower shapes should read as threat only when gameplay supports it.

Silhouette priority: high if defensive or threat-related, medium for utility/support.

Selection ring relationship:

- ring should sit at foundation,
- narrow towers need enough base width for selection clarity.

Health bar/label relationship:

- leave clean roof/sky space for health bar,
- avoid bright detail directly behind the bar.

Minimap relationship:

- building marker outranks unit marker.

Screenshot QA target:

- `tutorial-desktop.png` for player tower contexts,
- `cinderfen-watch-desktop.png` for future Ashen tower/reference contexts.

Replacement priority: medium.

## Scale Class 8 - Production Building

Current approximate render size:

- barracks: max sprite height 90.88 px,
- mystic lodge: max sprite height 88.04 px,
- enemy barracks: max sprite height 90.88 px.

Future visual target:

- mid-size building,
- role readable by silhouette, entrance, staging/forge/ritual cues,
- below command/stronghold dominance.

Silhouette priority: high because production buildings drive RTS decisions.

Selection ring relationship:

- ring should align with footprint and foundation,
- overhangs should not make the selectable area feel wrong.

Health bar/label relationship:

- label and health bar remain important,
- art should leave clear top space and not bury the label in roof clutter.

Minimap relationship:

- building marker size should stay below command/stronghold if hierarchy is refined later.

Screenshot QA target:

- `tutorial-desktop.png`,
- `cinderfen-watch-desktop.png`,
- `cinderfen-watch-pressure-desktop.png`.

Replacement priority: high for enemy barracks, medium for player production.

## Scale Class 9 - Command Hall / Stronghold

Current approximate render size:

- Command Hall: max sprite height 116.44 px,
- Enemy Stronghold: max sprite height 124.96 px.

Future visual target:

- largest building tier,
- primary base anchor,
- obvious victory/defeat target relation,
- authored foundation and road relationship.

Silhouette priority: very high.

Selection ring relationship:

- ring must be broad and readable at foundation,
- art must not hide ring edges or imply a different footprint.

Health bar/label relationship:

- health bar should be cleanly above roofline,
- label remains protected for objective clarity,
- damage readability should not depend on tiny art cracks.

Minimap relationship:

- strongest building marker priority.

Screenshot QA target:

- `tutorial-desktop.png`,
- `cinderfen-crossing-desktop.png`,
- `cinderfen-watch-desktop.png`,
- `results-defeat-desktop.png` if perceived threat changes.

Replacement priority: high, especially enemy stronghold.

## Scale Class 10 - Capture-Site Landmark

Current approximate render size:

- resource/capture icon: 42 x 42 px,
- Cinderfen capture-site radii: roughly 74 to 84 world units,
- ring/progress overlays carry most site readability.

Future visual target:

- landmark larger than current icon identity but smaller than buildings,
- base silhouette stable across neutral/player/enemy/active/depleted states,
- capture ring remains the gameplay boundary.

Silhouette priority: very high for Cinder Shrine and key capture sites.

Selection ring relationship:

- not selected like a unit/building, but must coexist with capture ring and progress ring,
- landmark should sit inside the ring without making the radius feel smaller.

Health bar/label relationship:

- capture sites have labels and progress feedback,
- labels remain protected until landmark recognition is proven.

Minimap relationship:

- capture-site marker remains higher priority than units,
- future minimap art should stay diagrammatic unless separately scoped.

Screenshot QA target:

- `cinderfen-crossing-shrine-desktop.png`,
- `cinderfen-crossing-pressure-desktop.png`,
- `cinderfen-crossing-tablet.png`.

Replacement priority: critical for Cinderfen identity, high for general capture sites.

## Scale Class 11 - Environmental Prop

Current approximate render size:

- no standardized file-backed Cinderfen prop scale is approved,
- current terrain/roads/water are mostly procedural.

Future visual target:

- below units and buildings in decision priority,
- edge/identity support rather than interactive focus,
- prop scale tied to road width, unit size, shrine size, and building foundations.

Silhouette priority: low to medium. Props should not steal focus from units, roads, shrines, or buildings.

Selection ring relationship:

- no selection ring unless a prop becomes a real gameplay entity in a separate goal,
- avoid ring-like prop shapes near capture sites.

Health bar/label relationship:

- no bars or labels for decorative props,
- if a future blocker has labels/bars, it is no longer decorative and needs a separate spec.

Minimap relationship:

- decorative props should not appear on minimap unless future map readability requires special markers.

Screenshot QA target:

- `cinderfen-crossing-desktop.png`,
- `cinderfen-watch-desktop.png`,
- future before/after Cinderfen material screenshots.

Replacement priority: low to medium after core terrain, shrine, and buildings.

## Scale Consistency Rules

- Preserve gameplay truth first: radii, sizes, capture-site radii, map dimensions, pathfinding, fog, formation spacing, and camera zoom must not be changed as visual fixes in this phase.
- Future art should document both visual height and gameplay footprint relationship.
- Heroes and commanders should be visually above common units and below buildings.
- Brutes should be larger than common infantry and below commanders/hero landmarks.
- Capture-site landmarks should be larger than icons and smaller than buildings.
- Production buildings should not out-rank command halls or strongholds.
- Environmental props should not look interactable unless they are actually gameplay objects.
- Ground contact must be authored: shadows, foundations, wet ash, plinths, and roads should explain scale.
- Health bars, labels, selection rings, progress rings, and minimap markers remain review surfaces, not afterthoughts.

## What Not To Change Until Asset Replacement Begins

Do not change in v0.9:

- unit radii,
- building `size`,
- capture-site radius,
- capture timing,
- camera zoom,
- pathfinding cell size,
- fog cell size,
- formation spacing,
- map dimensions,
- building placement rules,
- health bar offsets,
- label offsets,
- selection ring sizes,
- minimap marker sizes,
- runtime sprite scale constants,
- manifest runtime entries,
- asset files.

Small visual tuning can be considered only in a later goal with before/after screenshots and full verification.

## Future Manifest Scale Metadata

Every future replacement candidate should record:

- `scaleClass`,
- `intendedWorldHeightPx`,
- `currentRenderHeightPx`,
- visual footprint notes in `notes`,
- source/source-license proof in `sourceReviewNotes`,
- screenshot targets in `screenshotQaTargets`.

Recommended note pattern:

```text
Intended as <scale class>. Current prototype target render height is <number> px; intended world visual height is <number> px. Source art must preserve readable relationship to <related classes> and must fit current label/bar/ring placement before runtime integration.
```

For reference-only style frames, use `scaleClass: "reference"` or the closest target class and mark `usage: "docs-reference"` or `manual-reference`. Do not pretend reference art is a runtime-sized asset.

## No Runtime Scaling Change

This phase does not change runtime scale. It prepares future reviewers to compare art candidates against the current playable proportions before any asset replacement begins.
