# v0.380 Corrected Highland Infrastructure Review Report

## Executive result

READY FOR HUMAN V0380 CORRECTED HIGHLAND INFRASTRUCTURE REVIEW

v0.380 is an isolated human visual-review checkpoint. It imports the supplied corrected highland-infrastructure GLB byte-for-byte and presents it through a deterministic opt-in Godot route. This report does not claim production acceptance.

## Baseline and scope

- Branch: `codex/v0215-v0226-recovery`
- Starting HEAD: `eaa2bd2a684f3f28f161dc873e657aed57df519f`
- Implementation commit: `5f2d0f5a3287d4e47466c4634ef3fa14f87d89bd`
- Exact-SHA GitHub Actions: run `30174957949` — success
- Prototype scene: `desktop-spikes/godot-salto/scenes/v0380_corrected_highland_infrastructure.tscn`
- Prototype script: `desktop-spikes/godot-salto/scripts/v0380_corrected_highland_infrastructure.gd`
- Exact imported asset: `desktop-spikes/godot-salto/assets/v0380/corrected-highland-infrastructure/barrosan_highland_infrastructure_v0380.glb`
- Launch: `npm run godot:play:v0380-highland-infrastructure`
- Smoke: `npm run godot:smoke:v0380-highland-infrastructure`
- Capture: `npm run godot:capture:v0380-highland-infrastructure`
- Validator: `npm run godot:validate:v0380-highland-infrastructure`

The work is limited to continuous terrain, an embedded road, a recessed continuous river with wet banks, a timber bridge with granite landings, sparse rocks/reeds/shrubs, and bounded presentation settings. No buildings, units, HUD, gameplay, or production migration were added.

## Source preservation

The supplied GLB and imported Godot GLB both hash to `746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb`. The supplied generator hashes to `4b8eafeac69f16a87bd6899a69ab6c6bb8cb5d49103c5ba9cb3da325f38f3e19`. No remesh, material replacement, vertex-colour replacement, replacement water, or primitive repair was used.

## Presentation loop and visual result

Three deterministic iterations used the same source asset. Iterations 1 and 2 were rejected because their primary views exposed map-edge wedges. Iteration 3 used bounded camera framing and restrained ambient/key/exposure tuning only. The final six renders are genuine 1920x1080 images in the review pack.

Iteration 3 visibly demonstrates:

- broad smooth low-poly relief without the v0.379 corrugated/triangular terrain read;
- one continuous watercourse entering and leaving the frame;
- water continuing below the bridge deck with no land plug splitting the channel;
- restrained, aligned road approaches at both granite landings;
- bridge planks, rails, beams, supports, abutments, and landings reading as a coherent crossing;
- no visible map boundary in the primary RTS frame;
- no HUD, debug overlay, title card, black frame, fog, bloom, or darkness-based concealment.

## Human review limitations

This is still a small infrastructure-only source with sparse dressing and simplified materials. It does not establish a final Barrosan art direction, production asset quality, buildings, units, HUD integration, or full Salto conversion. Human review must decide whether the corrected source is worth carrying forward.

## Preservation

The true default runtime, accepted v0.378/v0.379 routes, gameplay semantics, stable IDs, saves, and unrelated untracked user files were preserved. v0.380 is opt-in only and is not selected by the default runtime.

## Review pack

`artifacts/manual-review/v0380-corrected-highland-infrastructure/`

The pack has exactly ten files: one read-me, six rendered images, one source/import report, one presentation review, and one validation JSON.

## Validation evidence

The focused v0.380 validator passed with exact GLB/source hashes, six runtime captures, exact ten-file pack membership, opt-in/default-runtime boundaries, and real 1920x1080 PNG checks. The focused smoke passed with Godot 4.6.3. The full local suite also passed: `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run validate:runtime-art-slots`, `npm run validate:artifact-retention`, `npm run godot:all`, and `git diff --check`.

The implementation commit `5f2d0f5a3287d4e47466c4634ef3fa14f87d89bd` was pushed to `codex/v0215-v0226-recovery`; exact-SHA GitHub Actions run `30174957949` completed successfully.
