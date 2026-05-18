# v0.14.2 Hosted Settings Smoke Failure Audit

Date: 2026-05-18

Scope: audit the GitHub Actions hosted smoke regression seen after v0.14.1 commit `256c688`.

## Remote Evidence

| Field | Value |
| --- | --- |
| Workflow | CI Release Matrix Dry Run #55 |
| Commit | `256c688` |
| Failed group | Release matrix (smoke) |
| Failed test | `tests/e2e/smoke.spec.ts:825`, `settings screen persists accessibility options @ci-fast` |
| Result | 1 failed, 12 passed |
| Failure mode | Test timed out at 60 seconds on first attempt and retry |
| Artifacts | GitHub generated screenshot, video, and trace |

The GitHub CLI is not installed in this local environment, and the GitHub app workflow tools need a numeric run id rather than the displayed workflow run number, so this audit records the supplied run #55 evidence rather than over-claiming artifact inspection.

## Why This Looks Isolated

Only the hosted smoke group failed, and only the settings accessibility smoke failed inside that group. The rest of hosted smoke passed:

- new campaign flow
- Border Village battle launch
- post-Ashen/Cinderfen paths
- trophy standard
- skirmish setup
- skirmish difficulty/fog/pressure
- inventory

That pattern argues against a broad hosted preview failure, broken build, or general app boot regression.

## v0.14.1 Changes That Could Affect It

v0.14.1 expanded this path indirectly by adding a pause/menu assertion to the existing settings accessibility smoke. Relevant touched areas:

- keyboard focus guarding
- battle input cleanup
- battle HUD menu behavior
- pause menu rendering
- HUD stable-panel refresh handling
- direct BattleScene smoke launch after settings

The settings test now verifies all of the following in one `@ci-fast` test:

- settings save and reopen persistence
- document accessibility datasets
- direct battle launch after settings
- floating text disabled in runtime combat
- fog override in battle
- reduced motion and colorblind minimap runtime state
- colorblind minimap DOM markers
- battle Menu opens pause overlay
- Resume closes pause overlay

## Local Hosted Reproduction

Command:

```bash
npx playwright test tests/e2e/smoke.spec.ts --config=playwright.hosted-release.config.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on --reporter=line
```

Result before the fix: passed locally in about 45 seconds.

That local result is green but too close to the previous 60-second scoped timeout for a GitHub-hosted runner, especially because production preview and CI video/trace capture are slower than a local desktop run.

## Likely Root Cause

The failure is most likely a scoped test-budget regression, not an assertion regression. v0.14.1 kept the settings persistence/runtime checks and added pause overlay behavior to the same hosted smoke test. On the local hosted config, the test already used about three quarters of its previous 60-second budget.

## What Must Not Be Weakened

- Do not skip or delete the settings smoke test.
- Do not remove settings persistence assertions.
- Do not remove accessibility document/runtime assertions.
- Do not remove floating text, fog override, reduced motion, or colorblind minimap checks.
- Do not hide console errors.
- Do not change gameplay numbers, save format, maps, factions, units, or assets.
- Do not change the hosted release matrix structure for this isolated timeout.
