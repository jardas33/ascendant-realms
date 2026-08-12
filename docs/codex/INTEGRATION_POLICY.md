# Integration policy

Integration is a review gate, not a file copy.

1. Confirm candidate base and changed-file ownership.
2. Run focused tests and the required build/content checks.
3. Inspect real player-facing evidence at the required resolutions.
4. Compare against the current baseline and reject stale/black/title-card evidence.
5. Run a normal rehearsal without debug overlays controlling play.
6. Ask an independent critic to identify regressions and scope creep.
7. Integrate only the smallest passing candidate into a fresh local branch.
8. Re-run combined regression checks and record exact SHA.

Do not push, merge, promote, or mutate a protected checkout unless separately authorized.
