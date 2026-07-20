# v0.354 Barn Final Evidence Report

## Scope

v0.354 is a narrow evidence-integrity repair after the human rejection of v0.353 as a final gold closeout. The accepted barn, roof, shutters, materials, terrain contact, workers, House02 context, lighting, gameplay isolation, and true-default isolation remain frozen. This checkpoint changes only square evidence capture framing, square diagnostics, review-board placement, compact summary, validator coverage, and packaging.

## Base and human decision

- Base HEAD: `d945785be95d07a1de5709f0c9efdede3747e2f2`
- Branch: `codex/v0215-v0226-recovery`
- Decision carried forward: `V0.353 HUMAN-REJECTED AS FINAL GOLD CLOSEOUT — BARN, ROOF, NATURAL CONTACT AND INTACT WORKERS ACCEPTED AND FROZEN; TRUE-ASPECT 256 CAPTURE, SAME-CAMERA DIAGNOSTICS AND SUMMARY CONTRACT FAILED`

The human decision accepted the v0.353 visual asset content and rejected only its true-aspect square evidence contract.

## Failure diagnosis and repair

The failed v0.353 source was `artifacts/runtime/v0353/screenshots/14_true_256_pixel_source.png`. Its square SubViewport created an independent local camera and reused wide framing in the shared World3D. The result was mostly empty background with a clipped barn sliver at the right. v0.354 creates a direct `256x256` SubViewport, copies the accepted camera global transform, uses orthographic `KEEP_HEIGHT`, and measures the barn-only projected mask before writing the manifest.

The final square camera state is:

`projection=orthographic|keepAspect=KEEP_HEIGHT|position=(-15,8.4,15)|target=(0,2.65,0)|size=25.0|viewport=256x256|barnTransform=(0,0.18,0)`

The three square captures share camera hash `61ce13d05c5ab632213256450449924dae4f1c02585a57168189cfaf4019c4dd`. The raw neutral source and review-board source hashes are identical: `ae4399552ef53ff9802d4d10b4e670ebd89e43dc307419a327c99dadde3cf22f`.

Measured raw subject bounds are `x=33, y=79, width=191, height=92`, with `74.609375%` width occupancy, `35.9375%` height occupancy, `32 px` minimum edge margin, `0.5 px` horizontal centre error, and `3.0 px` vertical centre error. This satisfies the required margins, centre limits, and 45–82% / 35–82% occupancy ranges.

## Frozen content preserved

- v0.353 barn and roof geometry remain unchanged.
- v0.353 natural terrain contact remains engine directional shadow and ambient fill only.
- Both complete upright workers remain intact: 2 complete, 2 upright, 0 disassembled, 0 detached, 0 horizontal.
- House02, terrain, lighting, material inputs, and accepted worker atlas remain unchanged.
- No new asset import, model replacement, gameplay, state, movement, combat, economy, resource, save, or stable-ID work was added.

## Evidence and review pack

Raw capture command:

`npm run godot:capture:salto-v0354-barn-final-evidence`

Pack command:

`npm run godot:pack:salto-v0354-barn-final-evidence`

Review pack:

`artifacts/manual-review/v0354-barn-final-evidence/UPLOAD_TO_CHAT/`

The pack contains exactly ten files: one README, eight PNG boards, and `compact-evidence-summary.json`. It contains no video. Board 06 shows the raw 256×256 neutral source in a square display rectangle without distortion. Board 07 shows neutral, greyscale, and warm 256×256 panels with identical framing.

The pack includes:

1. v0.353 human decision and frozen asset authority
2. accepted barn contact and complete workers
3. accepted exterior roof and shutters
4. contextual PLAYER proof
5. House02/barn material unity
6. true 256 neutral raw source
7. true-aspect neutral/greyscale/warm comparison
8. final DEBUG_REVIEW summary with projected bounds and camera identity

## Validator

Dedicated validator:

`tools/godot/saltoV0354BarnFinalEvidenceTool.mjs`

Command:

`npm run godot:validate:salto-v0354-barn-final-evidence`

It verifies the frozen v0.353 files and v0.350 material hashes, the direct square SubViewport and camera-global-transform contract, raw dimensions, bounds, margins, camera hashes, source/display hash identity, exact ten-file/eight-PNG/no-video packaging, required summary keys, human-review flags, and no gameplay/default-runtime mutation.

## Validation evidence

Local v0.354 capture and pack generation pass. The dedicated validator passes after the pack is generated. The full retained repository validation is run before commit and recorded in the final closeout.

## CI and final repo state

CI evidence is recorded after the v0.354 commit is pushed and the exact commit SHA workflow completes successfully. The final closeout will report the exact commit, workflow run, and the required clean/synced `0 ahead / 0 behind` state.

Human review remains required. v0.354 does not claim automatic gold approval or production approval.
