# v0.389 Inhabited Crossing Farmyard Readability Repair

## Scope and ancestry

This is a bounded opt-in visual repair following ChatGPT's v0.388 `REJECT`. It targets only route contrast, farmyard relationship, functional prop legibility, role spacing, and grayscale hierarchy.

- Base commit: `5eda14d5f45bd60d8fcda95bc6365fd333deac23`
- Branch: `codex/v0215-v0226-recovery`
- v0.388 remains retained as the rejected reference.
- Accepted v0.380 GLB hash remains `746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb`.

## Repairs

- Raised a continuous dark-earth route underlay and warm worn-earth inlay so the bridge landing → yard → doorway line survives the land-plane value.
- Moved the barn into a closer but non-overlapping farmyard relationship with the house.
- Reduced cart dominance and added authored low-profile working surfaces for cart, firewood, storage, and the workbench.
- Moved the farmer and porter into open yard positions while retaining the crossing guard at the bridge approach.
- Added a visible doorway threshold stone and increased localized settlement fill without changing accepted infrastructure.

## Preservation

No gameplay, movement, navigation, pathfinding, combat, AI, economy, production, stable-ID, save, state-chain, pressure, resource, accepted geometry, or true-default runtime behavior was changed. v0.388 remains available as a rejected reference and the accepted v0.380–v0.387 lineage is retained.

## Evidence and validation

- Scene: `desktop-spikes/godot-salto/scenes/v0389_inhabited_crossing_farmyard_readability_repair.tscn`
- Capture: `npm run godot:capture:v0389-inhabited-crossing`
- Smoke: `npm run godot:smoke:v0389-inhabited-crossing`
- Validator: `npm run godot:validate:v0389-inhabited-crossing`
- Review pack: `artifacts/manual-review/v0389-inhabited-crossing-farmyard-readability-repair/`
- Three iteration records: `desktop-spikes/godot-salto/artifacts/work/v0389-iteration-01/` through `-03/`

The final pack is submitted for independent rendered review. It must be judged from the actual Godot frames, not from the structural validator.

## Independent rendered verdict

The linked ChatGPT visual review returned `REJECT` after inspecting the seven real 1920x1080 Godot frames. The validator remains green, but the rendered gate is not met:

- the route still reads as disconnected angular patches rather than bridge landing → yard → doorway;
- raised rectangular work/storage surfaces read as debug pads;
- the barn remains detached and partly collapses into a dark roof slab;
- the five yard functions are not independently legible at primary RTS scale;
- the bridge still dominates grayscale value and contrast.

The three character roles were visibly separated, so that part passes. The narrow next checkpoint is v0.390 Natural Yard Grounding and Settlement Value Repair: replace the raised pads with one flush irregular yard surface, ground all five functions directly on it, move/angle the barn toward the shared yard while preserving a gap, reduce bridge brightness, raise settlement midtones, and tighten primary framing. No new assets, buildings, props, vegetation, gameplay, HUD, animation, or runtime integration are authorized by this review.
