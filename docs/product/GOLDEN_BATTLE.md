# Golden Battle

The Golden Battle is the proposed player-facing integration target for Ascendant Realms. It is not currently certified complete.

## Scenario

An ordinary player starts a Hollowspan match as Barrosan against Lioraen on Easy, reads the opening objective, selects a unit, issues a movement order, gathers or secures an initial resource, constructs or restores a military building, queues production, rallies a unit, responds to enemy contact, wins or loses a bounded engagement, and reaches truthful Results. The player can Continue or Play Again without a stale state.

## Proof requirements

- setup, loading, and runtime identity agree;
- no debug overlay is needed to understand the match;
- selection, order, queue, cost, health, and result feedback are visible;
- navigation is causal and reliable on ordinary terrain;
- one deterministic combat scenario proves damage and casualty semantics;
- one natural match proves the integrated flow;
- screenshots or video show the player-facing experience, not only validators.

The Golden Battle becomes the principal integration gate only after the focused interaction shell is reliable.
