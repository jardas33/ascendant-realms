# v0.8 Visual Scale And Readability Audit

Date: 2026-05-10  
Scope: current browser prototype entity scale, tactical readability, and future scale standard.

## Purpose

This audit records the current size rules for units, heroes, buildings, capture sites, labels, health bars, selection rings, minimap markers, camera assumptions, and grid scale. It does not implement scale changes. The goal is to separate safe prototype readability from future production art requirements.

## Files Inspected

- `src/game/entities/BaseEntity.ts`
- `src/game/entities/Unit.ts`
- `src/game/entities/Hero.ts`
- `src/game/entities/Building.ts`
- `src/game/entities/CaptureSite.ts`
- `src/game/data/units.ts`
- `src/game/data/buildings.ts`
- `src/game/data/maps/*.ts`
- `src/game/battle/BattleSceneMapRenderer.ts`
- `src/game/battle/BattleSceneSnapshots.ts`
- `src/game/ui/MinimapView.ts`
- `src/game/systems/CameraSystem.ts`
- `src/game/systems/PathfindingGrid.ts`
- `src/game/battle/BattleSceneSystems.ts`
- `src/game/config.ts`
- `src/game/core/Constants.ts`

## Current Size Rules

### Viewport And Camera

| Rule | Current value |
| --- | --- |
| Phaser scale mode | `Phaser.Scale.RESIZE` |
| Default configured viewport | 1280 x 720 |
| Battle camera bounds | active map width/height |
| Battle camera zoom | default camera zoom, no explicit zoom tuning |
| Camera pan speed | 520 world units per second |
| Camera minimap rectangle | `camera.width / camera.zoom` by `camera.height / camera.zoom` |

Readability note: the camera is simple and predictable. There is no zoom layer to compensate for unit scale, so entity readability depends heavily on sprite/label/bar constants and screen-space HUD layout.

### Tactical Grid And Fog

| System | Current value |
| --- | --- |
| Pathfinding cell size | 80 world units |
| Battle fog cell size | 96 world units |
| Default `FogOfWarSystem` constructor value | 160 world units when not overridden |
| Formation spacing | 34 world units |
| Capture time | 4 seconds |

Readability note: pathfinding cells, fog cells, and capture-site radii are all large relative to infantry. This is acceptable for a broad prototype but means exact visual footprints should not pretend to be pixel-perfect tactical bounds.

### Unit Radii And Sprite Scale

| Unit | Radius | Runtime sprite target height |
| --- | ---: | ---: |
| Hero | 19 | `radius * 4.35` = 82.65 |
| Militia | 13 | `radius * 3.65` = 47.45 |
| Ranger | 12 | `radius * 3.65` = 43.80 |
| Acolyte | 12 | `radius * 3.65` = 43.80 |
| Raider | 13 | `radius * 3.65` = 47.45 |
| Hexer | 12 | `radius * 3.65` = 43.80 |
| Brute | 16 | `radius * 3.65` = 58.40 |
| Enemy Commander | 18 | `radius * 3.65` = 65.70 |
| Wild Hound | 12 | `radius * 3.65` = 43.80 |
| Stone Imp | 14 | `radius * 3.65` = 51.10 |

Additional unit layout:

- Unit sprite origin is `(0.5, 0.8)`.
- Unit sprite y offset is `radius * 0.1`.
- Unit shadow is an ellipse `radius * 2.5` wide by `radius * 0.72` high.
- Unit view depth is 10 by default.
- Hero view depth is 12.
- Enemy hero still uses the normal unit sprite-height multiplier unless rendered through a separate hero path later.

Readability note: the hero is clearly bigger than common units. Brutes and enemy commanders are larger, but source art and labels do more identity work than pure silhouette.

### Unit Selection Rings

| Entity | Selection radius base | Width | Height | Y offset |
| --- | ---: | ---: | ---: | ---: |
| Hero | `max(radius + 7, 23)` | radius base * 2.35 | `max(9, base * 0.62)` | visual bottom + 0.5 |
| Non-hero unit | `max(radius + 7, 20)` | radius base * 2.15 | `max(9, base * 0.56)` | visual bottom + 0.5 |
| Base default | `radius + 7` | base * 2.1 | `max(8, base * 0.62)` | 0 unless overridden |

Readability note: rings are wider than collision radii and function as ground markers. This is correct for selection usability, but future final art needs a style pass so rings do not look like debug ellipses.

### Unit Health Bars And Labels

