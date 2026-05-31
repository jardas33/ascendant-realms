# v0.88 AI-Art Prompt Template Library

Status: future-use templates only. Do not generate images during v0.88. Do not import output into runtime without the intake gate in `docs/V088_ART_INTAKE_AND_REVIEW_GATE.md`.

## Template Rules

- Every prompt must specify original IP, no protected-style imitation, and no direct copying of named games, films, artists, or franchises.
- Every prompt must name the target faction, role, scale, camera, aspect ratio, and review purpose.
- Every generated candidate must receive a manifest entry before any runtime discussion.
- No image is approved just because it is attractive; it must pass silhouette, readability, consistency, source/license, and protected-IP checks.

## Style-Frame Prompt Template

Use for broad faction or environment mood frames.

```text
Create an original dark heroic fantasy RTS/RPG style frame for [FACTION_OR_REGION].
Purpose: visual-direction review only, not runtime art.
Subject: [SCREEN_OR_SCENE], showing [KEY_ELEMENTS].
Visual anchors: [MATERIALS], [LIGHTING], [SHAPES], [CULTURAL_IDENTITY].
Gameplay readability: preserve clear silhouettes, readable terrain, and negative space for UI.
Camera: [CAMERA_RULE].
Aspect ratio: [ASPECT_RATIO].
Style constraints: painterly concept-art clarity, grounded materials, original IP, no protected franchise resemblance, no mobile-game card composition.
Avoid: [NEGATIVE_PROMPT_BLOCK].
Output expectation: one coherent style frame with no logo, no watermark, no text, no UI labels unless the prompt is specifically a HUD-frame template.
```

## Faction Silhouette-Sheet Template

```text
Create an original silhouette exploration sheet for [FACTION].
Purpose: human review of faction readability before concept art.
Include exactly [COUNT] full-body silhouettes: Worker/utility, basic melee troop, ranged troop, elite unit, hero/commander, and optional building mass thumbnails if requested.
Identity anchors: [ANATOMY], [POSTURE], [MATERIALS], [ROLE_LANGUAGE].
Scale: RTS readability, thumbnail-safe, no detailed rendering required.
Camera: front three-quarter and side-profile alternates, neutral standing pose, no dramatic action blur.
Aspect ratio: [ASPECT_RATIO].
Avoid: protected-IP resemblance, generic fantasy costumes, anatomy inconsistency, human-reskin drift for non-human factions.
No text, no logos, no watermarks.
```

## Unit Concept-Sheet Template

```text
Create an original concept sheet for [FACTION] [UNIT_ROLE].
Purpose: visual review only, not runtime art.
Show: one clean front three-quarter pose, one side silhouette, one small RTS-scale thumbnail, and 2-3 material callouts.
Role readability: [ROLE_TAGS].
Faction anchors: [FACTION_ANCHORS].
Equipment: [WEAPON_OR_TOOL], [ARMOR_CLOTHING], [SIGNATURE_PROP].
Proportions: [PROPORTION_RULES].
Camera: orthographic-feeling concept sheet, no extreme perspective.
Aspect ratio: [ASPECT_RATIO].
Avoid: [NEGATIVE_PROMPT_BLOCK], no copied franchise shapes, no logos, no text labels unless requested for review.
```

## Building Concept-Sheet Template

```text
Create an original RTS building concept sheet for [FACTION] [BUILDING_ROLE].
Purpose: visual review only, not runtime art.
Show: front three-quarter view, top-down footprint thumbnail, small RTS-scale silhouette, and material callouts.
Gameplay readability: entrance, team ownership, construction state, and damage state must be conceptually readable.
Materials: [MATERIALS].
Faction anchors: [FACTION_ANCHORS].
Camera: isometric RTS-friendly angle, no cinematic lens distortion.
Aspect ratio: [ASPECT_RATIO].
Avoid: generic mobile strategy building, protected RTS silhouettes, impossible construction, cluttered scale cues, logos, watermarks.
```

## Battlefield-Environment Template

