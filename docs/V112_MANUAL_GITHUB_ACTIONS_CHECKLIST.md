# v0.11.2 Manual GitHub Actions Checklist

Date: 2026-05-11

Audience: Emmanuel / project owner

Purpose: collect the first authenticated GitHub Actions evidence for the v0.11.1 `CI Release Matrix Dry Run` workflow. Codex could not inspect the remote run from this environment because `gh` is unavailable, the GitHub connector token is expired, and unauthenticated Actions API access returns `404 Not Found`.

## 1. Open The Workflow

1. Open GitHub in a browser where you are signed in.
2. Go to the Ascendant Realms repository:

```text
https://github.com/jardas33/ascendant-realms
```

3. Click the **Actions** tab.
4. Open the workflow named:

```text
CI Release Matrix Dry Run
```

5. Look for the run triggered by this commit:

```text
f0651afaf66c1622f454b751c118e4443a7590a7
Checkpoint v0.11.1 CI release matrix dry-run
```

If a newer v0.11.2 commit has been pushed, inspect that latest run too.

## 2. Fast Confidence Job

For a normal push to `main`, the important automatic job is:

```text
Fast confidence
```

It should show a green success check. Open it and confirm these steps appear:

1. Checkout
2. Setup Node
3. Install dependencies
4. Install Playwright Chromium
5. Unit and pure-rule tests
6. Production build
7. Content validation
8. Art-intake validation
9. E2E smoke
10. Production preview smoke
11. Upload Playwright failure artifacts

Record:

- job conclusion;
- total duration;
- duration of `Install Playwright Chromium`;
- duration of `E2E smoke`;
- duration of `Production preview smoke`;
- any failed step name.

## 3. Expected Manual Jobs On Push

These jobs should be skipped or absent on a normal push:

```text
Optional visual QA
Release matrix (shard-1-of-3)
Release matrix (shard-2-of-3)
Release matrix (shard-3-of-3)
Release simulator
Full release e2e
```

Skipped manual jobs are expected. They do not mean CI failed.

## 4. Trigger Manual Visual QA

Use this only when you intentionally want screenshot artifacts.

1. Open **Actions**.
2. Select **CI Release Matrix Dry Run**.
3. Click **Run workflow**.
4. Choose the current branch, usually `main`.
5. Enable:

```text
run_visual_qa = true
```

6. Leave the other heavy options off unless you also want them.
7. Click **Run workflow**.
8. When it finishes, download the artifact named:

```text
visual-qa-latest
```

Expected contents:

```text
index.md
18 PNG screenshots
```

Open `index.md` first. It should report screenshot count, browser console error count, and viewport coverage.

## 5. Trigger Manual 3-Way Release Gate

Use this before a release freeze or after risky technical changes.

1. Open **Actions**.
2. Select **CI Release Matrix Dry Run**.
3. Click **Run workflow**.
4. Enable:

```text
run_release_matrix = true
```

5. Leave `run_full_release` off unless you specifically want the slow full lane too.
6. Confirm these jobs run:

```text
Release matrix (shard-1-of-3)
Release matrix (shard-2-of-3)
Release matrix (shard-3-of-3)
Release simulator
```

Record each job's conclusion and duration. If a shard fails, download its `playwright-release-*` artifact if present.

## 6. Trigger Manual Full Release Lane

Use this sparingly for major freezes because it is intentionally slow.

1. Open **Run workflow**.
2. Enable:

```text
run_full_release = true
```

3. Keep `run_release_matrix` off unless you want both forms of release evidence.
4. Confirm the job named `Full release e2e` runs and record duration.

## 7. What Artifacts To Download

Download artifacts only when they exist and are relevant:

| Artifact | When to download |
| --- | --- |
| `playwright-fast-confidence` | If fast confidence fails or has diagnostics. |
| `visual-qa-latest` | After manual visual QA. |
| `playwright-visual-qa` | If visual QA fails or has diagnostics. |
| `playwright-release-shard-*` | If manual release shards fail or have diagnostics. |
| `playwright-full-release` | If manual full release fails or has diagnostics. |

No artifact is source/license proof for runtime art. Visual QA screenshots are temporary review evidence only.

## 8. What To Send Back To Codex

If anything fails, send:

- workflow run URL;
- job name;
- step name;
- final 30 to 60 log lines around the failure;
- artifact ZIP if GitHub provides one;
- whether rerunning the failed job changed the result.

If everything passes, send:

- workflow run URL;
- fast confidence duration;
- confirmation that `Production preview smoke` passed with 0 browser console errors;
- whether manual jobs were skipped as expected.

## 9. Do Not Panic About These

These are expected:

- the known Phaser vendor chunk-size warning during `npm run build`;
- manual visual/release jobs skipped on normal push;
- hosted runner durations slower than local runs;
- no Playwright artifact uploaded when a job passes and no diagnostics exist;
- visual QA being optional and human-reviewed, not pixel-perfect.

## 10. Report These Immediately

These need follow-up:

- workflow file parse failure;
- `npm ci` failure;
- Playwright Chromium install failure;
- `npm test`, build, content validation, or art-intake validation failure;
- e2e smoke failure;
- `smoke:preview` timeout, port conflict, process hang, or browser console error;
- manual release shard failure;
- artifact path issue that fails a job;
- any change that would tempt removing coverage for speed.

Do not delete tests or weaken assertions to make CI green.
