# v0.326 Barrosan Hero Art Pipeline Proof

## Executive outcome

**READY FOR HUMAN ART BENCHMARK REVIEW**.

This is an isolated opt-in hero-art diorama and pipeline proof. It is not production-ready, an art lock, a final art-direction decision, or gameplay-integration approval.

## Base HEAD and branch

- Base HEAD: `bff71e16204a69a9752ed92d7802d5bbe570b38a`
- Branch: `codex/v0215-v0226-recovery`
- Base checkpoint: v0.325 Human-First River and Hamlet Naturalization
- v0.325 exact CI: `29493214012` — success for the exact base SHA

## Toolchain audit

The capture host has no Blender executable on PATH. The repository-local Godot 4.6.3 build was available and used with the non-headless OpenGL Compatibility renderer. Bundled Python/Pillow generated six deterministic local textures. Bundled FFmpeg/FFprobe encoded and independently audited the continuous capture.

The repository retains the authored v0.233-v0.239 Blender lineage. This slice reuses:

- `desktop-spikes/godot-salto/assets/v0238/salto_barrosan_building_roster.glb`
- `desktop-spikes/godot-salto/art-source/blender/v0238/salto_barrosan_building_roster.blend`
- `house_dwelling`, `farm_granary`, `bridge_module`, and authored vegetation/prop modules

No new Blender export is claimed because Blender is unavailable on this host. The retained authored GLB/Blend lineage is coupled to deliberately authored Godot ArrayMesh terrain, riverbed, water, path, and grounding geometry.

## Prototype scope and commands

Scene:

`desktop-spikes/godot-salto/visual_vertical_slice/V0326BarrosanHeroArtPipelineProof.tscn`

Capture command:

```text
npm run godot:capture:salto-v0326-barrosan-hero-art-pipeline
```

The wrapper launches the isolated scene with the repository-local Godot executable, `gl_compatibility`, and `opengl3`, then builds and validates the pack. The true default runtime remains unchanged because this scene is not the project main scene and no launcher path was changed.

## Route C implementation

### Camera/projection

The prototype uses one stable orthographic oblique RTS camera with visible building side faces and ordinary tactical framing. The continuous capture moves the camera only for visual inspection. No free rotation, zoom system, cinematic lens, or perspective distortion was added.

### Terrain, river, and road

The ground is a deliberate 26x26 SurfaceTool grid with generated normals, authored UVs, a shallow valley, bank rise, and local height variation. The river is a continuous 25x6 cross-section mesh with a curved centreline, varying width, recessed stone bed, and separate water surface below the land plane. The connected path is a variable-width textured strip with UVs and generated normals. No translucent debug pads or primitive placeholder patches are in the prototype.

Recorded metrics:

- Terrain triangles: `1352`
- Riverbed triangles: `300`
- Water triangles: `300`
- Local height range: `1.72`
- Water width range: `3.8` to `5.6`
- Riverbed below water: `true`
- Path connectivity: `true`

### Bridge construction

The bridge is the retained authored `bridge_module` GLB asset. Its deck, rails, supports, timber material, stone contacts, and elevation remain visible in the close-up. It is placed over the authored recessed water and is not a flat debug rectangle.

### Building geometry

The retained `house_dwelling` and `farm_granary` modules provide roof planes, side faces, bases, doors, trim, and authored depth. Imported source materials are duplicated and tuned to the local Barrosan palette. No gameplay footprint or building-system data is touched.

### Unit treatment and grounding

The Worker uses the repository-authored `res://assets/v0310/barrosan_worker_v0147_source.png` as a billboard Sprite3D. Its position is derived from the authored terrain height, with a restrained contact ring. No locomotion, animation system, AI, collision, or unit gameplay logic was added. The manifest records `workerGroundedContact: true`, `workerToolPresent: true`, and `workerSkeletonPresent: false` honestly.

### Lighting and materials

The scene uses one warm directional key light, one cool low-energy fill, restrained fog, filmic tonemapping, and coherent cast shadows. Local deterministic Pillow textures cover grass breakup, worn earth, granite, weathered timber, weathered slate, and recessed water. The material set is rough and readable rather than glossy or sci-fi.

## Visual evidence and review pack

The exact upload set is:

`artifacts/manual-review/v0326-barrosan-hero-art-pipeline/UPLOAD_TO_CHAT/`

