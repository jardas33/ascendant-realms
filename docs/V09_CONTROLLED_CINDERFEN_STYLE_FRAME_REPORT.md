# v0.9 Controlled Cinderfen Style-Frame Report

Date: 2026-05-10  
Status: docs/specs/prompts-only style-frame sprint. No generated art, imported assets, runtime replacement, gameplay change, map change, save change, engine change, or desktop packaging was added.

## What Was Added

- `docs/V09_CINDERFEN_STYLE_FRAME_RESEARCH_PACKET.md`
- `docs/V09_CINDERFEN_VISUAL_PILLARS.md`
- `docs/V09_CINDERFEN_TERRAIN_MATERIAL_SHEET_SPEC.md`
- `docs/V09_CINDER_SHRINE_LANDMARK_SPEC.md`
- `docs/V09_ASHEN_OUTPOST_ARCHITECTURE_SPEC.md`
- `docs/V09_UNIT_BUILDING_SCALE_REFERENCE.md`
- `docs/V09_CINDERFEN_STYLE_FRAME_PROMPT_PACK.md`
- `docs/V09_FUTURE_CINDERFEN_MANIFEST_TEMPLATES.md`
- `docs/V09_CINDERFEN_SCREENSHOT_ACCEPTANCE_CRITERIA.md`
- `docs/V09_CINDERFEN_VISUAL_REPLACEMENT_IMPLEMENTATION_PLAN.md`

## What Was Not Added

- No generated art.
- No image API calls.
- No downloaded web images.
- No imported assets.
- No runtime art replacement.
- No manifest runtime entries.
- No runtime renderer, CSS, map, gameplay, save, campaign progression, unit, building, faction, reward, pressure, worker, economy AI, desktop, or engine changes.
- No production approval for unknown-source assets.

## Cinderfen Research Packet Summary

The research packet identifies the current visual problems: paint-like roads, blob-like water/swamp, unclear material identity, icon/ring-led capture sites, unit/building scale mismatch, and text-heavy HUD dependence. It defines Cinderfen as an ash-glass wetland with blackened raised causeways, ember-lit shrine sites, drowned ruins, dead reeds, wet reflective pools, blue-green fog, and cinder haze.

It also sets original-IP guardrails: no Warcraft or Warlords Battlecry copying, no copied factions/units/maps/UI/art/music/lore, no direct copyrighted reference ingestion, and no runtime asset work in this sprint.

## Visual Pillars Summary

The visual pillars define eight rules:

1. Roads read first.
2. Shrines glow second.
3. Units always sit above terrain noise.
4. Wetland is dangerous but not messy.
5. Ashen architecture is angular, scorched, and ritualized.
6. Player structures remain grounded and readable.
7. Fog frames decisions, not hides them.
8. UI labels support, but do not carry, identity.

Each pillar links visual direction to gameplay readability, screenshot QA targets, and future asset implications.

## Terrain Material Sheet Summary

The terrain spec defines eight future materials: blackened causeway road, ash mud/dark marsh ground, shallow reflective water, deep swamp pool, dead reed beds, cinder fog/shadow overlay, ruined stone edging, and embers/ritual scorch marks.

Each material includes purpose, readability role, color/value direction, detail level, edge/blend behavior, scale notes, browser prototype target, future desktop target, risks, prompt fragment, and manifest metadata expectations.

## Shrine Landmark Spec Summary

The Cinder Shrine spec reframes capture sites as future landmarks rather than ring/icon placeholders. It defines neutral, player-controlled, enemy-controlled, active surge, and depleted/claimed variants while protecting current ownership/progress rings, labels, objective copy, and capture behavior.

The spec includes visual language, prompt templates, required manifest fields, screenshot QA targets, and no-art/no-runtime limits.

## Ashen Architecture Spec Summary

The Ashen outpost spec defines a future enemy architecture family: stronghold, barracks/war camp, watchtower, shrine/ritual support, and small barricade/road marker.

