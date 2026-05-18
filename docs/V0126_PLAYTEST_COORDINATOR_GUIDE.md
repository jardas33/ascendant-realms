# v0.12.6 Playtest Coordinator Guide

Date: 2026-05-18

Audience: Emmanuel or whoever is coordinating real human playtests for the current v0.12.x browser prototype.

This guide helps you hand the game to testers, collect usable feedback, and avoid turning one person's rough session into premature tuning.

## Coordinator Goal

Make the playtest easy enough that a tester can:

- open the game
- play one assigned route
- understand what to ignore for now
- record clear ratings and notes
- send evidence back in a usable format

Do not lead testers toward expected answers. The value is in what they notice naturally.

## Who To Ask

A useful small tester mix:

- RTS veteran: checks whether routes, commands, and pressure feel credible.
- Casual strategy player: checks whether objectives and pacing make sense without heavy optimization.
- Non-RTS player: catches first-action confusion, UI density, and basic command feedback issues.
- RPG progression player: reacts to hero growth, retinue, upgrades, rewards, and earned power.

You do not need a large group before learning something useful. Three testers can reveal repeated clarity problems. Five to seven testers are more useful before making route balance decisions.

## How Many Testers Before Decisions

Use the v0.12.5 thresholds:

| Evidence | Interpretation |
| --- | --- |
| 1 isolated report | Note only. |
| 2 similar reports | Monitor or consider copy/readability. |
| 3+ similar reports | Candidate for a small fix. |
| 3+ reports across different routes | Strong signal. |
| 5+ reports or a severe blocker | Priority issue. |

One severe reproducible crash or progression blocker can be investigated immediately. One balance complaint should not drive tuning.

## What To Send Testers

Send:

1. `docs/V0126_READY_TO_SEND_TESTER_MESSAGE.md`
2. `docs/V0126_TESTER_QUICK_START.md`
3. `docs/V0126_FEEDBACK_SUBMISSION_PACKET.md`
4. The assigned route name from `docs/V0126_ROUTE_ASSIGNMENT_PLAN.md`

Only send the larger v0.12.4 packet if the tester is comfortable with more structure.

## Assigning Routes

Use `docs/V0126_ROUTE_ASSIGNMENT_PLAN.md`.

Default:

- First tester: Baseline Cautious.
- Second tester: Fast Army or Greedy Economy.
- Third tester: Retinue + Training Yard II if a prepared save/profile exists.

Avoid assigning every tester the strongest route first. You need a normal baseline before judging whether the strong profile is too easy.

## Session ID Naming

Use the v0.12.5 format:

```text
PT-YYYYMMDD-TESTER-ROUTE-01
```

Examples:

- `PT-20260518-EMMANUEL-BASELINE-01`
- `PT-20260518-ALEX-GREEDY-01`
- `PT-20260519-JORDAN-FASTARMY-02`

Use uppercase initials or a nickname if privacy matters. Use `UNKNOWN` when route or build is unclear.

## Collecting Forms

For each session, collect:

- filled `docs/V0126_FEEDBACK_SUBMISSION_PACKET.md`
- route/profile
- build or commit
- nodes played
- wins/losses/timeouts
- screenshots or videos, if any
- notes about missing information

Do not ask testers to rewrite their feedback into designer language. Preserve their plain wording when it explains confusion or fairness.

## Avoid Leading The Tester

Good prompts:

- "Play naturally and tell me what you noticed."
- "What did you think you were supposed to do?"
- "Did you notice the warning while fighting?"
- "What felt unfair, if anything?"

Avoid:

- "Did Retinue + Training Yard II feel overpowered?"
- "Did you miss the pressure warning?"
- "Was the art bad?"
- "Was Greedy Economy underpowered?"

Ask neutral follow-ups after the session if evidence is missing.

## Separate Art Complaints From Gameplay Clarity

Tag as future visual overhaul when:

- the art looks bad but the tester could still play
- scale looks placeholder but selection/orders were readable
- the map lacks polish but objectives were understandable

Tag as clarity/readability when:

- the tester could not identify an objective
- a warning was missed because of visual clutter
- UI density blocked understanding
- map visuals caused a wrong decision

## When Feedback Is Ready For The Next Goal

Feedback is ready for v0.12.7/v0.13 planning when:

- each session has a session ID
- build/commit is recorded or marked unknown
- routes and nodes are recorded
- top issues are split into individual reports
- watchpoint ratings are aggregated
- uncertainty is tagged
- repeated issues are separated from one-off noise

Recommended next goal after real forms arrive: review completed tester packets, classify evidence, and decide whether the next step is no change, copy/readability polish, tiny tuning, more testing, future visual overhaul, or future systems work.
