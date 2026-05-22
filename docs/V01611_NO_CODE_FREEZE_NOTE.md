# v0.16.11 No-Code Freeze Note

Date: 2026-05-22

## Decision

Stop autonomous code changes for the current release candidate unless a real manual test or tester report exposes a blocking bug.

The next useful evidence is human/manual testing, not more speculative code.

## Why

- v0.16.7 made the narrow runtime combat/control fix.
- v0.16.8 through v0.16.10 added automated soak, deterministic proxy coverage, package validation, release-candidate docs, public-safety checks, and tester kit polish.
- Exact-final push Fast confidence is green on `7cc6eff`.
- The enabled workflow-dispatch release matrix is green on `ad4eee0`, which is already after the v0.16.7 runtime fix.
- Emmanuel has not yet manually retested the release candidate.

## What Is Allowed Next

- Emmanuel manual retest.
- 2-5 external tester batch.
- Anonymous feedback intake and triage.
- Exact-final workflow-dispatch matrix if Emmanuel wants remote parity.
- v0.16.x bugfix only if a real retest fails.

## What Is Not Allowed Next Without A New Goal

- Worker construction implementation.
- New units, buildings, maps, factions.
- Patrol runtime or formations.
- Runtime art/assets.
- Balance/stat/wave changes.
- Save migration.
- Broad AI/pathing rewrite.
- Speculative combat/control changes without manual evidence.

## Reopen Criteria

Reopen v0.16.x code only if the issue has:

- build/package identifier
- browser and OS
- route/map
- exact steps
- expected result
- actual result
- whether it reproduced
- screenshot/video if useful and kept outside public repo when private
