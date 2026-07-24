# v0.374 Barrosan Art-Production Reset, Asset Audit and Integration Contract

## Status

READY FOR HUMAN V0374 BARROSAN ART-PRODUCTION DECISION REVIEW

This is a documentation, inventory and production-planning checkpoint. No new
scene, rendered screenshot, gameplay integration, import conversion, download
or runtime mutation was performed.

## Baseline and preservation

- Branch: codex/v0215-v0226-recovery
- Base HEAD: dd3fbb386cef274bfc731c966a4094bc02ef5bc2
- Repository: jardas33/ascendant-realms
- The tracked worktree was clean before this checkpoint.
- Existing/generated untracked assets were preserved.
- v0.367-v0.373, the true default runtime, saves, stable IDs, UI, gameplay and
  accepted House02/Barn assets were not modified.

The v0.373 decision is accepted as truthful: the available Quaternius family is
useful for technical prototyping, but another procedural composition pass would
not solve the missing authored terrain, architecture and hostile-identity gap.

## Audit method and actual sources

The audit inspected the files under:

- external-art-intake/quaternius/medieval-village-megakit/
- external-art-intake/quaternius/fantasy-props-megakit/
- external-art-intake/quaternius/stylized-nature-megakit/
- external-art-intake/quaternius/ultimate-modular-men/
- repository-authored Blender/GLB assets from v0.233-v0.355;
- retained v0.370-v0.373 scenes, scripts, manifests and reports;
- the v0.373 internal audit and six-iteration log.

Observed intake sizes:

| Source | Files | Approx. bytes | Actual formats | License evidence |
| --- | ---: | ---: | --- | --- |
| Medieval Village MegaKit | 936 | 174,347,235 | glTF/bin, FBX, OBJ/MTL, PNG, JPG | License_Standard.txt, CC0 1.0 |
| Fantasy Props MegaKit | 517 | 162,871,281 | glTF/bin, FBX, OBJ/MTL, PNG, JPG | License_Standard.txt, CC0 1.0 |
| Stylized Nature MegaKit | 453 | 122,112,601 | glTF/bin, FBX, OBJ/MTL, PNG, JPG | License_Standard.txt, CC0 1.0 |
| Ultimate Modular Men | 111 | 277,070,570 | glTF, FBX, BLEND, JPG, TXT | License.txt, CC0 1.0 |

The detailed machine-readable inventory is in
artifacts/manual-review/v0374-barrosan-art-production-decision/01_ASSET_INVENTORY.csv.

## Executive findings

### Safe reuse

1. The human-approved Barn gold lineage is the strongest existing production
   visual anchor: BarrosanBarnGold.tscn, the v0.355 manifest, v0.350 GLB and
   its slate/timber texture family. It is passive and not production-integrated.
2. House02/v0.330-v0.338 provides a credible Barrosan domestic-material and
   granite/slate reference, but it is a single-building lineage rather than a
   complete settlement kit.
3. The v0.233/v0.235 authored Blender/GLB kits provide useful contract,
   coordinate, roof and module precedents. Their recorded status is partial;
   they are not evidence of a complete production environment.
4. Quaternius assets can remain as temporary workers, militia, foliage and prop
   placeholders under their recorded CC0 provenance.

### Must be replaced or newly authored

The three most important missing categories are:

1. **Continuous terrain, elevation, riverbed, banks and embedded roads** with
   authored Barrosan material transitions rather than ribbons or test planes.
2. **A coherent Barrosan building and infrastructure family** covering civic,
   economic, military, domestic, bridge and hostile structures in one silhouette
   language.
3. **Production unit silhouettes** for Worker, Militia, Ashen Raider and a hero
   rig that read at gameplay distance and share a deliberate faction language.

Resource outcrops, agricultural dressing, hostile props and animation coverage
are the next supporting gaps.

## Current asset decisions

| Asset family | Decision | Why |
| --- | --- | --- |
| v0.355 Barn gold | KEEP | Human-approved Barrosan granite/slate/timber anchor; passive and hash-registered. |
| House02 v0.330-v0.338 | KEEP | Strong Barrosan domestic/granite reference; needs roster context before production integration. |
| v0.233/v0.235 authored kits | KEEP WITH BARROSAN REWORK | Useful authored modules and contracts; recorded partial status and incomplete environment coverage. |
| Quaternius village, props, nature and men | TEMPORARY PROTOTYPE | Real importable geometry and CC0 provenance, but mixed style and weak final Barrosan identity. |
| v0.370 imported subset | TEMPORARY PROTOTYPE | Valid technical proof subset; intentionally not a production kit. |
| v0.368 playable/player layer | TEMPORARY PROTOTYPE | Useful gameplay and fallback baseline, not final visual direction. |
| v0.373 scene | TEMPORARY PROTOTYPE | Validated visual failure evidence; do not continue rearranging it. |

