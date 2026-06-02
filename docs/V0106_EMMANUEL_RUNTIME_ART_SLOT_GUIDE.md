# v0.106 Emmanuel Runtime Art Slot Guide

Status: ready for review after final verification.

## What To Review

Open the private Playtest Hub and use the `Art Slot Fallbacks` group.

Review these states:

- Menu fallback.
- Campaign fallback.
- Battlefield terrain fallback.
- Unit fallback.
- Building fallback.
- Lume fallback.
- HUD fallback.
- Results fallback.
- Mock routing mode.

Use the `Art Slots` diagnostics toggle only in private playtest/dev posture. Public play should not show it.

## What This Checkpoint Proves

- The game can name future runtime art slots without breaking today.
- Missing art falls back safely.
- Unapproved art cannot load.
- `runtime-candidate-approved` is still not runtime integration.
- Future assets must pass a separate runtime-integrated proof.

## What Not To Judge Yet

- Final image quality.
- Sprite polish.
- Full UI kit art.
- Animation polish.
- Finished logo art.
- Final terrain rendering.

## Hard Boundary

Do not place generated or candidate images into runtime folders during v0.106 review. Candidate images belong only in the v0.105 art-review workspace until a future explicit integration checkpoint is approved.
