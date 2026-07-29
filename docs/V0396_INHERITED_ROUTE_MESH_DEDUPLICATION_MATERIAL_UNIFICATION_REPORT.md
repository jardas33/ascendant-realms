# v0.396 — Inherited Route Mesh De-duplication and Material Unification

Status: Accepted by independent v0.396 visual review.

## Scope

This is a narrow opt-in visual repair following the independent v0.395 `REVISE ONCE` verdict. The accepted v0.394 route topology and v0.395 flush elevation are preserved. The repair identifies the inherited material override that made the main route read as a near-black patch and unifies that route mesh with the v0.395 compacted warm worn-earth material.

## Diagnosis

Runtime mesh inventory identified `V0395_One_Compacted_Warm_Earth_Bridge_Yard_Door_Route` with the inherited `V0394_Bridge_Desaturated_Value` material override. The name contains `Bridge`, so the inherited v0.394 bridge-value pass also matched the generated main route. This explains why the barn/doorway side appeared warm while the bridge-to-yard section remained near-black.

## What changed

- Added an opt-in v0.396 route-mesh diagnosis and material-unification script.
- Captured an isolated diagnostic frame with the inherited main route hidden before the final render.
- Replaced only the inherited main-route material override with the v0.395 compacted warm worn-earth material contract.
- Preserved route topology, width profile, flush elevation, cull safety, doorway termination, barn branch, western landing contact, bridge, terrain, props, characters, camera, lighting, gameplay, and default runtime.
- Added deterministic smoke/capture/validation commands and five real renders.

## Evidence

- `01_PRIMARY_RTS_VIEW.png`: unified warm route from bridge landing through yard to doorway.
- `02_CLOSE_ROUTE_YARD_DOORWAY.png`: close route continuity and local material read.
- `03_GRAYSCALE_PRIMARY.png`: route remains distinct without becoming the darkest shape.
- `04_DIAGNOSTIC_INHERITED_ROUTE_MESH_ISOLATED.png`: pre-unification isolation evidence.
- `05_V0395_V0396_PRIMARY_COMPARISON.png`: direct before/after comparison.

## Boundaries preserved

No bridge, terrain, building, character, prop, camera, lighting, state, gameplay, movement, pathfinding, combat, economy, resource, save, stable-ID, or true-default runtime behavior changed. No geometry was raised or moved.

## Commands

- Launch: `npm run godot:play:v0396-route-mesh`
- Smoke: `npm run godot:smoke:v0396-route-mesh`
- Capture: `npm run godot:capture:v0396-route-mesh`
- Validator: `npm run godot:validate:v0396-route-mesh`
- Review pack: `artifacts/manual-review/v0396-inherited-route-mesh-deduplication-material-unification/`

Independent visual review is required; structural validation is not visual acceptance.

## Independent verdict

`ACCEPT` — the route is consistently warm-brown from the bridge landing through the yard to the doorway and barn branch; the near-black inherited patch is gone; grayscale continuity remains legible; and no topology, elevation, or surrounding-scene regression is visible.
