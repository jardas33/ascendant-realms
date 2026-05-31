# v0.90 Visual QA Review Rules

Checkpoint: v0.90 UX Visual-Regression Harness and Desktop-Viewport Acceptance Hardening

## Review Policy

Do not blindly accept changed screenshots. Each changed screenshot needs:

- the screenshot ID from `docs/V090_VISUAL_REGRESSION_MATRIX.json`;
- the affected viewport;
- the intended UI change;
- confirmation that reward, save, gameplay, and stable IDs were not changed;
- a note explaining why the old screenshot should be retired.

## Blocking Findings

Block the checkpoint if any of these are observed:

- campaign nodes overlap;
- primary campaign action is off-screen by default;
- Results primary actions require scrolling;
- key card text clips horizontally;
- HUD panels collide with each other;
- objective tracker hides the minimap or command panel;
- Lume/private-demo controls appear outside eligible private-demo posture;
- private-demo Results lose compact no-save summary;
- browser console errors appear during visual QA;
- any screenshot retries are needed.

## Non-Blocking Findings

Capture as follow-up notes rather than blocking if:

- a layout is readable but visually plain;
- a screenshot reveals placeholder art;
- a panel could be more beautiful but still preserves hierarchy;
- copy is clear enough but could be shorter later.

## Screenshot Update Rules

- Update the manifest only when adding, removing, or renaming a deterministic screenshot.
- Keep screenshot IDs stable when the same state is still being reviewed.
- Use `v0.90` as the review checkpoint until a later checkpoint explicitly revises the matrix.
- Never use visual QA as a way to approve gameplay, reward, save, or balance changes.
