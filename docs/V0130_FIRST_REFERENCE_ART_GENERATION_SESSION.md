# v0.130 First Reference-Art Generation Session

Generate only these four reference-only assets first, then stop for human review. Do not generate a larger batch, do not import anything into runtime, and do not mark anything runtime-ready.

## 1. Salto 2.5D Environment Style Frame

- Copy-ready prompt path: `docs/art-prompts/V0123_01_SALTO_2_5D_ENVIRONMENT_STYLE_FRAME.md`
- Purpose: establish the Salto terrain mood, tactical lane clarity, material language, and 2026 fixed-camera RTS/RPG ambition.
- Expected dimensions/aspect: 16:9, preferably 1920x1080 or 2048x1152.
- Visual questions: Does Salto feel atmospheric without losing tactical readability? Are road, ford, quarry, shrine, ruin, buildable ground, blocked ground, and Lume clear at command distance?
- Rejection triggers: protected-IP resemblance, unreadable clutter, first-person/cinematic framing, mobile-game gloss, dashboard flatness, missing tactical lanes, or runtime-sprite treatment.
- Original-IP reminder: original JARDAS/Ascendant Realms direction only; no copied Warlords Battlecry, Warcraft, Age of Empires, or protected symbols.
- Reference-only warning: this is not production art and must stay outside runtime.
- No runtime integration: do not add this image to `public/`, manifests, Godot resources, browser assets, or runtime art slots.

## 2. HUD Style Frame

- Copy-ready prompt path: `docs/art-prompts/V0123_08_HUD_STYLE_FRAME.md`
- Purpose: explore compact desktop RTS/RPG HUD density, selected hero/Worker/squad posture, command buttons, minimap, objectives, and Results affordance.
- Expected dimensions/aspect: 16:9 gameplay frame, preferably 1600x900 or 1920x1080.
- Visual questions: Does the HUD preserve the battlefield? Are resources, selected unit, command row, objective line, and minimap readable without feeling like a developer dashboard?
- Rejection triggers: copied RTS layouts, giant decorative panels, mobile-game card stacks, unreadable tiny type, generic web dashboard styling, or final UI-kit claims.
- Original-IP reminder: Barrosan material cues, muted cloth, dark iron, weathered timber, and restrained teal Lume highlights must remain original.
- Reference-only warning: this is a visual direction frame only.
- No runtime integration: do not slice UI assets, add icons, or wire runtime UI from this frame.

## 3. Aster Hero Silhouette Sheet

- Copy-ready prompt path: `docs/art-prompts/V0123_02_BARROSAN_HERO_SILHOUETTE_SHEET.md`
- Purpose: find a central persistent hero silhouette that reads above Worker, Militia, and Ranger at RTS camera scale.
- Expected dimensions/aspect: square sheet, preferably 2048x2048, with 8 to 12 small silhouettes and two larger pose callouts.
- Visual questions: Does Aster feel like the player's persistent commander? Is the shape readable at small scale without over-ornate fantasy armor?
- Rejection triggers: protected hero lookalikes, horned dark-lord shapes, paladin clone, MMO raid armor overload, chibi/mobile proportions, animation-sheet treatment, or final sprite claims.
- Original-IP reminder: practical Barrosan oath-bearer, steel, leather, wool, timber-shield accents, restrained Lume trim.
- Reference-only warning: this is not a sprite sheet and not runtime art.
- No runtime integration: do not replace the procedural Aster placeholder.

## 4. Worker Silhouette Sheet

- Copy-ready prompt path: `docs/art-prompts/V0123_03_BARROSAN_WORKER_SILHOUETTE_SHEET.md`
- Purpose: define a humble Barrosan builder/support silhouette for mining, building, and site work.
- Expected dimensions/aspect: square sheet, preferably 2048x2048, with 10 small silhouettes and three larger detail sketches.
- Visual questions: Does the Worker read as practical support, not military hero? Are tools and carried materials clear without clutter?
- Rejection triggers: famous RTS worker resemblance, peasant/peon clone, mascot proportions, oversized impractical tools, final sprite-sheet treatment, or runtime-ready asset claims.
- Original-IP reminder: worn cloth, leather straps, timber, iron tools, wet highland grit, and no copied protected unit shape.
- Reference-only warning: this is not production art.
- No runtime integration: do not replace the procedural Worker placeholder.
