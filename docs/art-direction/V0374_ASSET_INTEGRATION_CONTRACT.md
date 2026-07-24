# v0.374 Barrosan Asset Integration Contract

This contract is a pre-integration specification. v0.374 does not implement it
in gameplay or change the runtime asset registry.

## Source preservation and provenance

- Preserve the original delivery outside the runtime import tree.
- Register creator, pack or commission ID, license copy, source hash and import
  date in a versioned manifest.
- Never overwrite an accepted House02, Barn or fallback source in place.
- Every revision receives a new versioned directory and rollback record.

## Directory and naming

Use:

external-art-intake/<vendor-or-commission>/<family>/<delivery>/
art-source/blender/v0NNN/<asset_family>.blend
desktop-spikes/godot-salto/assets/v0NNN/<asset_family>.glb
docs/gold-or-art/V0NNN_<ASSET>_MANIFEST.json

Names are stable, role-oriented and ASCII-safe. Render asset, material, texture,
collision, LOD and source names must share a documented stem.

## Scale, orientation and pivots

- 1 unit equals 1 metre.
- Source Z-up converts to Godot's documented orientation without hidden scale.
- Buildings pivot at ground-center or an explicitly documented entrance axis.
- Props pivot at their support/contact point.
- Units pivot at the foot origin; root motion policy is explicit.
- Bridge modules expose both endpoint/abutment anchors.

## Materials and shaders

- Materials are owned by the asset family and use Godot-compatible PBR inputs.
- Texture references are relative and remain beside the canonical export or in a
  versioned texture directory.
- No absolute paths, hidden external shader dependencies or broad runtime tint
  overrides are accepted.
- Granite, slate, timber, plaster, earth, water and wet-bank slots remain
  separately inspectable.
- Faction recoloring uses masks or named slots and does not destroy base detail.

## Geometry, collision and navigation

- Render mesh, collision mesh and optional occluder/LOD meshes are separate.
- Building footprints and entrances are explicit metadata, not inferred from a
  screenshot.
- Navigation footprints are supplied as integration data but are not silently
  changed by visual mesh edits.
- Resource interaction points, bridge landings and construction anchors are
  named stable sockets.

## Building and construction data

Every building manifest records:

- role, faction and stable asset ID;
- footprint, height, entrance and selection footprint;
- intact, construction and damaged variants where needed;
- material slots, LODs, collision and performance budget;
- threshold/yard sockets and optional prop attachment points.

## Units and animation

Every unit manifest records rig origin, scale, faction, silhouette role, weapon
socket, selection base, skeleton version and animation names. Required names are
idle, walk, work or brace, aim where applicable, attack or action, hit and death
where the gameplay contract requires them. Retargeting must be reproducible and
must not alter stable unit IDs or saves.

## Performance budgets

Each delivery supplies triangle counts, material count, texture memory, draw-call
estimate, LOD thresholds and repeated-instance expectations. Repeated trees,
rocks, props and units must be instanced or batched where appropriate. Any
budget exception requires written approval.

## Stable IDs, rollback and validation

- Visual asset IDs are additive and never reused for a different role.
- Gameplay IDs, saves, production data and selection semantics remain untouched
  during art import.
- A failed import can be removed by deleting one versioned directory and
  reverting one manifest entry.
- Validators must check path existence, hashes, license provenance, scale,
  material slots, collision/LOD presence, stable sockets and no default-runtime
  mutation.
- Human visual approval is required at overview and close role distances.

## Approval sequence

1. Intake and license audit.
2. Source/export/hash registration.
3. Isolated Godot import smoke.
4. Material, scale, pivot, collision and LOD audit.
5. Connected RTS-sector visual review.
6. Human Barrosan art-direction approval.
7. Opt-in integration only.
8. Gameplay/default-runtime integration only through a separate checkpoint.
