# Parallel work policy

Parallel lanes must have explicit ownership, base SHA, allowed paths, forbidden paths, validation commands, evidence requirements, and integration owner.

- no shared dirty worktree;
- one concern per lane;
- no two lanes edit the same file without an integration decision;
- generated evidence stays isolated;
- candidates are compared before integration;
- integration is local-only until an explicit release/push authorization;
- a lane that changes gameplay semantics must identify save/stable-ID impact before implementation;
- a critic reviews rendered evidence and scope, not just tests.

The proposed first sprint is documented in [`../current/NEXT_MILESTONES.md`](../current/NEXT_MILESTONES.md); it is not executed by this reset.
