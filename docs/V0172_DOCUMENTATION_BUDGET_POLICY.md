# v0.172 Documentation Budget Policy

Status: `PASS_V0172_DOCUMENTATION_BUDGET_POLICY`

The repo has accumulated substantial milestone documentation. v0.172 does not delete tracked historical docs because this prompt does not authorize broad doc cleanup and the current docs are not proven exact generated duplicates.

## Current Count

- Versioned tracked docs matching `docs/V*.md`: `1077`.
- Many past milestones exceed four tracked docs.
- Recent Salto art/runtime checkpoints often needed extra docs because they carried strict reference-art, private-comparator, player-slice, cleanup, fallback, benchmark, and boundary proof.

## Future Default Budget

Future milestones should default to 3-4 tracked docs:

1. Implementation report.
2. QA/benchmark report.
3. Boundary/rollback report.
4. Extra decision packet only when materially needed.

## Rules

- Prefer compact summaries over near-identical reports.
- Update `LLM_GAME_HANDOFF.md`, `DEVELOPMENT_CHECKPOINT.md`, `ROADMAP.md`, `CHANGELOG.md`, `RELEASE_CHECKLIST.md`, and `docs/SALTO_EXPERIMENTAL_ARTIFACT_INDEX.md` instead of duplicating the same facts across new milestone docs.
- Keep ignored artifact JSON/markdown as detailed evidence when the tracked doc can summarize it.
- Do not delete tracked historical docs unless a later prompt proves exact duplication and explicitly authorizes deletion.
- Do not move or archive docs that are still referenced by scripts, tests, handoff notes, or release checklist entries.
- Keep acceptance gates and PASS tokens visible in one implementation report rather than scattering them across many small files.

## Allowed Exceptions

Use more than four tracked docs only when a milestone has materially separate decisions, for example:

- Human style-lock or freeze decision.
- Cleanup approval packet with legal/retention risk.
- Future prompt contract that must be handed to another checkpoint.
- Separate risk/rollback document for player-facing integration.

## v0.172 Application

v0.172 creates five tracked docs because the prompt explicitly requested all five. The policy applies to future milestones and should reduce new tracked-doc proliferation after this checkpoint.
