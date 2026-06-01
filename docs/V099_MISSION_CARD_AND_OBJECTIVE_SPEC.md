# v0.99 Mission Card and Objective Spec

Status: implemented.

## Goal

Act 1 mission cards should explain what the player is doing next without reading like debug entries. The campaign panel remains map-first and uses existing node data, unlock checks, actions, tabs, and More Details disclosure.

## Default Mission Card

The default selected mission panel should surface:

- mission title;
- mission type;
- one-line premise;
- primary objective;
- difficulty or pacing chip;
- reward chips;
- lock reason or recommended next step;
- primary action;
- `More Details`.

## Hidden Behind More Details

The following remain available but should not dominate the default read:

- doctrine details;
- long briefing prose;
- build hints;
- extended reward copy;
- replay notes;
- telemetry-style explanations;
- rival detail;
- modifier explanations;
- optional objective details.

## Objective Clarity

- Each Act 1 card has one clear primary objective line.
- Optional goals remain secondary.
- Counts and progress copy must reflect existing state rather than invented narrative progress.
- Debug terms and stable IDs must not appear in player-facing default copy.
- Replay copy must say what is safe to replay without implying first-clear rewards duplicate.

## Lock and Next-Step Copy

- Locked nodes show the existing locked reason as the compact guidance line.
- Available nodes show the existing Act 1 recommended next action when known.
- Completed nodes show replay posture or Act 1 complete posture.
- Placeholder/future nodes keep the existing preview lock language.

## Non-Goals

v0.99 does not change unlock logic, reward logic, objective completion, campaign save fields, stable IDs, mission order, maps, enemy AI, difficulty, or art.