| Entity | Health bar | Health bar y | Label y |
| --- | --- | --- | --- |
| Hero | 56 x 6 | visual top - 13 | visual bottom + 7 |
| Non-hero unit | 42 x 5 | visual top - 11 | visual bottom + 7 |
| Base default | `max(34, radius * 2.4)` x 5 | `-radius - 13` | `radius + 11` |

Label style:

- Font: Verdana.
- Size: 10 px.
- Fill: `#e9ecd8`.
- Stroke: `#111713`, thickness 3.

Readability note: bars and labels are functional but dense. The current battlefield remains legible because text carries identity. Future art should reduce reliance on always-visible labels.

### Building Footprints And Sprite Scale

| Building | Data size | Runtime radius | Sprite max width | Sprite max height |
| --- | ---: | ---: | ---: | ---: |
| Command Hall | 96 x 82 | 48 | width * 1.24 = 119.04 | height * 1.42 = 116.44 |
| Barracks | 82 x 64 | 41 | width * 1.24 = 101.68 | height * 1.42 = 90.88 |
| Mystic Lodge | 72 x 62 | 36 | width * 1.24 = 89.28 | height * 1.42 = 88.04 |
| Watchtower | 48 x 72 | 36 | width * 1.24 = 59.52 | height * 1.42 = 102.24 |
| Enemy Stronghold | 104 x 88 | 52 | width * 1.24 = 128.96 | height * 1.42 = 124.96 |
| Enemy Barracks | 82 x 64 | 41 | width * 1.24 = 101.68 | height * 1.42 = 90.88 |

Additional building layout:

- Building sprite origin is `(0.5, 0.66)`.
- Sprite scale is `min(maxWidth / sprite.width, maxHeight / sprite.height)`.
- Enemy building sprites receive tint `0xf0aaa0`.
- Building shadow is an ellipse `size.width * 1.1` by `size.height * 0.46`.
- Building view depth is 5.

Readability note: buildings are visibly bigger than units and tactically clear. The scale is practical but not yet architecturally grounded because footprint, sprite silhouette, and terrain foundation are not authored as one asset set.

### Building Selection Rings, Health Bars, And Labels

| Building rule | Current value |
| --- | --- |
| Selection radius base | `max(radius + 7, max(width, height) * 0.64)` |
| Selection width | `max(width * 1.16, base * 2.05)` |
| Selection height | `max(18, height * 0.38)` |
| Selection y | visual bottom - 2 |
| Health bar width | `max(64, width * 1.08)` |
| Health bar height | 7 |
| Health bar y | visual top - 14 |
| Label y | visual bottom + 8 |

Readability note: building rings and bars are clear. They are also visually heavy, especially when selected alongside unit labels.

### Capture Sites

| Rule | Current value |
| --- | --- |
| Common map capture-site radii | 74 to 86 |
| Cinderfen Causeway radii | 76, 76, 78, 84 |
| Cinderfen Watchpost radii | 74, 76, 78 |
| Ground underlay | radius + 30 |
| Ground fill | radius + 18 |
| Ground outer stroke | radius + 16 |
| Ground inner stroke | radius + 4 |
| Runtime ring | radius, fill alpha 0.22, stroke width 4 |
| Runtime progress ring | radius - 8, stroke width 3 |
| Resource icon size | 42 x 42 |

Readability note: capture sites are large compared with units, which is good for play. The icon-to-ring ratio is weak for visual identity: the ring carries the site more than the landmark.

### Minimap Markers

| Marker | Current size |
| --- | ---: |
| Capture site | circle radius 3.2 |
| Building | `max(2.8, min(5, max(width, height) / 38))` |
| Neutral camp | diamond radius 2.5 in snapshot, 2.4 fallback in renderer |
| Player rally | 2.3 |
| Hero | 2.1 |
| Enemy hero | diamond radius 2.6 |
| Common unit | circle radius 1.35 |
| Ping | animated radius from 2.2 to 11.2 |
| Fog unseen opacity | 0.78 |
| Fog explored opacity | 0.34 |

Readability note: minimap hierarchy is appropriate: sites and buildings outrank units. The minimap is diagrammatic and should stay that way until a UI-art pass defines the final marker language.

## Obvious Inconsistencies

1. Enemy commander scale is close to large unit scale, not hero scale.
   - `enemy_commander` radius 18 becomes about 65.7 px target height.
   - Player hero radius 19 becomes about 82.65 px target height.
   - This may be acceptable for the current enemy-hero placeholder, but future commanders should have a deliberate hero/elite scale rule.

