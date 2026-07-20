# v0.350 Final House02/Barn Material Unity Calibration

## Human decision carried forward

v0.349 was rejected as the final gold candidate because the barn read too dark and olive/brown, the slate courses were too regular, and the House02/barn value relationship was not unified. v0.350 is the bounded calibration pass requested from that decision. It is a human-review handoff and does not claim gold or production readiness.

## Scope and baseline

- Base HEAD: `35f650d0d4dc30494bcf4111fc15906d0b0adb2c`
- Branch: `codex/v0215-v0226-recovery`
- Opt-in fixture: `desktop-spikes/godot-salto/scenes/review/V0350FinalHouse02BarnMaterialUnity.tscn`
- Outcome: `READY FOR HUMAN V0350 FINAL HOUSE02/BARN MATERIAL-UNITY REVIEW`

This checkpoint calibrates the House02/barn material response under one shared neutral-overcast fixture. It preserves the accepted v0.347 geometry carrier and v0.348 UV infrastructure, derives from the accepted v0.349 material baseline, and makes no production-runtime or gameplay change.

## Accepted achievements preserved

- v0.347 geometry: bounds, horizontal mass, two 20-degree roof slopes, straight ridge, overhang, two complete granite gables, openings, and worker-scale relationship.
- v0.348 explicit roof and gable UV infrastructure, material separation, diagnostics, and review fixture.
- v0.349 external albedo/normal/roughness resource workflow, albedo-first slate response, and isolated opt-in review path.

The v0.350 GLB remains a copied v0.347 geometry carrier. The permitted upper-loading-opening reduction is applied only in the v0.350 Godot review fixture: width 3.82 to 3.32 metres (13.0%), height 1.02 to 0.92 metres (9.8%), with two shutters retained and the lower agricultural door dominant. No accepted source geometry is overwritten.

## Shared-light methodology

House02 and the barn are captured in the same v0.350 review scene with `V0350_Shared_Neutral_Overcast_Key`, a single restrained directional key (`light_energy = 1.08`), identical environment treatment, camera framing, and exposure. A separate restrained-warm capture is diagnostic only; it is not the material baseline. This makes the comparison about material response rather than changing light or camera conditions.

## Material calibration

### Slate

The roof uses the external v0.350 traditional-slate set with albedo first, normal strength `0.08`, roughness `0.95`, and metallic `0.0`. The pattern uses three restrained widths, staggered joints, subtle course-height variation, and limited chipped lower edges. Recorded apparent scale remains close to House02: House02 tile width `0.56m`, barn `0.58m`, a `3.57%` delta; course height is `0.45m` versus `0.47m`.

Normal-enabled, normal-disabled, albedo-only, roughness/isolation, UV-layout, and 256-pixel captures are included so the slate identity is auditable without relying on a strong normal map. In the matched 512px board, the sampled roof median luminance is `133.2` for both House02 and barn under the shared fixture; the equal result is the intended calibration target, not a claim that every texel is identical.

### Granite and foundation

Granite is calibrated toward a medium grey / grey-brown family using the House02-derived lineage at matched scale, with no normal contribution in the calibration baseline. Foundation response is bounded lower-wall damp/soil weathering in the recorded `20–35cm` range, applied as irregular contact treatment rather than a uniform black stripe or floating band.

### Timber and iron

Timber is muted dark chestnut with high roughness. Iron is near-black but remains visible. Roof-edge treatment is subordinate charcoal weathered timber so the silhouette is not outlined by a bright or saturated trim.

## Structural and contextual evidence

The direct-front capture shows the complete exterior gable silhouette. The upper opening is visibly subordinate to the lower door. The contextual capture places House02 and the barn together with one small worker near each, providing a bounded hamlet read without adding gameplay entities or production placement logic.

## Evidence and review pack

The runtime capture manifest contains exactly fifteen actual Godot PNG renders:

1. matched House02/barn neutral full;
2. matched roof normal enabled;
3. matched roof normal disabled;
4. barn albedo-only roof;
5. neutral barn three-quarter;
6. direct front;
7. complete direct exterior gable;
8. granite/foundation close-up;
9. doors/openings close-up;
10. roof-edge slate irregularity;
11. far RTS;
12. true 256-pixel source;
13. greyscale;
14. restrained warm directional;
15. contextual House02/barn hamlet.

The exact ten-file review pack is at `artifacts/manual-review/v0350-final-house02-barn-material-unity/UPLOAD_TO_CHAT/`. It contains eight rendered PNG boards, one README, and `compact-evidence-summary.json`; it contains no video. The visual-quality boards use the actual rendered frames rather than title-card-only evidence. Black/blank frames were rejected during inspection.

## Validation and isolation

Dedicated command: `npm run godot:validate:salto-v0350-final-house02-barn-material-unity`.

The validator checks the frozen v0.347 hashes, retained v0.348/v0.349 sources, geometry and roof contracts, external resource truth, opening reduction, shared-light fixture, albedo-first response, exact fifteen raw captures, exact ten-file pack shape, eight PNG boards, no video, required human-review outcome, no default-runtime integration, and no gameplay/movement/pathfinding/combat/economy/resource mutation.

The dedicated generator, capture wrapper, pack builder, fixture, runtime script, metrics, manifest, source-lineage record, and material-response matrix are all isolated under the v0.350 paths. The true default runtime remains unchanged. No protected or third-party game asset was imported; the geometry is repository-authored/procedurally derived and the texture lineage is recorded.

## Full local validation evidence

The closeout runs:

- `npm run godot:validate:salto-v0350-final-house02-barn-material-unity`
- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run validate:runtime-art-slots`
- `npm run validate:artifact-retention`
- `npm run godot:all`
- `git diff --check`

The v0.350 generator, capture, pack, and dedicated validator have already passed before closeout. The remaining full repository checks and exact-SHA CI are run before this checkpoint is declared complete.

## Human review status

**READY FOR HUMAN V0350 FINAL HOUSE02/BARN MATERIAL-UNITY REVIEW**

This is intentionally not an automatic gold or production-ready approval. Human review should judge the matched House02/barn value relationship, whether the slate course rhythm is sufficiently natural at gameplay scale, and whether the bounded foundation treatment reads as weathering rather than a material band.

## CI and final repository state

The implementation commit `161de201e4d68ef8c1327023af491186b1b96b5a` was verified by GitHub Actions run `29751813788`, `CI Release Matrix Dry Run`, with conclusion `success`; its `Fast confidence` job also completed successfully. The final documentation amendment is pushed and verified again at closeout. Final repository state is required to be clean and synchronized with origin at `0 ahead / 0 behind`.
