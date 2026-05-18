# v0.12.4 Manual Human Playtest Packet

Date: 2026-05-18

Build under test: current `main` at `1184e5f` or a later v0.12.4 docs-only checkpoint built from it.

Use this document first. It tells a human tester what to play, what to ignore for now, what to rate, and how to send feedback that can drive the next Ascendant Realms goal without accidentally turning one play session into a balance overreaction.

## Purpose

This is a manual playtest packet for the current v0.12.x browser prototype. It focuses on human feel:

- Can you understand what to do?
- Do commands feel responsive?
- Do objectives and results explain the campaign?
- Do Cinderfen pressure warnings get noticed during real combat?
- Does defeat feel fair?
- Does victory feel earned?
- Does any route feel obviously broken?

This is not a search for new content, final art, broad rebalance, or new systems. The current watchpoints are Retinue + Training Yard II, Greedy Economy, Fast Army, early defeat clarity, pressure warning noticeability, and Cinderfen fairness.

## What Not To Judge Yet

Do not spend most of the session judging:

- ugly prototype art
- rough map visuals
- placeholder character scale
- missing 2026-quality graphics
- lack of animation polish
- lack of final VFX
- unfinished landmark silhouettes
- minimap icon art

Only report art when it blocks gameplay understanding, such as "I could not tell this was the shrine" or "the warning was hidden by visual clutter." Pure visual quality belongs to the future visual overhaul.

## What To Judge Now

Judge the current playable experience:

- Clarity: did you know the first useful action?
- Controls: did selection, movement, attack, retreat, and production feel responsive?
- Objectives: did the tracker and selected-node panel tell you what mattered?
- Pressure warnings: did you notice them while fighting?
- Fairness: did defeat feel caused by readable mistakes?
- Victory: did the win feel earned?
- Balance watchpoints: did any route feel obviously broken?
- Results: did the result screen tell you what happened and what to do next?
- Fun: did the scenario make you want one more attempt?

## Setup Instructions

Use the current browser prototype build only. If Emmanuel or the maintainer gives you a local URL, open that URL in a desktop browser. If you are running from the repository, use the repo's normal README instructions and avoid changing code or data.

Before each session:

- Start from a clean save when the route asks for clean campaign evidence.
- If a prepared save is provided for a route, use that save and write its name in your notes.
- Record the route/profile you played.
- Record the nodes you played.
- Record approximate start/end time or time spent.
- Record whether you are familiar with RTS games: `new`, `casual`, `experienced`, or `expert`.
- Record browser and screen size if anything felt cramped or unreadable.

Do not install mods, change data files, change difficulty data, edit saves by hand, or compare against older builds unless the maintainer explicitly asks.

## Recommended Test Order

For a first manual session:

1. Tutorial / Proving Grounds.
2. Border Village.
3. Ashen Outpost.
4. Cinderfen Crossing.
5. Cinderfen Watch.
6. Results screen and campaign return after at least one victory or defeat.

For balance-route testing, use the route cards in `docs/V0124_PLAYTEST_ROUTE_CARDS.md`. If a route needs a prepared save you do not have, mark it as `not tested` rather than improvising data changes.

## Rating Scale

Use this same 1-5 scale everywhere:

| Rating | Meaning |
| --- | --- |
| 1 | Very bad, confusing, unfair, or actively frustrating. |
| 2 | Weak, often unclear, or only works after guessing. |
| 3 | Acceptable but rough. Playable, with notes. |
| 4 | Good. Clear enough and mostly satisfying. |
| 5 | Excellent. Clear, fair, responsive, and satisfying. |

## Ratings To Record

Fill these after each mission or route:

| Category | Rating 1-5 | One sentence note |
| --- | --- | --- |
| Clarity |  |  |
| Difficulty fairness |  |  |
| Command responsiveness |  |  |
| Objective readability |  |  |
| Pressure noticeability |  |  |
| Combat readability |  |  |
| Result usefulness |  |  |
| Fun |  |  |

Use `N/A` when a category does not apply. For example, Border Village has no Cinderfen pressure warning.

## What Counts As A Real Issue

A real issue is stronger when it includes:

- the route/profile used
- the exact node
- what you had built or unlocked
- army state and obvious losses
- hero danger or death, if noticed
- resources floating or missing
- whether the problem repeated
- screenshot, video, or approximate time
- one sentence about what you expected instead

One unlucky loss is not enough for tuning. Repeated confusion may justify copy or UI changes. Repeated fair losses may mean the route is working. Repeated unfair losses may justify a tiny future tuning pass.

## What Belongs To Future Art Overhaul

Send visual notes to the future visual-overhaul bucket when they are mostly about polish:

- art is ugly but still understandable
- unit scale looks placeholder but selection works
- VFX is plain but damage is understandable
- map lacks beauty but objectives are readable

Escalate visual notes into gameplay/readability only when they block decisions:

- you could not find the shrine, tower, road, or enemy base
- you missed a pressure warning because it blended into combat
- fog, icons, or labels made the objective misleading
- results density prevented you from understanding victory or defeat

## Reporting Packet

Use these documents in order:

1. `docs/V0124_PLAYTEST_ROUTE_CARDS.md`
2. `docs/V0124_MISSION_CHECKLISTS.md`
3. `docs/V0124_WATCHPOINT_RATING_SHEET.md`
4. `docs/V0124_BUG_AND_FRICTION_REPORT_TEMPLATE.md`
5. `docs/V0124_PLAYTEST_SUMMARY_FORM.md`

Send the summary form plus any route cards, mission checklists, and bug/friction reports you filled out. The next Codex goal should be able to decide whether the evidence supports no change, copy/readability changes, tiny tuning, more testing, future art/UI overhaul, or a future systems pass.
