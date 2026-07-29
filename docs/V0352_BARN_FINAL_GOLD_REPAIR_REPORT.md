# v0.352 Barn Final-Gold Repair Report

## Scope

v0.352 is a narrow repair checkpoint for the v0.351 Barrosan agricultural barn review fixture. It addresses only the rejected exterior roof visibility, rectangular foundation-contact presentation, and contextual PLAYER proof. It does not redesign the barn, alter the accepted shutters, or change gameplay/runtime semantics.

Base HEAD: `c029305be963353e122da669e67d7d33b8d06c0a`

Branch: `codex/v0215-v0226-recovery`

Required outcome: `READY FOR HUMAN V0352 BARN FINAL-GOLD REVIEW`

## Human rejection carried forward

The v0.351 human decision was:

> V0.351 HUMAN-REJECTED AS FINAL GOLD - AGRICULTURAL SHUTTER REPAIR ACCEPTED; EXTERIOR ROOF VISIBILITY, ORGANIC FOUNDATION CONTACT AND CONTEXTUAL PLAYER PROOF FAILED

The v0.351 shutter repair is retained exactly. The two closed vertical-board timber leaves, center seam, one strap per leaf, opening dimensions, and lower/upper area contract were not redesigned in this checkpoint.

## Roof visibility repair

The source v0.350 GLB contains the frozen barn geometry and material identity. The failure was isolated to a rear-facing roof slope that could disappear under ordinary backface culling, exposing an interior/cutaway read from rear three-quarter views.

The repair adds one opt-in v0.352 review-only group with two correctly wound, closed exterior slope surfaces inside the frozen eave/ridge bounds. Backface culling remains ordinary `CULL_BACK`; culling is not disabled and no camera-specific roof hiding is used. The source roof remains a straight two-slope roof at 20 degrees, with the same measured bounds before and after. Nine exterior orbit frames were captured, including both rear three-quarter views, with zero missing slopes, cutaways, interior exposure, or hidden roof nodes.

Frozen source geometry hash: `0b4944d8a15006664dad84cec5e8b41546497588d14194d5b2e49621071e209c`

v0.352 repair descriptor hash: `0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9`

## Organic foundation contact

The rejected rectangular v0.351 contact plane and floating foundation corner artifacts are absent. The v0.352 fixture uses five low rounded transparent contact-shadow blobs plus one irregular rounded doorway soil response. These are confined to building contact and have no rectangular perimeter or gameplay-zone read.

## Contextual PLAYER proof

The fixture now includes two explicitly named, complete review-only workers near House02 and the barn. The workers have readable body, head, two legs, and grounding base parts, with a modest fixture-only scale adjustment and tighter building spacing so both are inspectable in a normal three-quarter RTS context. The principal context frame uses an orthographic three-quarter camera and the close worker-proof frame is retained separately. This is capture-only dressing; it is not a gameplay unit, does not move, and is not integrated into the default runtime.

## Capture and evidence

Capture command:

`npm run godot:capture:salto-v0352-barn-final-gold-repair`

The runtime evidence contains 20 required rendered PNG captures plus diagnostic files. The true 256x256 source is an actual square render, not a title card or a resized metadata claim. The normal RTS family, matched House02/barn material view, greyscale value proof, restrained warm proof, contextual PLAYER proof, and DEBUG_REVIEW roof/contact proof are all rendered captures.

Upload pack:

`artifacts/manual-review/v0352-barn-final-gold-repair/UPLOAD_TO_CHAT/`

The upload pack is intentionally exactly ten files: one read-me, eight rendered PNG boards, and one compact evidence summary JSON. It contains no video. The boards cover the frozen v0.351 decision, final front/direct-front proof, complete roof orbit, rear visibility, organic contact, matched material unity, 256/greyscale/warm evidence, and contextual PLAYER proof.

## PLAYER and DEBUG_REVIEW separation

The v0.352 scene is opt-in and review-only. Normal clean captures contain no labels or overlays. The single DEBUG_REVIEW capture exposes the technical roof/contact readout, while the underlying repair groups remain deterministic and inspectable. No accepted PLAYER state, HUD, default scene, or gameplay system is changed.

## Preserved contracts

- v0.351 shutters remain frozen and validated.
- v0.350 barn material unity and source asset hashes remain unchanged.
- v0.347-v0.350 retained art roots remain untouched.
- The accepted v0.287-v0.351 state chain is not modified.
- True default runtime remains unintegrated.
- No movement, pathfinding, combat, damage, HP, AI, waves, economy, resources, save, or stable-ID behavior is added or changed.
- No production-ready or automatic-gold claim is made.

## Validator and validation

Dedicated validator:

`npm run godot:validate:salto-v0352-barn-final-gold-repair`

The validator checks the frozen source hashes, shutter contract, roof bounds/pitch/winding/culling contract, absence of roof hiding, organic-contact contract, contextual worker fixture, 20-capture manifest, actual 256 source, exact ten-file/eight-PNG/no-video upload pack, default-runtime isolation, and absence of automatic gold approval.

Full local validation is run before commit:

- dedicated v0.352 validator
- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run validate:runtime-art-slots`
- `npm run validate:artifact-retention`
- `npm run godot:all`
- `git diff --check`

## Human review status

This checkpoint is ready for human v0.352 Barn Final-Gold review. The validator and rendered evidence establish the requested repair contract; they do not grant automatic gold approval. Final acceptance remains a human visual decision using the upload pack.

## CI and final repository state

Commit: `30578391f8e1a8eaf5bc6a15977fc3d4f34e9c2e`

GitHub Actions: run `29767928374` (`CI Release Matrix Dry Run`, run 518) completed with `success` for the exact commit SHA. The Fast confidence job completed unit/pure-rule tests, production build, content validation, art-intake validation, E2E fast smoke, and production preview smoke successfully.

Final repository state at the original v0.352 commit: clean and synced with origin, 0 ahead / 0 behind.