```text
Create an original battlefield environment style frame for [REGION_OR_MISSION].
Purpose: terrain/material review for a desktop RTS/RPG, not runtime art.
Include: playable lane/readable ground, capture-site zone, road/path, resource landmark, faction presence, and UI-safe negative space.
Mood: [WEATHER], [LIGHTING], [TIME_OF_DAY].
Materials: [GROUND], [STONE], [WATER_OR_MIST], [VEGETATION], [STRUCTURAL_DETAILS].
Camera: high three-quarter RTS camera, clear walkable vs blocked areas.
Aspect ratio: [ASPECT_RATIO].
Avoid: cinematic-only composition, hidden paths, overdark terrain, generic AI fantasy matte painting, protected franchise resemblance, text, logos, watermarks.
```

## HUD-Frame Template

```text
Create an original desktop RTS/RPG HUD frame style exploration.
Purpose: UI style-frame review only, not runtime CSS implementation.
Include: resource bar frame, command panel frame, minimap frame, selected-unit panel frame, notification strip, tooltip example, Results/debrief header sample.
Faction/material anchors: Barrosan granite, hearth iron, restrained Lume teal, dark heroic fantasy.
Readability: high contrast, compact desktop density, clear selected/available/locked/hostile/friendly/neutral states.
Camera: flat UI board, no perspective mockup, no fake gameplay screenshot.
Aspect ratio: [ASPECT_RATIO].
Avoid: mobile game buttons, gacha cards, shop UI, bright purple/blue gradient theme, beige parchment overload, copied UI from known RTS games, logos, watermarks.
```

## Negative Prompt Guidance

Base negative block:

```text
No protected franchise imitation, no Warcraft-like silhouettes, no Warlords Battlecry copying, no generic mobile strategy UI, no anime/furry style drift unless explicitly approved, no AI text artifacts, no logos, no watermarks, no extra limbs, no broken hands, no unreadable silhouettes, no overdark low-contrast image, no neon fantasy soup, no modern objects, no guns unless future setting approval exists.
```

Faction-specific additions:

- Barrosan: no royal castle faction, no clean paladin army, no beige parchment village, no tartan stereotype shortcut.
- Ashen: no demons/orcs/undead, no skull-and-horn chaos faction, no lava everywhere, no pure black unreadable armor.
- Wolfveil: no humans in wolf masks, no protected wolf-beast race resemblance, no caricature tribal shorthand, no inconsistent digitigrade anatomy.

## Camera-Angle Rules

- RTS environment: high three-quarter, walkable areas readable.
- Unit concept sheet: front three-quarter plus side silhouette.
- Building concept sheet: isometric-friendly three-quarter plus footprint thumbnail.
- HUD frame: flat, orthographic UI board.
- Avoid dramatic worm-eye, heavy lens blur, cinematic crop, or splash-art composition for functional review.

## Aspect Ratios

- Style frame: 16:9 for screen context.
- Silhouette sheet: 3:2 or 4:3.
- Unit concept sheet: 4:3.
- Building concept sheet: 4:3 or 16:9 if footprint/context is needed.
- HUD frame: 16:9.
- Vertical mobile aspect ratios are not approved for this milestone.

## Consistency Anchors

Barrosan:

- Wet granite, hearth light, timber, resilient human highland stewardship, readable Worker tools.

Ashen:

- Blackened iron, disciplined flame, smoke, chains, overcharge, altered civilization.

Wolfveil:

- Lupine beastkin anatomy, pack hierarchy, mist, speed, ridge paths, non-human posture.

Lume:

- Teal living land-power, restrained glow, linked-site energy, never generic magic blue.

## Review Checklist

Before accepting a candidate:

- Does it match the correct faction/role/screen?
- Is it original and free of obvious protected-IP resemblance?
- Is the silhouette readable at thumbnail scale?
- Are materials consistent with the brief?
- Does it avoid mobile-like UI or composition shortcuts?
- Does it preserve future RTS readability?
- Are anatomy and construction plausible?
- Is source, license, generated-by, prompt version, and review status recorded?
- Is it still marked non-runtime until explicit integration approval?
