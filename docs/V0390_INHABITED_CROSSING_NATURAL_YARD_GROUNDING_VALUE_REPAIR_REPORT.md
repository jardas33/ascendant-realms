# v0.390 Natural Yard Grounding and Settlement Value Repair

## Scope and ancestry

This is a bounded opt-in visual repair following ChatGPT's v0.389 `REJECT`. It targets only flush yard grounding, route continuity, farmyard relationship, functional prop legibility, and grayscale hierarchy.

- Base commit: `bdf7462940db89c0bbad207ed26464c77efe1688`
- Branch: `codex/v0215-v0226-recovery`
- v0.389 remains retained as the rejected reference.
- Accepted v0.380 GLB hash remains `746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb`.

## Repairs

- Raised a continuous dark-earth route underlay and warm worn-earth inlay so the bridge landing → yard → doorway line survives the land-plane value.
- Repositioned and angled the barn toward the shared yard while preserving a visible gap and separate silhouette.
- Grounded cart, firewood, storage, and workstation directly on the shared flush yard surface with no individual rectangular pads.
- Moved the farmer and porter into open yard positions while retaining the crossing guard at the bridge approach.
- Reduced bridge key-light dominance, raised settlement midtones, and tightened primary framing without changing world geometry.

## Preservation

No gameplay, movement, navigation, pathfinding, combat, AI, economy, production, stable-ID, save, state-chain, pressure, resource, accepted geometry, or true-default runtime behavior was changed. v0.388 remains available as a rejected reference and the accepted v0.380–v0.387 lineage is retained.

## Evidence and validation

- Scene: `desktop-spikes/godot-salto/scenes/v0390_inhabited_crossing_natural_yard_grounding_value_repair.tscn`
- Capture: `npm run godot:capture:v0390-inhabited-crossing`
- Smoke: `npm run godot:smoke:v0390-inhabited-crossing`
- Validator: `npm run godot:validate:v0390-inhabited-crossing`
- Review pack: `artifacts/manual-review/v0390-inhabited-crossing-natural-yard-grounding-value-repair/`
- Three iteration records: `desktop-spikes/godot-salto/artifacts/work/v0390-iteration-01/` through `-03/`

The final pack is submitted for independent rendered review. It must be judged from the actual Godot frames, not from the structural validator.

## Prior v0.389 independent rendered verdict

The linked ChatGPT visual review returned `REJECT` after inspecting the seven real 1920x1080 Godot frames. The validator remains green, but the rendered gate is not met:

- the route still reads as disconnected angular patches rather than bridge landing → yard → doorway;
- raised rectangular work/storage surfaces read as debug pads;
- the barn remains detached and partly collapses into a dark roof slab;
- the five yard functions are not independently legible at primary RTS scale;
- the bridge still dominates grayscale value and contrast.

The three character roles were visibly separated, so that part passes. The narrow next checkpoint is v0.390 Natural Yard Grounding and Settlement Value Repair: replace the raised pads with one flush irregular yard surface, ground all five functions directly on it, move/angle the barn toward the shared yard while preserving a gap, reduce bridge brightness, raise settlement midtones, and tighten primary framing. No new assets, buildings, props, vegetation, gameplay, HUD, animation, or runtime integration are authorized by this review.

## v0.390 independent rendered verdict

The linked ChatGPT visual review inspected all seven real 1920x1080 Godot frames and returned `REJECT`. The characters were visible and unobstructed, but the visual gate was not met:

- the bridge-landing → yard → doorway connection remained too pale and diffuse to read as one deliberate worn-earth route;
- a rectangular workstation slab still read as debug geometry;
- the five yard functions were not independently legible, with firewood and fence/gate failing to resolve;
- the barn remained too tightly overlapped with the house and the roof silhouettes merged;
- grayscale still made the bridge the largest and brightest object while the settlement compressed into a dark cluster.

The narrow next checkpoint is v0.391 Ground-Plane Legibility and Building Separation Repair: remove remaining artificial bases, make one clearly visible flush irregular yard surface with a barn branch, separate the barn roof silhouettes and expose its yard-facing side, ground all five functions with distinct spacing, and rebalance bridge/settlement values and framing. No new asset families, buildings, characters, gameplay, HUD, animation, or default-runtime changes are authorized.
