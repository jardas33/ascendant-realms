# v0.375 Original Barrosan Low-Poly Art Kit — Fail-Closed Visual Gate

## Status

**BLOCKED — V0375 ORIGINAL BARROSAN VISUAL QUALITY GATE NOT MET**

This is an honest visual-quality blocker, not a runtime or build failure. The isolated Route-B/original-kit implementation is technically viable, but the rendered evidence does not meet the requested production-art threshold.

## Scope and base

- Base HEAD: `d18e9e5fe89923c9f5acffa1eb7df4d5f561f816` (accepted v0.374)
- Branch: `codex/v0215-v0226-recovery`
- Prototype scene: `desktop-spikes/godot-salto/scenes/v0375_original_barrosan_visual_proof.tscn`
- Blender source: `art-source/blender/v0375/original_barrosan/barrosan_original_kit.blend`
- Exported prototype kit: `desktop-spikes/godot-salto/assets/v0375/original_barrosan/barrosan_original_kit.glb`
- Launch: `npm run godot:play:original-barrosan-proof`
- Capture: `npm run godot:capture:original-barrosan-proof`
- Validator: `npm run godot:validate:original-barrosan-proof`

## What was implemented

The isolated kit contains repository-authored low-poly geometry for:

- two uneven terrain banks with a recessed curved stream;
- raised riverbanks, stream stones, embedded worn roads, and an integrated timber bridge;
- Main Hall, Field Barracks, a smaller Barrosan house, foundations, roof planes, timber courses, doors, windows, and limited landmark details;
- worked gold outcrop, ore cart, hostile camp, barricades, camp shelter, and fire focal point;
- original low-poly trees, bushes, meadow tufts, rocks, and limited settlement props;
- a fixed oblique orthographic RTS camera, warm key light, cool fill, and coherent shadows;
- temporary Quaternius characters only for Worker/Militia/Reserve/hostile scale reference.

The current v0.303 fallback/debug renderer and accepted runtime were not replaced or enabled by default.

## Evidence and gate decision

Six iterations were rendered and inspected as four real 1920x1080 images per iteration. The best candidate is in `artifacts/work/v0375-iteration-6/`. The detailed record is `artifacts/work/v0375-iteration-log.md`.

The bridge, recessed water, route readability, oblique camera, shadow direction, and unit scale are useful proof. The gate remains failed because:

1. attractiveness is 6.5/10, below the required 8;
2. immediate RTS readability is 7.5/10, below the required 8;
3. terrain credibility is 6.2/10, below the required 7;
4. Barrosan identity is 6.5/10, below the required 7;
5. building material richness and authored character remain limited;
6. temporary imported characters are acceptable for scale proof but are not final faction art.

No black or blank frame was accepted. No success review pack was created. The raw iteration renders are intentionally preserved under `artifacts/work/v0375-iteration-1/` through `artifacts/work/v0375-iteration-6/` and padded evidence copies under `v0375-iteration-01/` through `v0375-iteration-06/`.

## Preservation proof

The prototype is world-only and isolated. It adds no gameplay, movement, pathfinding, route following, combat, damage, HP, AI, waves, economy, resources, selection, HUD, save, stable-ID, pressure, or default-runtime behavior. v0.368-v0.374 accepted runtime and asset paths remain untouched. House02/Barn gold sources remain untouched.

The original geometry is repository-authored. The only external content used in the prototype is the already-intaken CC0 Quaternius character subset from `assets/third_party/quaternius/v0370/men/`, used explicitly as temporary scale references and not as the main kit.

## Safest next repair

Do not integrate this prototype into the accepted runtime. The safest next art-direction step is a new bounded asset-quality pass that keeps this scene isolated while replacing the provisional unit references and adding authored Barrosan material variation, terrain breakup, and stronger building silhouettes. That is outside v0.375 closeout and is not started here.
