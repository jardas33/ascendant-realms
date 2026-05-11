# v0.11.2 CI Artifact Remote Review

Date: 2026-05-11

Scope: review whether GitHub Actions artifacts from the v0.11.1 workflow are likely useful and correctly scoped. This phase does not change gameplay, content, saves, tutorial behavior, visuals, runtime art, campaign progression, source/license status, or test coverage.

## Remote Artifact Evidence

Remote artifact evidence is not available from this environment because authenticated GitHub Actions inspection is unavailable and unauthenticated Actions API access returns `404 Not Found`.

This review therefore records expected artifact behavior from the workflow and local output structure. Emmanuel should confirm actual artifact presence in the GitHub UI after an authenticated workflow run.

## Workflow Artifact Uploads

| Job | Artifact name | Paths | Retention | Expected use |
| --- | --- | --- | ---: | --- |
| `fast-confidence` | `playwright-fast-confidence` | `test-results/`, `playwright-report/` | 7 days | Failure diagnostics for smoke/preview problems. |
| `visual-qa` | `visual-qa-latest` | `visual-qa/latest/` | 7 days | Manual screenshot review package when visual QA is intentionally run. |
| `visual-qa` | `playwright-visual-qa` | `test-results/`, `playwright-report/` | 7 days | Playwright diagnostics if visual QA fails. |
| `release-shards` | `playwright-release-${{ matrix.name }}` | `test-results/`, `playwright-report/` | 7 days | Shard-specific diagnostics. |
| `full-release` | `playwright-full-release` | `test-results/`, `playwright-report/` | 7 days | Full release diagnostics. |

All artifact uploads use `if-no-files-found: ignore`, so an empty diagnostics folder should not fail a healthy job. This is appropriate because Playwright only creates traces/screenshots/videos on failure under the current config.

## Local Output Structure

Current local generated visual QA folder:

```text
visual-qa/latest/
  index.md
  asset-gallery-desktop.png
  campaign-map-desktop.png
  campaign-route-complete-desktop.png
  cinderfen-crossing-desktop.png
  cinderfen-crossing-pressure-desktop.png
  cinderfen-crossing-shrine-desktop.png
  cinderfen-crossing-tablet.png
  cinderfen-watch-desktop.png
  cinderfen-watch-pressure-desktop.png
  hero-inventory-desktop.png
  main-menu-desktop.png
  main-menu-mobile.png
  main-menu-tablet.png
  preview-smoke-tutorial-gameplay.png
  results-defeat-desktop.png
  results-victory-desktop.png
  skirmish-setup-desktop.png
  tutorial-desktop.png
  tutorial-mobile.png
```

The visual QA index includes:

- screenshot count;
- browser console error count;
- viewport coverage;
- per-capture file names and notes;
- a reminder that screenshots are review artifacts, not pixel-perfect baselines.

`visual-qa/` is ignored by git, so generated screenshots do not become source-controlled runtime art.

## Playwright Diagnostic Paths

Local diagnostic folders:

| Path | Local status | Review |
| --- | --- | --- |
| `test-results/` | Present with `.last-run.json` | Safe to upload when present. Failure traces/screenshots/videos would live here. |
| `playwright-report/` | Not present | Safe to list with `if-no-files-found: ignore`. |
| `blob-report/` | Ignored but not uploaded | Not currently part of the workflow. Fine unless reporter config changes later. |

## Source and License Boundary

Artifacts are temporary CI evidence. They are not:

- runtime assets;
- production-approved art;
- source/license proof;
- candidate style-frame intake files;
- a reason to commit generated screenshot binaries.

Visual QA screenshots can contain current prototype visuals and should remain short-retention review artifacts only.

## Human GitHub UI Checklist

When authenticated Actions access is available, Emmanuel should check:

1. For a normal push, `fast-confidence` may upload no artifact if everything passes and no diagnostic files exist. That is acceptable.
2. If `fast-confidence` fails, download `playwright-fast-confidence` and inspect `test-results/`.
3. When manual visual QA is triggered, confirm `visual-qa-latest` includes `index.md` and 18 PNG files.
4. When manual release shards are triggered, confirm each shard artifact name includes its shard name if there are diagnostics.
5. Confirm artifact retention shows 7 days.
6. Confirm no candidate art binaries or source/license intake files are uploaded unexpectedly.

## No-Change Decision

No artifact YAML change is justified from local review. The configured paths match current local output directories, artifact uploads are tolerant of absent diagnostic files, and visual QA artifacts remain manual and ignored by git.
