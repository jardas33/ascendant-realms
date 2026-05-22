# v0.16.11 Tester Launch Packet Index

Date: 2026-05-22

## Package To Send

Use the latest clean package generated after the v0.16.11 commit. Do not send any package folder ending in `-dirty`.

At minimum, the package must include:

- `README_FOR_TESTERS.md`
- `TESTER_QUICK_START.md`
- `PLAYTEST_BUILD_INFO.md`
- `RELEASE_CANDIDATE_NOTES.md`
- `FIRST_TESTER_MESSAGE.md`
- `TESTER_FEEDBACK_FORM_SHORT.md`
- `ROUTE_ASSIGNMENTS_SMALL_BATCH.md`
- `EMMANUEL_MANUAL_RETEST_CHECKLIST.md`
- `START_GAME_WINDOWS.bat`
- `START_GAME_MAC_LINUX.sh`
- `start-playtest-server.mjs`
- `game/`

## Send To Emmanuel First

Send or point Emmanuel to:

- the clean package folder
- `EMMANUEL_MANUAL_RETEST_CHECKLIST.md`
- `RELEASE_CANDIDATE_NOTES.md`
- `PLAYTEST_BUILD_INFO.md`

Emmanuel should run the manual retest before v0.17.

## Small Tester Batch

For 2 testers:

- Tester 1: Route A, Tutorial Only
- Tester 2: Route E, Behaviour Mode Stress

For 3 testers:

- Tester 1: Route A, Tutorial Only
- Tester 2: Route B, Tutorial Plus First Campaign
- Tester 3: Route E, Behaviour Mode Stress

For 4 testers:

- Tester 1: Route A, Tutorial Only
- Tester 2: Route B, Tutorial Plus First Campaign
- Tester 3: Route C, Baseline Cautious
- Tester 4: Route E, Behaviour Mode Stress

For 5 testers:

- Tester 1: Route A, Tutorial Only
- Tester 2: Route B, Tutorial Plus First Campaign
- Tester 3: Route C, Baseline Cautious
- Tester 4: Route D, Skirmish / Broken Ford
- Tester 5: Route E, Behaviour Mode Stress

Do not commit tester names, emails, or raw private notes to the repo.

## Files To Send To Each Tester

Send the full clean package plus these top-level docs:

- `README_FOR_TESTERS.md`
- `TESTER_QUICK_START.md`
- `FIRST_TESTER_MESSAGE.md`
- `TESTER_FEEDBACK_FORM_SHORT.md`
- `ROUTE_ASSIGNMENTS_SMALL_BATCH.md`

Tell each tester only their assigned route label and route instructions.

## What To Collect

- assigned route
- browser and OS
- time played
- missions or modes played
- biggest confusion
- first control problem noticed
- attack / retreat / selection clarity
- Tutorial or Results clarity
- repeated bugs with steps
- screenshots/video only if useful

Keep raw submissions private. Public repo issues should contain only anonymized, actionable summaries.
