# v0.14 Playtest Package Coordinator Guide

Date: 2026-05-18

Audience: Emmanuel.

Goal: create a private playtest package that a tester can open with simple instructions, without knowing the repo or development tools.

## Create The Package

From the repo root:

```bash
npm run package:playtest
npm run verify:playtest-package
```

`npm run package:playtest` runs a playtest-safe production build and creates:

```text
artifacts/playtest/ascendant-realms-private-playtest-<commit>/
```

If the working tree has uncommitted changes, the package folder includes `-dirty` in its name and `playtest-build-info.json` records that. Send a clean package after the checkpoint commit when possible.

## Verify Before Sending

Run:

```bash
npm run verify:playtest-package
```

The verifier checks:

- package folder exists
- `game/index.html` exists
- built assets exist
- tester README exists
- feedback packet exists
- route assignment plan exists
- build info exists
- local server helpers exist
- no `node_modules/`
- no `.git/`
- no raw private feedback folders
- no obvious secret files or token assignments
- package `index.html` uses relative asset URLs

Optional extra confidence:

```bash
npm run smoke:preview
```

Use that after a build when you want a production preview browser smoke. Do not make private packaging depend on heavy hosted release groups.

## What To Send

Send the whole folder:

```text
artifacts/playtest/ascendant-realms-private-playtest-<commit>/
```

You can zip that folder manually.

Do not send:

- the full repo
- `node_modules/`
- `.git/`
- raw private feedback folders
- development logs
- unapproved art-review binaries
- private contact lists

## Assign A Route

Use `ROUTE_ASSIGNMENT_PLAN.md`.

Default:

- first tester: Baseline Cautious
- second tester: Fast Army or Greedy Economy
- third tester: Retinue + Training Yard II only if setup is clear

Do not ask a tester to edit files or saves. If a route needs a prepared save and you do not have one, mark that route as not tested.

## Record A Session ID

Use:

```text
PT-YYYYMMDD-TESTER-ROUTE-01
```

Examples:

- `PT-20260518-T01-BASELINE-01`
- `PT-20260518-T02-FASTARMY-01`
- `PT-20260519-T03-GREEDY-01`

Keep private name/contact mappings outside the repo.

## What Message To Send

Use:

```text
docs/V014_READY_TO_SEND_PRIVATE_PLAYTEST_MESSAGE.md
```

Replace:

- package/link placeholder
- route name
- expected time
- where to return the completed form

Keep the message short and neutral.

## Collect Feedback

Ask for:

- completed `FEEDBACK_SUBMISSION_PACKET.md`
- route/profile
- build/commit if available
- nodes played
- wins, losses, or timeouts
- screenshots or videos if useful

Do not convert one tester complaint into a tuning decision. Store and triage real feedback later through the v0.12.5/v0.12.6 feedback intake process.

## What Not To Commit Publicly

Do not commit:

- full names without permission
- emails, phone numbers, Discord handles, or private contact details
- private chat logs
- large videos
- large screenshot batches
- unapproved raw feedback
- secret files

Commit only sanitized summaries when a future feedback-triage goal explicitly asks for it.