2. Capture-site rings are much larger than their visible core icons.
   - A 42 px icon sits inside a 74 to 86 world-unit radius ring plus extra ground strokes.
   - This makes sites readable but also makes the world feel icon-led.

3. Building sprite scale is footprint-based, but source-art proportions can still disagree.
   - Runtime scale creates practical consistency.
   - It cannot guarantee matching roof height, perspective, wall thickness, or base contact.

4. Labels and bars carry too much tactical identity.
   - This is useful now.
   - It will become unacceptable once the project aims at premium battlefield presentation.

5. Terrain material scale is not tied to entity scale.
   - Road widths are 30 to 56 world units.
   - Infantry radii are 12 to 16, hero radius is 19, buildings are 48 to 104 wide.
   - The tactical proportions work, but the art treatment does not make roads, water, buildings, and units feel authored to one camera scale.

6. Fog and pathfinding grids do not visually explain themselves.
   - 80 world-unit pathfinding cells and 96 world-unit fog cells are simulation choices.
   - The rendered map does not expose or hide these as a visual design principle.

## Safe Scale Tweaks Possible Without Assets

These are technically safe if a future screenshot/e2e pass proves a specific readability issue:

- Slight selection ring opacity or stroke tuning.
- Slight label y-offset changes to reduce bar/label crowding.
- Slight health bar y-offset changes for tall sprites.
- Slight minimap unit marker size increase for visibility.
- Slight capture-site icon size increase if shrine/site salience remains weak.
- Slight capture-site ring opacity reduction if the site reads too UI-heavy.
- Minor terrain overlay opacity tuning.

These are readability tweaks only. They will not solve the art-direction mismatch.

## Risky Scale Tweaks

These should not be done without screenshots and focused layout/browser checks:

- Changing unit radii, because radii affect collision, targeting, pathing, capture checks, selection, and spacing.
- Changing building `size`, because it affects footprint, placement, pathfinding, collision, minimap size, and selection.
- Changing capture-site radius, because it affects capture gameplay and balance.
- Changing camera zoom, because it would affect every map, HUD relationship, minimap camera rectangle, e2e screenshot assumptions, and player pacing.
- Changing pathfinding or fog cell size as a visual fix.
- Making labels conditional before silhouettes and UI can carry identity.
- Scaling all sprites globally without checking source-art proportions.

## Proposed Future Scale Standard

This is a target for future art and implementation planning, not a v0.8 code change.

| Category | Future target |
| --- | --- |
| Hero | Largest infantry-scale readable silhouette; roughly 1.25x to 1.45x common infantry visual height; special selection/VFX treatment. |
| Common infantry | Baseline human scale; readable weapon pose at default camera; role legible without label. |
| Ranged infantry | Same body scale as infantry but clearer weapon/pose silhouette and projectile read. |
| Brute or large enemy | 1.25x to 1.5x common infantry visual height; wider footprint but not building-sized. |
| Enemy commander | Hero/elite scale, not just a large unit; unique banner/VFX/silhouette. |
| Monster | Size tier depends on threat: small beast near infantry, heavy beast above brute, boss only when explicitly designed. |
| Command building | Visibly dominant base anchor, about 2.0x to 2.5x common building footprint width, with authored foundation. |
| Production building | Mid-size, role readable by silhouette and activity. |
| Defensive tower | Tall, narrow, high-contrast threat shape with attack direction clarity. |
| Capture site | Landmark first, ring second; capture boundary clear but not the whole identity. |
| Neutral camp | Environmental landmark plus small marker, with risk readable from prop/silhouette language. |

## Future Tests And Screenshot Checks

Future visual-scale work should add or preserve:

- A desktop screenshot check for one Chapter 1 map and both Cinderfen pressure maps.
- A mobile or narrow-viewport layout check if HUD scale changes.
- A selected hero, selected multi-unit, selected building, and selected capture-site screenshot set.
- A minimap marker hierarchy assertion or screenshot check after marker-size changes.
- A fog-on screenshot check to ensure units, sites, and warnings remain readable.
- A battle-status overlap check when labels/bars are dense.
- A no-console-error Browser preview smoke after any visual runtime change.
- Unit tests for any pure scale helper if scale constants are extracted.

## Phase 6 Decision

No scale code change is justified in this phase.

The current scale rules are tactically readable, and the most obvious visual problems come from mixed source art and procedural terrain rather than a single broken constant. A future Phase 7 readability decision may still choose one tiny non-gameplay tweak, but unit radii, building sizes, capture-site radii, camera zoom, pathfinding cell size, fog cell size, and map dimensions should stay unchanged for v0.8.
