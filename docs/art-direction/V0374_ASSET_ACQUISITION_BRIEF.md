# v0.374 Barrosan Asset Acquisition and Commissioning Brief

## Objective

Acquire or commission one coherent Barrosan environment foundation rather than
another mixed catalogue of isolated props. The target is a stylised 2026 RTS
presentation: readable at gameplay distance, materially grounded, irregular but
modular, and compatible with Godot.

## Required visual package

The source must cover, in one visual family:

- terrain/elevation, riverbed, banks, roads and bridge;
- Main Hall, house, barracks, economy, storage, tower and wall/gate modules;
- resource outcrops and working props;
- agricultural, settlement and hostile-camp dressing;
- two temperate tree families, bushes, grasses, reeds and rocks;
- enough role variants to avoid samey orange-roof silhouettes.

Characters may be temporary imports under separate provenance, but the
environment family must not depend on unrelated civilian props to fabricate
hostile territory.

## Rights and provenance

- Commercial-use permission must be explicit and retained with the source.
- Redistribution, modification and game-shipping terms must be clear.
- Source creator, pack/version, purchase or commission record and license copy
  must be stored in the repository intake record.
- No asset with unclear rights, scraped provenance or restrictive redistribution
  terms enters the runtime tree.

## Source and export requirements

- Preferred source: Blender or another editable DCC source plus GLB/glTF export.
- Accepted interchange: GLB/glTF 2.0; FBX only when a reproducible conversion
  and texture audit are supplied.
- Godot import must work without editor-only source dependencies.
- Metric scale: 1 Blender unit = 1 metre; Z-up source, documented Godot
  orientation and origin conventions.
- Every building has a documented footprint, entrance, pivot and optional
  selection footprint.

## Material and texture requirements

- PBR base color, normal and roughness/ORM maps where material response matters.
- Materials are named by role and owned by the asset family; no hidden links to
  external absolute paths.
- Texture resolution must be appropriate to gameplay scale; avoid large maps
  that only improve close-ups.
- Faction color masks or deliberate material slots are required where recoloring
  is expected.
- Roof, granite, timber, plaster, earth, wet bank and water must be separable
  without destructive flat overrides.

## Geometry, LOD and performance

- Silhouette and readable role mass take priority over micro-detail.
- Provide LODs or a documented low-poly budget for every repeated prop and tree.
- Supply collision meshes separately from render meshes.
- Modular parts must snap without visible seams or floating pads.
- Target budgets must be stated per building, repeated prop, tree and unit; the
  artist must provide triangle counts and texture memory estimates.
- A full-field overview must remain readable without excessive draw-call or
  overdraw risk.

## Animation and rigging

For character sources, provide a stable rig or documented retarget path, with
idle, locomotion, work/brace, attack/action, hit and death coverage as required
by the current gameplay contract. Animation names and root motion policy must be
explicit. Environment assets do not need animation beyond optional construction
or ambient elements.

## Delivery documentation

Each delivery must include source files, exports, textures, license, changelog,
scale/orientation notes, material table, pivot table, collision table, LOD table,
animation table, known limitations and a Godot import verification capture or
log. Human art-direction approval is required before runtime integration.

## Explicit rejection criteria

Reject a candidate if any of the following is true:

- it requires primitive terrain ribbons or flat olive plates to look complete;
- buildings, nature, roads and hostile pieces visibly come from unrelated styles;
- only isolated hero assets exist without a connected environment family;
- no credible bridge, bank, terrain or elevation solution is supplied;
- hostile camp identity must be fabricated from civilian stalls and fence scraps;
- roofs or one material dominate the palette;
- silhouettes fail at the gameplay camera or grayscale check;
- formats cannot be imported reliably into Godot;
- license terms are unclear or do not permit the intended use;
- source paths, pivots, scale, collision or texture ownership are undocumented;
- the package cannot be rolled back without overwriting accepted assets.

## Evaluation gate

Review the candidate as a connected settlement sector at RTS zoom before any
purchase or integration. The candidate must pass terrain credibility, bridge and
river depth, building role separation, resource readability, hostile identity,
unit scale, shadow consistency and Barrosan material cohesion simultaneously.
