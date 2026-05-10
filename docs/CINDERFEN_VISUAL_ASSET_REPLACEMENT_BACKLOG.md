# Cinderfen Visual Asset Replacement Backlog

Date: 2026-05-10  
Status: future art-production planning only. No assets, maps, units, factions, rewards, gameplay, renderer behavior, or UI layout changed in this phase.

## Purpose

This backlog translates the v0.8 visual debt work and the v0.8.1 screenshot QA review into practical future asset replacement candidates for Cinderfen. It is intentionally conservative: the current browser prototype remains systems-first, and no replacement should begin until source/license metadata, scale metadata, screenshot QA targets, and validation rules are ready.

## Backlog Rules

- Do not replace an asset without updating `src/game/assets/visualAssetManifest.ts`.
- Do not mark an asset `final` without known source, license, review, and production approval.
- Do not commit large binary assets without explicit approval.
- Do not copy protected art, names, factions, UI, maps, terrain, characters, or style-specific expression from existing games.
- Do not change map layout, rewards, pressure behavior, unit definitions, campaign progression, or save format as part of visual replacement.
- Do not remove current placeholder assets until the replacement has passed screenshot QA and manifest validation.

## Critical Replacements

### Cinderfen Terrain And Road Style

Current problem:

- Roads are readable but look like broad painted strokes.
- Terrain lacks material identity: ash mud, marsh, roads, blackwater, and blocked zones do not feel like one authored place.
- Current terrain is mostly procedural rendering rather than file-backed art.

Desired future state:

- Blackened causeways, wet ash mud, shallow blackwater, road edges, marsh banks, and terrain boundaries should be readable from RTS camera distance.
- Road and water materials should help players understand passable lanes without relying only on labels and outlines.

Asset type:

- Terrain style frame.
- Later modular terrain tiles/materials or renderer material definitions.

Needed dimensions / scale notes:

- Must remain readable at current `1440x900` desktop battle view and future mobile/tablet battle captures.
- Road width must preserve current gameplay lane readability; do not imply passability changes unless map data changes in a separate approved goal.

Likely files touched later:

- `src/game/battle/BattleSceneMapRenderer.ts`
- `src/game/data/maps/cinderfenCauseway.ts`
- `src/game/data/maps/cinderfenWatchpost.ts`
- `src/game/assets/visualAssetManifest.ts`
- `public/assets/final/` only after approved asset import

Risk:

- High. Terrain changes can accidentally hide objectives, imply changed paths, or make units less readable.

Validation needed:

- `npm run validate:content`
- `npm run visual:qa`
- `npm run test:e2e:layout`
- Cinderfen battle smoke for Crossing and Watch
- Manual screenshot review against `docs/CINDERFEN_VISUAL_REWORK_SPEC.md`

Screenshot QA target:

- `cinderfen-crossing-desktop.png`
- `cinderfen-crossing-shrine-desktop.png`
- `cinderfen-watch-desktop.png`

### Water And Swamp Material

Current problem:

- Water/swamp regions are blob-like and feel disconnected from terrain flow.
- Ripple strokes read as annotation rather than natural surface detail.

Desired future state:

- Blackwater pools, wet reflective shallows, dead reeds, ash banks, and boundary transitions should feel grounded while remaining tactically clear.

Asset type:

- Terrain material kit or procedural material pass.
- Optional prop set later: dead reeds, ash banks, wet rocks.

Needed dimensions / scale notes:

- Must contrast with units, selection rings, health bars, and minimap markers.
- Should not darken the playfield enough to obscure enemy silhouettes.

Likely files touched later:

- `src/game/battle/BattleSceneMapRenderer.ts`
- Cinderfen map data only if prop placement becomes approved later
- `src/game/assets/visualAssetManifest.ts`

Risk:

- Medium-high. Better water can improve mood, but over-detail can reduce unit readability.

Validation needed:

- Visual QA screenshots.
- Layout/e2e battle readability.
- Manual color/contrast review.

Screenshot QA target:

- `cinderfen-crossing-desktop.png`
- `cinderfen-watch-pressure-desktop.png`

### Cinder Shrine / Capture-Site Landmark

Current problem:

