# v0.11.1 CI Release Matrix Plan

Date: 2026-05-11

Scope: design a conservative CI release matrix before adding workflow files. This plan does not change gameplay, content, saves, tutorial behavior, campaign progression, visuals, runtime art, tests, scripts, or Playwright configuration.

## Design Principles

- Keep the local release gate authoritative.
- Add CI as a repeatability aid, not a reason to remove local checks.
- Use fast feedback on pull requests and manual triggers for expensive lanes.
- Prefer 3-way release shards in CI because the 2-way split remains lopsided.
- Upload artifacts when they help diagnose failures or review screenshots.
- Do not require secrets, paid services, deployment, desktop packaging, or asset services.
- Do not skip meaningful coverage to make CI look green.

## Tier 1 - PR / Fast Confidence

Recommended triggers:

- `pull_request`
- `push` to `main`
- optional `workflow_dispatch` for manual reruns

Commands:

```text
npm ci
npx playwright install --with-deps chromium
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run test:e2e:smoke
npm run smoke:preview
```

What it protects:

- TypeScript and production bundle creation.
- Pure rules and unit behavior.
- Content/data validation.
- Non-runtime art-intake metadata gate.
- Main browser smoke flows, including Tutorial / Proving Grounds no-save/no-reward coverage.
- Production `dist/` boot through `npm run smoke:preview`.
- Browser console errors in both smoke and preview paths.

Expected runtime:

- Usually under 10 minutes on a healthy runner, dominated by e2e smoke.

Artifact policy:

- Upload `test-results/` only when present.
- Keep retention short, about 7 days.
- Do not upload `dist/` by default; rebuild on the checked commit.

## Tier 2 - Visual / QA Optional Manual

Recommended triggers:

- `workflow_dispatch` only for the first workflow.
- Optionally add a manual input such as `run_visual_qa`.

Commands:

```text
npm ci
npx playwright install --with-deps chromium
npm run build
npm run visual:qa
```

What it protects:

- Optional screenshot capture flow.
- Human-review screenshot index.
- Browser console error capture during visual QA.
- Desktop/tablet/mobile viewport coverage metadata.

What it does not do:

- It does not approve visual quality.
- It does not perform pixel-perfect diffs.
- It does not approve candidate art for runtime.

Artifact policy:

- Upload `visual-qa/latest/` when generated.
- Upload `test-results/` when present.
- Use a short retention window, about 7 days.
- Treat screenshots as human review artifacts, not source/license proof.

## Tier 3 - Release Gate Manual

Recommended triggers:

- `workflow_dispatch` only.
- Use before release freezes, long-goal final gates, or risky technical branches.

Matrix commands:

```text
npm run test:e2e:release:shard1of3
npm run test:e2e:release:shard2of3
npm run test:e2e:release:shard3of3
```

Additional command:

```text
npm run playtest:sim
```

Optional major-freeze command:

```text
npm run test:e2e:release
```

Recommended implementation:

- Use one matrix job for the 3-way Playwright shards.
- Keep `workers: 1` inside each shard through the existing Playwright config.
- Run `npm ci` and `npx playwright install --with-deps chromium` in each matrix job.
- Run `npm run build` in each shard job for first-pass simplicity, or add a build artifact only in a later dedicated optimization pass.
- Run `npm run playtest:sim` in a separate release-support job.
- Do not run the full release lane automatically in the same workflow unless manually requested.

Expected runtime:

- Shard 1 of 3: about 11-12 minutes locally.
- Shard 2 of 3: about 13 minutes locally.
- Shard 3 of 3: about 5 minutes locally.
- CI timing may differ, but the 3-way split should be much better balanced than the 2-way split.

## Trigger Strategy

| Workflow mode | Trigger | Jobs |
| --- | --- | --- |
| Fast confidence | `pull_request`, `push` to `main`, `workflow_dispatch` | Tier 1 only |
| Manual visual QA | `workflow_dispatch` input | Tier 2 |
| Manual release matrix | `workflow_dispatch` input | Tier 3 |

Avoid running Tier 2 and Tier 3 automatically on every push. They are useful, but they create unnecessary CI time and artifact noise for routine docs/tooling changes.

## Matrix Strategy

Recommended matrix values:

```yaml
matrix:
  shard:
    - name: shard-1-of-3
      command: npm run test:e2e:release:shard1of3
    - name: shard-2-of-3
      command: npm run test:e2e:release:shard2of3
    - name: shard-3-of-3
      command: npm run test:e2e:release:shard3of3
```

Use `fail-fast: false` so all shards report results even when one fails. A single failed shard still fails the release gate, but collecting all failures makes debugging less sequential.

## Cache Strategy

First workflow:

- Use `actions/setup-node` with `cache: npm`.
- Use `npm ci`, not `npm install`.
- Do not cache `dist/`, `visual-qa/latest/`, `test-results/`, `playwright-report/`, or candidate art.

Future optimization, only if needed:

- Consider Playwright browser cache after observing GitHub runner runtime.
- Consider a build artifact shared with release shards only after preview/dev serving strategy is revisited.

## Artifact Strategy

Upload on failure or always when review evidence matters:

| Artifact | When | Retention |
| --- | --- | --- |
| `test-results/` | always if present for browser jobs | 7 days |
| `playwright-report/` | if a future reporter creates it | 7 days |
| `visual-qa/latest/` | visual QA job only | 7 days |
| `bundle-analysis/` | only if a future manual bundle-analysis job is added | 7 days |

Do not upload runtime art candidate binaries unless a future source/license review explicitly approves that as review evidence.

## Timeout Strategy

Suggested job timeouts:

| Job | Timeout |
| --- | ---: |
| Fast confidence | 25 minutes |
| Visual QA | 15 minutes |
| Each release shard | 25 minutes |
| Simulator | 10 minutes |

Use command-specific failure output before changing timeouts. If a job times out without failing-test output, rerun the same lane once and document whether the issue was runner slowness, port conflict, or stale process cleanup.

`smoke:preview` can use:

```text
ASCENDANT_PREVIEW_TIMEOUT_MS=120000
```

only if CI startup proves healthy but slow.

## What To Skip And Why

| Skip by default | Why |
| --- | --- |
| Full release on every PR | Too slow and duplicates the cheaper smoke path for routine work. |
| 2-way shards in new CI | Coverage-preserving but lopsided; keep local scripts for compatibility. |
| Visual QA on every PR | Optional human-review artifacts; not a blocker for unrelated changes. |
| Bundle analyzer on every PR | Measurement artifact, not a routine correctness gate. |
| Dist artifact sharing | Extra workflow complexity; not needed until CI runtime evidence justifies it. |
| Browser deployment | Project does not need external services or secrets for release verification. |

## Avoiding Duplicate Expensive Runs

- Do not run full release and all three release shards automatically in the same workflow.
- Do not run visual QA automatically after every fast confidence job.
- Do not run both 2-way and 3-way shards in CI unless manually investigating shard behavior.
- Keep the local final gate broader than the routine CI gate.

## Recommended First Workflow

Add a single `.github/workflows/ci.yml` with:

- `fast-confidence` on pull requests, pushes to `main`, and manual dispatch.
- `visual-qa` behind a manual input.
- `release-shards` behind a manual input and a 3-way matrix.
- `simulator` behind the same manual release input.
- artifact uploads for browser outputs.

This keeps CI discoverable and conservative while preserving local release authority.

