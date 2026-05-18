# v0.12.6 Feedback Storage Plan

Date: 2026-05-18

This is a docs-only plan for storing future real playtest feedback. Do not create a database for this process.

## Storage Goal

Keep real tester feedback traceable enough for future evidence triage while avoiding private data, giant media files, and invented results.

## Suggested Folder Structure

If future feedback is approved for the repo, use:

```text
docs/playtest-feedback/v0126/
  raw/
  summarized/
  screenshots/
  triage/
```

Recommended use:

- `raw/`: sanitized copies of completed tester forms or message excerpts.
- `summarized/`: one short session summary per tester/session.
- `screenshots/`: only lightweight images approved for commit, or text files that link to private media.
- `triage/`: classified issues, watchpoint aggregation copies, and next-action decisions.

Do not create these folders until there is real approved feedback to store.

## Naming Convention

Use the v0.12.5 session ID format:

```text
PT-YYYYMMDD-TESTER-ROUTE-01
```

Suggested files:

```text
docs/playtest-feedback/v0126/raw/PT-20260518-ALEX-BASELINE-01.md
docs/playtest-feedback/v0126/summarized/PT-20260518-ALEX-BASELINE-01-summary.md
docs/playtest-feedback/v0126/triage/PT-20260518-ALEX-BASELINE-01-triage.md
```

Use uppercase route keys:

- `BASELINE`
- `NORETINUE`
- `ONEVET`
- `MIXEDVETS`
- `RETYARD2`
- `GREEDY`
- `FASTARMY`
- `MIXED`
- `UNKNOWN`

## What Not To Commit

Do not commit:

- tester full names without permission
- emails, phone numbers, Discord names, or private contact details
- private chat logs that include unrelated conversation
- large video files
- large screenshot batches
- raw files that mention private information
- unapproved recordings of a tester's screen or voice

When in doubt, keep raw evidence outside the repo and commit only a sanitized summary with links or file names.

## Anonymizing Testers

Use initials or neutral aliases:

- `T01`
- `T02`
- `RTS-VET-01`
- `CASUAL-01`
- `NONRTS-01`
- `RPG-01`

Keep the private mapping outside the repo if it exists.

## Evidence Rules

- Do not invent playtest results.
- Do not summarize a tester into saying something they did not say.
- Mark missing build, route, node, or result information as uncertainty.
- Keep direct quotes short and relevant.
- Separate raw feedback from designer interpretation.
- Use `docs/V0125_EVIDENCE_CLASSIFICATION_GUIDE.md` before recommending action.

## Intake Flow

1. Receive the completed `docs/V0126_FEEDBACK_SUBMISSION_PACKET.md`.
2. Assign a session ID.
3. Save raw or sanitized feedback outside the repo until commit permission is clear.
4. Create a sanitized session note if it should enter the repo.
5. Classify issues using v0.12.5 intake docs.
6. Aggregate watchpoint evidence.
7. Open a future Codex goal only when evidence is ready.
