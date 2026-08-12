# Player evidence rules

- Use real gameplay-scale frames or video from the named runtime.
- State the exact branch, SHA, resolution, mode, scenario, and capture time.
- Reject black, blank, transitional, stale, resized, mislabeled, or title-card-only evidence.
- Show the player-facing path without debug overlays controlling the decision.
- Pair visual proof with a semantic trace or validator when the claim is stateful.
- Keep comparison framing and scale consistent.
- Store generated evidence outside tracked source unless the active goal explicitly authorizes a retained pack.

Proof of an internal state is not proof that a player can see or use that state.
