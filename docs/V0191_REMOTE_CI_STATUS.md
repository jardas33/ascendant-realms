# v0.19.1 Remote CI Status

Date: 2026-05-24
Status: v0.19 exact remote matrix inspected; narrow layout-lane fix applied locally

## Baseline Runs

- Commit `ec73568` push run: GitHub Actions CI Release Matrix Dry Run #112 / run id `26367416563`.
- Result: success for automatic Fast confidence.
- Skipped by push rules: Release simulator, hosted release matrix groups, optional visual QA, and Full release e2e.

## v0.19 Exact Release Matrix Dispatch

- Workflow: `CI Release Matrix Dry Run`.
- Ref: `main`.
- Commit: `ec735680d86f47c1f9bf9666e31044b32f1cd83c`.
- Run: #113 / run id `26367693184`.
- URL: https://github.com/jardas33/ascendant-realms/actions/runs/26367693184
- Dispatch inputs:
  - `run_release_matrix=true`.
  - `run_full_release=false`.
  - `run_visual_qa=false`.

Expected active lanes:

- Fast confidence.
- Release simulator.
- Release matrix (deep-meta).
- Release matrix (deep-battle).
- Release matrix (deep-campaign-pressure).
- Release matrix (layout-core).
- Release matrix (layout-cinderfen).
- Release matrix (smoke).

Expected skipped lanes:

- Optional visual QA.
- Full release e2e.

## Run #113 Result

Completed lanes:

- Fast confidence: success.
- Release simulator: success.
- Release matrix (deep-meta): success.
- Release matrix (deep-battle): success.
- Release matrix (deep-campaign-pressure): success.
- Release matrix (smoke): success.

Failed lanes:

- Release matrix (layout-core): failure.
- Release matrix (layout-cinderfen): failure.

Skipped lanes:

- Optional visual QA.
- Full release e2e.

## Failure Diagnosis

Both layout failures came from the shared hosted layout helper still expecting Command Hall `build` and `upgrade` command buttons. That expectation was stale after v0.19 intentionally made Command Hall Worker-only in normal player-facing UI.

The remote diagnostics showed the expected v0.19 UI state: selecting the Command Hall exposed the `Train Worker` action and no normal Command Hall army/build/research role buttons.

## Narrow Fix

Updated `tests/e2e/layout.spec.ts` so Command Hall layout reachability checks expect the `train` action instead of the removed `build` and `upgrade` actions.

Local verification after the fix:

```text
npm run test:e2e:release:hosted:layout-core PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
```

## Current Decision

The only red remote lanes for exact v0.19 were stale test expectations, not a runtime role regression. v0.19.1 carries the narrow layout expectation fix plus the broader local verification matrix. If exact remote evidence is required for the final v0.19.1 commit, dispatch `CI Release Matrix Dry Run` on `main` after push with `run_release_matrix=true`, `run_full_release=false`, and `run_visual_qa=false`.