- Cinder Shrine is readable because of a large ring, icon, label, and status text.
- The site itself is not memorable as a place.
- Cinder Shrine salience remains a long-running watchpoint.

Desired future state:

- Original ember-lit shrine landmark, readable at RTS distance.
- Capture ring supports ownership clarity but does not carry all identity.
- Shrine should remain obvious during pressure and objective feedback.

Asset type:

- Capture-site landmark sprite/model concept.
- Ownership/VFX treatment later.

Needed dimensions / scale notes:

- Current icon is tracked at 42 px while the capture ring is much larger.
- Future landmark should be large enough to read from default camera without overpowering units.
- Must leave room for health bars, labels, and selection rings in the capture area.

Likely files touched later:

- `src/game/entities/CaptureSite.ts`
- `src/game/assets/AssetKeys.ts`
- `src/game/assets/visualAssetManifest.ts`
- `public/assets/final/`
- `tests/visual-qa/visual-qa.spec.ts` if a new shrine-focused capture is needed

Risk:

- High. Shrine art can confuse capture ownership or hide unit clusters if too large.

Validation needed:

- Manifest validation.
- Screenshot QA at shrine capture moment.
- Existing pressure/e2e coverage for Cinder Shrine feedback.

Screenshot QA target:

- `cinderfen-crossing-shrine-desktop.png`

### Enemy Stronghold / Ashen Outpost Identity

Current problem:

- Enemy structures are readable as hostile mainly through placement, tint, labels, and health bars.
- Enemy stronghold art does not yet define an original architectural identity.

Desired future state:

- Enemy stronghold should have a strong silhouette, grounded foundation, and original materials tied to the Ashen commander identity without copying protected factions or buildings.

Asset type:

- Building sprite/model concept.
- Later damage/destruction states if approved.

Needed dimensions / scale notes:

- Should preserve current building footprint and selection readability.
- Must not make enemy base appear larger or harder in gameplay terms unless balance work separately approves it.

Likely files touched later:

- `src/game/entities/Building.ts`
- `src/game/assets/AssetKeys.ts`
- `src/game/assets/visualAssetManifest.ts`
- `public/assets/final/`

Risk:

- Medium-high. Strong building art can shift perceived difficulty and base threat.

Validation needed:

- Manifest validation.
- Battle launch screenshots.
- Existing battle victory/e2e flows.

Screenshot QA target:

- Future enemy-base-centered screenshot.
- Current closest targets: `cinderfen-crossing-desktop.png`, `cinderfen-watch-desktop.png`.

## High-Priority Replacements

### Player Hero Scale And Style

Current problem:

- The hero is readable and appropriately important, but sprite style and terrain style are mismatched.
- Hero identity still leans on label, portrait, selection ring, and HUD.

Desired future state:

- Original hero silhouette with clear weapon/command pose, consistent ground contact, and scale relationship to infantry.

Asset type:

- Unit concept sheet.
- Battle sprite or future model.
- Portrait alignment later.

Needed dimensions / scale notes:

- Current render height is about 82.65 px.
- Future hero should remain taller than infantry but not tower like a building.

Likely files touched later:

- `src/game/entities/Unit.ts`
- `src/game/assets/AssetKeys.ts`
- `src/game/assets/visualAssetManifest.ts`
- `public/assets/final/`

Risk:

- Medium. Changing hero scale can alter selection feel and screenshot composition.

Validation needed:

- Visual QA tutorial and Cinderfen battle screenshots.
- Selection/command HUD smoke.

Screenshot QA target:

- `tutorial-desktop.png`
- `cinderfen-crossing-shrine-desktop.png`

### Militia And Ranger Consistency

Current problem:

- Militia and Ranger are readable mostly through labels and HUD selection list.
- Role silhouettes need more consistent weapons, stance, and source style.

Desired future state:

- Militia and Ranger should read at a glance from weapon shape and silhouette, even before the label is read.

Asset type:

- Infantry/ranged concept sheets.
- Battle sprites or future models.

Needed dimensions / scale notes:

- Current common-unit target heights are roughly 43.8 to 47.45 px.
- Future infantry/ranged scale should be standardized before replacing multiple units.

Likely files touched later:

- `src/game/entities/Unit.ts`
- `src/game/assets/visualAssetManifest.ts`
- `public/assets/final/`