It contains exactly ten files: one real comparison sheet, six real OpenGL-rendered PNGs, one H.264 continuous capture, and one compact JSON summary. The comparison uses the recovered v0.141 Barrosan reference, the v0.325 technical prototype, the actual v0.303 PLAYER reference, and the v0.326 authored hero diorama. It is not a title card.

The visual-quality contact sheet is:

`artifacts/manual-review/v0326-barrosan-hero-art-pipeline/full-evidence/41_VISUAL_QUALITY_CONTACT_SHEET.png`

The technical isolation sheet is:

`artifacts/manual-review/v0326-barrosan-hero-art-pipeline/full-evidence/42_TECHNICAL_ISOLATION_CONTACT_SHEET.png`

The black-frame rejection report is:

`artifacts/manual-review/v0326-barrosan-hero-art-pipeline/full-evidence/black-frame-rejection-report.md`

The headless dummy-renderer attempt was rejected because it returned no viewport texture. Final evidence was regenerated through non-headless Godot OpenGL. The final media is H.264, 1280x720, 24 fps, 12 seconds, 288 decoded frames, and 288 unique frame hashes.

The capture-loop FPS metric averaged `1.38` with a minimum of `1.0`. This is evidence-capture throughput on the high-detail OpenGL path, not a production-performance certification.

## What changed

- Added the isolated v0.326 hero diorama scene and script.
- Reused retained authored v0.238 GLB modules in a new opt-in composition.
- Added authored ArrayMesh terrain, recessed riverbed/water, and connected path geometry.
- Added six deterministic local material textures and their generator.
- Added Worker billboard scale and grounding proof.
- Added genuine non-headless Godot capture tooling.
- Added exact-ten-file review-pack builder, media audit, and black-frame report.
- Added dedicated v0.326 validator and package commands.
- Added this report.

## What did not change

- No full-game conversion, runtime art-slot replacement, or default runtime mutation.
- No project main scene, launcher, gameplay system, accepted state chain, stable-ID, save, or production logic change.
- No movement, pathfinding, route following, combat, damage, HP, AI, waves, fog gameplay, economy, resources, or pressure change.
- No v0.325 scene replacement.
- No protected-game or third-party asset import.

## Preservation and validation

The runtime manifest records `prototypeOptIn: true`, `defaultRuntimeChanged: false`, `gameplayChanged: false`, and all forbidden gameplay mutation flags false. The accepted v0.322 continuous-media SHA remains `8901bb6a074e5c3cc01bf5e16572f21dac06a527a4ea15273d649c71c73faa84`. The v0.325 scene remains present and unchanged.

Dedicated commands include:

- `npm run godot:validate:salto-v0326-barrosan-hero-art-pipeline`
- `npm run godot:validate:salto-v0326-authored-mesh`
- `npm run godot:validate:salto-v0326-primitive-rejection`
- `npm run godot:validate:salto-v0326-uv-material`
- `npm run godot:validate:salto-v0326-texture-origin`
- `npm run godot:validate:salto-v0326-mesh-integrity`
- `npm run godot:validate:salto-v0326-godot-import`
- `npm run godot:validate:salto-v0326-shader-compilation`
- `npm run godot:validate:salto-v0326-clean-player`
- `npm run godot:validate:salto-v0326-continuous-media`
- `npm run godot:validate:salto-v0326-exact-upload`
- `npm run godot:validate:salto-v0326-v0325-preservation`

Each focused invocation executes the complete evidence contract, so no focused command can silently omit runtime, media, source, preservation, or exact-upload checks.

Retained evidence at closeout covers the v0.325, v0.324, v0.323, and v0.322 dedicated validators, the v0.321-v0.303 retained visual/art validators, the v0.259 UI invariant, full repository tests/build/content/art/runtime checks, artifact retention, Godot validation, and diff checks.

## Human review status

The evidence proves a real isolated authored pipeline with genuine geometry, imported Barrosan modules, deterministic material inputs, and a workable ordinary RTS camera. The art direction remains open for human benchmark review. This checkpoint does not claim that the historical target has been matched or that Route C is production-ready.

## CI and final repo state

The final commit SHA, exact pushed GitHub Actions run, and clean/synced repository state are recorded at closeout after all local validation, commit, push, and exact-SHA Actions completion.
