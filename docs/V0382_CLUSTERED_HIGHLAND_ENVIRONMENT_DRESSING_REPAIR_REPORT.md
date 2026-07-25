# v0.382 Clustered Highland Environment Dressing Repair

## Executive result

v0.382 is an isolated opt-in presentation repair for the rejected v0.381 sparse environment dressing. The final render passes the clustered-dressing gate and is ready for human review. The accepted bridge, river, roads, terrain, and v0.380 infrastructure GLB remain unchanged.

## Provenance and base

- Branch: `codex/v0215-v0226-recovery`
- Starting HEAD: `a5173d23b6fa7845817e28795f9daa72d6d15def`
- Accepted infrastructure commit: `06f45ce1428af5baeac77d542fa1e0811b52c88a`
- Ancestry check: passed; v0.380 is an ancestor of the starting HEAD.
- Imported GLB SHA-256: `746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb`
- Source generator SHA-256: `4b8eafeac69f16a87bd6899a69ab6c6bb8cb5d49103c5ba9cb3da325f38f3e19`

## Scope

The prototype is `desktop-spikes/godot-salto/scenes/v0382_clustered_highland_dressing.tscn`, routed only by the v0.382 command flags. It loads the v0.380 kit unchanged and adds only existing in-repository Quaternius dressing. No buildings, units, HUD, gameplay, state, movement, pathfinding, combat, economy, resource, save, or default-runtime changes are included.

## What changed

- Removed the v0.381 sparse/even showroom placement by using a new scene rather than layering on that scene.
- Added six named riverbank clusters, three on each bank, with tall grass, low grass, shrubs, and two rock shapes.
- Added two asymmetrical highland vegetation masses with trees, shrubs, grass, and grouped rocks.
- Added five deliberate geological rock clusters instead of isolated authored dressing rocks.
- Added only restrained approach dressing: two fence fragments and one crate.
- Added a tighter 22-unit orthographic oblique RTS primary and deterministic detail/audit captures.
- Added the three-iteration render log, dedicated validator, package commands, and review pack.

## Visual review

The primary render keeps the bridge and continuous river as the focal corridor. The two large masses register at opposite outer areas without blocking the bridge deck or landings. Six bank clusters are visible in the primary and close detail. The audit view verifies that authored dressing is clustered and that the scene contains no translucent debug pads or map edge. The grayscale capture retains separation between bridge, river, cluster silhouettes, and terrain.

The v0.381 failure was sparse/random dressing. v0.382 addresses that failure structurally through named clusters, deliberate asymmetry, scale appropriate to the bridge rail, and a tighter composition. The accepted infrastructure itself is not redesigned.

## Iterations

See `artifacts/work/v0382-iteration-log.md`. Iteration 1 cleaned distribution and established rock/mass structure; iteration 2 added six readable bank clusters; iteration 3 applied framing, approach dressing, and lighting polish. Each iteration has real 1920x1080 captures under `desktop-spikes/godot-salto/artifacts/work/`.

## Lighting and constraints

Lighting is neutral-to-warm daylight with restrained cool fill. No fog, bloom, dramatic color treatment, or gameplay-zone shadows were added. Existing Quaternius assets are used under the retained repository notice; no external or purchased assets were imported.

## Default-runtime and gameplay preservation

The scene is opt-in only through `--v0382-clustered-dressing`, `--v0382-clustered-dressing-smoke`, and `--v0382-clustered-dressing-capture`. The true default runtime is untouched. No gameplay systems or state chain are present in the scene. The accepted v0.380 GLB hash is asserted by the validator.

## Paths and commands

- Scene: `desktop-spikes/godot-salto/scenes/v0382_clustered_highland_dressing.tscn`
- Script: `desktop-spikes/godot-salto/scripts/v0382_clustered_highland_dressing.gd`
- Launch: `npm run godot:play:v0382-clustered-dressing`
- Smoke: `npm run godot:smoke:v0382-clustered-dressing`
- Capture: `npm run godot:capture:v0382-clustered-dressing` with `V0382_ITERATION=1|2|3` and optional `V0382_OUTPUT_ROOT`
- Validator: `npm run godot:validate:v0382-clustered-dressing`
- Review pack: `artifacts/manual-review/v0382-clustered-highland-dressing/`

## Validation and CI

The dedicated validator asserts opt-in routing, exact accepted GLB provenance, clustered scene structure, real 1920x1080 captures, the review-pack file contract, and no gameplay tokens. v0.380 validation remains part of the closeout ladder. Full local validation and exact-SHA GitHub Actions results are recorded at closeout after commit.

## Recommendation

Proceed to human review of this isolated clustered-dressing prototype. Do not migrate it into the accepted runtime or begin v0.383 from this report until the human visual decision is explicit.
