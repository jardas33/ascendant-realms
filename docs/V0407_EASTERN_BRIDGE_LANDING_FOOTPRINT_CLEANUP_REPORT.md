# v0.407 Eastern Bridge Landing Footprint Cleanup

## Scope

v0.407 is a narrow, opt-in visual correction for the eastern landing of the accepted Salto crossing. The only runtime change is a material reassignment on one existing bridge component. No gameplay, geometry authoring, scene topology, camera, lighting, or default-runtime behavior is changed.

## Base and branch

- Base commit: `f109828e0827ba0ee8eb35ab5f8c5cc71f0b4149` (accepted v0.406)
- Branch: `codex/v0215-v0226-recovery`
- Prototype entry scene: `desktop-spikes/godot-salto/scenes/v0407_eastern_bridge_landing_footprint_cleanup.tscn`

## Diagnosis

The v0.406 comparison showed an oversized dark trapezoidal footprint beneath the eastern bridge landing. A temporary, isolated component diagnostic tested the existing footing, abutment, underbeam, and edge-course meshes with distinct unshaded colours. The green `Bridge_Abutment_+1` panel matched the footprint exactly; the footing, underbeam, and edge course did not. The diagnostic was temporary and is not part of the runtime path.

## Correction

`Bridge_Abutment_+1` now receives a duplicated warm-earth material derived from the accepted v0.396 route material. The derived material disables inherited vertex tint, uses a restrained warm-earth albedo, and remains fully rough. The correction is material-only:

- Y correction: `0.0`
- X/Z coordinates: unchanged
- vertex count: `8` before and after
- index count: `36` before and after
- triangles: `12` before and after
- surfaces: `1` before and after
- topology and indices: unchanged
- duplicate meshes, overlays, and decals: none

The bridge remains structurally seated and the eastern landing reads as a warm-earth continuation rather than a dark diagnostic footprint. The close colour and grayscale renders show no dominant dark polygon; the landing remains legible as a connected approach surface.

## Evidence

- Capture command: `npm run godot:capture:v0407-eastern-landing`
- Smoke command: `npm run godot:smoke:v0407-eastern-landing`
- Validator: `npm run godot:validate:v0407-eastern-landing`
- Runtime evidence: `desktop-spikes/godot-salto/artifacts/runtime/v0407/`
- Review pack: `artifacts/manual-review/v0407-eastern-bridge-landing-footprint-cleanup/`
- Evidence: seven real rendered PNGs, component-isolation diagnostic, wide/close v0.406-v0.407 comparisons, and `v0407-preservation-audit.json`

## Preservation

The accepted bridge deck, rails, supports, road geometry, terrain, buildings, characters, props, route topology, lighting, camera, gameplay, fallback renderer, debug renderer, and true default runtime are unchanged. The v0.407 router is opt-in through explicit capture/smoke arguments and does not alter normal launch behavior.

## Review verdict

`ACCEPT` for the bounded v0.407 gate. The responsible existing component is identified by rendered isolation evidence, and the final candidate removes the dark value failure without replacing or moving geometry. The remaining warm-earth landing shape is the existing abutment surface and is visually consistent with the route rather than a dark diagnostic blob.

## Validation

The v0.407 smoke and rendered capture pass. The dedicated validator checks the existing eastern abutment, material-only assignment, zero vertical correction, geometry preservation, real non-blank captures, opt-in routing, and runtime/default preservation. Retained v0.406, v0.401, and v0.400 validators plus the repository test/build/content/art/runtime/Godot checks are run before commit and recorded in the closeout.

## Closeout

Commit, exact pushed SHA, GitHub Actions result, and final clean/synced repository state are added here after the local validation ladder and remote CI complete.
