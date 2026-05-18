# v0.12.5 Severity And Priority Rubric

Date: 2026-05-18

Severity describes how bad the issue is for a tester. Priority describes when the project should act. A severe issue can be low priority if it belongs to a future overhaul, and a moderate issue can be high priority if it is repeated and cheap to fix.

## Severity

### S0 Blocker

Definition:

- Prevents play.
- Crashes or hangs.
- Corrupts save or risks data loss.
- Blocks campaign progress.
- Makes a required objective impossible.

Examples:

- Continue Campaign cannot open a valid save.
- Cinderfen Watch cannot launch.
- Result screen never appears after victory.

Default priority:

- P0 immediate if reproducible on current build.

### S1 Major

Definition:

- Repeated unfair defeat.
- Impossible-feeling objective with clear evidence.
- Command failure during normal play.
- Severe confusion that causes loss or abandonment.
- Pressure warning repeatedly missed with no practical reaction time.

Examples:

- Multiple testers lose Ashen Outpost before understanding the first objective.
- Multiple testers cannot issue retreat/move commands clearly during pressure.

Default priority:

- P1 next polish pass or P2 future balance pass depending on root cause.

### S2 Moderate

Definition:

- Noticeable friction.
- Unclear warning.
- Weak result guidance.
- Repeated route concern that does not block play.
- Combat readability problem that causes mistakes but not session failure.

Examples:

- Cinder Shrine payoff is missed by two testers.
- Greedy Economy timeout is understood only after reading results twice.

Default priority:

- P1 if copy/readability is clear and small.
- P2 if balance evidence needs more runs.

### S3 Minor

Definition:

- Copy roughness.
- Small UI annoyance.
- Mild pacing complaint.
- One tester preference that does not block play.

Examples:

- Tester wants shorter result text but still understands it.
- Main menu copy feels prototype-like.

Default priority:

- P3 or P4.

### S4 Deferred

Definition:

- Visual polish.
- Wishlist.
- Low-confidence one-off.
- Feature request outside current slice.
- Aesthetic complaint that does not block decisions.

Examples:

- Map art is ugly but readable.
- Tester wants a new faction.
- One vague "too hard" report with no route or node.

Default priority:

- P3 future visual overhaul or P4 backlog/watch only.

## Priority

### P0 Immediate

Use for:

- reproducible S0 blockers
- current-build crashes
- save corruption
- unable to continue campaign

Action:

- Bug investigation goal before feature or balance work.

### P1 Next Polish Pass

Use for:

- repeated clarity/readability issues
- repeated pressure noticeability misses with clear non-numeric cause
- result guidance issues that confuse multiple testers
- command feedback clarity issues

Action:

- Small copy/UI/readability goal.

### P2 Future Balance Pass

Use for:

- repeated unfair defeat after clarity is ruled out
- repeated too-easy route after objective/pressure engagement is proven absent
- route dominance evidence across testers

Action:

- Tiny tuning proposal with old/new values only after evidence threshold is met.

### P3 Future Visual Overhaul

Use for:

- landmark salience that requires art
- minimap/icon language redesign
- map readability that needs replacement visuals
- animation/VFX polish
- results density that needs broader UI design

Action:

- Keep in visual-overhaul backlog.

### P4 Backlog / Watch Only

Use for:

- one-off noise
- wishlist features
- contradictory evidence
- low-confidence concerns
- issues that need more testing

Action:

- Record and revisit after more sessions.

## How Severity And Priority Differ

Severity asks: how bad was this for the tester?

Priority asks: should this project act now?

Examples:

- Ugly map art can feel S3/S4 and still be P3 because it belongs to the visual overhaul.
- A small copy issue can be S2 and P1 if three testers hit it and the fix is safe.
- A single "Fast Army is too fast" complaint can be S2 for that tester but P4 until repeated evidence exists.
- A reproducible save corruption bug is S0/P0 even if only one tester found it.