Risk:

- Medium. Role readability is important for training, selection, and battlefield clusters.

Validation needed:

- Tutorial screenshot.
- Cinderfen shrine/Watch screenshots with multiple selected units.

Screenshot QA target:

- `tutorial-desktop.png`
- `cinderfen-watch-pressure-desktop.png`

### Enemy Raider / Brute / Caster Silhouettes

Current problem:

- Enemy identity is carried by team color, labels, and position.
- Raider, brute, and caster do not yet share a strong original enemy-family language.

Desired future state:

- Raider should be fast/light, brute should be heavy, caster should be arcane/supportive, and all should belong to one original enemy visual family.

Asset type:

- Enemy unit concept sheet.
- Battle sprites or future models.

Needed dimensions / scale notes:

- Keep brute larger than raider/caster.
- Maintain enough contrast against roads, swamp, and fog.

Likely files touched later:

- `src/game/entities/Unit.ts`
- `src/game/assets/visualAssetManifest.ts`
- `public/assets/final/`

Risk:

- Medium. Better silhouettes can improve readability but may change perceived threat.

Validation needed:

- Battle launch screenshots.
- Enemy pressure warning screenshot.
- Simulator not required for visual-only replacement, unless perceived difficulty drives later balance work.

Screenshot QA target:

- `cinderfen-crossing-shrine-desktop.png`
- `cinderfen-watch-pressure-desktop.png`

### Minimap Marker Pass

Current problem:

- Minimap is tactically useful but diagrammatic.
- Terrain identity and marker hierarchy are not final.

Desired future state:

- Minimap should preserve clarity while reflecting future terrain/capture-site categories.

Asset type:

- UI/minimap marker style pass.
- Possibly no file-backed asset if it remains procedural.

Needed dimensions / scale notes:

- Markers must remain readable at desktop, tablet, and mobile sizes.

Likely files touched later:

- `src/game/ui/MinimapView.ts`
- `src/game/ui/hudPanels/MinimapPanel.ts`
- `src/game/assets/visualAssetManifest.ts` only if file-backed icons are introduced

Risk:

- Medium. Minimap clarity is more important than artfulness.

Validation needed:

- `npm run test:e2e:layout`
- `npm run visual:qa`

Screenshot QA target:

- All battle screenshots.

## Medium-Priority Replacements

### UI Frame Consistency

Current problem:

- UI surfaces are readable but still generic fantasy frame treatment.
- Main menu, campaign map, battle HUD, and results surfaces are not a fully unified final UI system.

Desired future state:

- Cleaner, scalable, original fantasy command interface with consistent surfaces, button states, typography, icons, and spacing.

Asset type:

- UI style frame.
- Frame/border/button/icon asset set.

Needed dimensions / scale notes:

- Must support desktop, tablet, and mobile layouts.
- Button hit targets and text fit must remain protected.

Likely files touched later:

- `src/game/styles/*.css`
- `src/game/ui/**/*.ts`
- `public/assets/final/ui-kit/`
- `src/game/assets/visualAssetManifest.ts`

Risk:

- Medium-high. UI changes can create layout regressions.

Validation needed:

- `npm run test:e2e:layout`
- `npm run visual:qa`
- Smoke and release lanes if UI changes affect launch flows.

Screenshot QA target:

- `main-menu-desktop.png`
- `campaign-map-desktop.png`
- `skirmish-setup-desktop.png`
- `tutorial-desktop.png`

### Health Bars And Labels

Current problem:

- Health bars and labels are useful but visually dense.
- They carry too much identity burden for final art.

Desired future state:

- Health bars and labels should remain readable but become less visually dominant once silhouettes improve.

Asset type:

- UI/VFX styling, likely procedural/CSS/Phaser graphics rather than file-backed assets.

Needed dimensions / scale notes:

- Must remain readable on current unit scale and mobile/tablet battle views.

Likely files touched later:

- `src/game/entities/BaseEntity.ts`
- `src/game/entities/Unit.ts`
- `src/game/entities/Building.ts`
- `src/game/entities/CaptureSite.ts`

Risk:

- Medium. Reducing label dominance too early can harm prototype comprehension and tests.

Validation needed:

