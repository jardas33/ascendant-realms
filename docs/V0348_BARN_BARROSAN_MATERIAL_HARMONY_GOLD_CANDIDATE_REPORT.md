# v0.348 — Barn Barrosan Material-Harmony Gold Candidate

## Executive verdict

v0.347 remains the accepted barn geometry, silhouette, and functional-architecture foundation. **v0.347 geometry is frozen.** This checkpoint creates an isolated Barrosan material-harmony candidate for human review. The rendered ten-capture gate is clean: the barn is broad and agricultural, its roof reads as individual slate courses, the granite continues through both gables, the lower door dominates the upper loading opening, timber and iron are aged and restrained, and the asset remains readable at RTS and 256-pixel scale.

The candidate is not human-approved, gold, or production-ready. Automated visual approval remains false and human review remains required. No default runtime integration is present.

**READY FOR HUMAN V0348 BARN MATERIAL-HARMONY GOLD-CANDIDATE REVIEW**

## Scope and frozen source

- Base HEAD: `591ee43102995710d62ed0fd34985f9bb79b9c68`
- Branch: `codex/v0215-v0226-recovery`
- Source foundation: `art-source/blender/v0347/barn_rendered_geometry_truth.blend`
- Godot geometry carrier: `desktop-spikes/godot-salto/assets/v0347/barn_rendered_geometry_truth.glb`
- Derived Blender source: `art-source/blender/v0348/barn_barrosan_material_harmony.blend`
- Derived review carrier: `desktop-spikes/godot-salto/assets/v0348/barn_barrosan_material_harmony.glb`
- Frozen v0.347 geometry SHA-256: `e5c8c9d561fc921f97a971110b34b706ed8dbd1824e4e451addab2ac1573a69a` for Blend and `0b4944d8a15006664dad84cec5e8b41546497588d14194d5b2e49621071e209c` for GLB.
- House02 anchor SHA-256: `3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6` for Blend and `ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89` for GLB.

The main rectangular footprint, horizontal mass, depth, wall/eave height, ridge height, 20-degree roof pitch, two principal slopes, straight ridge, overhangs, gables, agricultural openings, and Worker scale relationship are unchanged. No dimensional redesign was introduced.

## Material-harmony treatment

### House02 slate

The roof uses a new authored weathered-slate course set with independent front/rear roof UVs. Both slopes use eave-parallel courses with independent eave-to-ridge progression; the slopes are not mirrored or inherited from an ambiguous prior projection. The evidence ledger records House02 texel density, visible tile width, course height, roof UV rotations, apparent scale delta, and nine visible courses from eave to ridge. The candidate remains rough, non-metallic charcoal blue-grey with restrained variation and subtle joints rather than an asphalt sheet or noisy gravel surface.

### Granite continuity

The wall and gable use the House02-derived rubble/granite material lineage. The same medium grey / grey-brown stone language continues above the eave into both complete gable triangles. No roof material is assigned to the gables, no compressed stone band interrupts the triangles, and contact/eave/opening areas remain darker without becoming a black stripe.

### Timber, iron, edge, and weathering

Timber and iron are dark, aged, and muted. The lower agricultural double door remains the dominant opening; the upper loading opening stays secondary. The roof edge is a restrained charcoal/brown line, subordinate to the roof and stone rather than cream, orange, bright, or metallic. Material response evidence includes normal-enabled, normal-disabled, albedo-only, roughness-isolation, checker, and authored UV-layout diagnostics.

## Runtime and capture implementation

The v0.348 scene is opt-in only:

`desktop-spikes/godot-salto/scenes/review/V0348BarnBarrosanMaterialHarmony.tscn`

The Godot review script applies the v0.348 material skin to the frozen v0.347 GLB geometry carrier because the locked Godot importer rejected the new embedded Blender image variant. This is an explicit compatibility boundary, not a geometry substitution: the Blender derivative contains the authored material resources and UV contract, while the isolated review scene applies the same skin for deterministic rendered evidence.

Commands:

- `npm run blender:generate:salto-v0348-barn-material-harmony-gold-candidate`
- `npm run godot:capture:salto-v0348-barn-material-harmony-gold-candidate`
- `npm run godot:pack:salto-v0348-barn-material-harmony-gold-candidate`
- `npm run godot:validate:salto-v0348-barn-material-harmony-gold-candidate`

The capture path produces exactly ten raw Godot renders: front three-quarter, direct front, side gable, House02 roof match, openings close-up, far RTS, 256-pixel source, true matched House02/barn comparison, neutral overcast, and restrained warm directional. The true matched comparison is 512x256 and the source-scale capture is 256x256.

## Visual gate evidence

- Roof slate reads as separate overlapping course pieces at close, RTS, and 256-pixel scale.
- House02 and barn are shown in the same matched-camera comparison.
- Both granite gables are continuous and use the wall-scale stone language.
- The roof edge is dark and restrained.
- The lower agricultural double door is dominant; the upper loading opening is subordinate.
- The barn remains broad and heavy with the accepted 20-degree roof slopes.
- The front three-quarter, direct front, and direct side views show real rendered geometry rather than title cards.
- The value board includes the far RTS view, 256-pixel source, warm directional render, and neutral grayscale proof.
- The PBR board includes actual diagnostic renders plus the checker and authored roof/gable UV layout.

## What changed

- Added the isolated v0.348 Blender derivative and source-lineage ledger.
- Added authored slate albedo, normal, roughness, checker, and UV-layout evidence.
- Added explicit roof/gable UV contract and material-role metrics.
- Added the isolated Godot review scene and opt-in material skin.
- Added deterministic ten-capture runtime tooling and diagnostics.
- Added the exact ten-file upload pack at `artifacts/manual-review/v0348-barn-material-harmony-gold-candidate/UPLOAD_TO_CHAT/`.
- Added the dedicated v0.348 validator and package command.

## What did not change

- v0.343–v0.347 source assets, reports, packs, validators, and accepted geometry remain preserved.
- The true default runtime is unchanged and does not load the v0.348 scene or material skin.
- No gameplay, movement, pathfinding, route following, combat, damage, HP, AI, waves, fog gameplay, economy, resource mutation, saves, stable IDs, or production logic were added or changed.
- No object positions, building footprints, openings, pressure, or accepted state semantics were changed.

## Validation contract

Dedicated validator: `tools/godot/saltoV0348BarnMaterialHarmonyGoldCandidateTool.mjs`

It verifies frozen v0.347 and House02 hashes, geometry bounds and roof metrics, independent UV evidence, material roles, opt-in scene isolation, ten rendered captures, diagnostic files, exact pack count (eight PNG boards plus readme and JSON), non-empty visual evidence, no default-runtime integration, no gameplay coupling, and the single human-review outcome.

The retained source/asset lineage is checked against v0.347 and the House02 anchor. The accepted v0.343–v0.347 source chain is not rewritten by this candidate.

## Local validation evidence

The closeout runs the dedicated v0.348 validator, `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run validate:runtime-art-slots`, `npm run validate:artifact-retention`, `npm run godot:all`, and `git diff --check`. The exact pushed SHA and final GitHub Actions result are recorded in the checkpoint closeout after the local gate is green.

## CI and final state

GitHub Actions is required to complete for the exact pushed commit SHA before this checkpoint is closed. The final closeout records the branch, full commit SHA, Actions run ID/result, report path, review-pack path, and a clean repository synchronized with origin at 0 ahead / 0 behind.

Human review remains the final decision on whether this material-harmony candidate advances; this report does not grant that approval.
