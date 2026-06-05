# v0.132 Worker Assignment Guidance Spec

Status: `PLAYER_FACING_REPAIR_IMPLEMENTED`

## Required Interaction

1. After `West Stone Cut Mine` becomes controlled, the Worker receives a visible focus ring, arrow, and `WORKER` label.
2. The objective asks the player to select the highlighted Worker.
3. With the Worker selected, the player right-clicks the controlled `West Stone Cut Mine`.
4. The slice shows assignment feedback, updates the site state to `WORKER_ASSIGNED`, and shows production-boost feedback.
5. The objective advances only after the real Worker assignment event.

## Boundaries

This does not add a broad economy, hauling, depot rules, new Worker AI, new build tree, save mutation, or campaign progression. It is only a bounded player-facing guidance repair for the existing microloop.
