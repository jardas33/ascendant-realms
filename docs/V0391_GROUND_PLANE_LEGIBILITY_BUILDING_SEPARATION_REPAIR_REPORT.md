# v0.391 Ground-Plane Legibility and Building Separation Repair

## Scope and ancestry

This is a bounded, opt-in visual repair following the independent v0.390 `REJECT`. It targets only ground-plane legibility, route visibility, barn separation, functional-yard spacing, and settlement-versus-bridge value hierarchy.

- Base commit: `9fddf4fe` (v0.390 rejection record)
- Branch: `codex/v0215-v0226-recovery`
- v0.390 remains retained as the rejected reference.
- Accepted v0.380 GLB hash remains `746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb`.

## v0.391 repairs

- Removed the broad workstation slab in favor of a narrow two-leg bench and ground-level whetstone.
- Extended one clearly visible flush irregular worn-earth surface from the western bridge landing through the yard to the doorway, with a short branch toward the barn entrance.
- Moved the barn farther left/back and rotated it toward the shared yard so its roof silhouette and yard-facing side separate from the house.
- Re-spaced cart, firewood, storage, bench, and open-gate fence directly on the yard surface.
- Applied a named bridge-value control, lifted settlement midtones, and tightened framing without changing accepted infrastructure or gameplay geometry.

## Preservation

No gameplay, movement, navigation, pathfinding, combat, AI, economy, production, stable-ID, save, state-chain, pressure, resource, accepted geometry, or true-default runtime behavior was changed. v0.390 remains available as a rejected reference and the accepted v0.380-v0.389 lineage is retained.

## Prior v0.390 independent rendered verdict

The linked ChatGPT visual review inspected seven real 1920x1080 Godot frames and returned `REJECT`. The validator remained green, but the rendered gate was not met:

- the route remained too pale and diffuse to read as one deliberate bridge landing to yard to doorway connection;
- a rectangular workstation slab still read as debug geometry;
- firewood and the fence/gate did not resolve as independent functions;
- the barn roof silhouettes merged with the house;
- the bridge still dominated grayscale value and contrast.

The three character roles were visibly separated, so that part passed. The narrow v0.391 repair is to remove artificial bases, make the route and barn branch visibly read on the ground plane, separate the barn roof silhouettes, and rebalance bridge/settlement values. No new asset families, buildings, characters, props, vegetation, gameplay, HUD, animation, or runtime integration are authorized.

## Evidence and validation

- Scene: `desktop-spikes/godot-salto/scenes/v0391_ground_plane_legibility_building_separation_repair.tscn`
- Capture: `npm run godot:capture:v0391-ground-plane`
- Smoke: `npm run godot:smoke:v0391-ground-plane`
- Validator: `npm run godot:validate:v0391-ground-plane`
- Review pack: `artifacts/manual-review/v0391-ground-plane-legibility-building-separation-repair/`
- Iteration records: `desktop-spikes/godot-salto/artifacts/work/v0391-iteration-01/` through `-03/`

The pack is ready for independent rendered review. Structural validation remains separate from visual acceptance; black frames, title-card-only evidence, and validator-only claims are not acceptance evidence.

## v0.391 independent rendered verdict

The linked ChatGPT visual review inspected all seven real 1920x1080 Godot frames and returned `REJECT`. Three requirements passed: the workstation slab is gone, the barn has a clear roof silhouette and ground separation, and all three characters are visible and unobstructed. The rendered gate still failed because:

- the required bridge-landing to yard to house-door route was visually absent on the uniform pale ground;
- the fence pieces did not form a coherent boundary or unmistakable open gate;
- the bridge and bright landing still competed strongly with the settlement focal cluster.

The narrow next checkpoint is v0.392 Worn-Earth Route and Open-Gate Readability Repair: add one flush, irregular, visibly contrasting worn-earth surface that begins at the western landing, widens through the yard, terminates at the doorway, and branches to the barn; replace disconnected fence pieces with one short coherent fence line and unmistakable open gate; slightly reduce bridge brightness and lift local doorway/yard/gate contrast. No new assets, buildings, characters, gameplay, HUD, animation, or default-runtime changes are authorized.
