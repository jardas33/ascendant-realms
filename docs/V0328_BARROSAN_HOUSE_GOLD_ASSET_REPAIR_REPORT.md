# v0.328 Barrosan House Gold-Asset Structural Completion and Material Refinement

## Human review inherited from v0.327

v0.327 established the authentic authored direction but rejected the asset as a gold asset because the roof presentation, 361-object LOD0, 44-triangle LOD1, placeholder UV proof, and capture-contaminated performance gate were not acceptable. v0.328 repairs that same source in place; it does not create a second house.

## Roof structural reconstruction

The repaired asset has two closed continuous principal slate planes, a raised continuous ridge, continuous eaves, overlapping slate-course lips, closed front/rear gables, and a slate flashing junction at the grounded chimney. The authored geometry reports a maximum intended component gap of 0.00m and 0 unsupported roof components.

## Building-envelope completion

Front and rear gables close the upper envelope, while recessed openings retain lintels, sills, shutters, and dark proxy interiors. The agricultural lower floor, domestic upper floor, external stair, landing, chimney, foundation, and rear utility identity remain intact.

## Granite, slate, timber, openings, and stairs

Local deterministic textures now use larger irregular granite families, restrained mortar/joint marks, darker foundation courses, dark-grey slate with course seams, desaturated rough timber, and non-featureless openings. The stair meets the ground and upper landing; the chimney passes through the roof with a flashing plate.

## Mesh consolidation and LOD rebuild

- LOD0: 7164 vertices / 13096 triangles / 8 render objects.
- LOD1: 2960 vertices / 4672 triangles.
- LOD2: 1200 vertices / 710 triangles.
- Collision: 36 triangles.
- Materials: 6; estimated draw calls: 8.

Static render geometry is consolidated by material into a small number of sensible groups; LODs are separate from collision geometry.

## UV verification and Godot import

The Blender UVMap was exported to `artifacts/runtime/v0328/barrosan-house-gold-01-uv-layout.svg` and rasterized from the exported UV segments for the review image. It reports 7726 islands, 0 unintended overlaps, 0 out-of-bounds islands, and 8.0% maximum density deviation.

The opt-in Godot review scene remains HUD-free, uses neutral highland ground/sky, orthographic RTS and close inspection cameras, daylight and overcast lighting, contact shadows, and no gameplay anchors.

## Performance benchmark and validator corrections

The new benchmark warms up for 5.0s, measures 20.01s across 1500 post-warm-up samples, and disables screenshot dumping, video encoding, and debug overlays. It records average 74.97 FPS, median 74.98, 1% low 73.21, 0.1% low 54.15, minimum 54.15, maximum frame time 18.47ms, and 0 repeated spikes above 50ms. The corrected validator cannot classify the old v0.327 13-FPS minimum as a pass.

## Preservation and known limitations

The original v0.327 source remains recoverable in Git history at `09be641b73b01357741f1f2c497dad06edc4777b`. v0.326, v0.325, v0.303, v0.322 media, default runtime, gameplay, movement, pathfinding, combat, economy, AI, resources, saves, and stable IDs are unchanged. This remains an isolated house review asset, not production integration, faction art lock, or environment-ready content. Human review should still judge the roof/material balance at ordinary RTS scale.

## Evidence and closeout

Review pack: `artifacts/manual-review/v0328-barrosan-house-gold-repair/UPLOAD_TO_CHAT/`.

Turntable: H.264 1280x720, 24.00 FPS, 12.00s, 288 decoded frames, SHA-256 `20a64db16c97a7828ee06a427d6c4b92ff722545c36903bd0383603c63b57904`.

Dedicated validator: `npm run godot:validate:salto-v0328-barrosan-house-gold-repair`.

Exact-SHA CI and final clean/synced repository state are recorded in the checkpoint closeout after the full local validation ladder completes.
