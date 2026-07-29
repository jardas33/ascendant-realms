# v0.395 Natural Worn-Earth Route Material and Edge Integration

## Scope

This is a narrow opt-in visual-only refinement of the independently accepted v0.394 route. It changes only route material, local width profile, vertex-tone variation, and locked-camera evidence. No gameplay, infrastructure, props, characters, camera, or default runtime semantics change.

## Baseline and carried-forward contract

v0.394 remains the fixed route topology baseline: western bridge landing to working yard to house doorway, with one branch to the barn entrance. The v0.394 cull-safe route and complete fence rollback are retained through inheritance and explicit preservation metadata.

## What changed

- Replaced the oversized near-black route treatment with compacted warm worn earth (`#7b573b`) using a rough, unshaded, cull-disabled material.
- Added restrained per-vertex tonal variation so the surface reads as worn earth without becoming noisy or glossy.
- Reduced route width at the bridge landing, house doorway, and barn branch.
- Kept one controlled widening around the working yard/cart/workstation.
- Added a locked six-view capture set plus a 3840x1080 v0.394/v0.395 primary comparison render.

## What did not change

Buildings, characters, yard props, bridge, river, roads, camera framing, lighting direction, gameplay, state semantics, stable IDs, saves, and true default runtime remain unchanged. No fence, gate, movement, pathfinding, combat, economy, or resource behavior was added.

## Visual review criteria

The route must remain immediately traceable in primary and grayscale views, darker than surrounding terrain but not black, flush with no sidewalls or floating slab, narrower at transitions, and wider only around the working yard. Independent visual review and acceptance is required; the structural validator is not a substitute for rendered review.

## Evidence and commands

- Launch: `npm run godot:play:v0395-route-material`
- Smoke: `npm run godot:smoke:v0395-route-material`
- Capture: `npm run godot:capture:v0395-route-material`
- Validator: `npm run godot:validate:v0395-route-material`
- Review pack: `artifacts/manual-review/v0395-natural-worn-earth-route-material-edge-integration/`

The pack contains real 1920x1080 Godot renders, grayscale evidence, and a direct v0.394/v0.395 comparison image. Black, blank, and title-card-only evidence is rejected.

## Validation

The dedicated validator checks v0.394 topology inheritance, material and width contracts, opt-in routing, forbidden gameplay tokens, retained asset hashes, seven real captures, comparison dimensions, review-pack file integrity, and the independent-review gate.

## Review status

Ready for independent v0.395 visual review.
