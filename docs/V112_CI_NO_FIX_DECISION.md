# v0.11.2 CI No-Fix Decision

Date: 2026-05-11

Scope: decide whether v0.11.2 should make any tiny CI-only workflow/helper tuning after the capability, evidence, static workflow, timeout, preview-helper, artifact, and manual-checklist phases. This phase does not change gameplay, content, saves, tutorial behavior, visuals, runtime art, campaign progression, coverage strength, workflow YAML, or helper code.

## Decision

No CI-only code, YAML, timeout, artifact, or helper change is made in v0.11.2 Phase 8.

## Why

The earlier phases found no concrete fixable problem:

| Review | Result |
| --- | --- |
| Remote CI capability | Authenticated Actions inspection is unavailable here. Limitation documented. |
| GitHub Actions evidence | No hosted-run evidence could be fetched. Limitation report created. |
| Static workflow review | Referenced scripts exist, manual jobs are guarded, browser jobs install Chromium, artifact paths are safe. |
| Timeout review | Existing values are conservative enough for first hosted evidence; no timeout failure is known. |
| Preview helper remote review | Helper has host/port/timeout env controls, Chromium GPU args, console capture, and process cleanup. |
| Artifact review | Workflow upload paths match local output/diagnostic folders and use `if-no-files-found: ignore`. |
| Manual checklist | Emmanuel now has a concrete GitHub UI procedure for collecting the missing hosted evidence. |

Making workflow or helper changes without hosted evidence would be speculation. The safer release-reliability move is to preserve the v0.11.1 workflow exactly, document the access limitation, and wait for real GitHub UI evidence before tuning.

## Explicit Non-Changes

No change was made to:

- `.github/workflows/ci.yml`;
- `tools/smokePreview.ts`;
- `package.json`;
- Playwright configs;
- e2e tests;
- visual QA tests;
- app source;
- content/data;
- save format;
- runtime art;
- release coverage.

## What Would Justify A Future Tiny Fix

Only these kinds of real hosted evidence should trigger a follow-up CI-only patch:

- GitHub Actions workflow syntax failure;
- Node or npm setup failure caused by the workflow;
- Playwright Chromium install failure on hosted Linux;
- `smoke:preview` timeout despite healthy preview startup;
- hosted port conflict requiring an explicit CI-only preview port env;
- process cleanup hang after preview smoke completes;
- artifact path issue that fails an otherwise healthy job;
- release shard timeout after steady test progress;
- manual jobs running automatically on push unexpectedly.

The response should remain tiny and CI-only. Do not delete tests, reduce assertions, skip real checks, or change app behavior.

## Verification Required For This No-Fix Decision

This phase still uses the tooling-change verification level because the decision concerns CI/tooling behavior:

```text
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run test:e2e:smoke
npm run smoke:preview
git diff --check
```
