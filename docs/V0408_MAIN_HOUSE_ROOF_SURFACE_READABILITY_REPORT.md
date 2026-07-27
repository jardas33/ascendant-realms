# v0.408 Main-House Roof Surface Readability

## Scope

v0.408 is a narrow, opt-in material-readability correction for the accepted v0.407 Salto slice. It is a material-only change: it changes only material assignments and parameters on the existing v0.400 main-house roof planes, ridge, and eaves. The accepted roof silhouette and all gameplay/runtime semantics remain authoritative.

## Base and branch

- Base commit: `9c6b763d6d0e62cb9f13c214e852b93faa4c07a4` (accepted v0.407 final)
- Branch: `codex/v0215-v0226-recovery`
- Scene: `desktop-spikes/godot-salto/scenes/v0408_main_house_roof_surface_readability.tscn`
- Opt-in capture: `npm run godot:capture:v0408-main-house-roof`
- Opt-in smoke: `npm run godot:smoke:v0408-main-house-roof`

## Treatment

The featureless brown roof came from the existing v0.400 roof-plane material. v0.408 keeps the same five required roof/ridge/eave nodes and assigns derived materials only: both roof planes and the two already-existing visible roof-face closure nodes use the repository-authored `res://assets/v0338/barrosan_house_02_material_gold_candidate_slate_albedo_1024.png` with restrained UV scale and high roughness; the existing ridge receives a darker slate edge value; the existing eaves retain their timber role with a calibrated warm value. The closure nodes are existing roof faces, not new overlays or replacement geometry. No UV arrays are edited and no geometry is added.

The temporary diagnostic isolates the two visible roof faces, ridge, and one eave using red/green/blue/yellow materials. It is captured only as evidence and is restored before the player-facing frames. The first v0.408 candidate used the older v0326 texture but was rejected after inspection because it remained visually flat; the current rendered candidate uses the stronger existing v0338 slate source.

## Preservation contract

The audit records unchanged vertex/index/triangle/surface counts, UV counts, AABBs, transforms, and the five required plus two existing visible roof-face nodes. The chimney remains untouched. Camera, lighting, bridge, route, characters, props, fallback renderer, debug renderer, gameplay, and true default runtime remain unchanged. There are no overlays, decals, duplicate surfaces, duplicate meshes, or replacement roofs.

## Evidence

- Runtime evidence: `desktop-spikes/godot-salto/artifacts/runtime/v0408/`
- Review pack: `artifacts/manual-review/v0408-main-house-roof-surface-readability/`
- Required evidence: wide colour, roof close colour, wide grayscale, roof close grayscale, material-ID diagnostic, matched v0.407/v0.408 wide comparison, matched roof-close comparison, and preservation JSON
- Dedicated validator: `npm run godot:validate:v0408-main-house-roof`

The roof-close comparison is matched framing: its left half is captured in the same v0.408 scene with the accepted pre-v0.408 materials restored, and its right half is the final v0.408 material treatment. This avoids comparing the roof against the unrelated v0.407 eastern-landing close-up.

## Review gate

The initial flat-texture candidate failed visual inspection and was not retained as the final evidence. The current candidate passes the visual gate: the primary RTS view reads a deliberate weathered slate surface, both planes show coherent repeated scale without stretching or wall bleed, the ridge/eaves remain distinct, and grayscale separates roof, ridge, eaves, and chimney from the stone walls. If the repository texture cannot satisfy those criteria on the existing faces, the correct result is `ASSET_UV_LIMITATION_MAIN_HOUSE_ROOF` with no retained candidate.

## Validation and closeout

The dedicated v0.408 validator, retained v0.407/v0.406 validators, repository test/build/content/art/runtime checks, `npm run godot:all`, and `git diff --check` are run before commit. Exact commit, GitHub Actions, and final clean/synced repository state are recorded here after remote CI completes.
