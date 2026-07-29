# v0.335 House 02 Granite Source Replacement Proof — Material Study Only

## Executive outcome

`READY FOR HUMAN GRANITE SOURCE SELECTION`

This is a human-review gate, not an automated authenticity decision and not a
winner selection. Three materially different sources are shown on one identical
real Godot test structure. No candidate has been applied to House 02.

## Scope and frozen v0.334 decision

v0.334 was accepted technically but rejected artistically: its three candidates
read as large regular blockwork, ashlar, cladding, or synthetic masonry. v0.335
tests replacement material sources only. The full House 02 architecture, roof,
stairs, bindings, gameplay, default runtime, IDs, saves, and state chain are out
of scope.

The immutable v0.334 source GLB remains SHA-256
`f85cf2e7a448015638455f5de5cd49c18b085cbb1103a1fd5dfa8f7706d24be5`. The
recorded imported resource remains SHA-256
`b3be51e7d6e52fdfb829400afafbf26e9e0f9983b902b8ccba83f38306bba531`.

## Base and source/licence provenance

- Base HEAD: `94235691e12670fa9f7efc3fbd1d8e9df984a4d0`
- Branch: `codex/v0215-v0226-recovery`
- Source study: Poly Haven `stone_wall`, CC0, Charlotte Baglioni photography and Dario Barresi processing, accessed 2026-07-18. See the [Poly Haven Stone Wall source page](https://polyhaven.com/a/stone_wall).
- Vendored originals: `art-source/materials/v0335/source/polyhaven_stone_wall_original/`
- Vendored source bundle: `art-source/materials/v0335/source/polyhaven_stone_wall_original_2k.zip`
- Per-file SHA-256 records and modifications are in `art-source/materials/v0335/v0335-source-provenance.json`.
- The documentary Montesinho images are visual targets only; they are not runtime sources.

The original 2K diffuse, displacement, normal, roughness, and AO files are
preserved. Candidate A copies those originals, Candidate B is an authored
polygonal mask source, and Candidate C is a derived scan-plus-relief source.

## Candidate methods and blind mapping

The identical structure is labelled only MATERIAL 1/2/3 in the visual board.
The randomized mapping is stored in the compact summary and is not used to
automatically select a winner:

- MATERIAL 1 → candidate C
- MATERIAL 2 → candidate A
- MATERIAL 3 → candidate B

### Candidate A — photo-scanned rubble

The genuine CC0 scan is preserved without changing the original files. The
isolated Godot scene uses deterministic 1024px study derivatives of that source
set so this proof does not become an unnecessary large asset dump. It provides
the strongest natural reference for irregular stone scale, damp variation, and
weathering response.

### Candidate B — procedural polygonal rubble

This is a deterministic authored polygon mask with non-axis-aligned boundaries,
varied areas, broken joints, and no row/brick generator. Height, normal, albedo,
roughness, and labelled stone mask are all derived from the same authored mask.
It is deliberately a feasibility study rather than a claim of photographic
authenticity.

### Candidate C — hybrid scan plus low-poly relief

Candidate C uses a distinct derived scan response and one merged Godot relief
mesh containing limited protruding stones, corner quoins, lintel/sill relief,
and foundation stones. It does not create one object per stone and does not
change the test structure’s architecture.

## Test structure and scale

Every candidate uses one real three-dimensional Godot structure with:

- principal wall: 4.0m wide × 3.0m high;
- external 90-degree corner and 1.8m side return;
- actual recessed window opening with dark recess, lintel, and sill;
- foundation stones and ground contact;
- 1.75m human-scale figure;
- 2m metric scale bar;
- roof planes, eaves, side faces, support shed, and directional shadows.

The scene is not three flat wall rectangles. It is isolated at
`desktop-spikes/godot-salto/scenes/review/V0335GraniteSourceProof.tscn` and
does not instantiate a complete House 02 asset.

## Anti-brick metrics

The metrics are automated rejection aids only. They do not assert granite
authenticity or choose a winner. All three candidates pass the numeric gate:

| Blind candidate | visible stones | median height | p90 height | area CV | non-axis joints | mortar width CV |
|---|---:|---:|---:|---:|---:|---:|
| MATERIAL 1 | 126 | 0.28m | 0.55m | 0.59 | 62% | 0.46 |
| MATERIAL 2 | 118 | 0.27m | 0.52m | 0.61 | 58% | 0.43 |
| MATERIAL 3 | 132 | 0.25m | 0.49m | 0.56 | 79% | 0.51 |

The remaining checks include high-rectangularity share below 25%, longest
continuous horizontal mortar below 1.20m, internal mortar below 35% of the
4m wall, repeated dimensions at or below 15%, and no vertical joint chain over
two nominal levels. The labelled mask and compact metric evidence are in
`06_STONE_MASKS_AND_ANTI_BRICK_METRICS.png`.

## Material maps and Godot response

Each candidate has actual albedo, height, normal, and roughness maps. Candidate
A also retains AO. Candidate B derives all maps from the authored polygon mask.
Candidate C derives its distinct response from the scan and receives limited
merged relief in Godot.

The Godot response board includes albedo-only, neutral-grey normal-only,
roughness-isolation, neutral-overcast, and warm-directional evidence. The
normal-only capture has visible relief variance and was not accepted as a flat
diagnostic. The identical camera, viewport, lights, background, and orthographic
projection are used for the comparative views.

## Camera and capture protocol

The isolated capture command is:

`npm run godot:granite-source:v0335:capture`

It runs Godot import verification, captures the three structures and diagnostic
views, encodes a 15-second MP4 from real Godot continuous frames, and builds the
canonical pack. The primary camera is an orthographic oblique RTS camera; a
direct top-down comparison is also captured. Near-corner/window, normal RTS,
far RTS, neutral-overcast, warm-directional, 256px-equivalent board thumbnails,
albedo-only, normal-only, and roughness-isolation evidence are included.

## Review pack and black-frame rejection

The only canonical upload directory is:

`artifacts/manual-review/v0335-granite-source-proof/UPLOAD_TO_CHAT/`

It contains exactly ten files: one read-me, seven actual evidence PNGs, one
continuous MP4, and `compact-evidence-summary.json`. The summary contains the
ordered filename/size/SHA records in `exactUploadFiles` and a computed
`manifestSha256`; no alternate payload list is retained. PNGs were reopened for
signature, dimensions, size, and nontrivial variance. The MP4 was checked for
ISO media signature, duration, and frame content. Blank, black, frozen, and
title-card-only evidence is rejected.

## Preservation and hard stop

Preserved:

- v0.334 House 02 GLB, imported-resource record, architecture, and roof;
- accepted v0.287–v0.334 state chain and true default runtime;
- stable IDs, saves, gameplay, pressure, economy, resources, movement,
  pathfinding, combat, AI, and production systems;
- existing v0.303 fallback/debug presentation.

Not done:

- no v0.335 complete House 02 Blender file or GLB;
- no House 02 material application or binding change;
- no House 01/default runtime/settlement integration;
- no gameplay, state, movement, pathfinding, combat, economy, resource, save,
  or stable-ID mutation;
- no automated winner selection;
- no next application phase.

The checkpoint stops after evidence. Human review must choose whether any source
is suitable; the next step must not be inferred from the automated gate.

## Validator and validation evidence

- Dedicated validator: `tools/godot/saltoV0335GraniteSourceProofTool.mjs`
- Dedicated command: `npm run godot:granite-source:v0335:validate`
- Capture command: `npm run godot:granite-source:v0335:capture`
- Generator command: `npm run godot:granite-source:v0335:generate`
- The dedicated validator checks v0.334 hashes/freeze, CC0 provenance, three
  distinct map sources, anti-brick gates, metric structure, opt-in isolation,
  actual Godot captures, exact ten-file pack, manifest hashes, media validity,
  and forbidden gameplay/default coupling.
- Retained v0.334 and earlier validators are run separately in the closeout
  ladder; this slice does not weaken or replace them.

## CI and final state

The report is part of the v0.335 commit. After local validation, the branch is
committed and pushed, the exact pushed SHA GitHub Actions run is awaited to a
terminal green state, and the final repository is verified clean and synced
with origin at 0 ahead / 0 behind.
