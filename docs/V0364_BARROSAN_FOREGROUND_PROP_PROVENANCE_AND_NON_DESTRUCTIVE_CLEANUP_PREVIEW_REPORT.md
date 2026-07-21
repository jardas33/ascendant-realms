# v0.364 Barrosan Foreground Prop Provenance and Non-Destructive Cleanup Preview

## Human review status

READY FOR HUMAN V0364 BARROSAN FOREGROUND PROP PROVENANCE AND NON-DESTRUCTIVE CLEANUP PREVIEW REVIEW.

This checkpoint stops at evidence. It does not authorize cleanup, presentation-layer hiding, mesh splitting, re-export, or another asset slot.

## Scope and base

- Base HEAD: `277f4d1d5a44660c0e9132efc45a001a319669df`
- Branch: `codex/v0215-v0226-recovery`
- Previous checkpoint: v0.363 Barn R0/R1/R2 evidence-board repair
- Dedicated scene: `desktop-spikes/godot-salto/scenes/review/V0364BarrosanForegroundPropProvenance.tscn`
- Capture command: `npm run godot:capture:salto-v0364-barrosan-foreground-prop-provenance-and-non-destructive-cleanup-preview`
- Pack command: `npm run godot:pack:salto-v0364-barrosan-foreground-prop-provenance-and-non-destructive-cleanup-preview`
- Validator: `npm run godot:validate:salto-v0364-barrosan-foreground-prop-provenance-and-non-destructive-cleanup-preview`

The accepted Barn placement remains `(4.000, 0.180, -1.000)`. Retained clearances are structural `2.480`, roof/eave `2.510`, and required worker `1.875`. No performance benchmark was rerun.

## Provenance findings

The audit uses active LOD0 render nodes only; dormant LOD1/LOD2 and collision meshes are excluded from visual candidate claims. Every row is backed by the Godot probe at `artifacts/runtime/v0364/capture/v0364-provenance-probe.json`, including owner/source scene, material identity, parent, local/world transforms, and local/world AABB.

| Region | Exact NodePath | Owner/source | Independent duplicate toggle | Finding | Documentary recommendation |
|---|---|---|---|---|---|
| A | `/V0358_House02_Shared_Baseline_Unmodified/LOD0_Granite` | canonical House02 GLB | No | The pale ground-front visual is carried by the parent granite render mesh; its purpose is not established from source. `MERGED WITH PARENT ASSET — FUTURE ASSET REWORK REQUIRED` | REWORK ASSET LATER |
| B | `/V0358_House02_Shared_Baseline_Unmodified/LOD0_Weathered_Timber` | canonical House02 GLB | Yes, in duplicate only | Authored timber node; hiding it removes the broad timber surface set, not only a narrowly named bracket. `PURPOSE NOT ESTABLISHED FROM SOURCE` | INSUFFICIENT EVIDENCE |
| C | `/V0358_Barrosan_Barn_Gold_OptIn_Single_Instance/V0347_Barn_Rendered_Geometry_Truth` | canonical Barn scene | No | The front-right timber is part of the single Barn render mesh. `MERGED WITH PARENT ASSET — FUTURE ASSET REWORK REQUIRED` | REWORK ASSET LATER |

The candidates are present in the R0/R1/R2 evidence states as source-tree content. The v0.364 preview fixture is separate from production and does not make any recommendation active.

## Review-only previews

The raw Godot captures are genuine non-headless viewport images. For A and C, the boards show the merged-parent finding rather than pretending that a child visibility toggle removes the visual. For B, the board shows an untouched original and a duplicate House02 preview with only `LOD0_Weathered_Timber` hidden. The combined board keeps A and C visible and hides B only in the right review panel.

The upload pack is exactly:

`artifacts/manual-review/v0364-barrosan-foreground-prop-provenance-and-non-destructive-cleanup-preview/UPLOAD_TO_CHAT/`

It contains the required README, eight PNG boards, and `compact-evidence-summary.json`. The PNG boards prioritize actual rendered images for the original, isolation, merged evidence, combined preview, callout, and retained R0/R1/R2 panels. Board annotations are documentary overlays, not runtime nodes.

## Preservation and hard boundaries

- Canonical Barn source, geometry, roof, materials, textures, shutters, and transforms: unchanged.
- House02 GLB source, geometry, materials, textures, UVs, and transforms: unchanged.
- Accepted Barn placement and retained clearances: unchanged.
- World, terrain, river, bridge, road, workers, collisions, navigation, gameplay, saves, stable IDs, and default runtime: unchanged.
- No source node was deleted, renamed, split, edited, or re-exported.
- No production visibility override was added.
- `combinedPreviewReviewOnly=true`; all mutation counters are zero.
- `benchmarkRerunCount=0`.
- R0/R1/R2 remains `0/1/0`; R0/R2 pixel and state matches are retained as true; rollback retains zero Barn nodes.

The source hash ledger retains canonical Barn raw source hash `13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3` and frozen roof hash `0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9`. The current House02 GLB hash is emitted in the v0.364 runtime manifest and summary.

## Validation evidence

The dedicated validator checks exact upload count (10), PNG count (8), UTF-8/no-BOM/no-mojibake/no-control-character hygiene, exact provenance paths, owner/source fields, merged findings, review-only preview fields, source-diff cleanliness, accepted transforms/clearances, R0/R1/R2 counts, retained R0/R2 identity, and actual Godot screenshot presence.

The retained ladder required for closeout is v0.363, v0.362, v0.361 through v0.354, the retained Barrosan validators, and the v0.259 UI invariant validator, followed by the repository test/build/content/art/runtime/artifact checks, `npm run godot:all`, and `git diff --check`. No benchmark command belongs to this checkpoint.

The local closeout run completed with the dedicated v0.364 pack/validator, retained v0.363 through v0.354 checks, retained Barrosan checks for the available v0.269-v0.279 and v0.285-v0.303 ranges, v0.334 and v0.337-v0.353, and the v0.259 invariant. The historical v0.280-v0.284 review directories are not present in this checkout, so those unavailable historical validators were not represented as passing evidence. The v0.333 validator's historical scope guard rejects the already-tracked v0.334 Blender source; that pre-existing repository condition is recorded rather than attributed to v0.364. Repository validation also passed: `npm test` (887 tests), `npm run build`, content validation, art-intake validation, runtime-art-slot validation, artifact retention, `npm run godot:all`, and `git diff --check`. The v0.364-specific benchmark rerun count remains zero.

## Final closeout

The commit and exact-SHA GitHub Actions result are recorded in the final checkpoint closeout after local validation and push. Human review must decide A, B, and C before any later cleanup checkpoint begins.
