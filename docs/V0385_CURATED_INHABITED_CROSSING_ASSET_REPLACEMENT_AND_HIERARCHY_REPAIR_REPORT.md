# v0.385 Curated Inhabited Crossing Asset-Replacement and Hierarchy Repair

## Executive status

`READY FOR HUMAN V0385 CURATED INHABITED CROSSING REVIEW`. This is an isolated visual candidate, not a full-game art conversion. v0.384 remains rejected evidence and is preserved rather than presented as a success.

## Base and scope

- Starting HEAD: `c334c74d313565be0ba5189f8df39b96a639d45b`
- Branch: `codex/v0215-v0226-recovery`
- Scene: `desktop-spikes/godot-salto/scenes/v0385_curated_inhabited_crossing.tscn`
- Launch: `npm run godot:play:v0385-inhabited-crossing`
- Smoke: `npm run godot:smoke:v0385-inhabited-crossing`
- Capture: `npm run godot:capture:v0385-inhabited-crossing`
- Validator: `npm run godot:validate:v0385-inhabited-crossing`

The prototype replaces only the rejected v0.384 inhabited layer with one curated primary Barrosan homestead, one subordinate agricultural building, five named yard groups, and exactly three static character-role nodes. It does not alter accepted infrastructure, gameplay/state semantics, or the true default runtime.

## Asset replacement and hierarchy repair

The primary uses the complete v0.338 Barrosan House 02 material-gold candidate; the subordinate uses the existing BarrosanBarnGold scene. The yard uses tracked Quaternius wagon, crate, barrel, whetstone, and fence assets. The final rendered frame shows the primary and subordinate as distinct structures, a readable road-to-yard-to-entrance threshold, a bridge visibly spanning the river, and a clear separation between the yard figures and bridge figure. The replacement is authored through existing asset instantiation, not scene-local primitive placeholders.

Iteration 01 was rejected for occlusion and scale, iteration 02 for an absent/ambiguous third role, and iteration 03 for the Worker origin/pose failing the same test. Iteration 04 is promoted because the third role is visible after the minimal source substitution to Adventurer and relocation; it is the only final evidence set copied to the runtime/review paths.

## Visual review

The seven captures are actual 1920x1080 Godot renders. The overview and context frames establish the crossing composition; yard and building detail establish material/entrance hierarchy; the character audit establishes three visible figures; the road/yard frame establishes the connection; grayscale establishes basic value separation. The candidate score is **84/100**: 18/25 attractiveness, 17/20 settlement/crossing readability, 16/20 character separation and scale, 16/20 asset coherence, 9/10 technical feasibility, and 8/10 maintainability.

Strengths are the recognizable Barrosan granite/slate primary, genuine bridge and river context, readable yard props, and a deterministic bounded asset set. Remaining limitations are sparse terrain dressing, a simplified river/road material field inherited from the accepted prototype, and repeated Adventurer geometry for two visual roles. This remains a review candidate, not a production-wide art lock.

## Preservation and boundaries

- Accepted v0.380 GLB hash remains `746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb`.
- v0.383 environment and v0.384 rejected evidence remain preserved.
- No movement, pathfinding, navigation, interaction, construction, economy, production, combat, AI, or state mutation was added.
- No HUD, labels, selection rings, or default-runtime presentation was changed.
- The scene is reachable only through explicit `--v0385-inhabited-crossing`, smoke, and capture flags.
- No protected-game assets are imported; provenance is recorded in `artifacts/work/v0385-asset-selection-audit.md`.

## Review artifacts

- Review pack: `artifacts/manual-review/v0385-curated-inhabited-crossing-repair/`
- Iteration audit: `artifacts/work/v0385-iteration-log.md`
- Asset audit: `artifacts/work/v0385-asset-selection-audit.md`
- v0.384 rejected report retained: `docs/V0384_FIRST_INHABITED_CROSSING_VISUAL_TARGET_REPORT.md`

## Validation and closeout

The dedicated validator checks the accepted GLB bytes/hash, opt-in routing, exact one/one/five/three composition, forbidden gameplay tokens, real 1920x1080 captures, non-duplicate final images, and the exact ten-file review pack. The retained v0.384, v0.383, v0.380, test/build/content/art/runtime/artifact-retention/Godot checks and exact-SHA CI are green. Implementation commit: `59530cfc3cb24d2e06d49928c01dd57de0dd5e41`. GitHub Actions run: `30183546596` — success for that exact SHA. Final working tree is kept clean and synchronized after closeout.
