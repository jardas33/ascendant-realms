# v0.426 Secondary-Barn Contact-Shadow Restraint Hierarchy

## Scope and baseline

v0.426 is one opt-in, material-only restraint pass on the existing secondary-barn contact-shadow surface. It starts from final v0.425 commit `a98e9abe41de5d8e52097343ab49bf5542133909` on `codex/v0215-v0226-recovery`. The accepted v0.399-v0.425 chain and pre-existing untracked artifact backlog remain preserved.

The admitted inventory is exactly `V0399_Barn_Contact_Shadow`, classified `BARN_CONTACT_SHADOW`. The v0.399 footprint, scale, rotation, elevation, shape and terrain offset are frozen. The stone base, terrain, barn body, later front/side/ridge/eave groups, and all lighting/shadow settings remain separately inventoried and excluded.

## Original material audit and candidate

Before candidate application, the runtime records the original material name, albedo and alpha, transparency, blend, depth, shading, roughness, metallic, specular, vertex-colour, culling, render priority, texture assignment, UV count, mesh/surface counts, transform, AABB, cast-shadow setting and visibility. A candidate is retained only when the original exposes a usable transparent `StandardMaterial3D` path without an albedo texture requiring out-of-scope UV work.

The bounded candidate is `V0426_Secondary_Barn_Contact_Shadow` with RGB `#302c28`, alpha capped at `0.16` and never increased above the original, roughness `1.00`, specular `0.00`, inherited vertex-colour albedo disabled, and all original transparent-material state copied exactly. It is intended to become almost unnoticed while preserving physical contact.

If the exact one-node boundary or transparent material path cannot be proven, the checkpoint fails closed with `ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_CONTACT_SHADOW`.

## Preservation

The change is material-only. Geometry, topology, indices, vertices, surfaces, UVs, transforms, AABBs, footprint, terrain, lighting, shadow settings, dimensions, placement, camera, layout, gameplay and runtime semantics remain unchanged. No new mesh, overlay, decal, shadow card, terrain patch, lighting change, or duplicate contact surface is permitted.

Capture-only close-context isolation hides unrelated descendants only for evidence capture. The barn shell, contact shadow, stone base, walls and relevant structural context remain present; every visibility state is restored before comparisons, audit completion and exit; the isolation never affects the true default runtime.

## Visual evidence

Required real evidence is stored in `artifacts/manual-review/v0426-secondary-barn-contact-shadow-restraint-hierarchy/`:

- `01_PRIMARY_RTS_COLOUR.png`
- `02_SECONDARY_BARN_CONTACT_SHADOW_CLOSE_COLOUR.png`
- `03_PRIMARY_RTS_GRAYSCALE.png`
- `04_SECONDARY_BARN_CONTACT_SHADOW_CLOSE_GRAYSCALE.png`
- `05_TEMPORARY_BARN_CONTACT_SHADOW_NODE_ID.png`
- `06_V0425_V0426_WIDE_COMPARISON.png`
- `07_V0425_V0426_CONTACT_SHADOW_CLOSE_COMPARISON.png`
- `v0426-preservation-audit.json`

The close frame must make the shadow’s relationship to the barn footprint and terrain assessable without turning the surface into a dark slab, oval, rectangle, detached halo or gameplay zone. The diagnostic identifies the exact contact-shadow node, excluded stone base, preserved footprint/terrain/lighting, and preserved shadow settings; it is absent from player-facing evidence. Black, blank, clipped, or title-card-only evidence is rejected.

## Commands and validation

- `npm run godot:play:v0426-secondary-barn-contact-shadow`
- `npm run godot:smoke:v0426-secondary-barn-contact-shadow`
- `npm run godot:capture:v0426-secondary-barn-contact-shadow`
- `npm run godot:validate:v0426-secondary-barn-contact-shadow`

The dedicated validator asserts the exact one-node inventory, original transparent-material audit, copied render-state properties, bounded candidate parameters, explicit exclusions, material-only preservation, unchanged footprint/terrain/lighting/shadow settings, capture-only visibility restoration, real evidence dimensions, fail-closed behavior, package wiring, and the v0.425 baseline. Before closeout, run the retained v0.426-v0.400 ladder, `npm test`, `npm run build`, content validation, art-intake validation, runtime-art-slot validation, artifact retention, `npm run godot:all`, and `git diff --check`.

## Closeout

The dedicated validator passed:

`PASS_V0426_SECONDARY_BARN_CONTACT_SHADOW_RESTRAINT_HIERARCHY_VALIDATOR (material-only transparent-state candidate; 1 contact shadow; footprint, terrain, lighting and shadow settings preserved; 7 real captures)`

The complete retained v0.426-v0.400 validator ladder passed. This includes the accepted v0.425, v0.424, v0.423, v0.422, v0.421, v0.420, v0.419, v0.418, v0.417, v0.416, v0.415, v0.414, v0.413, v0.412, v0.411, v0.410, v0.409, v0.408, v0.407, v0.406, v0.401 and v0.400 validators, including their fail-closed asset limitations where applicable.

The full local validation passed:

- `npm test` — 122 files, 887 tests passed.
- `npm run build` — production TypeScript/Vite build passed.
- `npm run validate:content` — passed.
- `npm run validate:art-intake` — passed.
- `npm run validate:runtime-art-slots` — 52 stable slots passed.
- `npm run validate:artifact-retention` — passed.
- `npm run godot:all` — passed.
- `git diff --check` — passed; only the existing Git LF/CRLF warning was reported.

The direct opt-in smoke and capture runs exited successfully. The smoke audit reported `RENDERED_CANDIDATE`, `candidateRetained: true`, `affectedNodeCount: 1`, and no unexpected visible contact-shadow names. Human inspection confirmed real non-black colour, grayscale, diagnostic, and comparison renders; the close shadow remains quiet and footprint-bound without a dark slab, oval, rectangle, detached halo or gameplay-zone appearance. The diagnostic identifies `V0399_Barn_Contact_Shadow` and explicitly excludes `V0399_Barn_Stone_Base`.

Implementation commit: `75c7e085d932cea405b47c28d4f27e0dde5e0311` (`v0.426 restrain secondary barn contact shadow hierarchy`). Exact-SHA GitHub Actions run: `30423546153` — success for `75c7e085d932cea405b47c28d4f27e0dde5e0311` (`CI Release Matrix Dry Run`, pull-request synchronize, Fast confidence passed; optional visual/release groups skipped by event policy).

A documentation-only confirmation commit and its exact-SHA Actions result will be appended after this report update. The pre-existing untracked artifact backlog is intentionally preserved and is not part of this checkpoint.
