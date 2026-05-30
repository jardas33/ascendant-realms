# v0.62 Survivor Continuity And Results Implementation Report

## Summary

v0.62 makes Retinue continuity readable at battle end. Results now distinguishes normal battle-only veterancy from opt-in Retinue roster continuity, and campaign battle Results show deployed, survived, and lost Retinue units.

## Runtime Changes

- Results veteran scope copy now explains that normal trained units remain battle-only unless added to the Retinue.
- Results Retinue recruitment shows roster capacity, deployment selected count, current Retinue, eligibility, and full-roster copy.
- Successful recruitment status copy points players back to the Campaign Map for deployment changes.
- Campaign Results show a Retinue deployed summary with survived/lost units.
- Deployed Retinue survivors increment counters after battle; lost deployed Retinue units are removed from roster and deployment selection.

## Rules Preserved

- Retinue rank/XP/kills remain modest continuity, not a new permanent army RPG layer.
- Replay cannot duplicate one-time growth because recruitment is opt-in, roster-capped, and duplicate-blocked.
- Tutorial/no-reward routes remain free of Retinue recruitment and deployment complexity.
- Existing control groups, Patrol, group movement, Worker commands, hero XP, skills, and relics remain unchanged.

## Verification Notes

- Full Vitest passed after implementation.
- Focused hosted Retinue proxy passed after rebuilding production `dist`.
- Required hosted release lanes, visual QA, controls, Act 1 telemetry, package generation, package verification, and `git diff --check` passed.
- Local release shard 1/3 timed out after 20 minutes with no summary; shards 2/3 and 3/3 passed.
- Final release/package verification is tracked in checkpoint closeout docs.
