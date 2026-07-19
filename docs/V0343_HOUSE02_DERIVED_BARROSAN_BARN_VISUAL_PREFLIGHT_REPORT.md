# v0.343 House02-Derived Barrosan Barn Visual Preflight

## Outcome

**REJECTED INTERNALLY — HOUSE02-DERIVED BARN STILL FAILS THE VISUAL PREFLIGHT**

This checkpoint is a visual preflight, not a production-asset approval. The five allowed source captures were rendered and inspected before any board or technical evidence was created. The candidate is rejected because the principal front elevation does not yet read as the same House02-derived stone family, the roof/eave treatment is not a coherent simple barn roof, and the matched 256-pixel comparison is too small to prove the intended identity. The rear, side, gables, openings, and slate roof do not compensate for those visual-first failures.

No upload review pack was created. No video, LOD, collision, UV, wireframe, performance, or other technical diagnostic evidence was created. No technical diagnostics were created. The rejection stops the visual preflight at the requested boundary.

## Scope

v0.343 creates one isolated, opt-in House02-derived Barrosan barn candidate for visual preflight only. It duplicates the frozen v0.338 House02 source, derives a compact closed barn from that source/material lineage, renders five unlabelled views, and records an honest human-review gate. It does not alter the accepted runtime or any gameplay system.

Base HEAD: `d7a266a468b58c3ad9c1a2d5688b5de4ec2ddddb`

Branch: `codex/v0215-v0226-recovery`

Frozen House02 Blend SHA-256: `3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6`

Frozen House02 GLB SHA-256: `ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89`

## Source lineage and construction grammar

The working source is `art-source/blender/v0343/house02_source_duplicate_initial.blend`, byte-identical to the frozen House02 Blend before derivation. The derived source is `art-source/blender/v0343/house02_derived_barrosan_barn_visual_preflight.blend`; its final SHA-256 is `ecb268c7a4f69c914951a0dbd9494fb332003566073b2311b47a348ba9f831e9`.

The exported prototype is `desktop-spikes/godot-salto/assets/v0343/house02_derived_barrosan_barn_visual_preflight.glb`; its final SHA-256 is `d4d780510b1812e7e4f082f24dfee049ab21f905acbaaeaa4f54d6f67b4118b9`.

The candidate uses a closed rectangular agricultural volume, two principal roof slopes, a straight ridge, a lower double livestock/storage door, upper hay-loading shutters, a rear service door, resolved rear and both gables, six material slots, and repository-authored transformation from the duplicated House02 source. The intended House02 material resources are reused, but the front principal surface is not visually convincing enough in the rendered evidence.

There is no visible v0.341 or v0.342 asset dependency. The v0.342 rejection is not repaired, remodelled, or continued.

## Prototype scene and capture command

Scene: `desktop-spikes/godot-salto/scenes/review/V0343House02DerivedBarnVisualPreflight.tscn`

Capture command:

```text
npm run godot:capture:salto-v0343-house02-derived-barn-visual-preflight
```

Validation command:

```text
npm run godot:validate:salto-v0343-house02-derived-barn-visual-preflight
```

The scene is a standalone Godot `Node3D` fixture containing only the frozen House02 visual anchor, the derived barn candidate, a neutral overcast environment, irregular ground, lighting, and two scale-reference workers. It is never loaded by the true default runtime. The default-runtime preservation check is the unchanged frozen asset hash plus the absence of runtime integration in the scene, package wiring, and manifest.

## Visual-first source captures

The capture root was `artifacts/runtime/v0343/screenshots/` during inspection. The files were rendered without labels and without technical overlays. Their exact ledger is preserved here so the temporary runtime folder can be removed before commit while retaining auditable evidence of what was inspected.

<!-- V0343_CAPTURE_LEDGER_JSON
{"captures":[{"fileName":"01_front_three_quarter_ordinary_rts.png","purpose":"front three-quarter ordinary RTS","bytes":538619,"sha256":"67ed4ae2e36c24430b89a6abac24f392615bf2161bae7de4391bdab499bd14a4"},{"fileName":"02_rear_three_quarter_ordinary_rts.png","purpose":"rear three-quarter ordinary RTS","bytes":452785,"sha256":"45829c148b74201071e75ff25a40b84912db14479db785f918eb9fd8edc8bc94"},{"fileName":"03_front_close_material.png","purpose":"front close material view","bytes":1254112,"sha256":"cd5ffc24c66d43177d35b96ba4bc0d3e254b04d628e60345c978ee36ef50e7f5"},{"fileName":"04_direct_side_gable.png","purpose":"direct side and gable view","bytes":738788,"sha256":"139ee010054bb09eef1e4391f9d5facc4fd55c2f1447f478269c1b43c3e979ac"},{"fileName":"05_house02_barn_matched_256.png","purpose":"House 02 and barn matched 256-pixel composition","bytes":15508,"sha256":"4156f403c041cf3d4dd716f1f1346045084fc2f0d072fc0dc0bb93ee6bbb9422"}]}
V0343_CAPTURE_LEDGER_JSON -->

