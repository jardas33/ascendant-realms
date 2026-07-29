# v0.393 Explicit Route Silhouette and Front-Yard Gate Repair

## Scope and ancestry

This is a bounded, opt-in visual repair following the independent v0.392 `REJECT`. It addresses only the rendered circulation silhouette and front-yard gate readability. No gameplay, state, asset-family, building, character, bridge, river, or default-runtime change is authorized.

- Base: v0.392 rejected rendered review
- Branch: `codex/v0215-v0226-recovery`
- v0.392 remains retained as the rejected reference; v0.391 remains retained in the rejected ancestry.
- Accepted v0.380 infrastructure GLB remains hash-locked at `746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb`.

## Narrow repair

- Replaced the visually lost route with one broad, flush, high-contrast irregular route ribbon that physically touches the western bridge landing, remains continuous through the yard, widens around the cart/workstation, and terminates at the house doorway.
- Added one visible barn-facing branch.
- Removed the asset fence placement from the visible gate contract and authored two coherent foreground fence runs with a wide gateway and paired gate posts.
- Kept the house, separate barn, five yard functions, three roles, bridge, river, and accepted infrastructure unchanged.
- Kept the prototype opt-in and visual-only.

## Required rendered acceptance

The primary RTS render and the grayscale render must make the complete route and open gateway immediately identifiable without labels, validator prose, or title-card evidence. If that condition is not met, this checkpoint must remain rejected.

## Preservation

No movement, navigation, pathfinding, route following, combat, AI, economy, production, stable-ID, save, pressure, state-chain, resource, or true-default runtime behavior changed. v0.392 and all earlier rejected/accepted references remain available.

## Evidence and validation

- Scene: `desktop-spikes/godot-salto/scenes/v0393_explicit_route_silhouette_front_yard_gate_repair.tscn`
- Capture: `npm run godot:capture:v0393-explicit-route`
- Smoke: `npm run godot:smoke:v0393-explicit-route`
- Validator: `npm run godot:validate:v0393-explicit-route`
- Review pack: `artifacts/manual-review/v0393-explicit-route-silhouette-front-yard-gate-repair/`
- Iteration records: `desktop-spikes/godot-salto/artifacts/work/v0393-iteration-01/` through `-03/`

## Independent v0.393 rendered verdict

`REJECT`.

The independent review found that the route repair was still absent in both the primary RTS and grayscale renders. The fence work was a severe regression: large brown beams floated around the barn, penetrated or protruded through the barn and house roofs, failed to form coherent runs, and exposed no readable gateway or paired posts. The five yard functions and three characters remained visible, but the settlement composition was less credible than v0.392 and the bridge still dominated.

## Next checkpoint

v0.394 — Route-Only Visibility Repair and Fence Regression Rollback:

- remove every v0.393 fence, gate post, and brown beam;
- restore the clean pre-v0.393 settlement geometry;
- add exactly one flush continuous worn-earth route mesh touching the western landing, passing between traveller and yard functions, widening around cart/workstation, terminating at the house doorway, and branching to the barn entrance;
- use a darker, warmer value that remains distinct in grayscale;
- keep it minimally above terrain to avoid z-fighting without a raised slab or visible sides;
- do not change buildings, characters, props, bridge, river, lighting, camera, gameplay, or default runtime.

Do not reintroduce fencing until the route alone passes rendered review.

The pack is now fail-closed as rejected. Structural green is not visual acceptance; black frames, title cards, and validator-only claims do not satisfy the gate.
