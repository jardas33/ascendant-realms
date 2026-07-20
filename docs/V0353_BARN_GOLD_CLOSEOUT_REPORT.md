# v0.353 Barn Gold Closeout

## Scope

v0.353 is a narrow repair of the v0.352 human-rejected evidence path. It repairs contextual worker integrity, removes artificial foundation contact geometry, and produces a true square 256×256 render. The accepted v0.352 barn roof repair, agricultural shutters, geometry, materials, and proportions remain frozen.

## Base and decision authority

- Branch: `codex/v0215-v0226-recovery`
- Base HEAD: `30810baa9c3dce41b115eb97c4546438a7fe30de`
- Human decision carried forward: `V0.352 HUMAN-REJECTED AS FINAL GOLD — EXTERIOR ROOF REPAIR ACCEPTED AND FROZEN; WORKER INTEGRITY, NATURAL FOUNDATION CONTACT AND TRUE-ASPECT 256 PROOF FAILED`
- Required outcome: `READY FOR HUMAN V0353 BARN GOLD-CLOSEOUT REVIEW`
- Automatic gold approval: false; human review remains required.

## What changed

1. Context workers are now two instances of `V0353CompleteBarrosanWorker.tscn`, each created with `PackedScene.instantiate()` from the accepted complete worker atlas source. The scene owns its local transform, billboard, feet contact, and upright closure. No worker body/head/limb pieces are manually reconstructed in the v0.353 fixture.
2. The barn uses directional engine shadows and ambient fill for terrain contact. The v0.352 artificial rounded contact treatment is not called or recreated. The v0.353 contact contract records zero visible blobs, zero decal boundaries, zero rectangular contact artifacts, and zero floating foundation geometry.
3. The 256 evidence frame is rendered through a dedicated 256×256 `SubViewport` sharing the same opt-in world and orthographic camera family. The source is read directly from that square viewport; it is not a stretched 16:9 frame or a cropped presentation substitute.
4. A contextual clean PLAYER capture and two DEBUG_REVIEW captures are included. DEBUG_REVIEW exposes the complete-worker hierarchy and engine-shadow-only contact contract without changing the accepted barn.
5. The dedicated capture wrapper, exact ten-file upload pack builder, validator, metrics, and this report were added under v0.353 names.

## What did not change

- No barn mesh, roof geometry, shutter geometry, material source, UV, or proportion redesign.
- No gameplay, state chain, default runtime, save, stable ID, movement, pathfinding, combat, economy, resource, or AI change.
- No accepted v0.352 files were edited.
- No video or large new asset import was added. The worker source is the existing repository-authored v0.314 atlas.

## Frozen barn and roof proof

The v0.352 roof repair hash remains `0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9`. v0.353 reuses the accepted roof visibility repair and upper shutter methods unchanged. The raw set includes front, rear, foundation, and retained roof orbit views, while the upload pack preserves the v0.352 decision/freeze board and adds new rendered proof boards.

## Worker integrity

The worker scene contains one complete `WorkerBillboard` sourced from `res://assets/v0314/h3/worker_directional_animation_atlas.png` and one small `WorkerContactShadow`. The fixture instantiates exactly two scene instances. Manifest and metrics values are:

- complete workers: 2
- disassembled workers: 0
- detached worker parts: 0
- horizontal workers: 0
- upright workers: 2
- minimum contextual worker height contract: 24 pixels
- local transforms owned by the complete scene: true

The close worker captures show attached heads, torsos, arms, legs, boots, and equipment as one intact authored atlas-cell figure. The contextual PLAYER captures keep both workers readable at ordinary RTS scale.

## Natural terrain contact

No artificial barn foundation patch is present in v0.353. Barn meshes cast ordinary directional shadows, and the world retains the neutral overcast fill. The contract is deliberately conservative: no visible contact blobs, no soil stain, no slab, no decal perimeter, and no floating foundation geometry. The DEBUG_REVIEW label reports that the contact method is engine shadow and ambient fill only.

## True-aspect 256 evidence

`14_true_256_pixel_source.png` and `15_true_aspect_square_presentation.png` are both direct 256×256 PNG reads from the dedicated square SubViewport. Manifest dimensions are `256x256`, pixel aspect ratio is `1.0`, and the capture method explicitly records no crop or stretch. The review board keeps the square source square.

## PLAYER and DEBUG_REVIEW evidence

PLAYER captures include frozen barn views, clean foundation views, two worker close views, front/side worker silhouettes, contextual three-quarter views, ordinary RTS scale, square proof, greyscale/value proof, warm directional proof, and matched House02/barn material unity. They contain no debug labels or artificial contact geometry.

DEBUG_REVIEW captures are intentionally limited to two technical frames: complete worker hierarchy and terrain contact contract. They preserve auditable evidence without changing the PLAYER fixture or accepted gameplay runtime.

## Review pack

Upload pack: `artifacts/manual-review/v0353-barn-gold-closeout/UPLOAD_TO_CHAT/`

The pack contains exactly ten files: `00_READ_ME_FIRST.md`, eight rendered PNG boards, and `compact-evidence-summary.json`. It contains no video. Raw renders and diagnostics are under `artifacts/runtime/v0353/`.

## Dedicated validator and capture commands

- Capture: `npm run godot:capture:salto-v0353-barn-gold-closeout`
- Pack: `npm run godot:pack:salto-v0353-barn-gold-closeout`
- Validator: `npm run godot:validate:salto-v0353-barn-gold-closeout`
- Scene: `desktop-spikes/godot-salto/scenes/review/V0353BarnGoldCloseout.tscn`
- Complete worker scene: `desktop-spikes/godot-salto/scenes/review/V0353CompleteBarrosanWorker.tscn`

The validator checks the frozen source hashes, v0.352 file preservation, complete-scene instantiation count, worker integrity metrics, zero artificial contact geometry, true 256 dimensions, required raw captures, exact pack contents, and default-runtime/gameplay isolation.

## Validation evidence

The dedicated v0.353 validator passed after the real Godot capture and exact pack build. The retained v0.352 validator also passed. Before commit, the full local checks passed: `npm test` (887 tests / 122 files), `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run validate:runtime-art-slots`, `npm run validate:artifact-retention`, `npm run godot:all`, and `git diff --check`. The Godot sweep generated only legacy import/UID churn; those generated files were removed or restored without touching accepted assets, and v0.353 evidence was preserved.

## CI and final state

The exact pushed commit and GitHub Actions run are recorded in the final closeout response and in the final revision of this report. The checkpoint is not considered closed until the branch is clean and synced with origin at 0 ahead / 0 behind.

## Human review status

`READY FOR HUMAN V0353 BARN GOLD-CLOSEOUT REVIEW`

This is a review handoff, not an automatic gold claim. Human inspection of the upload pack remains the final art decision.
