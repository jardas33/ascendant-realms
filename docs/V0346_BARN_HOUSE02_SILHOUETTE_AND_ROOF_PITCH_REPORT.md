# v0.346 Barn House02 Silhouette and Roof Pitch Repair

Outcome: **READY FOR HUMAN V0346 BARN HOUSE02-FAMILY SILHOUETTE REVIEW**

Automated visual approval remains false. This checkpoint is a human-review candidate and is not marked gold, accepted, or production-ready.

## Scope

v0.346 is an isolated visual derivative of the final v0.345 barn source. It addresses House02-family silhouette truth only: roof pitch, horizontal mass, closed gables, slate value, subordinate roof edges, and source-view orientation. It does not alter the accepted runtime, gameplay, saves, stable IDs, or default presentation.

## Base and human rejection carried forward

- Branch: `codex/v0215-v0226-recovery`
- Base HEAD: `52b4dacc7d994c364be46c8dc6cc0ef75510d841`
- v0.345 implementation: `212682615da285b9eb3d8d1814d4b32dc1c98066`
- v0.345 closeout metadata: `52b4dacc7d994c364be46c8dc6cc0ef75510d841`
- v0.345 was rejected by human review and is not represented here as gold.
- Exact human rejection: `REJECTED BY HUMAN REVIEW — V0.345 ACHIEVES A CLEAN TWO-SLOPE ROOF AND TRUE MATCHED COMPARISON, BUT THE BARN STILL READS AS TOO NARROW, TOO VERTICAL AND EXCESSIVELY STEEP-ROOFED FOR THE HOUSE02 BARROSAN FAMILY`

The v0.345 granite lineage and openings were retained; granite sourcing was not restarted and v0.341/v0.342 were not used as visible dependencies.

## What changed

- Added `art-source/blender/v0346/barn_house02_silhouette_roof_pitch.blend` as a byte-derived v0.345 candidate.
- Widened the retained wall envelope to a final front-width ratio of `1.379x` House02 and depth ratio of `1.188x`.
- Set the final ridge ratio to `1.040x` and eave ratio to `1.040x` House02.
- Reduced the measured roof-pitch angle from the v0.345 recorded `28.34°` to `27.77°`.
- Kept exactly two principal slopes and one straight ridge.
- Added closed granite gable panels on both ends and removed the interior underside cap that read as an open dark attic triangle.
- Preserved the v0.345 slate source, darkened it with a low-saturation material calibration, projected UVs on both slopes, and kept it rough/non-metallic.
- Replaced the visible roof edge with a thin `0.085m` low-saturation charcoal-brown fascia/ridge material; no orange edge faces are present.
- Corrected captures so the front file shows the lower agricultural doors and upper hay opening, while the rear file shows the rear/service side.
- Removed the v0.345 review-ground contact blocks from the v0.346 capture fixture; the barn sits directly on the natural review ground.

## What did not change

- No runtime scene, gameplay system, state chain, save path, stable ID, movement, pathfinding, combat, economy, or resource mutation.
- Frozen House02, v0.343, v0.344, and v0.345 sources are byte-preserved.
- v0.345 remains the rejected historical candidate; it was not overwritten.

## House02-family visual gate

The rendered five-frame source set was inspected before packaging. It shows a broader, calmer agricultural mass with a lower roof proportion, dominant lower agricultural entrance, subordinate upper opening, substantial granite wall bands, straight ridge, dark slate, thin edge, natural ground contact, and a worker at the same 1.75m scale. No black gable void, orange roof outline, secondary roof, dormer, cross-gable, or pediment is present. The transient source captures are intentionally not committed; the retained upload boards are the review evidence.

## Geometry and material evidence

The metrics ledger `art-source/blender/v0346/v0346-barn-metrics.json` records:

| Measure | v0.345 | v0.346 | House02-relative v0.346 |
|---|---:|---:|---:|
| Ridge | 7.8408m | 7.5504m | 1.040x |
| Eave | 4.68m | 4.5344m | 1.040x |
| Overall/front envelope width | 12.464m | 13.817m | 1.379x |
| Depth | 11.157m | 11.540m | 1.188x |
| Roof pitch | 28.34 degrees | 27.77 degrees | reduced |

The accepted `V0344_House02Derived_Granite_Continuous` material remains on wall/opening/gable surfaces. The roof uses `V0346_House02_Family_Dark_Weathered_Slate`, its restrained underside lineage, and `V0346_Subordinate_Charcoal_Brown_Roof_Edge`. No granite is assigned to roof planes and no slate is assigned to wall planes.

## Capture and review pack

- Isolated scene: `desktop-spikes/godot-salto/scenes/review/V0346BarnHouse02SilhouetteRoofPitch.tscn`
- Capture command: `npm run godot:capture:salto-v0346-barn-house02-silhouette-roof-pitch`
- Pack command: `npm run godot:pack:salto-v0346-barn-house02-silhouette-roof-pitch`
- Upload pack: `artifacts/manual-review/v0346-barn-house02-silhouette-roof-pitch/UPLOAD_TO_CHAT/`
- Pack contains exactly six files: one readme, four rendered PNG boards, and `compact-evidence-summary.json`.
- Summary records `exactlySixReviewFiles: true`, `exactlyFourPng: true`, and `noVideo: true`.
- The five unlabelled source captures are generation evidence and are intentionally transient, not extra upload files.
- The true comparison is an actual direct render: `05_true_matched_512x256_house02_barn.png`, 512x256 total with actual frozen House02 on the left and actual v0.346 on the right, 256x256 each.

## Validator and validation

- Dedicated validator: `tools/godot/saltoV0346BarnHouse02SilhouetteRoofPitchTool.mjs`
- Dedicated command: `npm run godot:validate:salto-v0346-barn-house02-silhouette-roof-pitch`
- The validator independently checks frozen source hashes, v0.345 derivation, the two-slope/one-ridge contract, closed gables, ratios, material roles, front/rear manifest truth, five source captures, true comparison dimensions, exact six-file pack count, summary booleans, no video, and runtime isolation.
- It also rejects human-approval/gold claims and checks forbidden gameplay coupling is absent.
- Retained v0.345 evidence remains unchanged and the v0.345 validator remains available.
- Artifact retention command used for the repository is `npm run godot:validate:salto-experimental-artifact-retention` because that is the package's existing command name.

Local validation completed before closeout: dedicated v0.346 and retained v0.345 validators, `npm test` (887 tests), `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run validate:runtime-art-slots`, `npm run godot:validate:salto-experimental-artifact-retention`, `npm run godot:all`, and `git diff --check`.

## CI evidence

- Implementation commit: `0432da2250ea1ece38f374a308d4693c63a33d61`.
- Exact GitHub Actions run: `29704565216` (`CI Release Matrix Dry Run`) completed successfully for that commit.

## Default-runtime and gameplay preservation

The scene is an opt-in review-only Node3D fixture. It loads the frozen House02 anchor and the new barn directly for capture, but it is not referenced by the true default runtime. The generator and fixture contain no movement, pathfinding, route following, combat, damage, HP, projectile, death, AI, wave, economy, resource, save, or stable-ID behavior. The current runtime and accepted visual chain remain unchanged.

There is no default runtime integration in this checkpoint.

## Human review status

This is a candidate for human v0.346 review. Human approval is intentionally not automated and must not be inferred from the validator or CI result.
