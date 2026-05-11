# v0.11.2 Preview Helper Remote Portability Review

Date: 2026-05-11

Scope: review `npm run smoke:preview` for GitHub-hosted runner portability after the v0.11.1 helper improvements. This phase does not change gameplay, content, saves, tutorial behavior, visuals, runtime art, campaign progression, or test coverage.

## Inputs Reviewed

```text
tools/smokePreview.ts
.github/workflows/ci.yml
docs/V11_PREVIEW_SMOKE_RELIABILITY_NOTES.md
docs/V111_PREVIEW_HELPER_PORTABILITY_AUDIT.md
docs/V112_GITHUB_ACTIONS_EVIDENCE_REPORT.md
```

Remote hosted-run evidence is not available from this environment, so this review uses static helper inspection plus local v0.11.2 evidence.

## Helper Behavior

The helper:

- starts Vite preview for the already-built `dist/` output;
- uses the local Vite CLI through `process.execPath`;
- binds to `127.0.0.1` by default;
- uses strict port `4173` by default;
- launches Playwright Chromium headlessly;
- applies the project SwiftShader/ANGLE WebGL launch args;
- verifies production menu, tutorial launch/exit, New Campaign, Continue Campaign, and Skirmish Setup;
- captures browser `console.error` and `pageerror`;
- fails if browser console/page errors are recorded;
- shuts down the preview process it started.

## Remote Portability Checks

| Area | Current support | Review |
| --- | --- | --- |
| Host | `ASCENDANT_PREVIEW_HOST`, default `127.0.0.1` | Good for GitHub-hosted Linux runners and local runs. |
| Port | `ASCENDANT_PREVIEW_PORT`, default `4173`, validated `1..65535` | Good. Strict port makes conflicts fail clearly. |
| Startup timeout | `ASCENDANT_PREVIEW_TIMEOUT_MS`, default `60000`, validated `1000..300000` | Good first pass. Increase only if hosted evidence shows slow but healthy startup. |
| Browser action timeout | `ASCENDANT_PREVIEW_ACTION_TIMEOUT_MS`, default `30000`, validated `1000..120000` | Good separation from server startup timeout. |
| Vite launch | `process.execPath` plus local Vite CLI path | Good cross-platform choice; avoids shell/npm wrapper differences. |
| Linux shutdown | POSIX process group with TERM then KILL fallback | Good hosted-run behavior for helper-owned child process cleanup. |
| Windows shutdown | `taskkill /PID /T /F` | Good local Windows behavior. |
| GPU/WebGL | Chromium args `--use-gl=angle`, `--use-angle=swiftshader`, `--enable-unsafe-swiftshader` | Matches e2e and visual QA configs. |
| Console errors | Captures `console.error` and `pageerror` and fails on any captured issue | Correctly strict for production preview smoke. |
| Build requirement | Workflow runs `npm run build` before `npm run smoke:preview` | Correct; helper intentionally tests production `dist/`. |

## Local Evidence

Latest local v0.11.2 helper evidence:

```text
npm run smoke:preview
PASS in about 25s
URL: http://127.0.0.1:4173/
Verified: title, Prototype v0.3 / Cinderfen Route Baseline, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup
Browser console errors: 0
```

This is local Windows evidence, not hosted Linux evidence. It confirms the helper still works after v0.11.1, but it does not prove GitHub-hosted behavior.

## Hosted Runner Evidence Still Needed

Emmanuel should confirm from GitHub Actions UI:

- the `Production preview smoke` step starts Vite preview;
- the helper reaches `http://127.0.0.1:4173/`;
- the step prints all expected `PASS:` lines;
- the step reports `Browser console errors: 0`;
- the job exits cleanly without hanging after the helper finishes;
- no process cleanup warning or port conflict appears in logs.

## When To Change The Helper

Do not change helper checks unless remote evidence points to a concrete failure. Possible evidence-driven adjustments:

| Hosted evidence | Tiny safe response |
| --- | --- |
| Healthy preview starts just over 60s | Set a larger `ASCENDANT_PREVIEW_TIMEOUT_MS` in workflow env. |
| Healthy browser actions exceed 30s | Set a larger `ASCENDANT_PREVIEW_ACTION_TIMEOUT_MS` in workflow env. |
| Port conflict on hosted runner | Change CI env to a different port, document the conflict, keep `--strictPort`. |
| Linux process remains after step | Revisit POSIX process-group cleanup with job logs. |
| Browser console error appears | Treat as real failure; do not suppress console capture. |

## No-Change Decision

No helper or workflow env change is made in this phase. The helper already has the portability controls v0.11.1 intended, the local v0.11.2 preview smoke passes, and hosted-run evidence is unavailable. Changing timeout/env defaults now would be speculative.
