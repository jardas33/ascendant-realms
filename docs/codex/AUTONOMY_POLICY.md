# Autonomy policy

## Allowed by default

- inspect repository, tests, docs, scripts, worktrees, and evidence;
- make the smallest causally justified change inside the named scope;
- run focused validation and fresh evidence capture;
- document uncertainty, blockers, and exact reproduction;
- use isolated worktrees for parallel candidate work.

## Requires explicit authorization

- gameplay/balance/content/save/stable-ID changes outside the named scope;
- protected checkout mutation;
- destructive Git operations, history rewriting, rebase, merge, push, PR mutation, or promotion;
- large asset imports, paid services, credentials, or irreversible external actions;
- broad renderer/engine replacement;
- treating a validator-only result as player-facing acceptance.

## Stop conditions

Stop the lane when the required base does not match, ownership of dirty files is unclear, a failure cannot be repaired within scope, or the next step needs a product/design decision. Report the exact blocker and safest next action.
