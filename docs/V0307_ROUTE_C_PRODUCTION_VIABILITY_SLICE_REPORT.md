# v0.307 Route C Production-Viability Slice Report

## Executive verdict

v0.307 is a bounded, isolated production-viability test rather than a runtime integration. The authored terrain and Barrosan utility house materially improve the Route C gap, while the unit bake-off makes the production choice explicit. The honest result is **continue Route C with one more isolated slice**, with U3 hybrid units as the recommended direction. v0.306 scored 68/100; this authored slice scores 78/100. It is not ready for production integration.

## Why v0.306 was not accepted

v0.306 remained a low-poly prototype board: terrain variation was mostly polygon breakup, the river was a uniform trench, the shoreline/bridge contact was weak, the support building still read as a blockout, fallback mannequin billboards weakened identity, and the cool palette compressed values. The next test therefore targets authored micro-detail and unit strategy, not another broad palette pass.

## Scope of the production-viability slice

The work is limited to one East bridge / riverbank / utility-house micro-slice in a new opt-in Godot scene. It does not alter the default launcher, accepted state chain, stable IDs, saves, gameplay, movement, pathfinding, combat, economy, pressure, or production runtime art slots.

## Authored terrain result

The bounded bridge-bank area uses irregular raised patches, sloped shoulders, erosion-color breaks, compacted landing surfaces, damp soil, grass tufts, and embedded rock contacts. The wider sector remains a recoverable prototype reference. Oblique, top-down, medium, and close captures are included.

## River and shoreline result

The river now has a darker deep channel, a separate shallow shelf, wet-stone edge, visible directional flow ribbons, one restrained foam disturbance, irregular shoreline rocks, and explicit bridge-water contact. The result is deterministic and capture-safe without requiring a final production shader.

## Bridge landing result

The existing bridge structure is retained as the tactical anchor and receives a damp beam, moss caps, and authored landing geometry. The bridge remains visibly spanning the river and readable at gameplay scale.

## Support building result

The v0.306 blockout is replaced by an authored Barrosan utility house with segmented fieldstone foundation/walls, dark timber braces, framed doorway, windows, porch, weathered slate gable, ridge cap, chimney, and damp moss foot. It has full, close, side/rear, and top-down footprint evidence and remains subordinate to the Field Barracks.

## Unit U1 result

U1 is an improved multi-angle directional billboard set using three crossed authored cards, a faction sash, grounding shadow, and restrained selection ring. It is the cheapest and safest fallback, but close-up identity remains limited by the source texture.

## Unit U2 result

U2 is a true low-poly 3D Aster with faceted body, head, cloak, hat, sash, grounding shadow, and selection treatment. It has the strongest native silhouette but carries the highest modeling, animation, equipment-variation, and faction-expansion burden.

## Unit U3 result

U3 combines a faceted low-poly body with a billboard/detail cloak, retaining a grounded 3D silhouette while reducing full-model burden. It is the best compromise for readability, identity, equipment variation, and production cost.

## Recommended unit strategy

Recommend **U3 hybrid low-poly body plus billboard/detail solution** for the next isolated production spike. Keep U1 as a fallback/proof strategy and reserve U2 for hero/specialist units until animation and equipment costs are understood.

## Material hierarchy result

The slice separates wet stone, dry stone, dark timber, weathered slate, compacted road, exposed earth, damp grass, deep water, shallow water, and restrained faction accents through value as well as hue. The scene remains cool and practical rather than monochrome, tropical, sci-fi, or fantasy-bloom heavy.

## Atmosphere result

The enabled setup uses soft mountain haze at restrained density and a cool ambient fill. The disabled/enabled pair proves the atmosphere supports distance separation without creating a fog wall or obscuring tactical information.

## Comparison with v0.141

The recovered v0.141 R1 image is reference-only. The v0.307 slice is closer in terrain/material intention and environmental density than v0.306, but it still lacks the authored asset richness, natural topography, and unit identity of the historical target. The comparison sheet is evidence, not a claim of parity.

## Production scalability

Selective authored 3D is plausible for landmark terrain edges and faction buildings. Full terrain conversion is costly but can be bounded by representative authored modules. U3 offers the strongest path to faction expansion without requiring every unit to be fully modeled and animated immediately.

## Performance considerations

The prototype uses a small number of meshes, static materials, orthographic capture, and no runtime gameplay systems. The capture is directional evidence, not production performance certification. Mesh/material batching and authored unit LOD policy remain future work.

## Production risks

- Terrain edge authoring cost may grow quickly across the full Salto map.
- U2 animation and equipment variation are expensive.
- U3 still needs authored Barrosan silhouette sources rather than fallback textures.
- Water variation is deterministic geometry/material treatment, not a final shader.
- The utility-house detail language must scale across a faction roster.

## Honest scorecard

| Subject | Score | Verdict |
| --- | ---: | --- |
| v0.306 Route C convergence | 68/100 | revise again |
| v0.307 authored micro-slice | 78/100 | continue isolated |
| U1 directional billboard | 55/100 | fallback only |
| U2 low-poly 3D | 74/100 | viable, expensive |
| U3 hybrid | 82/100 | recommended |

## Continue / revise / integrate / pivot decision

**Continue Route C, revise once in isolation, then reassess integration.** Do not integrate this scene into the true default runtime and do not treat the score as an automatic pass.

## Exact recommended v0.308

**v0.308 — Route C U3 Barrosan silhouette, terrain-edge, and utility-building production slice**: replace the remaining fallback Aster texture in U3 with one authored Barrosan silhouette source, add one authored terrain-edge module with a second utility-building variant, and measure the same real-rendered bake-off before any runtime integration decision.

## Preserved state

- accepted gameplay/state chain
- Pressure 70/100
- stable IDs and saves
- v0.303 fallback/debug renderer
- v0.305 and v0.306 recoverability
- true default runtime
- no gameplay, movement, pathfinding, combat, economy, resource, or pressure mutation
- no production integration
- no protected asset use

## Validation

Required v0.307 validation includes the dedicated validator, retained v0.306/v0.305/v0.304/v0.303 validators, tests, build, content/art/runtime checks, artifact retention, `npm run godot:all`, and `git diff --check`. Final exact-SHA CI evidence and repository state are recorded after commit and push.

## Final repo state

Recorded after the final pushed SHA completes exact GitHub Actions verification and the local branch is clean and synchronized with origin.
