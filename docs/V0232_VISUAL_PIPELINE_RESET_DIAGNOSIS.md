# v0.232 Visual Pipeline Reset Diagnosis

Status: `PRODUCTION_DIRECTION_PROVEN_NOT_PRODUCTION_ART`

## 1. Why v0.231 still looks bad

v0.231 improved local values, opacity and contact, but it did not change the underlying visual grammar. The battlefield is still assembled from broad flat sheets, repeated ribbons, transparent overlays and primitive blocks. The result has no convincing terrain volume, material response, architectural construction logic or consistent depth cue. Roads and water read as UI-like bands laid over a board. Structures may have recognizable parts, but their silhouette, scale and shadow language do not belong to the same authored world.

The failure is cumulative rather than one missing polish pass. Every new code-authored layer adds another independent visual system. The image becomes busier without becoming more believable.

## 2. Is Godot the problem?

No. The current pipeline is the problem. Godot supports orthographic 3D cameras, imported GLTF scenes, physically based materials, directional and local lighting, shadows, decals, terrain meshes, shaders, particles and post-processing. v0.231 uses only a narrow subset of that capability and asks runtime code plus primitive geometry to perform the job of environment art.

## 3. Would Unity or Unreal automatically fix it?

No. Either engine could render a strong RTS scene, but neither creates coherent art direction, authored landmarks, terrain materials, lighting composition or asset discipline automatically. Moving now would preserve the hardest problem while adding an engine migration, tooling rewrite and gameplay integration risk. Unreal may raise the rendering ceiling and Unity may offer a broader asset ecosystem, but the current bottleneck is authored content and pipeline ownership, not renderer availability.

## 4. Most realistic visual approach

The recommended production direction is Godot 3D with an orthographic/isometric camera and authored low-poly environment assets:

- Model modular terrain, road, bank, bridge and landmark kits in Blender.
- Export GLTF scenes with consistent scale, pivots, naming and material slots.
- Use a restrained PBR or hand-painted material family with shared palette and roughness rules.
- Keep water, decals, lighting, fog and selection feedback in Godot.
- Use 2D billboards or pre-rendered sprites selectively for units only if animation cost makes full 3D units unrealistic.

Pre-rendered 2D remains viable, but it creates angle, lighting, atlas and animation constraints while losing some of the depth and shadow flexibility demonstrated by this spike. Fully authored 2D tiles would also be viable, but the project already has a functioning Godot 3D orthographic foundation.

## 5. What should be abandoned

- Broad transparent terrain rectangles as final art.
- Roads, banks and rivers built from stacked color bands.
- Large runtime-generated primitive assemblies as final landmark geometry.
- Per-milestone accumulation of another visual overlay without a shared asset and material language.
- Claims that procedural cleanup alone can converge on premium fantasy RTS presentation.

These techniques may remain for debug visualization, deterministic fallback and automated tests.

## 6. What can be retained

- Browser gameplay and all gameplay data.
- Stable IDs, saves, economy, production, AI, pathing, collision and objectives.
- Selection and command semantics.
- Minimap data and most HUD information architecture.
- Existing unit identities and current billboard experiments as temporary scale references.
- Godot capture, validation, benchmark and isolated-launch infrastructure.
- v0.231 as comparator evidence, not as the production environment base.

## 7. Concrete recommendation

Keep Godot. Stop polishing the existing battlefield compositor. Treat the isolated v0.232 scene as evidence that orthographic authored 3D is the correct direction, while recognizing that code-built low-poly primitives are still only a style and pipeline prototype.

The next milestone should build one small Blender-authored modular kit—terrain chunks, one road set, one river-bank set, bridge, keep, barracks and mine—and import it into the isolated scene. Define scale, camera, palette, lighting, material and performance budgets there. Do not reconnect gameplay until that kit produces a green human visual review.
