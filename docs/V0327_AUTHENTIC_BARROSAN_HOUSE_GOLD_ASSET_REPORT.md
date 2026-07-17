# v0.327 Authentic Barrosan House Gold-Asset Gate

## Outcome

**READY FOR HUMAN BARROSAN HOUSE REVIEW**.

This checkpoint proves one newly authored, standalone Barrosan rural-house gold asset through Blender source, deterministic local textures, GLB export, Godot import, real non-headless OpenGL capture, continuous media, and technical validation. It does not claim production readiness, art lock, full faction readiness, environment integration, or gameplay integration.

## Scope and preservation

- Base HEAD: `06d2609570eb66c3c7ea75667f54cca64a1d2c46`
- Branch: `codex/v0215-v0226-recovery`
- New asset only: `art-source/blender/v0327/barrosan_house_gold_01.blend`
- New export: `desktop-spikes/godot-salto/assets/v0327/barrosan_house_gold_01.glb`
- Isolated review scene: `desktop-spikes/godot-salto/scenes/review/V0327BarrosanHouseReview.tscn`
- No river, bridge, Worker, combat unit, vegetation pack, terrain conversion, gameplay, movement, pathfinding, economy, resource, save, stable-ID, or default-runtime change.
- v0.326 remains preserved as the prior hero-art pipeline proof and is not patched.

The repository has no `game/godot` directory; the review scene therefore follows the existing `desktop-spikes/godot-salto` convention.

## Why this gate exists

v0.326 proved an authored hero-art pipeline but did not provide a new standalone house gold asset. v0.327 isolates the smallest meaningful architecture test: whether a Barrosan house can be authored from scratch, exported, imported, inspected, and reviewed without borrowing the retained v0.238 roster or contaminating the accepted runtime.

## Reference and art direction

