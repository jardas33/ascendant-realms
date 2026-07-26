# v0.401 Character Scale and Foot-Grounding Calibration

## Scope

This is a visual-only, opt-in calibration of the three existing character instances in the accepted Salto slice. It changes uniform visual scale and a small vertical contact correction only. It does not add gameplay, movement, pathing, combat, economy, resources, or new assets.

## Base and implementation

- Base: accepted v0.400 roof-silhouette cleanup.
- Scene: `desktop-spikes/godot-salto/scenes/v0401_character_scale_grounding_calibration.tscn`
- Capture: `npm run godot:capture:v0401-character-grounding`
- Smoke: `npm run godot:smoke:v0401-character-grounding`
- Validator: `npm run godot:validate:v0401-character-grounding`
- Review pack: `artifacts/manual-review/v0401-character-scale-grounding-calibration/`

## What changed

The existing resident worker, crossing guard, and traveller/porter are calibrated to one coherent adult-human visual scale: 0.90, 0.87, and 0.89 respectively. This uniform scale calibration is paired with a small ground contact correction so the feet read as planted rather than floating. Their feet receive small visual-only vertical corrections of -0.03, -0.03, and -0.04 world units. X/Z positions, imported poses, models, roles, props, route, bridge, buildings, camera, and lighting remain unchanged.

The calibration is idempotent and marked on each instance. The runtime audit records original transforms, calibrated scale, X/Z preservation, pose preservation, and the contact correction.

## Visual review evidence

`01_PRIMARY_RTS_VIEW.png` is the wide RTS view. `02_CHARACTER_SCALE_GROUNDING_CLOSE.png` is the direct scale/contact review. The grayscale equivalents test silhouette and grounding without hue. `05_V0400_V0401_PRIMARY_COMPARISON.png` provides the before/after frame pair.

The intended result is that people no longer make the settlement read miniaturized, while the three roles remain distinct and visibly contact the terrain. The check is limited to the already-authored characters; no doorway, barn, bridge rail, cart, workstation, or crate is moved or resized.

## Preserved contracts

- v0.400 single-ridge primary-house roof correction.
- v0.399 barn structural readability and the retained route/bridge/camera/layout.
- Existing three-role character set and poses.
- True default runtime and accepted gameplay/state semantics.
- No movement, pathfinding, route following, combat, damage, HP, projectiles, AI, waves, fog gameplay, economy, or resource mutation.

## Validation

The dedicated validator requires the opt-in scene/router/package/report contracts, five real 1920x1080 captures plus a 3840x1080 comparison, exactly three calibrated figures, unchanged X/Z and pose metadata, and a review-pack validation status. Retained v0.400 through v0.394 validators and the repository-wide checks are run before closeout.

## Review status

Final status: `ACCEPTED BY INDEPENDENT V0401 VISUAL REVIEW`.

Independent verdict: `ACCEPT` — the three characters read at a coherent adult-human scale against the doorway, cart/workstation, crates, and bridge rails, with clean visible ground contact and preserved roles, route, props, bridge, and layout.

## Closeout evidence

- Base HEAD: `bbceda3ab433555bcd8305f1bf16548f89ce04c9`.
- Branch: `codex/v0215-v0226-recovery`.
- Dedicated validator: passed.
- Retained v0.400, v0.399, v0.398, v0.397, v0.396, v0.395, and v0.394 validators: passed.
- `npm test`: 122 files and 887 tests passed.
- `npm run build`: passed.
- Content, art-intake, runtime-art-slot, and artifact-retention checks: passed.
- `npm run godot:all`: passed.
- `git diff --check`: passed.
- Independent ChatGPT visual review: `ACCEPT`.

The opt-in capture root and review pack contain real rendered colour and grayscale evidence, an explicit v0.400/v0.401 comparison, a transform audit, and the accepted validation record. The true default runtime remains unchanged.
