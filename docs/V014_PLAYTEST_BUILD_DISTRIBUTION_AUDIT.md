# v0.14 Playtest Build Distribution Audit

Date: 2026-05-18

Scope: audit the current Ascendant Realms build and preview flow, then define the private playtest package shape needed for low-friction human testing.

This audit is distribution-only. It does not change runtime gameplay, gameplay numbers, maps, factions, units, save format, runtime art/assets, hosted release patterns, or human feedback intake.

## Baseline

- Current baseline commit before v0.14 work: `afbb37f` (`Checkpoint v0.13.1a extended scenario lab integrity audit`).
- Branch baseline: `main`, clean and synced with `origin/main`.
- Existing production build command: `npm run build`.
- Existing production preview command: `npm run preview`.
- Existing automated preview smoke: `npm run smoke:preview`.
- Built files go to `dist/`.

## Current Build Command

`npm run build` runs:

```text
tsc -p tsconfig.json && vite build
```

This compiles TypeScript and writes a production Vite build under `dist/`.

Known current build warning:

- Vite may warn that the Phaser vendor chunk is larger than 500 kB.
- This is expected for the current Phaser prototype and is not a playtest packaging failure.

## Current Preview Command

`npm run preview` runs Vite preview against `dist/`:

```text
vite preview --host 0.0.0.0
```

`npm run smoke:preview` starts a controlled production preview on `127.0.0.1:4173`, opens Chromium through Playwright, verifies the main menu and key routes, checks browser console errors, and shuts down the preview process tree it started.

## Can The Build Be Opened Directly?

Do not rely on opening `dist/index.html` directly from the file system.

Reasons:

- The normal Vite build references module assets under `/assets/...`.
- Browser module loading from `file://` is unreliable and can fail because the page is not served from an HTTP origin.
- A tester should not need to understand Vite, ES modules, or browser CORS behavior.

v0.14 adds a playtest-specific build command that uses package-safe relative asset paths and ships a tiny local server helper in the package.

## Non-Developer Friction

A non-developer tester would struggle with the current repo flow because they would need to know:

- where the repo is
- whether dependencies are installed
- which npm command to run
- whether to use dev server or preview server
- why opening `index.html` may fail
- where the tester packet lives
- which feedback form to fill
- what not to judge yet

That is too much ceremony for private human feedback.

## Needed Package Files

A useful private package should contain:

- built game files under `game/`
- a simple tester README at the package root
- `PLAYTEST_BUILD_INFO.md`
- `playtest-build-info.json`
- `FEEDBACK_SUBMISSION_PACKET.md`
- `TESTER_QUICK_START.md`
- `ROUTE_ASSIGNMENT_PLAN.md`
- a local server helper
- a Windows double-click launcher
- a Mac/Linux shell launcher

The package should be a folder under:

```text
artifacts/playtest/ascendant-realms-private-playtest-<commit>/
```

This folder is ignored by git.

## What Must Not Be Included

Do not include:

- `node_modules/`
- `.git/`
- raw private tester feedback
- private contact information
- `.env` files
- tokens or API keys
- large videos or screenshot batches
- unapproved runtime art/assets
- art-review raw candidate binaries
- development logs or temporary preview logs

## Private Tester Data

Do not commit private tester data by default.

Future real feedback should stay outside the repo until it is sanitized and approved for commit. If approved later, use the v0.12.5/v0.12.6 feedback storage rules and avoid full names, contact handles, private chat logs, and large media files.

## Tooling-Only Package Plan

v0.14 can safely add:

- `npm run build:playtest`
- `npm run package:playtest`
- `npm run verify:playtest-package`
- package generation under ignored `artifacts/playtest/`
- package metadata
- tester and coordinator docs

No gameplay or runtime content change is required.