No reviewed group was classified as UNKNOWN because the referenced local files,
formats and license evidence were sufficient for this planning decision.

## Barrosan art-direction conclusion

Barrosan should be a warm, practical northern Portuguese/highland frontier:
irregular granite foundations, restrained limewash and timber, dark slate roofs,
worked yards, defensible thresholds, agricultural edges and damp river terrain.
The faction must feel inhabited and built for endurance, not like a generic
fantasy kit, a bright orange-roof village, or a showroom of isolated assets.

Terrain is one continuous landform with authored elevation, river depth, bank
transitions, embedded roads, settlement wear and restrained foliage. Hostile
territory needs a functional defensive silhouette, not a civilian market stall
surrounded by fence fragments. Gold, stone, timber and food must be understood
from silhouette and material grouping before labels are considered.

The complete visual rules are in
docs/art-direction/V0374_BARROSAN_RTS_ART_BIBLE.md.

## Minimum kit and acquisition brief

The smallest coherent kit required before another serious scene is:

- 6-8 role-differentiated building families plus construction variants;
- authored terrain/elevation, riverbed/banks, road and settlement-ground tools;
- 2 tree families, bushes, grasses, reeds, rocks and agricultural edge dressing;
- bridge, wall/gate, cart, work-yard, resource and hostile-camp modules;
- Worker, Militia, Ashen Raider and commander-capable unit rigs with required
  gameplay-facing animation coverage.

Exact minimum quantities and remaining gaps are in
docs/art-direction/V0374_MINIMUM_VIABLE_ART_KIT.md.

The procurement/commissioning constraints, source formats, licensing,
performance budgets and rejection criteria are in
docs/art-direction/V0374_ASSET_ACQUISITION_BRIEF.md.

## Integration contract

Future assets must preserve source provenance, versioned import directories,
metric scale, Godot-compatible GLB/glTF, explicit pivots, owned materials,
collision and selection footprints, stable IDs, rollback, LOD/performance
budgets and human visual approval. The contract is planning-only here and is in
docs/art-direction/V0374_ASSET_INTEGRATION_CONTRACT.md.

## Route decision

### Primary recommendation: ROUTE B — CUSTOM BARROSAN ENVIRONMENT / TEMPORARY IMPORTED UNITS

Route B is the safest route because the repository already has credible
Barrosan building/material anchors and a documented Blender-to-GLB path, while
the Quaternius men can continue to support gameplay prototyping temporarily.
It replaces the visual bottlenecks that caused the v0.373 blocker without
requiring a full custom unit family before the environment becomes readable.

- Expected visual improvement: high for terrain, settlement, bridge and hostile
  territory; medium for units until replacement rigs arrive.
- Effort: medium-high.
- Asset cost category: medium initially, with later unit commissioning as an
  optional high-cost extension.
- Reuse: Barn gold, House02, authored Blender conventions, safe Quaternius
  temporary characters/props/foliage, existing gameplay/fallback runtime.
- Replace/author: terrain solution, river/banks/roads, full building roster,
  bridge, resources, hostile camp and eventually production units.
- Largest risk: producing isolated gold buildings without a connected kit and
  without overview-scale review.

Route A is rejected because no single inspected pack is a cohesive Barrosan
family. Route C is technically attractive but unnecessarily expensive before
the environment grammar and minimum kit are proven. Route D is not justified by
the available evidence.

## What must happen before scene production resumes

Human art-production review must select Route B and approve the minimum kit,
then provide or commission the terrain/environment source and the first
connected kit slice. The first future visual scene should not begin until it
contains authored terrain, a real river/road/bridge solution, at least three
role-differentiated Barrosan structures, a readable resource site and a
purpose-built hostile camp. Codex should not resume by rearranging the v0.373
Quaternius scene.

## Validation evidence

The documentation-only validation checked:

- all required documents and exactly six review-pack files exist;
- referenced local asset paths exist;
- every inventory row has exactly one allowed classification;
- the gap matrix covers buildings, terrain, nature, props, resources and units;
- exactly one primary route is recommended;
- v0.370-v0.373 scenes/scripts and the true default runtime have no diff from
  the verified v0.374 baseline;
- git diff --check passes.

No rendering benchmark, capture loop, visual validator ladder, import mutation,
gameplay test or new scene was run for v0.374.

## Review pack

artifacts/manual-review/v0374-barrosan-art-production-decision/

The pack contains exactly the explicitly requested files and no rendered world
screenshots.

## Final decision status

READY FOR HUMAN V0374 BARROSAN ART-PRODUCTION DECISION REVIEW

Hard stop: no v0.375, no new scene, no gameplay connection, no asset purchase
or download, and no claim that the v0.373 visual blocker is resolved.
