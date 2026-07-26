# v0.394 Route-Only Visibility Repair and Fence Regression Rollback

## Scope

This is a narrow, opt-in visual repair after the independent rejection of v0.393. It removes the rejected fence/gate geometry and makes one continuous worn-earth route render reliably. It does not add gameplay or alter the accepted runtime.

## Ancestry and concrete defect

v0.391 remains retained. v0.392 was independently rejected because the route was not traceable. v0.393 was independently rejected because the route was still absent in primary and grayscale and the new brown fence beams floated, intersected roofs, and did not form a credible gate. The concrete implementation defect found during recovery was single-sided ground material culling: route meshes were present in the scene graph but could disappear from the camera-facing side.

## Repair

- Disabled culling on the route/ground material so the route is visible from the RTS camera.
- Removed every v0.393 fence run and gate-post mesh; the rollback is represented only by `V0394_Yard_Group_05_Fence_Regression_Rolled_Back` and a metadata audit flag.
- Added exactly one route assembly containing one flush continuous main route from the western bridge landing through the yard to the house doorway, plus one flush branch to the barn entrance.
- Kept the route dark and warm in primary and grayscale, with a minimal elevation above the terrain to prevent z-fighting and no raised slab or side walls.

## Unchanged

Buildings, characters, yard props, bridge, river, road infrastructure, camera treatment, lighting direction, gameplay, state semantics, IDs, saves, and the true default runtime are unchanged. This is opt-in through `--v0394-route-only`, `--v0394-route-only-smoke`, and `--v0394-route-only-capture`.

## Evidence and commands

- Launch: `npm run godot:play:v0394-route-only`
- Smoke: `npm run godot:smoke:v0394-route-only`
- Capture: `npm run godot:capture:v0394-route-only`
- Validator: `npm run godot:validate:v0394-route-only`
- Review pack: `artifacts/manual-review/v0394-route-only-visibility-repair-fence-regression-rollback/`

The capture pack contains seven real 1920x1080 Godot renders, including primary and grayscale views. Acceptance is deliberately deferred to independent visual review; green structural validation is not visual acceptance.

## Review status

Final status: ACCEPTED BY INDEPENDENT V0394 VISUAL REVIEW. The linked ChatGPT review confirmed that one continuous worn-earth route is traceable from the western bridge landing through the yard to the house doorway, with a visible barn branch, in both primary and grayscale. It also confirmed all v0.393 fence/gate beams are gone and no floating/protruding brown geometry remains. No fence was reintroduced.

## Validation

The dedicated validator checks the opt-in scene, cull-safe route, removed v0.393 fence geometry, seven real captures, retained infrastructure hashes, forbidden gameplay tokens, and the documentary contract. The retained runtime remains the fallback/proof layer.
