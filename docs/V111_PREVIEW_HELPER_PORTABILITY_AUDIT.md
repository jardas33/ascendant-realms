# v0.11.1 Preview Helper Portability Audit

Date: 2026-05-11

Scope: review `npm run smoke:preview` for Windows, Linux CI, and macOS portability. This phase changes only preview-smoke tooling/docs. It does not change gameplay, content, saves, tutorial behavior, campaign progression, visuals, runtime art, Vite build output, or Playwright e2e coverage.

## Helper Reviewed

```text
tools/smokePreview.ts
npm run smoke:preview
```

The helper starts a local Vite preview server for the already-built `dist/` output, runs a Playwright Chromium smoke through the production URL, records browser console/page errors, and shuts down the preview process it started.

## Current Default Behavior

| Area | Current behavior | Portability finding |
| --- | --- | --- |
| Preview launch | Runs local `node_modules/vite/bin/vite.js` through the current Node executable | Good cross-platform choice; avoids Windows `npm.cmd` wrapper spawning issues. |
| Host | Defaults to `127.0.0.1` | Good for local and hosted CI runners. |
| Port | Defaults to `4173` with `--strictPort` | Good because port conflicts fail clearly instead of silently switching URLs. |
| Browser | Playwright Chromium, headless | Matches e2e/visual QA browser family. |
| WebGL args | `--use-gl=angle`, `--use-angle=swiftshader`, `--enable-unsafe-swiftshader` | Matches project Playwright configs and helps headless GPU stability. |
| Console capture | Captures `console.error` and `pageerror` | Good release signal; does not hide browser failures. |
| Windows shutdown | Uses `taskkill /PID <pid> /T /F` | Good process-tree cleanup for Windows local runs. |
| Linux/macOS shutdown | Sends signals to the helper-owned process | Safe, but improved in this phase to target the helper-created process group. |

## Safe Portability Fixes Added

This phase keeps default behavior unchanged while improving failure clarity and process cleanup:

- Validates `ASCENDANT_PREVIEW_PORT` as an integer from `1` to `65535`.
- Adds `ASCENDANT_PREVIEW_TIMEOUT_MS` for slow CI preview startup, validated from `1000` to `300000` ms.
- Adds `ASCENDANT_PREVIEW_ACTION_TIMEOUT_MS` for slow browser actions, validated from `1000` to `120000` ms.
- Records child-process spawn errors and reports a clearer startup message.
- Starts a POSIX process group on Linux/macOS and terminates that helper-owned group during cleanup.
- Keeps Windows `taskkill /T /F` behavior unchanged.

These fixes do not alter the checked product flows.

## Environment Overrides

Use defaults for release evidence unless there is a documented CI or local conflict.

| Variable | Default | Use |
| --- | --- | --- |
| `ASCENDANT_PREVIEW_HOST` | `127.0.0.1` | Override only when a CI runner requires a different bind host. |
| `ASCENDANT_PREVIEW_PORT` | `4173` | Override only for documented port conflicts. |
| `ASCENDANT_PREVIEW_TIMEOUT_MS` | `60000` | Increase only when CI startup is slow but healthy. |
| `ASCENDANT_PREVIEW_ACTION_TIMEOUT_MS` | `30000` | Increase only when CI browser actions are slow but healthy. |

Invalid numeric overrides fail early with a direct message.

## Windows Compatibility

The helper should remain compatible with Windows because it:

- launches Vite through `process.execPath` rather than `npm.cmd`
- passes the local Vite CLI path as a file path argument instead of relying on shell parsing
- hides the child window
- pipes preview output with a `[preview]` prefix
- stops the process tree with `taskkill`

Latest local Windows evidence before this audit: `npm run smoke:preview` passed in the v0.11 final gate with 0 browser console errors.

## Linux CI Compatibility

The helper should be CI-friendly on Linux because it:

- avoids shell-specific command strings
- uses `127.0.0.1` and a strict port
- uses Playwright Chromium with the same GPU fallback args as the e2e config
- now creates and terminates a helper-owned process group
- exposes timeout env vars for slower hosted runners

The GitHub Actions workflow should still run:

```text
npx playwright install --with-deps chromium
npm run build
npm run smoke:preview
```

## macOS Compatibility

macOS should follow the same POSIX process-group path as Linux. This is not a primary CI target for the first workflow, but the helper does not rely on Linux-only shell syntax.

## Port Handling

The helper intentionally uses `--strictPort`. If port `4173` is occupied, the correct response is to fix the port conflict or explicitly set `ASCENDANT_PREVIEW_PORT`, not to silently smoke-test a different URL.

## Timeout Behavior

Timeouts now include the relevant URL and guidance to increase `ASCENDANT_PREVIEW_TIMEOUT_MS` only when the runner is slow but otherwise healthy. Assertion/action timeouts remain separate through `ASCENDANT_PREVIEW_ACTION_TIMEOUT_MS`.

## Console Error Capture

The helper fails on any recorded browser `console.error` or `pageerror`. That policy should remain strict because the command is a production-preview sanity check.

## Remaining Risks

- GitHub-hosted runners still need live validation after the workflow is pushed.
- Very constrained CI runners may need a larger preview startup timeout.
- Port conflicts should remain rare in isolated CI jobs but can still occur on shared developer machines.
- The helper does not replace full e2e release coverage, visual QA, simulator checks, or human review.

## Phase 2 Decision

`npm run smoke:preview` remains safe to include in a fast PR confidence workflow after `npm run build`, provided the workflow installs Playwright Chromium first and uploads artifacts only when helpful. Keep the helper as an explicit release/tooling check, not part of `npm test`.

