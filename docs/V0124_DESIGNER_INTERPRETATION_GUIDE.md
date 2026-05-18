# v0.12.4 Designer Interpretation Guide

Date: 2026-05-18

Use this guide when reading v0.12.4 manual playtest feedback. Its job is to prevent one noisy play session from becoming a premature balance patch.

## Core Interpretation Rules

- One complaint is not enough for tuning.
- Do not tune based on one unlucky run.
- Repeated confusion may justify copy, objective, result, or UI readability changes before balance numbers.
- Repeated unfair defeats may justify tiny tuning only after route, node, army state, resources, and pressure evidence are clear.
- Art complaints must be separated from gameplay readability.
- If art is ugly but the player still understood the decision, defer it to the future visual overhaul.
- If art blocked a decision, treat it as readability evidence first and visual-overhaul evidence second.

## Watchpoint-Specific Rules

Retinue + Training Yard II:

- Do not nerf it just because it is strong.
- It should not be tuned unless multiple testers report trivialization: no-loss or near-no-loss clears, ignored objectives, ignored pressure, little production, and no meaningful veteran risk.
- If testers call it satisfying earned power, keep watching but do not change.

Greedy Economy:

- Do not buff it just because it is risky.
- Greed should be tempting but punish delayed conversion into army and push timing.
- If testers understand that high resources must become army pressure, no change is likely.
- If multiple testers cannot diagnose timeouts or resource float, consider copy/readability before economy tuning.

Fast Army:

- Do not slow it just because it is fast.
- Fast play should reward decisive action.
- Concern starts when multiple testers clear Cinderfen with low losses while skipping shrine/road/pressure identity and making slower routes feel pointless.

Early defeat clarity:

- Separate "I lost because I made a risky decision" from "I lost before I knew what the game wanted."
- Early losses with clear recovery advice may be acceptable.
- Early losses without readable cause are clarity or tuning candidates depending on repetition.

Pressure warning noticeability:

- Judge warnings by noticeability and reaction time, not just whether they exist in telemetry.
- Ask whether the tester saw the warning during combat, knew what to do, and had time to react.
- If warnings are missed because of visual clutter, consider copy/UI/visual-overhaul buckets before timing changes.

Objective clarity:

- Objective clarity problems should usually be fixed before balance numbers.
- If testers take the wrong route because the objective tracker or selected-node panel is unclear, do not tune enemy stats first.

Results guidance:

- If results are dense but still useful, defer broad UI redesign.
- If players cannot tell why they won or lost, consider copy/readability.

## Suggested Action Mapping

Choose `no change` when:

- feedback is positive or mixed but understandable
- losses are readable
- strong routes still require decisions
- the issue is one-off or not repeated

Choose `copy/readability` when:

- multiple testers misunderstand the same objective, warning, result, or route consequence
- testers recover after explanation
- the mechanics seem fair but the presentation is late or vague

Choose `tiny tuning` when:

- repeated evidence shows unfair defeats or trivial wins
- the issue appears across more than one tester or route
- the smallest numeric change has a clear player-facing reason

Choose `needs more testing` when:

- evidence is plausible but thin
- one tester saw a problem that the current reports do not repeat
- route setup or save state is unclear

Choose `future art/UI overhaul` when:

- visual quality, landmarks, minimap icon language, animation, VFX, or screen density are the main complaint
- the fix would require art/assets or broad layout redesign

Choose `future systems pass` when:

- the fix needs new mechanics, new enemy economy, live reinforcements, reward redesign, campaign progression changes, or save migration

## Minimum Evidence Before Tuning

Before recommending numeric tuning, collect:

- at least two matching reports or one report plus strong existing telemetry
- route/profile
- node
- army state
- hero danger
- resources
- objective state
- pressure-warning state
- win/loss/timeout
- why copy/readability or art debt is not the root cause

If that evidence is missing, the next action is usually `needs more testing`.
