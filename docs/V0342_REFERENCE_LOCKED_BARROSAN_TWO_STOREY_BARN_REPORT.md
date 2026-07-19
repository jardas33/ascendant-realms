# v0.342 Reference-Locked Barrosan Two-Storey Barn

## Executive outcome

**REJECTED INTERNALLY — REBUILT BARN STILL READS AS A GARAGE, GREYBOX, REGULAR-BLOCK BUILDING, GENERIC LOW-POLY PROP OR NON-BARROSAN STRUCTURE**

Automated checks are not visual approval. The clean-room candidate exported,
loaded, and rendered in Godot, but the four visual-first lock frames did not
clear the human bar. The candidate is retained as a review record only; it is
not called gold and is not authorized for later production integration.

## Scope and base

- Checkpoint: v0.342
- Base HEAD: `426f6825331705b7422bf29f21fff26073e32fe1`
- Branch: `codex/v0215-v0226-recovery`
- Scene: `desktop-spikes/godot-salto/scenes/review/V0342ReferenceLockedBarrosanBarnReview.tscn`
- Source: `art-source/blender/v0342/reference_locked_barrosan_two_storey_barn.blend`
- Export: `desktop-spikes/godot-salto/assets/v0342/reference_locked_barrosan_two_storey_barn.glb`
- Capture: `npm run godot:capture:salto-v0342-reference-locked-barrosan-barn`
- Pack: `artifacts/manual-review/v0342-reference-locked-barrosan-barn/UPLOAD_TO_CHAT/`

The slice is opt-in and review-only. The true default runtime, accepted state
chain, stable IDs, saves, gameplay, pressure, economy, and resources are not
changed.

## Reference lock

The primary documentary anchor is the locally retained, reference-only image
`art-source/references/v0331/documentary/02_supplement_slate_roof_houses.jpg`:
“30985 Slate-roofed houses in Montesinho,” Panegyrics of Granovetter, Wikimedia
Commons, CC BY-SA 4.0, accessed 2026-07-19. Source page:
https://commons.wikimedia.org/wiki/File:30985_Slate-roofed_houses_in_Montesinho_(54961581200).jpg

It supplies closed granite/slate two-level working-house massing cues only. No
documentary pixels, mesh, or protected game asset enters the runtime. The
accepted v0.338 House 02 anchor remains frozen at these hashes:

- Blend: `3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6`
- GLB: `ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89`

## What was authored

The new generator is `tools/blender/generateV0342ReferenceLockedBarrosanBarn.py`.
It authors a closed 7.6m x 5.0m two-storey volume with a 5.44m wall and 7.17m
ridge, lower heavy granite, recessed double livestock/storage doors, an upper
hay-loading shutter, damp foundation contact, irregular polygonal rubble
relief, and two principal slate roof slopes with ten staggered course bands.
The source metrics record the accepted 2048² granite albedo/normal/roughness
lineage, 1024² slate and timber sources, material roles, UV status, LOD
budgets, and diagnostic provenance.

The scene includes the frozen House 02 anchor, the new barn, one secondary
support mass, irregular ground banks, a recessed river, a bridge and road
context, and two inherited Worker-scale references. v0.341 appears only as a
labelled rejected comparison in the review board; its visible mesh is not
reused.

## Four visual-first lock result

The required unlabelled frames were rendered before the pack was completed:

1. Front three-quarter: closed mass, lower/upper openings, and granite relief
   are legible, but the roof reads too dark and flat, with distracting verge
   members that weaken the agricultural silhouette.
2. Rear three-quarter: volume and foundation read, but the material response
   remains too high-contrast and the roof does not yet read as overlapping
   slate at ordinary RTS distance.
3. Front close material: the relief field reads as large dark patches rather
   than restrained irregular granite masonry; the smooth side plane and harsh
   foundation highlight are visible defects.
4. House 02 matched 256px: scale and material-family comparison is possible,
   but the rebuilt barn is not yet compatible in density or finish.

These are concrete visual defects, so the outcome is the permitted internal
rejection. Remaining captures and diagnostics document feasibility; they do
not override this human-review decision.

## Diagnostics and evidence integrity

The runtime writes 44 real Godot PNG captures and a 360-frame continuous route.
The pack builder creates exactly ten upload files, including the H.264
1280x720, 24fps, 360-frame, 15-second video. Blender also writes actual
authored-edge, UV, checker, and relief diagnostic sources. The runtime
manifest records normal enabled/disabled, albedo-only, roughness, height,
UV, wireframe, LOD, collision, camera, geometry, and preservation contracts.

The evidence is deliberately labelled as rejected and human-review-required;
the pack does not claim that a successful export is a visual pass.

## Preserved / not changed

- Frozen House 02 Blend and GLB are byte-identical.
- v0.341 remains rejected and comparison-only.
- No full-game conversion, runtime integration, gameplay, movement,
  pathfinding, route following, combat, damage, HP, projectiles, death,
  despawn, AI, waves, economy, resources, production, pressure behavior,
  saves, or stable IDs were changed.
- The existing v0.303 fallback/debug renderer and v0.304-v0.341 history remain
  available and untouched.

## Validation and next action

Dedicated command: `npm run godot:validate:salto-v0342-reference-locked-barrosan-barn`.
The retained repository verification is required after the local validator:
v0.341/v0.340 art gates, content/art/runtime checks, artifact retention,
`npm test`, `npm run build`, `npm run godot:all`, and `git diff --check`.

The safest next action is a new human-reviewed roof/material repair brief that
addresses the rejected lock defects. v0.342 itself does not authorize calling
this barn gold or starting a later production checkpoint.

Final state is reported only after the dedicated validator, retained checks,
commit, exact-SHA CI, and clean branch synchronization complete.
