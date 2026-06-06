# v0.147 Private Comparator-Only Boundary

v0.147 is the first single-slot runtime-art intake experiment, but only inside the isolated private Godot comparator.

## Allowed

- Exactly one original local Worker cutout generated with Codex built-in image generation.
- Deterministic matte-to-alpha processing of that one source.
- Ignored local experimental Worker slot artifacts under `artifacts/desktop-spikes/godot-salto/v0147/local-worker-slot/`.
- Tracked deterministic diagnostic fallback under the private comparator path.
- Private comparator loader validation.
- Private S/M/L benchmark and capture evidence.
- Human review docs and handoff updates.

## Forbidden

- No existing reference candidate import.
- Generating any additional image.
- Downloaded assets.
- Aster generation.
- HUD generation.
- Environment generation.
- Animation frames, spritesheets, atlas production, texture sheets, models, or icon assets.
- Normal Salto player-facing scene mutation.
- Default launcher replacement.
- No browser runtime wiring.
- Runtime manifest mutation.
- Production art-slot registry mutation.
- Production package inclusion.
- Save changes.
- Stable-ID changes.
- Final Worker design approval.
- Final runtime-art approval.
- Final engine choice.
- Full port.
- Multiplayer, campaign, economy, broad content, or v0.148 work.

## Current Posture

The local Worker cutout and its metadata remain ignored private comparator evidence only. The tracked fallback is diagnostic and exists only for clean-checkout reproducibility. Neither asset is production runtime art.
