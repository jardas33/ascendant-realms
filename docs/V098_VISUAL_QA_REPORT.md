# v0.98 Visual QA Report

Status: passed during closeout.

## Added Coverage

v0.98 adds eight deterministic visual-QA screenshots:

- hero overview at 1920x1080;
- hero overview at 1600x900;
- hero overview at 1366x768;
- Stronghold rescue at 1920x1080;
- Retinue rescue at 1600x900;
- campaign Inventory action at 1366x768;
- Results progression summary at 1920x1080;
- expanded Results details at 1366x768.

## Acceptance

The new captures check for no visible horizontal overflow on the key v0.98 surfaces. Final closeout preserved the full visual-QA set:

```text
npm run visual:qa - PASS, 14 tests / 126 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 126 screenshots / 7 contact sheets.
```

The first visual-QA run caught a v0.98 test-locator bug: the Results expanded-details click used a broad `summary` selector that also matched nested accordions. The test now targets the exact `Show Full Battle Details` summary, and the full visual-QA rerun passed.

## Boundary

No art was generated or imported.
