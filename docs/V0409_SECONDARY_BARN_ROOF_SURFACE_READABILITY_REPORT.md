# v0.409 Secondary Barn Roof Surface Readability

## Scope

v0.409 is a narrow, opt-in material-only correction for the accepted v0.408 subordinate left barn. It changes only material assignments and parameters on the existing barn roof faces, ridge, and eaves. Barn geometry, walls, entrance, grounding, silhouette, scale, placement, and all gameplay/runtime semantics remain authoritative.

## Base and branch

- Base commit: `548705c19c36aa2edf3655bc490c23372d515db3` (accepted v0.408 final)
- Branch: `codex/v0215-v0226-recovery`
- Scene: `desktop-spikes/godot-salto/scenes/v0409_secondary_barn_roof_surface_readability.tscn`
- Opt-in capture: `npm run godot:capture:v0409-secondary-barn-roof`
- Opt-in smoke: `npm run godot:smoke:v0409-secondary-barn-roof`

## Treatment and rendered result

The subordinate barn inherited a flat brown roof treatment from v0.399. The diagnostic first isolated the existing roof/trim nodes. It proved that `V0399_Barn_Front_Gable` is the visible brown roof-facing panel, while `V0399_Barn_Roof_Left` and `V0399_Barn_Roof_Right` affect only narrow edge geometry. The visible panel is an authored ArrayMesh with no UV arrays. A material-only slate attempt therefore rendered as a near-black, textureless panel rather than a coherent roof. The checkpoint fails closed with `ASSET_UV_LIMITATION_SECONDARY_BARN_ROOF`; no candidate material is retained.

The temporary diagnostic isolates the existing front gable, left roof, right roof, and ridge using red/green/blue/yellow materials. It is evidence-only and restored before the final baseline frames. No UV arrays, mesh data, transforms, or geometry are edited.

## Preservation contract

The audit records the limitation and unchanged runtime contract. Walls, entrance, contact, main house, bridge, route, characters, props, camera, lighting, fallback renderer, debug renderer, gameplay, and true default runtime remain unchanged. There are no retained overlays, decals, duplicate surfaces, duplicate meshes, replacement roofs, or procedural geometry.

## Evidence

- Runtime evidence: `desktop-spikes/godot-salto/artifacts/runtime/v0409/`
- Review pack: `artifacts/manual-review/v0409-secondary-barn-roof-surface-readability/`
- Required evidence: wide colour, barn roof close colour, wide grayscale, barn roof close grayscale, material-ID diagnostic, matched v0.408/v0.409 wide comparison, matched barn-close comparison, and preservation JSON
- Dedicated validator: `npm run godot:validate:v0409-secondary-barn-roof`

The barn-close comparison is matched framing: both halves remain on the accepted v0.408 material state because the v0.409 candidate is not retained. The diagnostic and audit explain why the candidate is rejected rather than presenting a black panel as a successful material result.

## Review gate

The candidate is accepted only if the wide view reads the subordinate barn as a complete secondary structure with an intentional weathered roof, the close view shows coherent roof-face scale and direction without stretching, seams, wall bleed, or trim mismatch, and grayscale separates roof, eaves, walls, entrance, and ground contact. Those conditions were not met. The final result is `ASSET_UV_LIMITATION_SECONDARY_BARN_ROOF` with no retained candidate.

## Validation and closeout

The dedicated v0.409 validator accepts this fail-closed status only when the audit explicitly retains no candidate and identifies the missing UV arrays. It passed with `ASSET_UV_LIMITATION_SECONDARY_BARN_ROOF`. The retained validators passed:

- `npm run godot:validate:v0408-main-house-roof`
- `npm run godot:validate:v0407-eastern-landing`
- `npm run godot:validate:v0406-western-footing`
- `npm run godot:validate:v0401-character-grounding`
- `npm run godot:validate:v0400-house-roof`

Full local validation passed: `npm test` (887 tests), `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run validate:runtime-art-slots`, `npm run validate:artifact-retention`, `npm run godot:all`, and `git diff --check`. The capture and smoke commands also passed, and the rendered close/diagnostic frames were manually inspected; no black candidate was retained.

Closeout:

- Commit: `706e01deb14f09d379049106870c3eb4ac5bd7d1`
- GitHub Actions: run `30241855859` — success for the exact SHA
- Final tracked repository state after push: clean and synced, 0 ahead / 0 behind

The checkpoint is intentionally not a successful roof-material adoption. It is a truthful, removable, opt-in fail-closed record that preserves v0.408 and identifies the smallest safe prerequisite for a future retry: author UV support for the existing visible `V0399_Barn_Front_Gable` surface or provide an approved existing face/material path that can cover it coherently.