- Layout tests.
- Visual QA screenshots.
- Human play review if label visibility changes.

Screenshot QA target:

- `cinderfen-crossing-shrine-desktop.png`
- `cinderfen-watch-pressure-desktop.png`

### Capture-Site Labels

Current problem:

- Capture-site labels are clear but reinforce the marker-like feel of important locations.

Desired future state:

- Labels should support landmark art instead of replacing it.

Asset type:

- UI label treatment, possibly no file asset.

Needed dimensions / scale notes:

- Must not overlap unit clusters or objective feedback in shrine/Watch moments.

Likely files touched later:

- `src/game/entities/CaptureSite.ts`
- `src/game/styles/*.css` only if DOM labels become involved later

Risk:

- Low-medium. Label changes are readable but can hurt tutorial clarity.

Validation needed:

- Screenshot QA and pressure/e2e coverage.

Screenshot QA target:

- `cinderfen-crossing-shrine-desktop.png`
- `cinderfen-watch-pressure-desktop.png`

## Low-Priority Replacements

### Decorative Props

Current problem:

- Cinderfen lacks environmental props such as reeds, broken markers, charred stumps, ash stones, and ruin fragments.

Desired future state:

- Props should give the map place identity without hiding paths, units, or capture sites.

Asset type:

- Terrain prop sprites/models.

Needed dimensions / scale notes:

- Props must stay smaller than units/buildings and avoid confusion with interactable objects.

Likely files touched later:

- Cinderfen map data only after prop placement is explicitly approved.
- `src/game/battle/BattleSceneMapRenderer.ts`
- `src/game/assets/visualAssetManifest.ts`

Risk:

- Low-medium. Decorative clutter can harm readability.

Validation needed:

- Screenshot QA.
- Visual/manual review.

Screenshot QA target:

- Future Cinderfen map art screenshots.

### VFX Polish

Current problem:

- Capture, shrine, pressure, attacks, and objective feedback are mostly text/overlay-driven.

Desired future state:

- Subtle VFX should support important events without overpowering the battlefield.

Asset type:

- Phaser graphics/VFX or file-backed effects.

Needed dimensions / scale notes:

- Effects must not obscure selection rings, health bars, or capture ownership.

Likely files touched later:

- `src/game/battle/BattleScene.ts`
- `src/game/entities/CaptureSite.ts`
- `src/game/systems/AbilitySystem.ts`
- `src/game/assets/visualAssetManifest.ts` if file-backed

Risk:

- Medium. Effects can become noisy or imply mechanics that do not exist.

Validation needed:

- Screenshot QA.
- Pressure warning/e2e checks if pressure feedback changes.

Screenshot QA target:

- `cinderfen-crossing-shrine-desktop.png`
- `cinderfen-watch-pressure-desktop.png`

### Portraits

Current problem:

- Portraits are useful but not a final art-direction system.

Desired future state:

- Hero, commander, and future NPC portraits should share original production style and license/source tracking.

Asset type:

- Portrait art.

Needed dimensions / scale notes:

- Must fit existing hero panel and inventory/campaign UI without clipping.

Likely files touched later:

- `src/game/ui/hudPanels/HeroHudPanel.ts`
- Campaign and inventory UI surfaces
- `src/game/assets/visualAssetManifest.ts`

Risk:

- Low-medium. Portraits affect presentation but not tactical readability.

Validation needed:

- Manifest validation.
- Main menu/campaign/tutorial screenshot QA if portrait surfaces change.

Screenshot QA target:

- `tutorial-desktop.png`
- `campaign-map-desktop.png`

## Recommended Future Order

1. Unit/building/capture-site scale sheet and source/license review.
2. Cinderfen terrain and road style frame.
3. Cinder Shrine landmark concept.
4. Enemy stronghold visual identity concept.
5. Infantry/enemy silhouette sheet.
6. Prototype terrain/capture-site readability pass.
7. UI frame/style consistency pass.
8. Decorative props, VFX, and portrait polish.

## v0.8.1 Decision

This backlog is ready to guide future visual work, but it does not authorize immediate asset replacement. The next visual implementation goal should begin with a single constrained target, source/license metadata, manifest updates, screenshot QA before/after captures, and full verification.
