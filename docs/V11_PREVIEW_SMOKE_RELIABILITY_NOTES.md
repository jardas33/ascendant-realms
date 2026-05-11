# v0.11 Preview Smoke Reliability Notes

Date: 2026-05-11

Scope: make production preview smoke repeatable after v0.10's manual preview pass exposed child-process cleanup friction. This phase adds tooling only. It does not change gameplay, content, tutorial behavior, save format, campaign progression, visual assets, runtime art, Vite chunking, or Playwright e2e coverage.

## Existing State

Before v0.11, preview smoke was documented as a manual or ad hoc Playwright/Browser pass:

```text
npm run preview
```

The v0.10 final gate passed at `http://127.0.0.1:4173/`, verifying:

- document title `Ascendant Realms`
- visible `Prototype v0.3`
- visible `Cinderfen Route Baseline`
- Tutorial / Proving Grounds launch and exit
- New Campaign reaching Campaign Map
- Continue Campaign reaching Campaign Map
- Skirmish Setup opening
- zero browser console errors

The first v0.10 harness attempt timed out because the preview child process stayed alive after checks. Cleaning repo-local preview processes and rerunning with explicit process-tree shutdown passed.

## v0.11 Helper

Added:

```text
npm run smoke:preview
```

Implementation:

```text
tsx tools/smokePreview.ts
```

The helper:

1. Starts Vite preview on `http://127.0.0.1:4173/` with `--strictPort`.
2. Waits for the server before opening Chromium.
3. Launches Chromium with the same SwiftShader/ANGLE arguments used by the Playwright configs.
4. Clears local storage for a clean first menu check.
5. Verifies the title and main menu release copy.
6. Launches Tutorial / Proving Grounds and exits back to the menu.
7. Starts a New Campaign and reaches Campaign Map.
8. Reloads the preview URL, uses Continue Campaign, and reaches Campaign Map.
9. Reloads the preview URL, opens Skirmish Setup, and confirms it is visible.
10. Captures browser `console.error` and `pageerror` events.
11. Fails if any browser console errors are recorded.
12. Shuts down only the preview process tree it started.

The helper intentionally does not run as part of `npm test`. It is a release/final-gate sanity check for the built `dist/` output.

Implementation note: the helper starts Vite through the local Vite CLI using the current Node executable. An initial draft spawned `npm.cmd` directly on Windows, which failed before launching preview with `spawn EINVAL`; the final helper avoids that wrapper and passed locally.

## Configuration

Default target:

```text
http://127.0.0.1:4173/
```

Optional environment overrides:

| Variable | Purpose |
| --- | --- |
| `ASCENDANT_PREVIEW_HOST` | Override the preview host. Defaults to `127.0.0.1`. |
| `ASCENDANT_PREVIEW_PORT` | Override the preview port. Defaults to `4173`. |

Use the defaults for release-gate evidence unless there is a documented port conflict.

## Failure Meanings

| Failure | Likely meaning | First response |
| --- | --- | --- |
| `Preview server exited before smoke checks started` | `dist/` missing, preview startup failed, or port conflict under `--strictPort` | Run `npm run build`, check port `4173`, rerun |
| Timeout waiting for preview URL | Preview server hung or port is blocked | Inspect preview output and port owner |
| Missing title/menu copy | Production build did not boot to the expected main menu | Treat as release-blocking |
| Tutorial launch/exit failure | Production build cannot run the tutorial shell | Treat as release-blocking |
| New/Continue Campaign failure | Production save/menu flow is broken | Treat as release-blocking |
| Skirmish Setup failure | Production menu route is broken | Treat as release-blocking |
| Browser console errors > 0 | Production-only browser error or WebGL launch issue | Inspect exact console message before changing code |

## Process Cleanup Policy

The helper owns the preview server it starts. On Windows it stops that tree with `taskkill /PID <child> /T /F`; on other platforms it sends a termination signal to the started child process. It should not terminate unrelated Node processes.

If a preview run still leaves a process behind:

1. Inspect the owner of port `4173`.
2. Stop only a process tied to this repo's Vite preview run.
3. Rerun `npm run smoke:preview`.
4. Document any repeated cleanup issue in `LLM_GAME_HANDOFF.md`.

## What This Does Not Replace

`npm run smoke:preview` does not replace:

- `npm run test:e2e:smoke`
- `npm run test:e2e:release`
- release shards
- `npm run visual:qa`
- `npm run playtest:sim`
- human visual review

It is a production-build sanity layer for the already-built app.

## Phase 3 Verification

Required after this tooling change:

```text
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run test:e2e:smoke
npm run smoke:preview
git diff --check
```

Local Phase 3 result:

```text
npm run smoke:preview
PASS: http://127.0.0.1:4173/
Verified title, Prototype v0.3 / Cinderfen Route Baseline menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup, and 0 browser console errors.
Preview process tree was shut down by the helper.
```
