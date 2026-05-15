# v0.11 Release Lane Reliability Plan

Date: 2026-05-11

Scope: define how Ascendant Realms should use the current Playwright release lanes, how to handle timeouts and transients, and how to keep release verification useful without reducing coverage. This plan does not change tests, scripts, Playwright config, gameplay, content, save format, tutorial behavior, visual assets, or campaign progression.

## Current Release Lanes

| Lane | Command | Current count | Latest known runtime | Intended use |
| --- | --- | ---: | --- | --- |
| Fast smoke | `npm run test:e2e:smoke:fast` | 6 tests | About 2-3m locally | Automatic GitHub push/PR browser confidence. |
| Full smoke | `npm run test:e2e:smoke` | 12 tests | About 5m locally | Local/manual smoke confidence with extended campaign/skirmish flows. |
| Full release | `npm run test:e2e:release` | 67 tests | About 29.0m | Major checkpoints, final gates, and full pre-freeze confidence. |
| 2-way shard 1 | `npm run test:e2e:release:shard1` | 55 tests | About 24.3m | Legacy 2-way split; currently heavy. |
| 2-way shard 2 | `npm run test:e2e:release:shard2` | 12 tests | About 4.8m | Legacy 2-way split; currently smoke-sized. |
| 3-way shard 1 | `npm run test:e2e:release:shard1of3` | 28 tests | About 11.5m | Deep-flow family. |
| 3-way shard 2 | `npm run test:e2e:release:shard2of3` | 27 tests | About 12.9m | Layout plus enemy-pressure family. |
| 3-way shard 3 | `npm run test:e2e:release:shard3of3` | 12 tests | About 4.9m | Smoke family. |
| Hosted release groups | `npm run test:e2e:release:hosted:*` | 67 tests across 6 explicit groups | Pending hosted rerun | Manual GitHub Actions release matrix against production preview. |
| Layout | `npm run test:e2e:layout` | 25 tests | About 12.5m recently | Responsive UI/HUD/tutorial overlay confidence. |
| Visual QA | `npm run visual:qa` | 5 capture tests | About 4m recently | Optional indexed screenshots and console-error capture for human review. |

## Recommended Use

Use the smallest lane that protects the changed surface during implementation, then run broader gates at checkpoint boundaries.

