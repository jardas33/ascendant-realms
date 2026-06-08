# v0.167 Three-Slot Presentation Playthrough QA

Status: `PASS_V0167_THREE_SLOT_PRESENTATION_PLAYTHROUGH_QA`

Scope: review only the existing M0/M1/M2/M3 Godot Salto player-slice postures, classify visible placeholders, and preserve cleanup boundaries before adding Aster.

## Covered Postures

- M0 default procedural.
- M1 Worker-only.
- M2 Worker + Barracks.
- M3 Worker + Barracks + Militia review launcher.
- Worker missing-art and hash-mismatch fallback.
- Barracks missing-art and hash-mismatch fallback.
- Militia missing-art and hash-mismatch fallback.

## Bounded Playthrough

The current evidence covers title, briefing, battle, Aster select/move, mine conversion, Worker assignment, Barracks restoration, Militia recruitment, squad/box-select, attack/wave-defense posture, visible Ashen-wave posture, Results, restart/replay, and recoverable-mistake posture.

## Visual Finding

Worker and Militia are now larger and legible in the review framing. The remaining block-like elements are classified as procedural terrain, objective/site markers, Barracks shell geometry, rings, health bars, HUD/minimap shell, or future environment-art work. No remaining block is classified as accidental duplicate generated-unit rendering.

## Evidence

Primary evidence is produced under `artifacts/desktop-spikes/godot-salto/v0167/` and references current v0.166 screenshots and real-input playthrough captures.

Computer Use review evidence:

- `artifacts/desktop-spikes/godot-salto/v0167/computer-use/v0167-computer-use-title.jpg`
- `artifacts/desktop-spikes/godot-salto/v0167/computer-use/v0167-computer-use-briefing.jpg`
- `artifacts/desktop-spikes/godot-salto/v0167/computer-use/v0167-computer-use-battle.jpg`
- `artifacts/desktop-spikes/godot-salto/v0167/computer-use/v0167-computer-use-three-slot-review.json`

Fallback evidence is explicitly checked by `tools/godot/saltoThreeSlotPresentationQaTool.mjs`:

- Worker fallback runtime: `artifacts/desktop-spikes/godot-salto/v0160/validation/missing-art-fallback/player-slice-validation-runtime.json` and `artifacts/desktop-spikes/godot-salto/v0160/validation/hash-mismatch-fallback/player-slice-validation-runtime.json`.
- Barracks fallback runtime: `artifacts/desktop-spikes/godot-salto/v0162/validation/barracks-missing-art-fallback/player-slice-validation-runtime.json` and `artifacts/desktop-spikes/godot-salto/v0162/validation/barracks-hash-mismatch-fallback/player-slice-validation-runtime.json`.
- Militia fallback runtime: `artifacts/desktop-spikes/godot-salto/v0166/validation/militia-missing-art-fallback/player-slice-validation-runtime.json` and `artifacts/desktop-spikes/godot-salto/v0166/validation/militia-hash-mismatch-fallback/player-slice-validation-runtime.json`.
