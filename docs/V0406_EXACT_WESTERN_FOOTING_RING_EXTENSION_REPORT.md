# v0.406 Exact Western Footing Ring Extension

## Scope

This opt-in visual checkpoint tests one source-mesh correction at the accepted western bridge landing. Exactly four existing vertices on `Bridge_Footing_-1` — indices `[2, 3, 4, 6]` — receive the measured horizontal delta `X +0.444089`, `Z +0.106548`; Y and every other node, mesh, surface, index, transform, route, bridge deck, rail, support, building, character, camera, lighting, and gameplay contract remain unchanged.

## Evidence

- Capture: `npm run godot:capture:v0406-western-footing`
- Smoke: `npm run godot:smoke:v0406-western-footing`
- Validator: `npm run godot:validate:v0406-western-footing`
- Runtime evidence: `desktop-spikes/godot-salto/artifacts/runtime/v0406/`
- Review pack: `artifacts/manual-review/v0406-exact-western-footing-ring-extension/`
- Base: accepted v0.401 commit `c4c25ab04ca94e2098712fbd8e987c4d8af42e4c`

The pack contains real wide and close colour renders, grayscale renders, a diagnostic capture naming only the four moved vertices, and before/after comparisons. The source correction is fail-closed if the visible pale gap, seam, wedge, or distorted footing remains.

## Preservation

The correction is implemented as an in-memory replacement of the existing single-surface `ArrayMesh` on the existing `MeshInstance3D`; no duplicate scene node, overlay mesh, decal, material workaround, or gameplay object is created. The audit records counts, hashes, AABBs, transforms, exact coordinates, displacement, topology/index preservation, unchanged route/deck/rail/support hashes, and default/fallback/debug renderer preservation.

## Review gate

This checkpoint is not accepted by validator success alone. Human review must confirm uninterrupted warm-earth route continuity in colour and grayscale, a naturally seated wooden bridge, no pale island or material seam, and no stretched/skewed/pinched support. If any criterion fails, revert the candidate and record `ASSET_GEOMETRY_LIMITATION_FINAL`; do not commit.

## Independent visual verdict

`ACCEPT` from the independent ChatGPT review of the seven real renders and `v0406-preservation-audit.json`. Wide and close colour views show one uninterrupted warm-earth route into the western landing with no pale gap, island, dark wedge, or distracting seam. The bridge deck remains structurally distinct and seated; the footing reads neither stretched nor skewed. Grayscale preserves the route-to-landing value band while deck, rails, and supports remain readable. The diagnostic identifies only `Bridge_Footing_-1` vertices `[2,3,4,6]`, each displaced `0.4566918` world units with unchanged Y. The audit confirms unchanged topology, indices, surfaces, vertex/triangle/node/mesh counts, route and deck/rail hashes, no overlays or duplicates, no gameplay change, and no default-runtime mutation.
