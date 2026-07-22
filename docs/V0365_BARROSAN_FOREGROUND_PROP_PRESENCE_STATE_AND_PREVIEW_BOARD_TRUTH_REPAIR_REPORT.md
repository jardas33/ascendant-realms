# v0.365 Barrosan Foreground Prop Presence-State and Preview-Board Truth Repair

## Human review status

READY FOR HUMAN V0365 BARROSAN FOREGROUND PROP PRESENCE-STATE AND PREVIEW-BOARD TRUTH REPAIR REVIEW.

This checkpoint repairs evidence only. It does not authorize cleanup, presentation hiding, mesh splitting, re-export, replacement assets, another art slot, or gameplay work.

## Scope and base

- Base HEAD: `6f22894958ddf5de9b850037d498694dd3dab30d`
- Branch: `codex/v0215-v0226-recovery`
- Previous checkpoint: v0.364 Barrosan foreground prop provenance and non-destructive cleanup preview
- Dedicated scene: `desktop-spikes/godot-salto/scenes/review/V0365BarrosanForegroundPropPresenceStateTruth.tscn`
- Capture command: `npm run godot:capture:salto-v0365-barrosan-foreground-prop-presence-state-and-preview-board-truth-repair`
- Pack command: `npm run godot:pack:salto-v0365-barrosan-foreground-prop-presence-state-and-preview-board-truth-repair`
- Validator: `npm run godot:validate:salto-v0365-barrosan-foreground-prop-presence-state-and-preview-board-truth-repair`

The accepted Barn root remains `(4.000, 0.180, -1.000)`. Structural, roof/eave and required-worker clearances remain `2.480`, `2.510` and `1.875`. The canonical Barn and House02 sources remain unchanged.

## v0.364 findings retained

- A is `/V0358_House02_Shared_Baseline_Unmodified/LOD0_Granite`, a merged House02 parent render mesh. It is not independently addressable and remains a future forked-asset rework candidate.
- B is `/V0358_House02_Shared_Baseline_Unmodified/LOD0_Weathered_Timber`, a broad authored House02 timber component. It can be hidden only in a duplicate review instance, and doing so also removes normal doors, windows, frames and other timber surfaces. The specific upper bracket purpose remains unestablished.
- C is `/V0358_Barrosan_Barn_Gold_OptIn_Single_Instance/V0347_Barn_Rendered_Geometry_Truth`, the single merged canonical Barn render mesh. It is not independently addressable and remains a future forked-asset rework candidate.

## Presence-state contradiction repaired

The v0.364 summary incorrectly reported C in R0/R1/R2. v0.365 derives state presence from real fixture transitions:

1. Load the accepted Barn once.
2. Roll it back and inspect the live R0 owner roots and target nodes.
3. Load the accepted Barn once and inspect live R1.
4. Roll it back again and inspect live R2.
5. Restore the single accepted Barn instance for the requested captures.

The derived truth is:

| Object | R0 | R1 | R2 | Absence reason | Derivation |
|---|---:|---:|---:|---|---|
| A | YES | YES | YES | none | House02 owner root and target node exist in every state |
| B | YES | YES | YES | none | House02 owner root and target node exist in every state |
| C | NO | YES | NO | R0 `BARN_ROOT_NOT_INSTANTIATED`; R2 `BARN_ROOT_REMOVED_BY_ROLLBACK` | Barn owner root and target node exist only in R1 |

The manifest, standalone state-presence artifact, provenance records and compact summary all carry the live owner-root/target-node proof. The validator fails if C appears in either zero-Barn state.

## Board 06 repair

Board 06 is now titled **BROAD HOUSE02 TIMBER-NODE VISIBILITY DIAGNOSTIC**. It is composed from two equal panels captured with the same camera, projection, viewport dimensions, lighting, terrain, House02 transform, Barn transform, worker transforms, river, road and bridge.

- Left: ORIGINAL ACCEPTED V0.363 FIXTURE.
- Right: BROAD TIMBER-NODE HIDDEN DIAGNOSTIC.
- Exactly two panels; no duplicate scene roots are added and no third partial building is visible.
- The right panel explicitly states: `DIAGNOSTIC ONLY - NOT A CLEANUP CANDIDATE`.
- It also states that hiding `LOD0_Weathered_Timber` removes House02 doors, windows and other timber surfaces, and that the upper-bracket purpose is not established from source.
- Board 06 is not called a clean player preview anywhere in the v0.365 pack or summary.

## Review pack

`artifacts/manual-review/v0365-barrosan-foreground-prop-presence-state-and-preview-board-truth-repair/UPLOAD_TO_CHAT/`

The exact upload pack contains 10 files: the required README, eight PNG boards, and `compact-evidence-summary.json`. Raw Godot captures remain under `artifacts/runtime/v0365/capture/` for validator audit.

## Preservation and hard boundaries

- No canonical House02 GLB, scene, geometry, materials, textures, UVs or transforms changed.
- No canonical Barn scene, rendered mesh, roof, materials, textures, UVs or transforms changed.
- No accepted placement, terrain, river, road, bridge, worker, collision, navigation, pathfinding, animation, save, stable-ID, authority-slot or fail-closed behavior changed.
- No production runtime, true-default runtime or browser runtime changed.
- No object was deleted, renamed, split, re-exported or replaced.
- All mutation counters remain zero.
- `benchmarkRerunCount=0`; no new v0.365 performance benchmark is run. Generic benchmark-related steps that already exist inside `npm run godot:all` are not v0.365 certification.
- Human review remains a hard stop before any asset cleanup or mesh separation.

## Validation evidence

The dedicated v0.365 validator checks exact pack count, eight PNG boards, UTF-8/no-BOM/no-mojibake/no-control-character hygiene, README opening, the v0.364 contradiction-retention flags, live state-presence proof for A/B/C, C's explicit R0/R2 absence reasons, Board 06 diagnostic metadata, same-camera/equal-panel/no-duplicate claims, accepted placement and clearances, R0/R1/R2 counts, rollback evidence, source-diff cleanliness, mutation zeros, human-review stop and genuine raw capture presence.

Retained v0.364, v0.363, v0.362-v0.354, available Barrosan and v0.259 invariant validators are run without treating unavailable historical packs as passing. Any pre-existing historical scope guard is reported as such. Repository checks include 887 tests, build, content validation, art-intake validation, runtime-art-slot validation, artifact retention, `npm run godot:all` and `git diff --check`.

## Final closeout

The exact implementation commit, exact-SHA GitHub Actions result, and final clean/synced state are recorded in the checkpoint closeout after local validation and push. This report and the review pack stop at evidence; wait for explicit human disposition before starting asset cleanup.
