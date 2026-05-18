# v0.12.5 Evidence Classification Guide

Date: 2026-05-18

Use this guide to classify every issue extracted from completed v0.12.4 playtest packets. Pick the primary category first, then add secondary tags only when useful.

## 1. Actual Bug

Definition:

Something breaks, crashes, hangs, desyncs, corrupts state, blocks progress, or behaves contrary to intended mechanics.

Examples:

- Game crashes when launching Cinderfen Watch.
- Continue Campaign button is enabled but does nothing.
- Result screen awards the wrong item or repeats a one-time reward.
- Unit command cannot be issued even though the UI says the unit is selected.

Required evidence:

- steps to reproduce
- build/commit
- node/screen
- expected result
- actual result
- screenshot/video or console error when available
- whether the tester reproduced it

Possible action:

- Bug investigation.
- Focused repro.
- Fix only after reproducing or finding clear code/data cause.

What not to do:

- Do not tune balance around a bug.
- Do not weaken tests to make a bug disappear.
- Do not classify a vague "felt weird" as a bug without behavior evidence.

## 2. Clarity / Readability Issue

Definition:

The game may be working, but the player does not understand what happened, what to do, why an objective matters, or how to recover.

Examples:

- Tester did not understand the Cinder Shrine +20 Aether surge.
- Tester did not know why Cinderfen Watch wanted the road first.
- Tester won but did not understand which objective unlocked the next node.

Required evidence:

- what the tester expected
- what the game showed
- exact node/screen
- whether the tester recovered after reading again
- screenshot or quote when possible

Possible action:

- Copy/readability polish.
- Objective tracker wording.
- Result guidance wording.
- UI hierarchy adjustment in a future polish pass.

What not to do:

- Do not change enemy stats before fixing unclear guidance.
- Do not call it balance if the tester misunderstood the route.

## 3. Balance Concern

Definition:

The game feels too easy, too hard, too punishing, too slow, or one route seems dominant.

Examples:

- Retinue + Training Yard II wins Ashen and Cinderfen with no losses while ignoring objectives.
- Greedy Economy times out repeatedly even when the tester understands the tradeoff.
- Fast Army makes slower routes feel pointless across multiple sessions.

Required evidence:

- route/profile
- node
- win/loss/timeout
- army state
- hero danger
- resources
- objectives completed/skipped
- pressure warnings seen/missed
- whether repeated

Possible action:

- Note only.
- Needs more testing.
- Tiny tuning only after repeated evidence.

What not to do:

- Do not tune from one run.
- Do not buff Greedy Economy just because greed is risky.
- Do not slow Fast Army just because it is fast.
- Do not nerf Retinue + Training Yard II just because it feels strong.

## 4. Pressure Noticeability Issue

Definition:

Warnings exist, but the player misses them, sees them too late, cannot connect them to action, or has no practical reaction time.

Examples:

- Tester notices Cinderfen Watch pressure only after losing units.
- Tester sees warning text but does not know whether to retreat, defend, or push.
- Warning appears during combat but is visually drowned out.

Required evidence:

- node
- route/profile
- whether tester was in combat
- whether warning was seen
- what action the tester took
- whether there was time to react
- result after the warning

Possible action:

- Copy/readability.
- UI salience review.
- Future visual/UI overhaul if visual clutter is the root.
- Tiny timing change only after repeated fair-play misses.

What not to do:

- Do not assume telemetry "warning shown" means humans noticed it.
- Do not expand pressure mechanics in this triage goal.

## 5. Control / Command Feel Issue

Definition:

Commands work technically, but feel delayed, unclear, unresponsive, hard to confirm, or hard to recover from.

Examples:

- Tester cannot tell if a move order registered.
- Unit selection changes but current orders are not noticed.
- Retreat feels clumsy even though units can be commanded.

Required evidence:

- command attempted
- selected unit/group
- node/screen
- expected feedback
- actual feedback
- whether it repeated

Possible action:

- Control feedback polish.
- UI state clarity.
- Focused browser/input review.

What not to do:

- Do not replace canvas/world click tests with DOM fallbacks.
- Do not use force clicks in hosted stability paths.
- Do not classify command feel as balance until control clarity is ruled out.

## 6. Results / Guidance Issue

Definition:

Victory, defeat, rewards, campaign return, or next-step information is not useful enough.

Examples:

- Tester loses and does not know what to try next.
- Tester wins Cinderfen Crossing but does not understand rewards or next node.
- Results screen is too dense to find the important result.

Required evidence:

- result type
- node
- what information was missing
- whether campaign return clarified it
- screenshot or quote when possible

Possible action:

- Result copy polish.
- Result hierarchy review.
- Future UI overhaul for density.

What not to do:

- Do not tune battle difficulty when the player only lacks post-run guidance.

## 7. Art / UI Debt

Definition:

The problem is mostly visual quality, scale, readability, icon language, map art, placeholder graphics, layout density, or landmark salience.

Examples:

- Map looks ugly but objectives are understandable.
- Shrine/tower silhouette is hard to distinguish.
- Minimap icon language does not help the player.

Required evidence:

- screenshot or specific visual description
- whether it blocked gameplay understanding
- node/screen
- decision affected, if any

Possible action:

- Future visual/UI overhaul.
- Copy/readability only if it blocks decisions and can be helped without art.

What not to do:

- Do not start runtime art replacement.
- Do not import or generate assets.
- Do not tune combat to compensate for ugly art.

## 8. Feature Request

Definition:

The tester wants something new outside the current slice.

Examples:

- Add multiplayer.
- Add workers or enemy construction.
- Add new faction, unit, map, procedural campaign, or new reward system.

Required evidence:

- requested feature
- why tester wanted it
- whether it blocks current play or is a wishlist item

Possible action:

- Future systems pass.
- Backlog/watch only.

What not to do:

- Do not treat feature requests as bugs.
- Do not add content under the v0.12.5 triage goal.

## 9. One-Off Noise

Definition:

A single unclear complaint with insufficient evidence, no route/node details, or no repeat signal.

Examples:

- "Too hard" with no node or route.
- "Fast Army is busted" with no result, losses, or save state.
- "The game felt bad" with no screen, action, or expected behavior.

Required evidence:

- none yet; this category means evidence is insufficient

Possible action:

- Note only.
- Ask follow-up if the tester is available.
- Needs more testing.

What not to do:

- Do not tune.
- Do not open implementation work.
- Do not treat a vague complaint as a trend.

## Classification Checklist

For each issue ask:

1. Did something break? If yes, start with Actual Bug.
2. Did the tester misunderstand what to do? If yes, start with Clarity/Readability.
3. Is it about warnings during combat? If yes, consider Pressure Noticeability.
4. Is it about command feedback? If yes, consider Control/Command Feel.
5. Is it about win/loss difficulty after understanding? If yes, consider Balance Concern.
6. Is it about post-run information? If yes, consider Results/Guidance.
7. Is it mostly visual? If yes, decide whether it blocked gameplay understanding.
8. Is it asking for new content/systems? If yes, Feature Request.
9. Is evidence missing? If yes, One-Off Noise or Needs More Testing.
