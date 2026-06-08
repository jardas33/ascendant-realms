# v0.166 Three-Slot Visual Coherence Correction Spec

Status: `PASS_V0166_THREE_SLOT_VISUAL_COHERENCE_SCOPE`

v0.166 is a bounded presentation and cleanup checkpoint for the existing three-slot Godot Salto opt-in posture. It generates zero images, adds zero slots, preserves all existing launchers, and keeps the default launcher procedural.

## Diagnosis

The v0.165 aspect and duplicate-render fixes are preserved. The remaining screenshot concern is treated as a review-legibility problem:

- the mode is not obvious in ordinary screenshots;
- Worker and Militia are intentionally RTS-scale and can read small at the default camera;
- procedural Aster, terrain blocks, markers, and structures still make the scene prototype-like;
- Barracks material is correctly bound but subtle at normal and zoomed-out distance.

## Allowed v0.166 Changes

- Add a review-only on-screen mode label through `--experimental-review-mode-label=`.
- Add review-only camera framing through `--salto-three-slot-review-framing`.
- Tune that review framing to camera size 7.8 with a lower safe focus, review-only Worker/Militia scale overrides, smaller translucent unit anchors, and a restrained Barracks material sheen.
- Report rendered pixel width/height using the active orthographic camera and viewport height.
- Add `GODOT_REVIEW_SALTO_THREE_SLOT_ART_WINDOWS.bat`.
- Route that review launcher through `AscendantRealmsGodotSalto-v0166.exe` so the live Windows review uses the same v0.166 label/framing path proven by capture automation.
- Add safe cleanup tooling that is dry-run by default and deletes only positively identified Godot-generated sidecars when `--apply-safe-only` is explicit.

## Boundaries

- No new images.
- No Aster or Ashen player-slice import.
- No fourth slot.
- No browser runtime wiring.
- No save, stable-ID, gameplay, objective, AI, or balance mutation.
- Default stabilized launcher and default player-slice launcher remain procedural.
