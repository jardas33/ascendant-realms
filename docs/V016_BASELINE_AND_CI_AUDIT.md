# v0.16 Baseline And CI Audit

Date: 2026-05-19
Starting commit: `27dfe1a` (`Checkpoint v0.15 RTS control behaviour foundation`)
Scope: confirm the v0.15 baseline before adding the v0.16 behaviour-mode gauntlet, control diagnostics, package hardening, and retest materials.

## Repository Baseline

- Branch: `main`.
- Local status before v0.16 work: clean.
- Sync status before v0.16 work: `origin/main...HEAD` reported `0 0`.
- Current HEAD before v0.16 work: `27dfe1a Checkpoint v0.15 RTS control behaviour foundation`.
- v0.16 is starting directly from the pushed v0.15 checkpoint named by Emmanuel.

## Required Context Read

The v0.16 pass started by reading or refreshing awareness from:

- `LLM_GAME_HANDOFF.md`
- `DEVELOPMENT_CHECKPOINT.md`
- `CHANGELOG.md`
- `README.md`
- `ROADMAP.md`
- `RELEASE_CHECKLIST.md`
- `docs/V015_BEHAVIOUR_MODES_SPEC.md`
- `docs/V015_CONTROL_COMBAT_BASELINE_AUDIT.md`
- `docs/V015_CONTROL_COMBAT_BEHAVIOUR_FIX_REPORT.md`

## v0.15 Baseline Summary

v0.15 implemented session-only behaviour modes:

- `Hold Ground`
- `Guard Area`
- `Press Attack`

The default mode is `Guard Area`. Patrol remains deferred. v0.15 changed runtime gameplay narrowly in battle input, combat acquisition, command feedback, attack target labels, retreat suppression timing, and HUD mode controls.

v0.15 did not change:

- gameplay data numbers;
- save format;
- maps;
- factions;
- units;
- runtime art/assets.

## GitHub Actions Reality Check

GitHub Actions could not be fully inspected through the normal local CLI path because the GitHub CLI is unavailable:

```text
gh : The term 'gh' is not recognized as the name of a cmdlet, function, script file, or operable program.
```

The GitHub connector was also queried for commit `27dfe1a1ec060708c831690c4bfa806b0d06cb32` in `jardas33/ascendant-realms`. It returned no PR-triggered workflow runs and no combined commit statuses for that SHA. No local Actions logs or artifacts were available through the repository checkout.

This audit therefore records the latest v0.15 GitHub Actions CI Release Matrix Dry Run status as unknown from the local machine. There was no red Actions result available to triage before v0.16 work, so the pass continued from the documented local-green v0.15 baseline.

## Proceed / Stop Decision

Proceed with v0.16 hardening because:

- the repository is clean;
- the branch is synced with `origin/main`;
- HEAD is the expected v0.15 checkpoint;
- GitHub Actions inspection found no visible run/status for the v0.15 SHA rather than a red run;
- the v0.15 handoff records full local verification and a clean private package.

If a later GitHub Actions signal becomes available and shows v0.15 or v0.16 red, the next pass should investigate the failing lane narrowly before broadening control work.

## Guardrails Reconfirmed

v0.16 must remain a hardening, diagnostics, regression, packaging, and evidence-quality pass. It must not add maps, factions, units, runtime art/assets, save persistence for behaviour modes, save migrations, Patrol runtime behaviour, balance tuning, broad AI/pathing rewrites, protected RTS UI patterns, force-click world shortcuts, DOM fallback world clicks, or invented human feedback.
