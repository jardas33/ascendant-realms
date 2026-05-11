# v0.11.2 Workflow Static Review

Date: 2026-05-11

Scope: inspect `.github/workflows/ci.yml` for likely syntax, path, timeout, cache, artifact, trigger, and coverage issues before any remote hosted-run evidence is available. This review is CI-only and does not change gameplay, content, saves, tutorial behavior, visuals, runtime art, campaign progression, or test coverage.

## Files Reviewed

```text
.github/workflows/ci.yml
package.json
playwright.config.ts
playwright.visual-qa.config.ts
tools/smokePreview.ts
docs/V111_CI_RELEASE_MATRIX_PLAN.md
docs/V111_CI_LOCAL_PARITY_CHECK.md
```

## Trigger Review

| Area | Finding |
| --- | --- |
| `pull_request` | Present. Runs fast confidence automatically for PRs. |
| `push` to `main` | Present. Runs fast confidence after main updates. |
| `workflow_dispatch` | Present. Exposes manual booleans for optional visual QA, release matrix, and full release. |
| Heavy lane guards | Manual jobs are guarded by `github.event_name == 'workflow_dispatch'` plus their boolean inputs. |
| Duplicate-run control | Concurrency is scoped by workflow and ref, with `cancel-in-progress: true`. This is acceptable for fast push/PR confidence and avoids stacked stale runs on the same ref. |

Decision: trigger shape matches v0.11.1's conservative plan. Heavy lanes are not automatic on every push.

## Permissions Review

```yaml
permissions:
  contents: read
```

This is the right first-pass permission level. The workflow only checks out code, installs dependencies, runs local commands, and uploads artifacts through the standard artifact action. No secrets, deployments, package publishing, issue writes, or paid-service integrations are required.

## Node, Cache, and Install Review

| Area | Finding |
| --- | --- |
| Node version | Uses Node 22, matching the current dev dependency generation and v0.11.1 docs. |
| npm cache | `actions/setup-node@v4` with `cache: npm` is safe and limited. |
| Dependency install | Uses `npm ci`, which is correct for CI reproducibility. |
| Playwright browser install | Uses `npx playwright install --with-deps chromium` in browser-running jobs. |
| Simulator job browser install | Not needed because `npm run playtest:sim` is pure Node/tsx and does not launch Playwright. |

No install-path issue is visible statically.

## Script Name Review

All workflow commands exist in `package.json`:

```text
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run test:e2e:smoke
npm run smoke:preview
npm run visual:qa
npm run test:e2e:release:shard1of3
npm run test:e2e:release:shard2of3
npm run test:e2e:release:shard3of3
npm run playtest:sim
npm run test:e2e:release
```

The workflow builds before `smoke:preview`, visual QA, release shards, and full release. That matches the local release flow and keeps preview smoke against production `dist/`.

## Playwright Config Review

| Config | CI-relevant finding |
| --- | --- |
| `playwright.config.ts` | Uses Chromium, single worker, trace/screenshot/video retained on failure, `retries: process.env.CI ? 1 : 0`, Vite dev server with `reuseExistingServer: !process.env.CI`, and a 120s web-server timeout. |
| `playwright.visual-qa.config.ts` | Uses Chromium, single worker, 120s test timeout, no retries, failure artifacts retained, and the same WebGL launch args. |

The workflow sets `CI: true`, so Playwright will start fresh dev servers and apply CI retries for regular e2e lanes. Visual QA remains no-retry and manual-only.

## Artifact Review

| Job | Artifact paths | Finding |
| --- | --- | --- |
| `fast-confidence` | `test-results/`, `playwright-report/` | Useful diagnostics on failure; `if-no-files-found: ignore` avoids false failures when there are no artifacts. |
| `visual-qa` | `visual-qa/latest/` plus Playwright diagnostics | Good manual screenshot artifact path. |
| `release-shards` | `test-results/`, `playwright-report/` | Good shard-specific artifact names through matrix name. |
| `full-release` | `test-results/`, `playwright-report/` | Good full-lane diagnostics. |
| `release-simulator` | none | Acceptable for now; simulator prints deterministic summary in logs and does not produce required artifacts. |

Retention is 7 days, which is appropriate for first-pass diagnostic artifacts and avoids long-lived bulky files.

## Timeout Review

| Job | Timeout | Static finding |
| --- | ---: | --- |
| `fast-confidence` | 35 minutes | Reasonable for first hosted PR/push confidence with npm install, browser install, unit/build/validation, smoke e2e, and preview smoke. |
| `visual-qa` | 20 minutes | Reasonable for optional 18-screenshot visual QA plus setup. |
| `release-shards` | 35 minutes | Reasonable first pass for 3-way shards based on local v0.11.1 timing plus hosted-run overhead. |
| `release-simulator` | 10 minutes | Reasonable; local simulator is short. |
| `full-release` | 45 minutes | Reasonable first pass for a slow manual major-freeze lane. |

No timeout change is justified without hosted-run evidence.

## Static Risk Review

| Risk | Review result |
| --- | --- |
| YAML syntax | The workflow structure is straightforward GitHub Actions YAML. Remote parse still needs GitHub UI confirmation because local authenticated Actions validation is unavailable. |
| Manual jobs running on push | Guards prevent this. |
| Coverage weakening | No coverage is removed or skipped. Fast lane is additive to existing local gates. |
| Secrets or paid services | None. |
| Runtime app behavior | None changed. |
| Runtime art/content/save behavior | None changed. |
| Artifact path false failures | `if-no-files-found: ignore` prevents empty diagnostics from failing jobs. |
| Preview smoke requiring `dist/` | Build runs before preview smoke. |

## No-Change Decision

No tiny workflow fix is justified from static review alone. The workflow matches the v0.11.1 plan, all referenced scripts exist, browser jobs install Chromium with dependencies, heavy lanes remain manual, and artifact paths use safe ignore behavior when no diagnostic files exist.

The next safe step is local tooling verification:

```text
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run test:e2e:smoke
npm run smoke:preview
git diff --check
```

Any future YAML timeout, artifact, or environment change should be based on hosted GitHub Actions evidence rather than prediction.
