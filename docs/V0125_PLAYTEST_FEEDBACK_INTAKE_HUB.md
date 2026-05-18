# v0.12.5 Playtest Feedback Intake Hub

Date: 2026-05-18

Purpose: central intake process for completed v0.12.4 manual playtest packets. Use this when Emmanuel or another tester sends summary forms, route cards, watchpoint ratings, screenshots, videos, or bug/friction reports.

This is an evidence intake framework. It does not authorize runtime code changes, tuning, new art, new content, save migration, or hosted release workflow changes.

## Before Intake

For distributing the playtest before feedback exists, use the v0.12.6 onboarding docs:

- Tester quick-start: `docs/V0126_TESTER_QUICK_START.md`
- Ready-to-send tester message: `docs/V0126_READY_TO_SEND_TESTER_MESSAGE.md`
- Route assignment plan: `docs/V0126_ROUTE_ASSIGNMENT_PLAN.md`
- Feedback submission packet: `docs/V0126_FEEDBACK_SUBMISSION_PACKET.md`
- Coordinator guide: `docs/V0126_PLAYTEST_COORDINATOR_GUIDE.md`
- Feedback storage plan: `docs/V0126_FEEDBACK_STORAGE_PLAN.md`

Do not create triage rows until a real tester has completed a form or sent usable evidence.

## Intake Location

Recommended storage pattern:

- Keep raw tester messages, screenshots, and videos in the original communication channel or a private drive location until sharing/commit permission is clear.
- Create one sanitized Markdown intake note per session when the feedback is ready to enter the repo.
- Suggested future folder for real reports: `docs/playtest-feedback/`.
- Suggested file name: `PT-YYYYMMDD-TESTER-ROUTE-01.md`.
- Add the session's watchpoint rows to `docs/V0125_WATCHPOINT_AGGREGATION_SHEET.md` or a future copy of that sheet.

Do not commit large screenshots or videos unless a future goal explicitly opens artifact intake. Link or describe them instead.

## Session ID Format

Use:

```text
PT-YYYYMMDD-TESTER-ROUTE-01
```

Examples:

- `PT-20260518-EMMANUEL-BASELINE-01`
- `PT-20260518-ALEX-GREEDY-01`
- `PT-20260519-JORDAN-FASTARMY-02`

Rules:

- Use uppercase tester nickname or initials.
- Use a short route key: `BASELINE`, `NORETINUE`, `ONEVET`, `MIXEDVETS`, `RETYARD2`, `GREEDY`, `FASTARMY`, `MIXED`, or `UNKNOWN`.
- Increment the final number when the same tester runs another session on the same day and route.
- If the route is unclear, mark it `UNKNOWN` and add uncertainty notes.

## Intake Header Template

Paste this at the top of every session note:

```text
Session ID:
Tester:
RTS experience:
Date played:
Build/commit:
Browser:
Screen size:
Route/profile:
Prepared save used:
Session length:
Nodes played:
Wins/losses/timeouts:
Evidence owner/source:
Screenshots/videos:
Intake author:
Intake date:
Uncertainty:
```

## What To Paste From The Tester

Paste or summarize:

- completed playtest summary form
- completed route card notes
- mission checklist answers
- watchpoint rating rows
- bug/friction reports
- direct quotes that explain confusion, fairness, pressure, or fun
- links or file names for screenshots/videos
- console errors only if the tester actually saw them

Keep tester quotes short and relevant. If the original report is long, summarize and preserve the exact line that drives the classification.

## Required Session Fields

Build/commit:

- Copy the commit from the tester's form when present.
- If missing, write `unknown`.
- If the build is not a v0.12.x build, tag the session `out-of-scope-build` and do not use it for tuning.

Route played:

- Use the route name from the v0.12.4 route cards.
- If the tester blended routes, use `MIXED` and describe the blend.
- If a prepared save was used, record its name or source.

Nodes completed:

- Record each node as `win`, `loss`, `timeout`, `not reached`, or `not tested`.
- Always include Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch when the route is a balance route.

Screenshots/videos:

- Record file name, link, or source message.
- Note what the screenshot/video is meant to prove.
- Do not infer unseen details from a screenshot; mark uncertainty.

Top issues:

- List up to five issues.
- Give each issue an intake ID: `PT-...-I01`, `PT-...-I02`, and so on.
- Classify each issue using `docs/V0125_EVIDENCE_CLASSIFICATION_GUIDE.md`.

## Uncertainty Tags

Use these tags whenever needed:

- `missing-build`
- `missing-route`
- `missing-node`
- `missing-army-state`
- `missing-result`
- `missing-reproduction`
- `unclear-if-art-or-clarity`
- `possible-one-off`
- `out-of-scope-build`
- `needs-tester-followup`

Uncertainty does not make feedback useless. It means the feedback should not drive tuning by itself.

## Do Not Overreact

Default intake action:

- One isolated report: record and watch.
- One vague report: classify as one-off noise unless it points to a blocker.
- One severe reproducible bug: investigate as bug even if only one tester found it.
- One balance complaint with no route/army/result evidence: do not tune.
- Repeated confusion across testers: consider copy/readability before numbers.
- Repeated unfair defeats with clear objective/pressure evidence: candidate for tiny tuning.

## Intake Workflow

1. Assign a session ID.
2. Paste the session header.
3. Paste/summarize the tester's completed forms.
4. Split feedback into issue rows.
5. Classify each issue.
6. Assign severity and priority.
7. Add watchpoint rows when relevant.
8. Decide recommended action: `no change`, `copy/readability`, `tiny tuning`, `needs more testing`, `future art/UI overhaul`, `future systems pass`, or `actual bug investigation`.
9. Keep raw evidence links.
10. Only open implementation work after repeated evidence clears the thresholds.

## Intake Completion Checklist

- Session ID assigned.
- Build/commit recorded or tagged missing.
- Route/profile recorded or tagged missing.
- Nodes and results recorded.
- Top issues split into individual rows.
- Each issue has category, severity, priority, and recommended action.
- Screenshots/videos linked or marked missing.
- Uncertainty tags applied.
- One-off noise separated from repeated evidence.
- No tuning recommended from a single vague complaint.
