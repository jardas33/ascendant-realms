# v0.292 Barrosan Selected Card Message Format Repair

- Status: PASS
- Scope: HUD/layout-only repair; no gameplay or state-machine behavior changed.
- Aster selected-card facts: `No active progress`; global instruction text is excluded from the card.
- Retained v0.291 chain: Commit, Hold Line, Train, Assign, Signal, Prepare, Approve, and Stage.
- Review pack: `artifacts/manual-review/v0292-barrosan-selected-card-message-format-repair/`.
- Captures: 49.

## Validation

- PASS: selected-card text is bounded, separated, and free of global prompts/diagnostic paragraphs.
