# v0.345 Barn Proportion and Simple Slate Roof Reset

## Gate outcome

READY FOR HUMAN V0345 BARN PROPORTION-AND-ROOF VISUAL REVIEW

This is a human-review gate, not an automated art approval. Automated visual approval remains false. The prior v0.344 human rejection remains authoritative: v0.344 passed granite continuity but failed roof silhouette, building proportion, and the true 256px comparison requirement. v0.344 is not marked gold, accepted, or production-ready by this checkpoint.

## Scope and baseline

- Base HEAD: `7c0ab922afdc398095fe4c5d640493f2b148b333`
- Branch: `codex/v0215-v0226-recovery`
- Checkpoint: v0.345
- Prototype only; the accepted runtime and true default runtime are unchanged.
- No gameplay, movement, pathfinding, combat, economy, resources, stable IDs, saves, or runtime integration were added.

The work is an isolated derivative of the frozen v0.344 Blender source. The byte-identical v0.344 copy is retained at `art-source/blender/v0345/v0344_source_duplicate_for_v0345.blend`. Frozen House02, v0.343, and v0.344 source/output hashes are recorded in `v0345-source-lineage.json` and checked by the dedicated validator.

## Diagnosis carried forward

`v0345-roof-object-diagnosis.json` records the source diagnosis before editing:

- v0.344 slate and roof-edge groups formed broad, low-detail roof faces.
- retained high-elevation roof-like granite faces created misleading pale triangular patches.
- strong roof-edge material created an oversized edge read.
- the inherited roof groups were removed as one unit before the replacement roof was authored.

## Proportion reset

The corrected barn is measured against the frozen House02 anchor:

| Measure | v0.344 before | v0.345 after | House02-relative ratio | Required range |
|---|---:|---:|---:|---:|
| Ridge | 6.78 | 7.8408 | 1.08 | 1.00–1.20 |
| Eave | 5.18 | 4.68 | 1.073 | 0.95–1.15 |
| Width | 8.04 | 12.464 | 1.244 | 1.10–1.40 |
| Depth | 6.115 | 11.157 | 1.149 | 0.95–1.30 |

The remaining agricultural envelope keeps the lower double livestock door, upper hay-loading opening, rear service opening, and two-level reading. The footprint is authored from the retained v0.344 surface and scaled to the House02-relative target; it is not connected to gameplay placement or navigation.

## Roof reset

The replacement roof is deliberately small and explicit:

- two principal continuous slate slopes;
- one straight ridge;
- two restrained eave fascia closures;
- subordinate dark timber edge material;
- a readable plain slate underside for the opposite slope;
- one retained-granite side-gable closure to prevent an exposed interior wedge.

There are zero secondary roof nodes, pediment nodes, pale roof faces, granite roof faces, placeholder roof faces, floating roof pieces, or intersecting secondary roof pieces in the exported metrics. The front slate remains sourced from the accepted `V0334_Weathered_Slate`; the underside is a subordinate material-only readability treatment, not a second roof.

## Material and source preservation

The accepted v0.344 continuous granite resource remains the building material. The final material set is:

- `V0344_House02Derived_Granite_Continuous`
- `V0345_Simple_Weathered_Slate`
- `V0345_Simple_Weathered_Slate_Underside`
- `V0345_Subordinate_Dark_Timber_Roof_Edge`
- retained v0.343 recess, timber, and iron resources.

The generator is repository-authored and derives only from the frozen v0.344 source plus accepted House02/v0.343 resources. No protected-game assets or large unapproved imports were used.

## Captures and true comparison

The isolated scene is `desktop-spikes/godot-salto/scenes/review/V0345BarnProportionSimpleSlateRoofReset.tscn`, with script `desktop-spikes/godot-salto/scripts/v0345_barn_proportion_simple_slate_roof_reset.gd`.

The capture wrapper writes five unlabelled source renders to `artifacts/runtime/v0345/screenshots/`:

1. front three-quarter;
2. rear three-quarter;
3. direct side/gable;
4. close roof/front material;
5. a true `512x256` two-panel comparison, with the frozen House02 rendered directly at `256x256` on the left and the v0.345 barn rendered directly at `256x256` on the right.

The generated review boards are real rendered images, not title-card substitutes. The direct review pack is `artifacts/manual-review/v0345-barn-proportion-and-simple-slate-roof/UPLOAD_TO_CHAT/` and contains exactly the required six files, with no video. The true comparison source is `05_true_matched_512x256_house02_barn.png`.

## Isolation and commands

Generate the Blender source and GLB:

`npm run blender:generate:salto-v0345-barn-proportion-and-simple-slate-roof`

Capture the isolated Godot review scene:

`npm run godot:capture:salto-v0345-barn-proportion-and-simple-slate-roof`

Build the six-file upload pack:

`npm run godot:pack:salto-v0345-barn-proportion-and-simple-slate-roof`

Run the dedicated validator:

`npm run godot:validate:salto-v0345-barn-proportion-and-simple-slate-roof`

The scene is not referenced by the accepted runtime, no default runtime project setting enables it, and there is no default runtime integration. The runtime manifest records `prototypeOptIn: true`, `prototypeOnly: true`, and `defaultRuntimeIntegrated: false`.

## Validation evidence

The dedicated validator checks frozen House02/v0.343/v0.344 hashes, v0.345 lineage, proportion bounds, roof topology, materials, openings, prototype isolation, capture truth, true comparison dimensions, pack completeness, and forbidden gameplay coupling.

The retained v0.344 validator and the required repository validation ladder are green locally. The runtime capture directory is intentionally not committed; the six-file upload pack is the retained review artifact, and the validator also passes from the pack when runtime captures are absent.

## Closeout evidence

- Dedicated v0.345 validator: PASS.
- Retained v0.344 validator: PASS.
- `npm test`: PASS, 122 files / 887 tests.
- `npm run build`: PASS.
- `npm run validate:content`: PASS.
- `npm run validate:art-intake`: PASS.
- `npm run validate:runtime-art-slots`: PASS, 52 slots.
- `npm run godot:validate:salto-experimental-artifact-retention`: PASS.
- `npm run godot:all`: PASS.
- `git diff --check`: PASS.
- Implementation commit: `212682615da285b9eb3d8d1814d4b32dc1c98066`.
- GitHub Actions: `29701136994` (`CI Release Matrix Dry Run`) succeeded for the exact implementation SHA above.
- This report update is metadata-only; the final closeout commit is verified by its own exact-SHA CI run and the final repository check.
- Final repo state: verified after the final metadata-only closeout push.

This report intentionally does not mark the barn production-ready or human-approved.
