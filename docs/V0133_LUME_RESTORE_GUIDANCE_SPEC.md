# v0.133 Lume Restore Guidance Spec

Status: `PASS_LUME_RESTORE_PROOF`

After simulation-backed wave defeat, the player-facing slice now:

- Advances to `Objective 9: Restore the Lume link`.
- Highlights the Lume link.
- Accepts a normal click on the highlighted Lume link.
- Restores the Lume link through an input-facing runtime method.
- Reaches the Results screen.

Verified captures:

- `19_lume_highlighted`
- `20_lume_restored`
- `21_results`

The repair preserves `linked_ward` at `0.92` and does not modify saves, stable IDs, browser runtime, or runtime art paths.