The interpretation uses documented Barroso vernacular cues: granite-dominant masonry, an agricultural lower level, a domestic upper level, recessed openings, slate roofing, timber details, and an external stone stair. Reference notes and provenance are in `docs/art-reference/V0327_BARROSAN_HOUSE_REFERENCE_NOTES.md`. Primary public references include [Ecomuseu de Barroso: Pitões das Júnias](https://www.ecomuseu.org/index/pt-pt/visite/freguesias/pitoes-das-junias), [Ecomuseu de Barroso: built heritage](https://www.ecomuseu.org/index/pt-pt/visite/patrimonio), [Município de Montalegre: A Casa Barrosã](https://www.cm-montalegre.pt/cmmontalegre/uploads/document/file/44/LivroMontalegre.pdf), and [Património Cultural, I.P.: Monte Travesso](https://imovel.patrimoniocultural.gov.pt/detalhes.php?code=7849205). The asset is an original interpretation and does not copy a literal protected structure or game asset.

## Blender toolchain and authoring

The host did not expose Blender on PATH, so the toolchain audit searched the installed applications and used:

- Blender: `C:\Program Files\Blender Foundation\Blender 5.1\Blender.exe`
- Version: Blender `5.1.2`, build `ec6e62d40fa9`
- Blender Python: `3.13.9`
- Headless `bpy` smoke: passed
- Headless GLB export: passed with `bpy.ops.export_scene.gltf`

The source creates four populated elevations with deliberately skipped openings, deep window recesses, lintels and sills, timber shutters, agricultural doors, individual slate courses over a continuous slate undercourse, ridge cap, fascia, chimney, granite stair and landing, firewood, trough, repair patch, doorstep, neutral inspection ground, LOD1 shell, and simple collision proxies.

Metrics:

- LOD0: 8,664 vertices / 15,884 triangles / 361 objects
- LOD1: 24 vertices / 44 triangles
- Collision: 24 vertices / 36 triangles
- UV channels: `UVMap`
- Materials: six authored identities
- Textures: six deterministic local 1024x1024 PNGs
- Invalid normals: 0
- Non-manifold edges: 0
- Unapplied transforms: 0

## Materials, UV, and provenance

The material set is granite, dark foundation stone, weathered slate, aged timber, imperfect limewash, and rough iron. Textures are generated locally by `tools/godot/generateV0327BarrosanHouseTextures.py`; no downloaded raster source or third-party game asset is imported. Texture origin and authoring metadata are carried in the export sidecar and Blender custom properties.

## Godot review scene and evidence

The isolated scene uses an orthographic RTS inspection camera, a restrained warm directional key, cool ambient fill, soft readable shadows, no fog, and no HUD. It hides LOD1 and collision proxies for the ordinary view, then verifies their presence and switching behavior. The scene captures eight real views and 288 turntable frames. The first headless dummy-renderer attempt was rejected because it returned no viewport texture; none of those frames are used as evidence. The accepted pack is built only after the non-headless OpenGL run.

Interactive benchmark average was above the 55 FPS target. The minimum sample contains occasional host-side readback spikes while the capture path is active; capture throughput is reported separately at roughly 3.7 frames/sec, and the report does not conflate screenshot throughput with gameplay performance.

## Review pack

The exact ten-file upload pack is:

`artifacts/manual-review/v0327-authentic-barrosan-house/UPLOAD_TO_CHAT/`

It contains the reference comparison, ordinary RTS view, front/rear and side elevations, material close-up, wireframe/UV/LOD proof, lighting/silhouette proof, a 12-second H.264 turntable at 24 FPS, README, and compact JSON. Full contact sheets and the black-frame rejection report are in the sibling `full-evidence` directory.

## Human visual assessment

The asset is clearly genuine 3D geometry with visible side elevations, deep openings, foundation separation, stair volume, chimney, material variation, and grounded directional shadows. The current capture is intentionally an inspection asset on a neutral ground rather than a finished Salto settlement view. Roof detailing and texture balance should receive human review before any wider art adoption. This is why the permitted outcome is **READY FOR HUMAN BARROSAN HOUSE REVIEW**, not production-ready or art-locked.

## Dedicated validator and commands

Dedicated validator:

`node tools/godot/saltoV0327BarrosanHouseTool.mjs validate`

Focused aliases are accepted for the required technical gates, including source, headless export, Godot import, mesh integrity, UV/PBR/texture origin, forbidden cues, LOD, collision, clean evidence, continuous media, exact upload, interactive performance, and v0.326 preservation.

Capture and pack commands:

- `npm run blender:generate:salto-v0327-barrosan-house-gold`
- `npm run godot:capture:salto-v0327-barrosan-house`
- `npm run godot:pack:salto-v0327-barrosan-house`
- `npm run godot:validate:salto-v0327-authentic-barrosan-house`

## Accepted chain and default runtime

The accepted v0.287-v0.326 runtime/state chain remains untouched. The v0.303 fallback/debug presentation remains intact. The new review scene is opt-in and standalone. No gameplay systems, state semantics, stable IDs, saves, minimap, or true default runtime assets are changed.

## Validation evidence

The dedicated validator checks source provenance, genuine Blender export, GLB import sidecar, mesh/UV/PBR integrity, six local textures, LOD/collision, no forbidden cues, real OpenGL captures, exact ten-file upload, H.264 media, v0.326/v0.325/v0.322 preservation, and scope-safe changed files. The retained v0.326 through v0.303 validators and v0.259 UI invariant validator remain required closeout checks, followed by npm tests/build/content/art/runtime/artifact-retention checks, `npm run godot:all`, and `git diff --check`.

## Recommendation and next proposal

Recommendation for this checkpoint: **READY FOR HUMAN BARROSAN HOUSE REVIEW**. Do not automatically integrate the house into the accepted runtime. A future v0.328 decision should be made only after human review of the ten-file pack, especially the roof, material response, and whether the silhouette belongs in the Barrosan roster.

## Final state

This report is written as the v0.327 gate documentation. Commit, exact-SHA CI, and final clean/synced state are recorded only after the complete local validation ladder and remote run finish.
