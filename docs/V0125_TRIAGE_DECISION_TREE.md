# v0.12.5 Triage Decision Tree

Date: 2026-05-18

Use this tree after splitting tester feedback into individual issues.

## Start

1. Is the report tied to a current v0.12.x build?
   - Yes: continue.
   - No or unknown: tag `out-of-scope-build` or `missing-build`; use only as weak context.

2. Does the report include node/screen and route/profile?
   - Yes: continue.
   - No: classify as one-off noise or needs tester follow-up unless it is a blocker.

3. Is it reproducible?
   - Yes: bug investigation if behavior is broken.
   - No: needs more evidence, unless multiple testers independently report the same pattern.

## Bug Branch

Question: Did something break, crash, hang, corrupt state, block progress, or contradict intended mechanics?

- Yes: classify as Actual Bug.
- Required next step: reproduce or inspect focused evidence.
- Recommended action: bug investigation.
- Do not tune around it.

## Understanding Branch

Question: Is the player confused about what happened, what to do, or why a result occurred?

- Yes: classify as Clarity/Readability or Results/Guidance.
- If confusion happens before difficulty, fix guidance first.
- If the player understands after one clearer sentence, prefer copy/readability.
- Do not change numbers first.

## Unfair Defeat Branch

Question: Is the report about unfair defeat, timeout, or being punished too hard?

Check:

- route/profile
- node
- army state
- hero danger
- resources
- objectives completed/skipped
- pressure warning seen/missed
- result screen guidance

Decision:

- If objective or warning was unclear before the hard moment, classify as clarity/pressure first.
- If controls failed, classify as control/command feel first.
- If the player understood everything and still repeatedly lost in similar conditions, classify as balance concern.
- If repeated across testers/routes, candidate for tiny tuning.

## Retinue + Training Yard II Branch

Question: Is the report about Retinue + Training Yard II being too strong?

- Do not tune because it feels powerful.
- Ask whether the tester ignored objectives, production, pressure, retreat, and veteran risk.
- Tune only if multiple testers report trivialization across Ashen Outpost and Cinderfen.
- If the route feels strong but satisfying, recommended action is no change or monitor.

## Greedy Economy Branch

Question: Is the report about Greedy Economy being weak, too slow, or timing out?

- Do not buff just because greed is risky.
- Check whether the tester understood that resources must become army pressure.
- If the tester floated resources and delayed push timing, classify as fair risk or clarity depending on their explanation.
- If multiple testers cannot diagnose the tradeoff, consider copy/readability.
- Consider tuning only if informed greedy play repeatedly fails unfairly.

## Fast Army Branch

Question: Is the report about Fast Army being too fast or dominant?

- Do not slow it just because it is fast.
- Check whether it invalidates other profiles.
- Check losses, skipped objectives, reward state, and whether Cinderfen pressure mattered.
- If it is fast but risky, no change.
- If multiple testers clear Cinderfen with low losses while skipping map identity, candidate for small fix or more testing.

## Pressure Warning Branch

Question: Is the issue about pressure warnings?

- Did the tester see the warning?
- Were they in combat?
- Did they know what to do?
- Did they have time to react?
- Did the result feel fair?

Decision:

- Missed because of text/copy: copy/readability.
- Missed because of visual clutter: UI/readability or future visual overhaul.
- Seen but too late across repeated reports: possible tiny timing/readability fix.
- One missed warning with no details: needs more testing.

## Visual Branch

Question: Is it about visuals?

- If it blocks gameplay understanding, tag UI/readability and possibly future art/UI overhaul.
- If it is aesthetic quality, defer to future visual overhaul.
- If it asks for new art/assets, defer.
- Do not start runtime art replacement in this goal.

## Feature Request Branch

Question: Does the tester want something new?

- New maps, factions, units, enemy construction, multiplayer, procedural systems, reward redesign, or save progression changes are feature requests.
- Recommended action: future systems pass or backlog/watch only.
- Do not implement under feedback intake.

## Final Decision

Choose one:

- `no change`
- `bug investigation`
- `copy/readability`
- `tiny tuning`
- `needs more testing`
- `future art/UI overhaul`
- `future systems pass`
- `backlog/watch only`

If unsure, choose `needs more testing` and state the missing evidence.
