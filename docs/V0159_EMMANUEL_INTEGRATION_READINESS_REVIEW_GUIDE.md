# V0159 Emmanuel Integration Readiness Review Guide

Status: review guide for a documentation-only readiness packet. v0.159 does not generate images, add slots, or integrate runtime art.

## Review These First

- `docs/V0159_FIRST_PLAYER_FACING_HYBRID_ART_INTEGRATION_READINESS.md`.
- `docs/V0159_FIRST_SLOT_DECISION_SCORECARD.md`.
- `docs/V0159_V0160_WORKER_OPT_IN_INTEGRATION_CONTRACT.md`.
- `docs/V0159_PLAYER_SLICE_INTEGRATION_RISK_REGISTER.md`.
- `docs/V0159_PLAYER_SLICE_INTEGRATION_ROLLBACK_PLAN.md`.
- `docs/V0159_PRIVATE_COMPARATOR_TO_PLAYER_SLICE_BOUNDARY.md`.
- `docs/art-prompts/V0160_01_GODOT_PLAYER_SLICE_WORKER_BILLBOARD_OPT_IN_INTEGRATION.md`.

## Decision Questions

1. Is Worker the right first player-facing slot, or should integration remain private-comparator-only?
2. Is the opt-in launcher posture strict enough to protect the default Salto player slice?
3. Is the fail-closed procedural fallback requirement sufficient for local-art risk?
4. Should v0.160 be authorized as a one-slot Worker proof, or should the team pause for more visual review first?

## What v0.160 Should Prove If Authorized

Future v0.160 should prove only that the selected Worker derivative can appear in the Godot player-facing Salto slice through an explicit opt-in launcher, while the default launchers still show the procedural Worker fallback.

The review packet should include:

- Default-vs-opt-in captures.
- Missing-file or hash-mismatch fallback captures.
- Worker selection, assignment, mine-work, Barracks-repair proximity, group, edge, and camera-distance captures.
- Performance/fair-path evidence.
- Boundary scans for no browser wiring, no second slot, no production manifest mutation, no save/stable-ID mutation, and no default launcher mutation.

## Stop Conditions

Stop before v0.160 if any of these are unacceptable:

- Worker is not the right first slot.
- The opt-in launcher is not isolated enough.
- Default-launcher preservation is uncertain.
- Local ignored art is not acceptable for a player-facing review proof.
- The team wants additional human art review before crossing the boundary.
