# v0.140 Reference-Only Boundary

Status: hard boundary for the v0.140 canary session.

## Allowed

- Generate exactly three Salto environment reference-only candidates.
- Store the generated candidates locally under the ignored v0.138 art-review workspace.
- Create matching ignored metadata records.
- Validate metadata, hashes, dimensions, contact sheet, and review pack.
- Commit tracked documentation that records the evidence and boundaries.

## Forbidden

- Generate HUD art, Aster art, Worker art, unit art, sprites, textures, models, animation sheets, or extra variants.
- Import, wire, register, package, approve, or load generated images in Godot or the browser runtime.
- Mutate runtime registries, art-slot registries, asset manifests, save data, stable IDs, content manifests, package scripts, or build outputs to consume candidates.
- Mark any candidate final, production-approved, protected-IP-approved, runtime-approved, or style-locked.
- Start v0.141 automatically.

## Metadata Boundary

Every v0.140 candidate metadata file must keep:

- `licencePosture.runtimeUse = forbidden`
- `runtimeIntegrationStatus = forbidden`
- `protectedIpReview.status = pending`
- `protectedIpReview.protectedLookalikeRisk = unknown`
- `humanStatus = pending-review`

This metadata is not a runtime registry. It must not be read by Godot, the browser runtime, save systems, asset manifests, stable-ID registries, or build packaging as production art.

## Stop State

v0.140 stops at human art review. Emmanuel should review the three environment candidates and decide whether any candidate is directionally promising, needs iteration, or should be rejected before any later milestone is queued.
