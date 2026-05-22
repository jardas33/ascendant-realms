# v0.16.8 Baseline And Remote CI Audit

Date: 2026-05-22

## Starting Baseline

- Starting commit: `169bb21d54bd1599f5241b15bbfb1a187276d921`
- Commit message: `Checkpoint v0.16.7 manual combat contact and aggro fix`
- Branch: `main`
- Branch state at intake: clean and synced with `origin/main`
- `git rev-list --left-right --count origin/main...HEAD`: `0 0`

## Package State At Intake

- Existing package path: `artifacts/playtest/ascendant-realms-private-playtest-169bb21`
- Package commit recorded in `playtest-build-info.json`: `169bb21d54bd1599f5241b15bbfb1a187276d921`
- Package dirty marker: clean, `workingTreeDirty: false`
- Package name: `ascendant-realms-private-playtest-169bb21`

The package exists and points at the v0.16.7 commit. A fresh package should still be regenerated after any v0.16.8 documentation or harness changes are committed so the tester bundle is tied to the final commit hash.

## v0.16.7 Runtime Scope

v0.16.7 changed runtime gameplay narrowly:

- melee contact and adjacent reacquisition semantics
- local melee enemy building aggro
- retreat / move-away suppression reliability
- attack hover/click hit tolerance

v0.16.7 did not change gameplay numbers, unit stats, enemy wave timings, save format, runtime art/assets, new units, new buildings, maps, factions, worker construction, Patrol, formations, broad AI/pathing, or balance tuning.

## Why Remote CI Rerun Is Mandatory

The v0.16.7 commit changed runtime combat/control behaviour. The normal push-triggered fast confidence lane is useful, but it does not run the workflow-dispatch release matrix jobs. The enabled manual release matrix lanes still matter because the changed behaviour touches hosted deep-battle, hosted smoke, control, and release-preview paths:

- Fast confidence
- Release simulator
- Release matrix deep-meta
- Release matrix deep-battle
- Release matrix deep-campaign-pressure
- Release matrix layout-core
- Release matrix layout-cinderfen
- Release matrix smoke

Optional visual QA and full release e2e are workflow-dispatch options and should only be claimed when explicitly run.

## Remote CI Access Note

The local environment does not have the GitHub CLI installed. The available GitHub connector exposes run/job/log inspection and rerun helpers, but no workflow-dispatch creation tool. For this checkpoint, remote CI was inspected through the public GitHub Actions API. Manual dispatch of the full release matrix still requires a user or token with Actions write permission.
