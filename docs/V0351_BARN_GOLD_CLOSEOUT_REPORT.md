# v0.351 Barn Gold Closeout

## Human acceptance carried forward

v0.350 is accepted as the final House02/barn material-unity baseline. The remaining gold-review concerns were intentionally narrow: the upper loading opening needed an authentic agricultural shutter treatment, the barn needed clean ground contact without evidence-fixture debris, and PLAYER/context captures needed complete worker-scale context. v0.351 is a human-review handoff; it does not claim automatic gold or production readiness.

## Scope and baseline

- Base HEAD: `896370138335029647209d2faeab7d8bdaaf894e`
- Branch: `codex/v0215-v0226-recovery`
- Opt-in fixture: `desktop-spikes/godot-salto/scenes/review/V0351BarnGoldCloseout.tscn`
- Runtime script: `desktop-spikes/godot-salto/scripts/v0351_barn_gold_closeout.gd`
- Required outcome: `READY FOR HUMAN V0351 BARN GOLD-CLOSEOUT REVIEW`

This checkpoint is isolated to the v0.351 review fixture and evidence path. The accepted v0.347 geometry carrier, v0.348 UV infrastructure, v0.349 external material lineage, and v0.350 shared-light calibration remain frozen. No production scene, gameplay state, stable ID, save, default runtime, or simulation behavior is changed.

## Upper loading shutter reconstruction

The upper loading opening now presents exactly two closed timber shutter leaves. Each leaf has vertical board seams and one restrained horizontal iron strap; the pair has one clear center meeting seam, with a practical timber lintel and sill. The fixture contains no grille, vent, balcony, rail, open void, or modern window treatment. The existing v0.350 opening bounds remain `3.32m x 0.92m`, and the lower-to-upper opening area ratio remains at least `3.64`, keeping the lower agricultural door dominant.

## Preserved material and structural baseline

- v0.347 geometry carrier, bounds, roof slopes, ridge, overhang, gables, and openings are unchanged.
- v0.348 UV infrastructure and diagnostic lineage are unchanged.
- v0.349 external albedo/normal/roughness resource lineage is unchanged.
- v0.350 slate, granite, timber, iron, roof-edge, shared-light, and House02/barn unity calibration is reused without global retuning.
- Frozen v0.350 source hashes are recorded in `art-source/blender/v0351/v0351-barn-gold-closeout-metrics.json`.

## Clean ground contact

The prior broad/floating evidence-footprint pieces are removed. v0.351 uses one bounded, restrained contact shadow and an irregular main-door soil stain over the existing damp/weathering band. The contact read is not a uniform black stripe, detached debris, a gameplay zone, or a new plinth. The runtime metrics record zero debris and the validator rejects the old floating foundation-block pattern.

## Context workers and presentation separation

The bounded contextual review captures include two complete authored worker-scale figures with body, head, legs, boots, cloth/skin materials, and grounding bases. They are review context only, not gameplay entities. Clean PLAYER-facing captures contain no technical readout; the `DEBUG_REVIEW` capture retains the dimension/contact evidence label and bounded contact mask for auditability.

## Evidence and review pack

The v0.351 runtime capture contains sixteen actual Godot PNG renders: neutral and direct fronts, shutter close-up, opening hierarchy, complete gable, opposite three-quarter, left/right contact views, far RTS, true 256px, grayscale, warm diagnostic, matched House02/barn, contextual PLAYER, DEBUG_REVIEW dimensions/contact, and contextual hamlet. Blank/title-card-only evidence was rejected during inspection.

The exact upload pack is at `artifacts/manual-review/v0351-barn-gold-closeout/UPLOAD_TO_CHAT/`. It contains eight rendered PNG boards, one README, and `compact-evidence-summary.json`; it contains no video. The visual boards use actual rendered frames, including the shutter close-up, lower/upper hierarchy, contact treatment, House02/barn unity, RTS/diagnostic views, and clean contextual PLAYER evidence.

## Human-review status

**READY FOR HUMAN V0351 BARN GOLD-CLOSEOUT REVIEW**

The human decision remains required. This checkpoint does not automatically approve the barn as gold or production-ready. Review should judge whether the two closed agricultural shutters read authentically, whether the softened contact treatment is natural at gameplay scale, and whether the clean contextual PLAYER view is sufficient for adoption.

## Dedicated validation and isolation

Dedicated command: `npm run godot:validate:salto-v0351-barn-gold-closeout`.

The validator checks the frozen v0.350 hashes and retained source roots, the two-shutter contract and absence of grille-style overlays, ground-contact/debris rules, complete context workers, shared light, opening dimensions and ratio, default-runtime isolation, no-gameplay flags, sixteen raw renders, exact ten-file/eight-PNG/no-video pack shape, required outcome, clean contextual capture, and DEBUG_REVIEW evidence.

The v0.351 scene, script, capture wrapper, pack builder, validator, metrics, runtime manifest, and review pack are isolated under their v0.351 paths. No protected or third-party game asset was imported. The true default runtime remains unchanged.

## Full local validation evidence

The closeout validation set is:

- `npm run godot:validate:salto-v0351-barn-gold-closeout`
- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run validate:runtime-art-slots`
- `npm run validate:artifact-retention`
- `npm run godot:all`
- `git diff --check`

The dedicated capture, pack, and v0.351 validator are green before commit. The repository-wide checks and exact-SHA GitHub Actions result are recorded at final closeout after the commit is pushed.

## CI and final repository state

The implementation is based on v0.350 final HEAD `896370138335029647209d2faeab7d8bdaaf894e`. The final implementation commit, exact-SHA GitHub Actions run, and clean synchronized state are recorded in the v0.351 closeout response after all local checks complete. The required final state is branch `codex/v0215-v0226-recovery`, `0 ahead / 0 behind`, with no unrelated generated importer changes.
