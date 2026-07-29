# v0.384 First Inhabited Barrosan Highland Crossing Visual Target

## Executive verdict

v0.384 is a bounded, opt-in visual target ready for human review. It turns the accepted v0.380 bridge/river/road slice into one readable inhabited crossing composition without changing the accepted runtime or gameplay. The rendered feasibility target scores 76/100 internally: strong crossing readability and clear scene-local isolation, with the explicit limitation that the building and human geometry is still prototype-quality rather than production gold art.

## Base and ancestry

- Branch: `codex/v0215-v0226-recovery`
- Starting HEAD: `01926e7391ed537c29559c5d2f6e4dec62176ac6`
- Accepted v0.380 infrastructure commit: `06f45ce1428af5baeac77d542fa1e0811b52c88a`
- Accepted v0.383 commit: `01926e7391ed537c29559c5d2f6e4dec62176ac6`
- Accepted imported GLB SHA-256: `746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb`
- Accepted source-generator SHA-256: `4b8eafeac69f16a87bd6899a69ab6c6bb8cb5d49103c5ba9cb3da325f38f3e19`

## v0.383 recommendation carried forward

v0.383 was accepted as a bridge-first environment hierarchy repair. Its human-review conclusion was to stop polishing the isolated crossing and move to an inhabited target. v0.384 follows that direction without rewriting v0.383.

## Prototype scope and launch

The new isolated scene is `desktop-spikes/godot-salto/scenes/v0384_first_inhabited_crossing.tscn` with script `desktop-spikes/godot-salto/scripts/v0384_first_inhabited_crossing.gd`.

Launch: `npm run godot:play:v0384-inhabited-crossing`

Smoke: `npm run godot:smoke:v0384-inhabited-crossing`

Capture: `npm run godot:capture:v0384-inhabited-crossing`

Validator: `npm run godot:validate:v0384-inhabited-crossing`

The route is opt-in through `--v0384-inhabited-crossing`; the true default runtime does not select it.

## Composition

The target is one compact west-bank cluster around the accepted east bridge/Field Barracks-style crossing. It contains exactly one primary roadside homestead, exactly one smaller timber shed, one irregular yard/footpath connection, nine scene-local prop nodes, and exactly three static humans: resident, crossing guard, and traveller/porter. The opposite bank remains substantially quieter. There is no HUD, selection ring, label, construction state, or gameplay logic.

## Camera and crossing

The scene inherits the accepted orthographic oblique RTS camera treatment. The promoted wide view keeps the river continuous, bridge deck legible, both landings visible, and the settlement offset from the bridge rather than blocking the crossing. The direct bridge detail capture verifies the road/bridge relationship.

## Buildings and yard

The primary is an authored low-poly Barrosan roadside homestead with granite-like foundation, plaster wall mass, timber bands, entrance and stairs, windows, twin slate roof planes, ridge, and chimney. The subordinate is a smaller timber shed with a darkened opening and related roof language. The yard groups cart, axle, barrel, crate, firewood, trough, and a short fence line. The road-to-yard connection is an irregular tapered mesh rather than a rectangular slab.

## Unit presentation

The three humans are static low-poly feasibility proxies with explicit roles, feet meeting the scene-local ground plane, readable silhouettes, and scale relative to the door, bridge rails, and building mass. There is no locomotion, animation loop, selection ring, unit logic, or AI.

## Lighting, materials, and atmosphere

The v0.383 daylight hierarchy is retained. A restrained non-shadowing yard fill was added only to prevent the primary directional shadow from concealing the functional yard. Materials use muted timber, slate, plaster, granite-like stone, earth, and subdued cloth/skin colors. No bloom, fog gameplay, saturated roof, sci-fi infrastructure, or large fake shadow zone was introduced.

## Three-way visual comparison context

The historical target and v0.303 runtime remain references outside this isolated pack. v0.384 is not claimed to replace either baseline. Its contribution is a directly rendered inhabited composition around the accepted bridge infrastructure; the main evidence is the real wide view and supporting detail views in the review pack.

## Scorecard

| Category | Score |
|---|---:|
| Overall inhabited composition | 15/20 |
| Building selection/placement | 11/15 |
| Bridge/crossing readability | 14/15 |
| Functional-yard coherence | 7/10 |
| Character scale/placement | 8/10 |
| Palette/material coherence | 8/10 |
| Terrain contact/ground connection | 7/10 |
| Lighting/grayscale hierarchy | 6/10 |
| **Total** | **76/100** |

This clears the provisional 75/100 human-review threshold, but the lighting/grayscale category is intentionally recorded as the limiting area and must not be treated as production approval.

## Asset selection and provenance

Candidate inspection and rejection reasons are recorded in `artifacts/work/v0384-asset-selection-audit.md`. Quaternius source packs were inspected recursively, but no bulk import was added. Scene-local authored geometry was selected to keep the target deterministic, small, removable, and free of incompatible modular scale. The accepted v0.380 GLB remains byte-identical.

## Iteration evidence

Exactly three real 1920x1080 iterations were rendered and inspected. Iteration 1 was rejected for bridge-landing intrusion and dark subordinate roof. Iteration 2 was rejected for a hard-edged rectangular path and heavy yard shadow. Iteration 3 promoted an offset cluster, irregular path, and restrained yard fill. Rejected evidence remains in `artifacts/work/v0384-iteration-01/`, `...02/`, and `...03/`; only the promoted iteration is in the human-review pack.

## What changed

- Added opt-in v0.384 scene, launch, smoke, capture, and validator commands.
- Added one authored primary building and one subordinate shed.
- Added one compact yard, tapered footpath, curated props, and three static humans.
- Added exact 1920x1080 final captures, audit, iteration log, manifest, and review pack.

## What did not change

- No accepted GLB bytes, bridge, river, landings, terrain, roads, or v0.383 fallback scene were modified.
- No default runtime, state chain, stable IDs, saves, economy, AI, navigation, combat, or production logic changed.
- No movement, pathfinding, route following, HUD, labels, or selection behavior was added.

## Validation and CI

The dedicated validator checks the accepted GLB hashes, opt-in routing, scene-local counts, exact pack, real captures, no gameplay tokens, and preservation of v0.383/v0.380 evidence. Closeout also runs the focused v0.383/v0.380 validators, smoke, tests, build, content/art/runtime checks, artifact retention, `npm run godot:all`, and `git diff --check`.

## Review pack

`artifacts/manual-review/v0384-first-inhabited-crossing/`

The pack contains exactly the required 10 files and excludes rejected iterations.

## Human handoff

`READY FOR HUMAN V0384 FIRST INHABITED CROSSING REVIEW`

The next decision is visual: accept this as the first inhabited target, request one bounded revision, or reject the authored geometry as insufficient. No v0.385 work is started by this checkpoint.
