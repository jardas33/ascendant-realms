# v0.349 Final Barn Material Harmony

## Scope and human decision

v0.349 is an isolated material-response repair after the human rejection of v0.348 as a gold candidate. The exact decision carried forward was: preserve v0.347 geometry and v0.348 UV infrastructure, then repair slate material response, roof-edge value, foundation weathering, and agricultural age. This checkpoint does not claim gold or production readiness; the result is a human-review handoff.

Base HEAD: `38a1007110c8bb04e48e97134e66732c5bcdf5f0`

Branch: `codex/v0215-v0226-recovery`

## Preserved foundation

- v0.347 geometry remains the carrier: bounds, horizontal mass, two 20-degree roof slopes, straight ridge, overhang, complete granite gables, openings, and worker-scale relationship are unchanged.
- v0.348 explicit roof-slope UVs, gable UV continuity, roof/gable material separation, diagnostics, review fixture, validator, and historical evidence remain intact.
- The v0.349 Blender derivative and Godot fixture are new isolated paths; v0.347 and v0.348 sources are not overwritten.
- The frozen carrier records the accepted upper-opening dimensions. v0.349 keeps those dimensions unchanged and makes the lower agricultural door dominant through darker aged frame/shutter response and a stronger masonry band; no risky architectural rebuild was introduced.

## Diagnosis and repair

The v0.348 roof read as a pale grey industrial grid and depended too heavily on its normal map. v0.349 makes the slate identity albedo-first:

- dark charcoal blue-grey albedo with staggered courses, two-plus restrained width phases, thin subdued joints, small course variation, and bounded piece variation;
- normal map kept nearly flat with effective strength `0.08`, adding only shallow relief;
- rough non-metallic response at roughness `0.95`, with metallic `0.0`;
- dark charcoal weathered edge material so the perimeter is subordinate at RTS scale;
- explicit external v0.349 albedo, normal, and roughness paths copied into the Godot fixture.

Granite is calibrated toward a medium grey / grey-brown House02-compatible value family. Timber is aged chestnut with muted red saturation and high roughness; iron is near-black and non-metallic. The lower-wall response is recorded as a bounded 20–35 cm damp/soil treatment with no uniform black stripe, moss stamp, or floating geometry. The opening hierarchy is retained and visually clarified: lower entrance dominant, upper loading opening secondary.

## Evidence

The twelve raw captures under `artifacts/runtime/v0349/screenshots/` are actual Godot renders:

1. matched House02/barn normal enabled;
2. matched House02/barn normal disabled;
3. barn albedo-only;
4. neutral front three-quarter;
5. direct front;
6. direct granite gable;
7. openings/foundation close-up;
8. far RTS;
9. true 256px source;
10. greyscale;
11. restrained warm directional;
12. roof-edge close-up.

Manual inspection found no blank or title-card-only evidence. The matched normal-enabled and normal-disabled frames preserve the same roof identity; the albedo-only frame still shows courses; the roof edge is no longer a bright brown outline; and the ordinary RTS/256px views retain the building silhouette and opening hierarchy.

The exact ten-file upload pack is at `artifacts/manual-review/v0349-final-barn-material-harmony/UPLOAD_TO_CHAT/`. It contains eight actual PNG boards, one README, and `compact-evidence-summary.json`; no video is included. Board 03 is the matched normal-enabled comparison, board 04 is normal-disabled plus albedo-only proof, board 05 is roof-edge detail, and board 06 covers granite, foundation, timber, iron, and openings.

## Import and runtime truth

The final source and material resources are inspectable at:

- `art-source/blender/v0349/barn_final_material_harmony.blend`
- `art-source/blender/v0349/v0349-final-barn-material-harmony-metrics.json`
- `art-source/blender/v0349/v0349-material-response-matrix.json`
- `desktop-spikes/godot-salto/assets/v0349/`
- `desktop-spikes/godot-salto/scenes/review/V0349BarnFinalMaterialHarmony.tscn`
- `desktop-spikes/godot-salto/scripts/v0349_barn_final_material_harmony.gd`

The review fixture fails on missing textures rather than silently substituting a fallback. The v0.349 GLB remains a copied v0.347 geometry carrier, and the final visible response is applied through explicit Godot material overrides using the external v0.349 resources. The fixture is opt-in only and is not wired into the true default runtime.

## Validation

Dedicated command: `npm run godot:validate:salto-v0349-final-barn-material-harmony`

The dedicated validator checks frozen v0.347 hashes, retained v0.348 source, geometry/roof/gable contracts, albedo-first and reduced-normal metrics, external resource truth, twelve rendered captures, exact pack shape, no video, no runtime integration, and no gameplay/movement/pathfinding/combat/economy/resource mutation.

Full local validation for closeout:

- dedicated v0.349 validator;
- `npm test`;
- `npm run build`;
- `npm run validate:content`;
- `npm run validate:art-intake`;
- `npm run validate:runtime-art-slots`;
- `npm run validate:artifact-retention`;
- `npm run godot:all`;
- `git diff --check`.

## Review status

Internal gate outcome: **READY FOR HUMAN V0349 FINAL BARN MATERIAL-HARMONY REVIEW**.

This is not an automatic gold or production-ready approval. Human review remains required, especially for final House02 value matching and whether the restrained course rhythm is sufficiently natural at production gameplay zoom.

CI evidence and the final repository state are recorded at closeout after the committed exact-SHA workflow completes.
