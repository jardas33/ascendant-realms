# v0.323 — True-3D Structural Geometry Repair

## Outcome

**READY FOR HUMAN GEOMETRY REVIEW**.

This checkpoint repairs the isolated v0.322 Barrosan bridge-hamlet hero slice only. It does not claim art lock, production readiness, final art, or visual acceptance.

## Base and scope

- Base HEAD: `097e2827d1fc0cf0e3403ea4adcf7a1f5ee49921`
- Branch: `codex/v0215-v0226-recovery`
- Scene: `desktop-spikes/godot-salto/visual_vertical_slice/V0323StructuralGeometryRepair.tscn`
- Capture: `npm run godot:capture:salto-v0323-structural-geometry-repair`
- Review pack: `artifacts/manual-review/v0323-structural-geometry-repair/UPLOAD_TO_CHAT/`

The accepted v0.322 MP4 evidence was not reopened as a media-production task. Its SHA-256 remains `8901bb6a074e5c3cc01bf5e16572f21dac06a527a4ea15273d649c71c73faa84` before and after v0.323 capture.

## Defects repaired

Human review identified inverted butterfly roofs, visible world coverage edges, benchmark/debug text in PLAYER captures, jagged/disconnected riverbanks, and weak structural grounding. v0.323 repairs those defects with a new opt-in scene/script and leaves v0.322 unchanged.

## Roof topology

Both buildings now use explicit two-plane gable roof meshes with a central ridge, outward eave trim, ridge caps, closed gable ends, and grounded vertical chimneys. The runtime audit uses `MeshDataTool` against the actual `MeshInstance3D` roof surfaces and applies each node’s `global_transform` before measuring world heights and normals.

Measured principal ManorRoof:

- left eave: `4.11999988555908`
- ridge: `5.34000015258789`
- right eave: `4.11999988555908`
- minimum rise: `1.22000026702881 m`
- upward normals: `12`
- invalid normals: `0`
- self-intersections: `0`
- chimney contact: `true`

Measured secondary WorkshopRoof:

- left eave: `3.8199999332428`
- ridge: `4.94000005722046`
- right eave: `3.8199999332428`
- minimum rise: `1.12000012397766 m`
- upward normals: `12`
- invalid normals: `0`
- self-intersections: `0`
- chimney contact: `true`

The upload includes front/side roof views and a separate diagnostic roof audit. Diagnostic measurements are not present in authoritative PLAYER images.

## World coverage

The actual terrain heightfield was extended to a `160 m × 160 m` authored surface. The widest approved orthographic capture uses size `29.0`; the measured projected footprint is `51.5555555555556 m × 29.0 m`, with a measured margin of `451%`. The runtime audit uses an `11x7` viewport-ray grid, reports `0` failed rays and `0` background corner matches, and records coverage surviving the approved pan/zoom range.

This is a geometry extension, not a screenshot crop, background-color disguise, UI mask, or camera-only evidence workaround.

## Riverbank continuity and grounding

The curved, nonuniform river course is retained. v0.323 replaces the disconnected bank strips with one continuous left-bank mesh and one continuous right-bank mesh, each built from continuous inner, mid-slope and outer terrain-connected rows. Water and recessed center surfaces remain continuous, and bridge approaches remain embedded into the bank/road transition.

Measured river audit:

- left-bank connected components: `1`
- right-bank connected components: `1`
- water connected components: `1`
- maximum water-to-bank gap: `0.012 m`
- degenerate bank triangles: `0`
- invalid bank normals: `0`
- terrain holes along river: `0`

Foundations, yards, bank slopes and bridge transitions use the repaired heightfield. No new terrain system or gameplay geometry was introduced.

## PLAYER hygiene

PLAYER HUD wording is neutral: `BRIDGE LINE | SALTO EAST`. The benchmark heading `BRIDGE HAMLET | PRESSURE STABILIZED`, `PLAYER prototype`, validator prose, diagnostic coordinates, geometry measurements and review labels are absent from PLAYER captures. The selected card remains readable as `Barrosan pioneer | grounded 3D unit`.

The roof and coverage audit is intentionally a separate diagnostic capture. The clean overview and ordinary gameplay captures contain no diagnostic overlay.

## Preservation boundary

Preserved unchanged:

- true default runtime;
- gameplay, movement, pathfinding, combat, economy, AI and resources;
- saves and stable IDs;
- accepted state chain;
- v0.303 fallback/debug layer and H3 fallback adapters;
- v0.320, v0.321 and v0.322 scenes/evidence;
- v0.322 exact-media validator and accepted MP4;
- existing Worker behavior and bridge traversal choreography.

The only retained-ladder repair outside the new v0.323 paths is a two-line
capture-only watermark reinitialization guard in the v0.318 evidence runner.
It repairs a nil UI reference during later save/load evidence capture; it does
not alter the H3 runtime, unit behavior, gameplay, or accepted evidence
semantics.

No unit-system expansion, settlement-building roster expansion, broad material redesign, or production integration was added.

## Review pack

`artifacts/manual-review/v0323-structural-geometry-repair/UPLOAD_TO_CHAT/` contains exactly 10 files:

1. preflight comparison;
2. clean PLAYER overview;
3. principal roof front/side render;
4. secondary roof front/side render;
5. diagnostic roof audit;
6. world-coverage corner audit;
7. riverbank continuity render;
8. ordinary gameplay render;
9. compact measured evidence JSON;
10. read-me file.

The review pack also contains full-evidence proof notes, a visual-quality contact sheet and a black-frame rejection report. No new MP4 is produced.

## Dedicated validators

- `npm run godot:validate:salto-v0323-roof-topology`
- `npm run godot:validate:salto-v0323-world-coverage`
- `npm run godot:validate:salto-v0323-riverbank-continuity`
- `npm run godot:validate:salto-v0323-player-hygiene`
- `npm run godot:validate:salto-v0323-structural-geometry-repair`
- `npm run godot:validate:salto-v0323-final-media`

The aggregate validator rejects any roof ridge/eave failure, inverted normal, self-intersection, floating chimney, coverage ray failure, background-corner match, river discontinuity, forbidden PLAYER text, default-runtime mutation, gameplay mutation, or v0.322 media SHA drift.

## Validation evidence

Passed locally:

- dedicated v0.323 roof-topology validator;
- dedicated v0.323 world-coverage validator;
- dedicated v0.323 riverbank-continuity validator;
- dedicated v0.323 PLAYER-hygiene validator;
- aggregate v0.323 validator;
- retained v0.322 exact-upload media validator;
- retained v0.322 through v0.303 validators;
- v0.259 UI invariant validator;
- `npm test`;
- `npm run build`;
- `npm run validate:content`;
- `npm run validate:art-intake`;
- `npm run validate:runtime-art-slots`;
- artifact-retention validation;
- `npm run godot:all`;
- `git diff --check`.

## CI and final state

The checkpoint is opt-in and isolated from the default runtime. Implementation commit
`743b01ad017bf973892dfadefe6d30bfcbd40cb3` completed GitHub Actions run
`29464444739` successfully for the exact pushed SHA. The final documentation-only
closeout commit and its exact-SHA CI result are recorded in the repository history.

The final repository state is clean and synchronized with
`origin/codex/v0215-v0226-recovery` at `0` ahead / `0` behind.
