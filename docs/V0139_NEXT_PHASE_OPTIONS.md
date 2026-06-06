# v0.139 Next-Phase Options

Status: roadmap only. Do not automatically start any option.

## Option A - Generate Four Reference-Only Style Frames

Generate the first four external reference-only images from the v0.138 prompt briefs, then stop for human art review.

Use when:

- `SALTO_SLICE_STABILIZATION_GREEN` is accepted.
- Emmanuel agrees the core packaged slice is stable enough for art-direction exploration.
- Candidate metadata remains `runtimeIntegrationStatus = forbidden`.

Risk:

- Visual direction may still need iteration before runtime art import is ever considered.

## Option B - One More Bounded Usability Polish Pass

Run a narrow final polish pass before art generation.

Use when:

- Emmanuel sees remaining HUD, minimap, camera, combat-readability, or pacing friction in the v0.139 review video.
- Any issue is bounded to player-facing usability and does not require new systems.

Risk:

- Delays reference-art exploration.

## Option C - Pause Godot And Run Unity Comparator

Run a Unity comparator only if a material Godot blocker emerged.

Use when:

- Routine Godot editor work becomes unavoidable.
- Fresh-checkout, package, performance, input, or automation gates reveal a material workflow blocker.

Risk:

- Starts a comparator path and should not happen unless the blocker is real.

## Recommendation

Based on the current v0.139 evidence, recommend **Option A**: generate the four reference-only style frames and stop for human art review.

Reason: the player-facing Salto slice is functionally completable, repeatable, packaged, zero-editor, and classified `SALTO_SLICE_STABILIZATION_GREEN`, while the v0.138 reference-art workspace is ready and still forbids runtime integration.

Do not begin Option A, B, or C automatically.
