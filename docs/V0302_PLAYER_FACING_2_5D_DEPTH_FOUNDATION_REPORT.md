# v0.302 Player-Facing 2.5D Depth Foundation

## Scope

This checkpoint adds a restrained pseudo-3D presentation foundation to the opt-in Barrosan `PLAYER` presentation path. It is a presentation-only layer: no gameplay state, accepted action, marker meaning, terrain navigation geometry, unit position, building footprint, resource, pressure, or true-default behavior is changed.

Base HEAD: `ec1c16cd8da16b130ea28cca14bc70b5165123af`

Branch: `codex/v0215-v0226-recovery`

## Why this foundation is needed

The accepted v0.301 separation made the normal Barrosan view clean, but its flat orthographic board still read as a debug fixture. v0.302 adds controlled depth cues that improve tactical readability without beginning a full 3D conversion or asset replacement pass.

## What changed

- Added a modular v0.302 PLAYER-only depth skin in `salto_barrosan_playable_runtime_skin.gd`.
- Applied a mild orthographic oblique posture (`-56.5` degree pitch, fixed `10.6` size).
- Added restrained water, bridge, road-edge, and building-foundation depth cues.
- Added low-alpha unit contact shadows and consistent directional-light treatment.
- Added shallow selection-depth treatment for runtime structures.
- Preserved v0.301 label arbitration and DEBUG_REVIEW evidence visibility.
- Added deterministic PLAYER/DEBUG_REVIEW capture tooling, validator, report, and 59-frame manual review pack.

## What did not change

No new gameplay, states, actions, buttons, movement, pathfinding, route following, combat, attacks, damage, HP loss, projectiles, death/despawn, AI, waves, fog gameplay, economy/resource mutation, pressure mutation, or true-default runtime mutation was added. Existing terrain geometry, road/river/bridge geometry, structure positions/footprints, and unit positions remain authoritative.

## PLAYER mode visual rules

PLAYER mode keeps v0.301’s clean label policy and applies the depth skin only to presentation nodes. The top strip, selected cards, minimap, current pressure state, and current bridge marker remain readable. Historical proof labels remain hidden. Depth cues are low contrast and do not function as gameplay zones.

## DEBUG_REVIEW preservation

DEBUG_REVIEW continues to use the v0.301 evidence rail and retains accepted proof labels, marker nodes, route segments, deployed-support presence, integration visual, and pressure evidence. v0.302 depth nodes are hidden in DEBUG_REVIEW so review captures remain deterministic and uncluttered while the accepted proof architecture remains available.

## Camera/projection treatment

The PLAYER camera remains orthographic and fixed. Only its opt-in presentation posture changes: a mild oblique pitch and bounded size provide depth without perspective distortion, navigation, panning, or camera gameplay.

## Terrain, building, unit, selection, and shadow treatment

Terrain separation uses shallow, transparent edge and under-bridge meshes. Building foundations follow existing structure transforms and footprints. Unit contact shadows are derived from existing unit positions without writing them back. Selection depth is a small, low-alpha cylinder aligned to the existing selected role. The existing directional light is kept soft and consistent.

## Before/after visual comparison

The review pack includes the retained flat v0.301 reference, v0.302 PLAYER captures, DEBUG_REVIEW captures, and a combined comparison sheet. Headless frames below the mean-8 threshold are rejected and replaced by explicit static contract cards; the rejection evidence is recorded in `v0302-black-frame-stats.json` and frame 59.

## Accepted chain preserved

The full accepted v0.287-v0.301 chain remains intact through `BRIDGE PRESSURE STABILIZED / PRESSURE STABILIZED`. Pressure remains `70/100`. Mode round-trip proof records PLAYER -> DEBUG_REVIEW -> PLAYER without state, card, top-strip, resource, marker, or position mutation.

## Validation and evidence

Dedicated command: `npm run godot:validate:salto-barrosan-player-facing-2-5d-depth-foundation`

Capture command: `npm run godot:capture:salto-barrosan-player-facing-2-5d-depth-foundation`

Dedicated validator source: `tools/godot/saltoV0302BarrosanPlayerFacing25DDepthFoundationTool.mjs`

Review pack: `artifacts/manual-review/v0302-player-facing-2-5d-depth-foundation/`

The retained ladder covers v0.301 through v0.269 plus the v0.259 UI invariant validator. Full local validation includes tests, build, content/art/runtime checks, artifact retention, Godot aggregate validation, and `git diff --check`.

## Final repo state

This report is completed as part of the v0.302 checkpoint and is updated with the final commit, exact-SHA GitHub Actions run, and clean/synced repository state during closeout.
