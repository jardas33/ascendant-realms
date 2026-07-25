# v0.381 Accepted Highland Infrastructure Environment Dressing Pass

## Executive result

v0.381 adds a small opt-in environment-dressing layer around the accepted v0.380 crossing. The supplied corrected infrastructure asset is not modified or replaced. The rendered result remains suitable for human review: the bridge is still the focal crossing, the river remains continuous, and the dressing reduces the sparse prototype feel without introducing gameplay or default-runtime changes.

## Scope and base

- Branch: `codex/v0215-v0226-recovery`
- Starting base: accepted v0.380 final state `06f45ce1428af5baeac77d542fa1e0811b52c88a`
- Base infrastructure: `desktop-spikes/godot-salto/assets/v0380/corrected-highland-infrastructure/barrosan_highland_infrastructure_v0380.glb`
- Prototype scene: `desktop-spikes/godot-salto/scenes/v0381_highland_infrastructure_dressing.tscn`
- Launch: `npm run godot:play:v0381-highland-dressing`
- Capture: `npm run godot:capture:v0381-highland-dressing`

## What changed

The new scene instantiates the unchanged v0.380 GLB and adds a deterministic `V0381_Sparse_Environment_Dressing_Only` node. Existing in-repository Quaternius v0370 content is used under its retained `THIRD_PARTY_NOTICE.md`: four distant trees, riverbank shrubs and reeds, six distributed rocks, and two fence segments plus one wooden crate placed well away from the crossing deck. Lighting and the v0.380 orthographic oblique camera treatment are retained.

## What did not change

There is no movement, pathfinding, route following, combat, damage, HP, AI, waves, economy, resources, production, pressure, state-chain, ID, save, HUD, or default-runtime work. The supplied v0.380 source asset remains byte-identical at SHA-256 `746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb`; its generator remains `4b8eafeac69f16a87bd6899a69ab6c6bb8cb5d49103c5ba9cb3da325f38f3e19`.

## Visual review

The primary and crossing-context frames show added environmental scale cues without crowding the bridge. The riverbank detail keeps reeds/shrubs on land and out of the channel. The bridge detail preserves deck, rails, supports, and landings. The elevated audit shows sparse distribution rather than a repeated wall of props. The grayscale frame confirms that the new silhouettes remain secondary to the crossing. No black, blank, or title-card-only evidence is included.

## Isolation and validation

The route is opt-in through `--v0381-highland-dressing`, `--v0381-highland-dressing-smoke`, and `--v0381-highland-dressing-capture`. The dedicated validator is `tools/godot/saltoV0381HighlandInfrastructureDressingTool.mjs` and the review pack is `artifacts/manual-review/v0381-highland-infrastructure-dressing/`. It asserts unchanged v0.380 hashes, existing-repository-only dressing paths, exact six rendered captures, opt-in/default-runtime boundaries, and absence of gameplay tokens.

## Remaining limitations and next review

The underlying v0.380 infrastructure remains a restrained review-layer kit with a simple material palette and limited surrounding ecology. v0.381 does not claim final production richness or full Salto conversion. Human review should decide whether the sparse dressing is a useful environment-context direction before any broader slice work. Do not start a new checkpoint from this report without an explicit next bounded goal.
