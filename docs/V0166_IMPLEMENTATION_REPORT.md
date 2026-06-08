# v0.166 Implementation Report

Status: `PASS_V0166_IMPLEMENTATION_COMPLETE`

Implemented:

- Added review-only GDScript args for an experimental mode label and three-slot review camera.
- Added rendered pixel size evidence for Worker and Militia billboard status.
- Added `apply_three_slot_art_review_framing()` on the Godot Salto 2.5D scene.
- Added `GODOT_REVIEW_SALTO_THREE_SLOT_ART_WINDOWS.bat`.
- Repaired the review launcher route so it uses the v0.166 executable while prior opt-in launchers preserve their default executable behavior.
- Added `GODOT_VALIDATE_SALTO_THREE_SLOT_VISUAL_COHERENCE_WINDOWS.bat`.
- Added `tools/godot/saltoThreeSlotVisualCoherenceTool.mjs`.
- Added `scripts/cleanupSaltoExperimentalArtifacts.mjs`.
- Added `GODOT_CLEANUP_SALTO_EXPERIMENTAL_ARTIFACTS_SAFE_WINDOWS.bat`.
- Added scaffold guardrail coverage.

Not implemented:

- No image generation.
- No new art slots.
- No Aster or Ashen player-slice integration.
- No default launcher art enablement.
- No browser runtime change.
- No save, stable-ID, gameplay, input, objective, AI, balance, or campaign mutation.

Validation target:

```text
npm run godot:validate:salto-three-slot-visual-coherence
npm run godot:cleanup:salto-experimental-artifacts
npm run godot:cleanup:salto-experimental-artifacts -- --apply-safe-only
node tools/godot/saltoThreeSlotVisualCoherenceTool.mjs report --artifact-root=artifacts/desktop-spikes/godot-salto/v0166
```

Latest scorecard status: `PASS_V0166_THREE_SLOT_VISUAL_COHERENCE_HUMAN_REVIEW_READY`.