| Work type | Recommended verification |
| --- | --- |
| Docs-only | `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `git diff --check` |
| Script/test tooling | Docs-only gate plus `npm run test:e2e:smoke:fast`; add full smoke when the touched surface affects campaign/skirmish flows |
| Tutorial or layout work | Add `npm run test:e2e:layout`; add `npm run visual:qa` when screenshots matter |
| Visual-intake metadata | Docs-only gate plus `npm run validate:art-intake` |
| Content/data/save/campaign work | Add focused unit tests, `npm run test:e2e:smoke`, relevant deep/release coverage, and `npm run playtest:sim` when campaign battle outcomes can change |
| CI long checks | Prefer the explicit hosted release groups in GitHub Actions; keep local 3-way shards for local/manual cross-checks |
| Final freeze | Run the full final gate, including smoke, full release, 2-way shards, 3-way shards, visual QA, simulator, diff check, and production preview smoke |

The full release lane should remain available even when 3-way shards are used in CI. The shards prove distributability and help CI scheduling; the full lane proves the suite also works in the single-command release path.

## v0.11.1 CI Dry-Run Follow-Up

v0.11.1 adds `.github/workflows/ci.yml` as a conservative first GitHub Actions workflow:

- automatic fast confidence on pull requests and pushes to `main`
- manual optional visual QA with screenshot artifact upload
- manual hosted release group matrix plus simulator
- manual full-release e2e lane for major freezes
- Node 22, `npm ci`, Playwright Chromium install, npm cache, no secrets, and no paid services

v0.11.5 changes the automatic push/PR browser lane from full smoke to `npm run test:e2e:smoke:fast` after hosted evidence showed the full smoke file is too heavy and context-sensitive for every push. Full smoke remains available locally and through release/manual lanes.

v0.11.8 keeps the manual 3-way release matrix unchanged but hardens the long hosted paths: deep-flow synthetic saves no longer use raw reloads, app-root setup navigation retries same-URL interruption/timeout cases before proving the real main menu, and reported release-path clicks use a non-forced actionability helper. A scoped 120s budget is allowed only for the seeded Cinderfen menu/campaign layout readability test that reproduced the shard-2 timeout pattern.

v0.11.9 changes only the hosted manual release matrix shape after remote run #13 showed the v0.11.8 helper fixes were still not enough for GitHub-hosted wall-clock limits. The workflow now runs six hosted shard jobs with Playwright test-level sharding, single-worker execution inside each shard, and a 45-minute per-shard timeout. Local `npm run test:e2e:release`, the 2-way shards, and the 3-way shards remain available and unchanged.

v0.11.10 supersedes the v0.11.9 hosted shard shape after remote run #15 showed the native 6-way split still failed across all hosted shards. The workflow now runs six explicit hosted groups: deep meta, deep battle, deep campaign plus pressure, layout core, layout Cinderfen, and smoke. This removes hosted `--fully-parallel` test-level sharding while preserving the same 67 release tests, the 45-minute manual job timeout, local full release, local 2-way shards, and local 3-way shards.

v0.11.11 supersedes the hosted environment for those explicit groups after remote run #17 showed all groups still failed against Vite dev server. Hosted release groups now use `playwright.hosted-release.config.ts` and `npm run preview:hosted`, so GitHub-hosted release matrix jobs run against production preview on `127.0.0.1:5173` while preserving the same 67 release tests and local full release lanes.

The CI workflow does not replace the local final gate. Treat the first pushed workflow run as a dry-run validation of GitHub syntax, runner timing, artifact behavior, Playwright browser installation, and `smoke:preview` portability.

## Timeout Policy

Treat a timeout differently from a test assertion failure.

1. If the command times out and there is no failing-test output, inspect whether a dev server, preview server, or Playwright browser process was left behind.
2. Clean up only repo-local or clearly related processes. Do not blindly kill unrelated user Node processes.
3. Rerun the same command with a longer command timeout when the previous output showed progress but the harness limit expired.
4. If the rerun passes, document the first timeout as a command-limit or process-cleanup issue in `LLM_GAME_HANDOFF.md`.
5. If the rerun times out again at the same point, treat it as a real reliability issue and investigate the focused spec first.

Timeouts that still show a specific failing assertion, stack trace, or test name should follow the transient/failure policy below instead of being treated as pure command-limit events.

## Transient Policy

Use one focused retry path before changing code:

1. Rerun the exact failed test once with the same reporter.
2. If the targeted rerun passes, rerun the relevant lane once.
3. If the relevant lane passes, document the transient in `LLM_GAME_HANDOFF.md` and continue.
4. If either rerun fails, investigate the real failure.
5. Do not change gameplay, waits, selectors, or assertions merely to hide a flaky symptom.

Examples:

```text
npx playwright test tests/e2e/smoke.spec.ts -g "tutorial entry launches" --reporter=line
npm run test:e2e:smoke
```

```text
npx playwright test tests/e2e/layout.spec.ts -g "tutorial entry and first objective overlay" --reporter=line
npm run test:e2e:layout
```

## Process Cleanup Policy

The project uses Vite dev and preview servers during browser verification. Leftover processes can create port conflicts or keep a helper command alive after checks finish.

Safe cleanup principles:

- Prefer helpers that own the child process and shut down the full process tree when the run ends.
- Before manual cleanup, identify process command lines and ports.
- Clean only processes tied to the current repo, Playwright run, Vite dev server, or Vite preview server.
- Avoid broad `node` process termination on a shared developer machine.
- After cleanup, confirm the target port is free or the next command can reuse the intended server.

Useful ports:

| Port | Owner |
| ---: | --- |
| `5173` | Vite dev server used by Playwright e2e and visual QA |
| `4173` | Vite preview server used by production preview smoke |

## Port Conflict Policy

If `5173` or `4173` is occupied:

1. Check whether it is an intended existing server from this repo.
2. If it is the intended server and local Playwright reuse is enabled, rerun the lane normally.
3. If it is stale or from a failed helper, stop only that process tree.
4. If it belongs to unrelated work, use a different preview port only for a manual investigation and document the deviation.

## What Not To Do

Do not improve release runtime by:

- deleting tests for speed
- replacing behavior checks with fake helper assertions
- reducing full release coverage
- disabling meaningful failure artifacts just to shorten runs
- changing gameplay or content so tests become easier
- making visual QA pixel-perfect
- raising Vite warning thresholds to hide the known Phaser vendor warning
- changing Playwright workers or parallelism without a dedicated stability pass

## Recommended Safe v0.11 Improvements

The v0.11 implementation should stay in the reliability/documentation lane:

- Add or document a production preview smoke helper that owns preview startup, browser checks, console-error capture, and process-tree shutdown.
- Document visual QA output behavior and, if tiny and safe, improve the screenshot index metadata or summary text.
- Refresh bundle/performance facts after v0.10.
- Add a developer command guide that maps work type to the correct verification gate.
- Tighten `RELEASE_CHECKLIST.md` so final verification is clear without making routine iteration unnecessarily heavy.

## Success Criteria

The release lane process is healthy when:

- fast smoke remains the automatic GitHub push/PR browser gate
- full smoke remains available for local/manual smoke confidence
- explicit hosted release groups remain the preferred GitHub Actions release-matrix split
- local 3-way shards remain available for local/manual cross-checks
- full release remains available and green before major checkpoints
- timeouts are documented and rerun with evidence
- process cleanup is precise and does not disturb unrelated work
- no test coverage is removed or weakened for speed
