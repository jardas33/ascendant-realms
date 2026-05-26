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
