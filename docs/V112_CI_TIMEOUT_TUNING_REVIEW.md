# v0.11.2 CI Timeout Tuning Review

Date: 2026-05-11

Scope: compare local v0.11.1/v0.11.2 runtime evidence with the first GitHub Actions workflow timeouts, and decide whether timeout tuning is justified. This phase is documentation-only; it does not change gameplay, content, saves, tutorial behavior, visuals, runtime art, campaign progression, workflow coverage, or test behavior.

## Evidence Available

Remote GitHub Actions timings are not available from this environment because:

- `gh` is not installed;
- the GitHub connector token is expired;
- the public GitHub Actions REST endpoint returns `404 Not Found` for the repository.

The review therefore uses the latest local final-gate evidence plus the v0.11.2 local smoke/preview check. Hosted-run tuning should wait for GitHub UI evidence.

## Local Runtime Baseline

Latest documented local v0.11.1 final-gate runtimes:

| Lane | Local result | Local runtime |
| --- | --- | ---: |
| `npm run test:e2e:smoke` | PASS, 12 tests | about 5.2m |
| `npm run test:e2e:release` | PASS, 67 tests | about 29.9m |
| `npm run test:e2e:release:shard1` | PASS, 55 tests | about 24.3m |
| `npm run test:e2e:release:shard2` | PASS, 12 tests | about 4.7m |
| `npm run test:e2e:release:shard1of3` | PASS, 28 tests | about 11.3m |
| `npm run test:e2e:release:shard2of3` | PASS, 27 tests | about 13.0m |
| `npm run test:e2e:release:shard3of3` | PASS, 12 tests | about 5.1m |
| `npm run visual:qa` | PASS, 18 screenshots, 0 console errors | about 3.2m |
| `npm run playtest:sim` | PASS, 255 runs / 85 battle nodes | short local Node run |
| `npm run smoke:preview` | PASS, 0 console errors | about 26s |

Current v0.11.2 Phase 3 local check:

| Lane | Local result | Local runtime |
| --- | --- | ---: |
| `npm run test:e2e:smoke` | PASS, 12 tests | about 4.7m |
| `npm run smoke:preview` | PASS, 0 console errors | about 25s |

## Workflow Timeout Review

| Job | Current timeout | Evidence-based review |
| --- | ---: | --- |
| `fast-confidence` | 35m | Local smoke plus build/validators/preview smoke should fit comfortably, but GitHub-hosted setup and browser install may add several minutes. Keep as-is until hosted data exists. |
| `visual-qa` | 20m | Local visual QA is about 3.2m after setup. Hosted npm/browser install/build overhead should still fit. Keep as-is. |
| `release-shards` | 35m | Local 3-way shards are about 11.3m, 13.0m, and 5.1m. Hosted overhead should fit with room. Keep as-is. |
| `release-simulator` | 10m | Local simulator is short and pure Node. Keep as-is. |
| `full-release` | 45m | Local full release is about 29.9m. Hosted overhead could be meaningful but this lane is manual. Keep as-is until actual hosted timing proves otherwise. |

## Why No Timeout Change Is Justified

No remote job has been observed to fail or approach its timeout. Increasing timeouts preemptively would make failures slower to diagnose; decreasing them would risk false negatives on first hosted runs. The current values are conservative enough for the first remote evidence pass and maintain coverage without moving expensive work onto automatic pushes.

## Timeout Policy For First Hosted Evidence

Use this policy when Emmanuel captures the first GitHub Actions run:

1. If a job fails with a real failing command, investigate the command rather than increasing timeout.
2. If a job times out with no failing-test output, collect the last log lines and job duration.
3. If the timeout happened during setup/browser install, document whether GitHub-hosted runner dependency install was slow or stuck.
4. If the timeout happened during Playwright execution, identify the spec/test name before changing timeouts.
5. Rerun the exact job once if it looks transient.
6. Increase a timeout only when the command is healthy but consistently slower on hosted runners.

## Recommended Future Adjustments If Evidence Requires Them

Only make these changes after hosted evidence supports them:

| Evidence | Possible tiny CI-only adjustment |
| --- | --- |
| `fast-confidence` succeeds but regularly runs near 35m | Raise to 45m or split preview smoke into a separate fast job. |
| `release-shards` shard 2 approaches timeout | Raise release-shards timeout to 45m or revisit shard balance without deleting coverage. |
| `full-release` times out after healthy progress | Raise manual full-release timeout to 60m and keep it manual-only. |
| Browser install dominates runtime | Consider Playwright browser caching only after artifact/cache behavior is documented. |
| `smoke:preview` startup is slow but healthy | Increase `ASCENDANT_PREVIEW_TIMEOUT_MS` in CI env rather than weakening preview checks. |

Do not delete tests, skip assertions, or move heavy release work to automatic push runs to solve timeout pressure.

## Phase 4 Decision

No timeout change is made in v0.11.2 Phase 4. The existing workflow timeouts remain the safest first-pass values until authenticated GitHub Actions evidence is available.
