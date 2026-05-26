# v0.29.1 Blocked Remote CI Status

Date: 2026-05-26

## Summary

Remote GitHub Actions is currently unavailable for reliable checkpoint validation. The v0.28-v0.29 push run failed before repository checkout completed, so the failure is not evidence of a code, test, build, content, art-intake, Playwright, or package regression.

## Affected Run

- Repository: `jardas33/ascendant-realms`
- Workflow: `CI Release Matrix Dry Run`
- Run id: `26447947052`
- Run URL: `https://github.com/jardas33/ascendant-realms/actions/runs/26447947052`
- Commit: `aa6fc0595edc48ae2d48520224114ac41c27f637`
- Commit short hash: `aa6fc05`
- Commit message: `Checkpoint v0.28-v0.29 hero progression and ability foundation`
- Event: push to `main`
- Final status: failed after two attempts

## Failure Point

Both attempts failed in the `Fast confidence` job during `actions/checkout@v4`.

The relevant checkout failure was:

```text
remote: Your account is suspended. Please visit https://support.github.com for more information.
fatal: unable to access 'https://github.com/jardas33/ascendant-realms/': The requested URL returned error: 403
```

The rerun repeated the same checkout failure. The final fetch attempt also reported HTTP 403 and `fatal: expected 'packfile'`, still before checkout completed.

## What Did Not Run Remotely

No repository commands ran in the failed remote job. Specifically, the remote runner did not reach:

- `npm ci`
- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run test:e2e:smoke:fast`
- `npm run smoke:preview`

The release matrix, full release e2e, release simulator, and optional visual QA jobs were skipped by push workflow rules as expected for this workflow configuration.

## Interpretation

Treat run `26447947052` as remote CI unavailable. Do not treat it as a code failure, flaky test failure, browser failure, or release-lane failure.

Do not claim remote CI is green for v0.28-v0.29 or v0.29.1 until GitHub Actions can check out the repository and actually run the workflow commands.

## Action Required

Resolve the GitHub account suspension, billing, organization access, repository permissions, or GitHub App/token condition that is causing checkout to return HTTP 403. After checkout access is restored, run the normal Fast confidence job and any manual release-matrix workflow required for release confidence.

Do not repeatedly rerun GitHub Actions while the checkout 403 remains unresolved; repeated runs will only reproduce the account-level failure and will not validate the code.

## Local Fallback

Use `docs/V0291_HERO_PROGRESSION_LOCAL_VERIFICATION_CLOSEOUT.md` for local fallback verification evidence until remote CI is available again.

## Recovery Update - 2026-05-26

Remote checkout access was restored after the original blocked run:

- v0.29.1 commit `765a99548a09575f84f42e661d224a4bf3e22789` pushed to `main` successfully.
- Push run `26478377719` completed successfully.
- `actions/checkout@v4` completed successfully in the `Fast confidence` job.
- Fast confidence then ran the repo commands and passed: install, `npm test`, `npm run build`, content validation, art-intake validation, fast smoke, and production-preview smoke.
- Release simulator, hosted release matrix, full release e2e, and optional visual QA were still skipped in the push run by workflow rules.

A manual `workflow_dispatch` run, `26478600449`, was then started with `run_release_matrix=true`:

- Checkout succeeded for Fast confidence, Release simulator, and every hosted release-matrix job.
- Fast confidence passed.
- Release simulator passed.
- Hosted release matrix passed for `deep-meta`, `deep-campaign-pressure`, `layout-core`, `layout-cinderfen`, and `smoke`.
- Hosted `deep-battle` failed on the initial attempt and on one job rerun. This was no longer an account or checkout failure; it was a hosted Playwright lane failure in `tests/e2e/deep-flow.spec.ts`.

Observed hosted `deep-battle` failure:

```text
tests/e2e/deep-flow.spec.ts:3829
behaviour mode control gauntlet preserves attack, retreat, marquee, and minimap intent @hosted-deep-battle

Expected retreatState.hasMoveTarget to be true, but received false.
```

The initial failed matrix attempt also saw one `Worker assignment and site upgrade boost a captured resource site` failure, but the rerun reduced the residual failure to the behaviour gauntlet move-order assertion.

Follow-up action taken locally:

- Added a test-only hosted deep-battle stabilization in `tests/e2e/deep-flow.spec.ts`.
- The shared world-move helper now prefers safe ground points that do not hit capture sites/buildings and reselects the original player units before retrying world right-clicks.
- The behaviour gauntlet retreat setup now parks hostile units away from the command target before testing the explicit retreat/move order.
- No runtime gameplay, balance, maps, factions, assets, save format, pathing, or production systems were changed.

Local follow-up verification:

```text
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "behaviour mode control gauntlet" --reporter=line PASS, 1 test.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Worker move-away pauses construction" --reporter=line PASS, 1 test.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
```

Remote CI is no longer blocked at checkout. Treat the remaining work as hosted release-lane verification for the follow-up test-only stabilization.