## Visual gate findings

### Front three-quarter ordinary RTS

The barn has a useful agricultural silhouette and the two-level opening arrangement is legible. However, the principal front wall reads as pale vertical weathered timber around the doors rather than as a confident continuation of the House02 irregular granite family. The roof shows recognizable slate courses but also bright edge/eave strips and an awkward layered appearance. This is a visual failure, not a missing technical proof item.

### Rear three-quarter ordinary RTS

The side and rear surfaces read more convincingly as stone, and the rear service opening exists. The rear service opening is visually too dark/blank, and the contrast between the rear/side stone and the front elevation makes the candidate feel materially inconsistent.

### Front close material

The close view confirms that the front principal material is the blocking defect. The stone family is not consistently legible across the main elevation, and the roof-edge treatment remains visually unresolved. Because this is a source-level identity gate, a close-up cannot be accepted on the basis of the better-looking side wall alone.

### Direct side and gable

The gable and side elevation provide real volume, roof slope, and a visible agricultural mass. They also expose the bright vertical edge strips and the roof assembly’s lack of a simple, resolved barn silhouette. This view does not clear the visual preflight.

### Matched House02 and 256-pixel comparison

The composition contains both the frozen House02 anchor and the candidate, but at the required 256-pixel comparison size the candidate is too small to prove material identity and opening hierarchy at a glance. The comparison therefore fails its evidence purpose.

## Exact rejection criteria

- **Principal House02-derived material identity:** failed on the front elevation; side/rear stone alone is insufficient.
- **Coherent agricultural roof:** failed; slate is present, but bright edge/eave strips and layered roof reading remain unresolved.
- **Two agricultural levels and openings:** present, but not enough to overcome the material/roof failures.
- **Closed volume, rear, both gables:** present in the source metrics and visible in the captures.
- **Terrain pedestal absence:** the fixture uses irregular ground rather than a presentation board; no large white pedestal is used.
- **Matched 256-pixel proof:** failed to make the identity confidently judgeable.

Because the visual-first gate failed, the result is not eligible for `READY FOR HUMAN HOUSE02-DERIVED BARN VISUAL PREFLIGHT REVIEW`.

## Preservation and boundaries

Preserved: true default runtime, frozen House02 hashes, accepted gameplay/state chain, stable IDs, saves, production runtime scenes, and all v0.342 behavior. The candidate is prototype-only and opt-in.

Not added: movement, pathfinding, route following, combat, damage, HP, projectiles, death/despawn, AI, waves, economy, resources, production logic, pressure behavior, runtime integration, or gameplay mutation.

Not created because of rejection: review board, upload pack, video, LOD evidence, collision evidence, UV evidence, wireframe evidence, performance evidence, and technical diagnostics.

## Validation evidence

The dedicated validator verifies source lineage, frozen hashes, isolated scene and capture commands, real 3D geometry metrics, five nonblank visual-first captures when present, or this report’s exact hash ledger after temporary captures are removed. It also verifies the exact rejection outcome, absence of a v0.343 review pack, absence of v0.341/v0.342 visible dependencies, no gameplay coupling, and no default-runtime integration.

The required package command is:

```text
npm run godot:validate:salto-v0343-house02-derived-barn-visual-preflight
```

The full local validation ladder for this checkpoint is recorded at closeout: dedicated v0.343 validator, `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run validate:runtime-art-slots`, `npm run godot:validate:salto-experimental-artifact-retention`, `npm run godot:all`, and `git diff --check`.

## Disposition

v0.343 is an honest rejection, not a production-ready barn. The isolated source and scene remain useful as a documented preflight attempt, but no asset is approved or integrated. A future prompt may revisit front material mapping and roof-edge normalization; that work is outside this checkpoint.

No v0.344 scope is started here.