It anchors the identity in scorched timber, black iron braces, basalt stones, ember-lit slits, ritual banners/original sigil shapes, angular silhouettes, wet ash foundations, and road-pressure construction logic without copying protected factions or buildings.

## Scale Reference Summary

The scale reference consolidates current render facts and future visual targets for hero, infantry, ranged infantry, brute/large unit, caster, commander/enemy hero, small building, production building, Command Hall/Stronghold, capture-site landmark, and environmental prop classes.

It explicitly freezes runtime scale in v0.9: no unit radii, building sizes, capture-site radii, camera zoom, pathfinding cells, fog cells, minimap markers, labels, rings, or sprite constants changed.

## Prompt Pack Summary

The prompt pack provides safe future briefs for:

- Cinderfen terrain material style frame,
- Cinderfen raised road/causeway,
- Cinder Shrine landmark,
- Cinder Shrine ownership states,
- Ashen stronghold,
- Ashen barracks/war camp,
- Ashen watchtower,
- Cinderfen environmental prop sheet,
- Cinderfen minimap/material readability reference,
- UI/background mood frame.

Each prompt includes original-IP requirements, protected-IP avoidance, top-down/2.5D readability, browser prototype and future desktop notes, output expectations, forbidden elements, source/license metadata fields, manifest checklist, and screenshot QA checklist.

## Future Manifest Templates Summary

The manifest template doc provides documentation-only examples for future style frames and candidates. It keeps all placeholders conservative, not runtime, not production-approved, and not added to `src/game/assets/visualAssetManifest.ts`.

Templates cover terrain style frame, causeway material, Cinder Shrine neutral/player/enemy states, Ashen stronghold/barracks/watchtower concepts, Cinderfen prop sheet, and a future terrain/material set.

## Screenshot Acceptance Criteria Summary

The acceptance criteria define future pass/fail review for main battlefield readability, road readability, shrine visibility, shrine ownership state clarity, unit silhouettes, enemy base readability, minimap consistency, mobile/tablet battle HUD compatibility, affected Results/Inventory/Gallery screens, performance/bundle impact, source/license metadata completeness, and screenshot QA coverage.

It explicitly forbids pixel-perfect visual diffing as the approval mechanism and requires human review.

## Future Replacement Implementation Plan Summary

The future plan sequences later work from style-frame creation through metadata, non-runtime review folders, reference/candidate manifest entries, screenshot QA, one tiny runtime candidate, validation, before/after visual QA, full release gate, and rollback.

The first possible future runtime candidates are:

- Cinder Shrine landmark replacement,
- Cinderfen road material overlay,
- Ashen stronghold replacement.

Each candidate has value, risk, likely touched files, tests, screenshot targets, and rollback notes.

## Remaining Risks

- Current visuals remain prototype-level.
- Cinderfen terrain still lacks material identity in runtime.
- Roads remain paint-like in runtime.
- Water/swamp still look blob-like in runtime.
- Capture sites still rely on rings/icons/labels in runtime.
- Unit/building scale and source style remain inconsistent.
- Most current file-backed assets still need source/license proof.
- No file-backed image asset is production-approved.
- Future generated or commissioned assets can still fail source/license review.
- Future runtime replacement can still harm readability if not kept tiny and screenshot-reviewed.

## Next Recommended Long Goal

Recommended next long goal: **v0.9.1 Controlled Cinderfen Style-Frame Intake And Source Review**.

Safe scope:

- manually generate, commission, or obtain 1 to 3 Cinderfen style-frame candidates outside runtime,
- record prompt/source/license metadata immediately,
- store candidates only in a non-runtime review folder if explicitly approved,
- add manifest entries as reference/candidate only,
- run `npm run validate:content` and `npm run visual:qa`,
- write a human screenshot/source review,
- do not wire assets into runtime yet.

First runtime replacement should wait until a style frame has source/license proof and passes the v0.9 screenshot acceptance criteria.
