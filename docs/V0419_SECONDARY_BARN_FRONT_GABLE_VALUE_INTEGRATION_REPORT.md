# v0.419 Secondary-Barn Front-Gable Value Integration

## Scope

This checkpoint is a single existing-surface material calibration for the visible secondary-barn front gable. It is opt-in capture tooling only and does not alter gameplay, runtime state, geometry, topology, transforms, UVs, camera, lighting, or any accepted prior checkpoint. It does not reopen v0.409-v0.418.

## Base and branch

- Base HEAD: `99f8ca689b8eac75e4f80c3c2e3c7b729e78da42`
- Branch: `codex/v0215-v0226-recovery`
- Target: `V0399_Barn_Front_Gable`
- Classification: `BARN_FRONT_GABLE`

## Candidate and inventory gate

The live scene inventory contains exactly one visible front-gable MeshInstance3D, `V0399_Barn_Front_Gable`, with no additional visible gable, pediment, or triangular façade surface. Its existing material-addressable surface is classified `BARN_FRONT_GABLE`. The accepted candidate is `V0419_Secondary_Barn_Front_Gable` with albedo `#675d52`, roughness `0.97`, specular `0.07`, and vertex-colour albedo disabled. The candidate is slightly warmer/lighter than the v0.417 wall body while avoiding the previous bright sunlit-stone read. If the inventory gate fails, the script writes `ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_FRONT_GABLE` and retains no candidate.

## Preservation

The v0.417 wall body and v0.418 entrance/window treatments remain applied through the inherited opt-in chain. Roof halves, ridge, eaves, timber frame, base, contact shadow, terrain, bridge, route, characters, props, camera, lighting, gameplay, default runtime, fallback renderer, and debug renderer remain unchanged. The audit records material-only status, zero new MeshInstance3D nodes, unchanged world hashes, unchanged mesh counts (292 before/after), unchanged snapshots, and all geometry/topology/indices/vertices/surfaces/transforms/AABB/UV/overlay/decals/duplicate-mesh flags false.

## Rendered evidence observation

The real v0.419 captures are nonblank PNGs at 1920x1080, with 3840x1080 before/after comparison strips. The wide view keeps the bridge, river, route, primary house, secondary barn, props, and characters readable. The close view shows the upper gable joining the restrained wall family, with the roof planes, timber edges, and v0.418 dark openings still distinct. Grayscale preserves the same hierarchy without a pale triangular insert. The comparison strips show the bounded material change only; no added geometry or overlay appears.

## Functional and runtime preservation

- Candidate retained: `true`; status: `RENDERED_CANDIDATE`.
- Affected count: one exact target; unexpected visible gable names: empty.
- v0.417 wall body and v0.418 openings: preserved.
- Gameplay, state behavior, stable IDs, saves, resources, route, bridge, terrain, characters, props, camera, lighting, default runtime, fallback renderer, and debug renderer: unchanged.
- No movement, pathfinding, combat, economy, or production behavior was added.

## Audit and review evidence

The machine-readable audit is `artifacts/manual-review/v0419-secondary-barn-front-gable-value-integration/v0419-preservation-audit.json`. The seven required rendered captures are copied into the same review pack; runtime originals remain under `desktop-spikes/godot-salto/artifacts/runtime/v0419/` and are not runtime assets.

## Evidence

The capture path writes a primary colour view, front-gable close view, grayscale equivalents, a temporary node-ID diagnostic, and v0.418/v0.419 wide and close comparisons. Acceptance is fail-closed until the real colour, grayscale, and comparison images are inspected for a restrained wall/upper-gable family, preserved roof explanation, readable v0.418 openings, and no bright pasted triangle.

## Commands and validation

- `npm run godot:smoke:v0419-secondary-barn-front-gable`
- `npm run godot:capture:v0419-secondary-barn-front-gable`
- `npm run godot:validate:v0419-secondary-barn-front-gable`

Passed:

- dedicated v0.419 smoke, capture, and validator commands
- retained v0.418, v0.417, v0.416, v0.415, v0.414, v0.413, v0.412, v0.411, v0.410, v0.409, v0.408, v0.407, v0.406, v0.401, and v0.400 validators
- `npm test` — 122 files, 887 tests
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run validate:runtime-art-slots`
- `npm run validate:artifact-retention`
- `npm run godot:all`
- `git diff --check`

v0.402-v0.405 have no repository-provided dedicated validator commands, matching the retained ladder convention. Exact commit and CI evidence are added at closeout.

## Closeout

- Implementation commit: pending commit/push.
- Exact GitHub Actions run: pending push.
- Final repository state: pending final clean/synchronized proof.

## Review pack

`artifacts/manual-review/v0419-secondary-barn-front-gable-value-integration/`
