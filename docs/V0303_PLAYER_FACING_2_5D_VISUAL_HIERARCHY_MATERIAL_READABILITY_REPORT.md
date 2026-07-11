# v0.303 Player-Facing 2.5D Visual Hierarchy and Material Readability

## Scope

v0.303 is a presentation-only refinement of the opt-in Barrosan PLAYER path. It improves material/value hierarchy between terrain, roads, water, bridges, buildings, units, shadows, and selection feedback without changing gameplay geometry, positions, footprints, state, pressure, resources, or the true default runtime.

Base HEAD: `64d1980155dca8f4f84aa9e3e39a48ecef329c74`

Branch: `codex/v0215-v0226-recovery`

## Why this pass follows v0.302

v0.302 established the controlled orthographic 2.5D depth foundation. Its low-alpha depth cues needed a clearer value hierarchy so tactical objects would separate from background terrain while roads, bridges, river, and buildings stayed immediately readable.

## What changed

- Added a centralized cached PLAYER material hierarchy in the Barrosan presentation skin.
- Added restrained value overlays for grass, roads, water, bridge decks/landings, and occupied pads.
- Added roof, side, and base cues for Main Hall, Field Barracks, and secondary buildings.
- Added subtle unit value lifts and preserved contact-shadow grounding.
- Added consistent low-alpha selection accents for Aster, Defender, Reserve Support, and Field Barracks.
- Preserved the v0.302 camera, pitch, orthographic projection, and depth foundation.
- Added dedicated capture tooling, validator, report, and 65-frame review pack.

## What did not change

No gameplay, states, actions, buttons, movement, pathfinding, route following, combat, attacks, damage, HP loss, projectiles, death/despawn, AI, waves, fog gameplay, economy/resource mutation, pressure mutation, object positions, building footprints, accepted labels, markers, or true-default behavior changed.

## Visual hierarchy treatment

Grass remains the base value. Roads use a distinct muted earth value, water uses a restrained cool value, and bridge surfaces use a warmer structural value. Building pads separate occupied ground from ordinary terrain without changing navigation geometry.

Buildings receive separate base, side, and roof cues. Main Hall and Field Barracks use stronger structural contrast; smaller buildings use a quieter secondary material family. Unit value lifts and existing contact shadows separate units without oversized halos or billboard dominance.

Selection accents remain shallow, low-alpha, and aligned to existing role positions. Shadows keep the v0.302 directional treatment and are not gameplay zones.

## PLAYER cleanliness and DEBUG_REVIEW preservation

PLAYER mode retains the v0.301 clean label arbitration, readable top strip, selected cards, minimap, and current bridge state. DEBUG_REVIEW keeps accepted proof labels, markers, five route segments, deployed support, integration visual, and pressure evidence; v0.303 material overlays are hidden there for deterministic review.

The mode round trip records PLAYER -> DEBUG_REVIEW -> PLAYER with shared material instances, no duplicate nodes, no marker/label duplication, and no state, position, resource, or pressure mutation.

## Before/after and evidence

The review pack includes the v0.302 PLAYER reference, v0.303 hierarchy captures, PLAYER and DEBUG_REVIEW contact sheets, a before/after comparison sheet, and a black-frame rejection report. Headless frames below mean 8 are rejected and replaced by explicit static contract cards.

## Accepted chain and preserved state

The accepted v0.287-v0.302 chain remains intact through `BRIDGE PRESSURE STABILIZED / PRESSURE STABILIZED`. Pressure remains `70/100`; selected-card state, top-strip state, resources, unit positions, and building positions/footprints remain unchanged.

## Validation

Dedicated capture command: `npm run godot:capture:salto-barrosan-player-facing-2-5d-visual-hierarchy-material-readability`

Dedicated validator command: `npm run godot:validate:salto-barrosan-player-facing-2-5d-visual-hierarchy-material-readability`

Dedicated validator: `tools/godot/saltoV0303BarrosanPlayerFacing25DVisualHierarchyMaterialReadabilityTool.mjs`

Review pack: `artifacts/manual-review/v0303-player-facing-2-5d-visual-hierarchy-material-readability/`

The retained ladder covers v0.302 through v0.269 plus the v0.259 UI invariant validator. Full local validation includes tests, build, content/art/runtime checks, artifact retention, `npm run godot:all`, and `git diff --check`. CI evidence and final exact SHA are recorded during closeout.

## Final repo state

Final closeout records the implementation commit, exact-SHA GitHub Actions success, and a clean repository synced with origin at 0 ahead / 0 behind.
