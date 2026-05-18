# v0.12.3 Human Campaign Play Session Protocol

Date: 2026-05-17

Scope: v0.12.3 Human Campaign Balance Play Session. This protocol defines direct human-style campaign review routes for the existing v0.12.2 green baseline. It is an evidence-gathering pass, not a new systems pass, content expansion, art pass, save migration, CI-plumbing pass, or broad rebalance.

## Phase 0 Baseline

- Branch: `main`.
- Current commit at Phase 0: `f8fa346` (`Checkpoint v0.12.2 human balance watchpoint review`).
- Sync state: clean and synced with `origin/main`.
- Previous decision: v0.12.2 made no numeric tuning and no runtime/copy changes.
- Remote baseline inherited from v0.12.2: GitHub Actions `CI Release Matrix Dry Run #44` was green on commit `1b28678`; v0.12.2 was docs-only and locally green before being pushed.

Green-state constraints to preserve:

- Hosted release groups stay on `playwright.hosted-release.config.ts` and `npm run preview:hosted`.
- Local full release lanes remain separate from hosted release groups.
- Do not replace `clickReady` with force clicks.
- Do not use DOM fallback for canvas/world clicks.
- Do not weaken `Moving`, minimap, no-save/no-reward tutorial, battle command, side-panel reachability, settings runtime-application, or hosted-release assertions.
- Do not turn tutorial smoke semantic advancement back into raw `tutorial-next` click chains.
- Do not add maps, factions, units, art/assets, runtime art replacements, save migrations, multiplayer, procedural generation, monetization, broad AI/economy rewrites, or CI plumbing.

## Shared Review Method

Use a player-like rhythm rather than a speedrun:

- Pause at battle start and read the current objective/status.
- Capture obvious economy/objective sites first unless the route explicitly tests greed or speed.
- Build and train through normal UI expectations in the mental model, even when using deterministic browser/test harness setup to reach the scenario.
- Record how the route feels: difficulty, clarity, losses, hero danger, resource pressure, pressure-warning noticeability, and whether victory/defeat feels earned.
- Treat simulator data as structural context and browser/visual evidence as readability/stress context.
- Prefer no change when evidence is mixed or only simulator-derived.

Decision threshold for tuning:

- Numeric tuning requires repeated evidence across multiple human-style routes, not just one fast scripted outcome.
- Copy/readability changes require a concrete player-facing confusion that is still present after v0.12/v0.12.1 copy improvements.
- Visual debt should be deferred to the future visual overhaul rather than patched through balance numbers.

## Common Nodes To Play Or Inspect

- Border Village: early campaign sanity and defeat-risk baseline.
- Ashen Outpost: milestone pacing, shrine/fortress/commander clarity, final-push pressure.
- Cinderfen Crossing: shrine tempo, pressure-warning noticeability, fast/greedy strategy spread.
- Cinderfen Watch: Watch Road, fog/tower pressure, warning noticeability, second Cinderfen pacing read.
- Campaign return after victory/defeat: whether results explain what happened and what to do next.

## Route A - Baseline Cautious Route

Assumed player choices:

- No deliberate optimization or speedrunning.
- Capture objectives in the obvious `Next` order.
- Read warnings before acting.
- Retreat/regroup if the army is hurt.
- Build enough production before final pushes.

Campaign nodes:

- Border Village.
- Ashen Outpost.
- Cinderfen Crossing.
- Cinderfen Watch.

What to observe:

- Whether objectives naturally produce a safe route.
- Whether the player has enough army/resources without special retinue reliance.
- Whether pressure warnings remain visible during ordinary command flow.
- Whether victory feels earned rather than automatic.

Too easy:

- Wins all reviewed battles quickly with low losses while ignoring side objectives, pressure, and production.

Unfair:

- Loses despite following objectives, building production, and responding to warnings.

Unclear:

- The player survives but does not know when to push, where to regroup, or why a warning matters.

Defer:

- Art/landmark salience, result density, minimap icon language, and any full UI redesign.

## Route B - No-Retinue Route

Assumed player choices:

- Avoid relying on saved veterans.
- Use only current battle production and ordinary campaign rewards.
- Follow objective guidance and do not intentionally rush.

Campaign nodes:

- Border Village as early baseline.
- Ashen Outpost as the main no-retinue milestone.
- Cinderfen Crossing and Cinderfen Watch if the route remains viable.

What to observe:

- Whether the campaign remains fair without retinue power.
- Whether Ashen Outpost asks for reasonable production and objective sequencing.
- Whether Cinderfen pressure can be handled without veteran cushion.

Too easy:

- No-retinue clears Ashen and both Cinderfen battles with little production, low losses, and no meaningful pressure response.

Unfair:

- No-retinue loses or times out despite following objective order and converting resources into army.

Unclear:

- The player cannot tell whether the missing ingredient is army size, objective order, hero ability timing, or side income.

Defer:

- Retinue-system redesign, new support nodes, new units, or new tutorialization.

## Route C - One-Veteran Route

Assumed player choices:

- Bring one meaningful veteran, usually Militia or Ranger.
- Keep the veteran grouped with the main army instead of using it recklessly.
- Follow ordinary objectives rather than exploiting speed.

Campaign nodes:

- Ashen Outpost.
- Cinderfen Crossing.
- Cinderfen Watch.

What to observe:

- Whether one veteran feels like earned help without making the route automatic.
- Whether permanent-death risk remains legible.
- Whether objective and pressure play still matter.

Too easy:

- One veteran erases Ashen/Cinderfen pressure, saves all losses, and lets the player skip setup.

Unfair:

- The veteran dies during ordinary cautious play with no readable danger signal.

Unclear:

- The player cannot tell whether to protect, spend, or ignore the veteran.

Defer:

- Veterancy XP thresholds, rank-stat redesign, or retinue UI overhaul unless a clear repeated issue appears.

## Route D - Mixed-Veterans Route

Assumed player choices:

- Use a moderate experienced-player path with two veterans.
- Build and train normally.
- Take objectives in a practical order.

Campaign nodes:

- Ashen Outpost.
- Cinderfen Crossing.
- Cinderfen Watch.

What to observe:

- Whether mixed veterans feel like a natural experienced-player advantage.
- Whether the army still needs production, shrine/road objectives, and pressure response.
- Whether losses remain plausible.

Too easy:

- Mixed veterans repeatedly produce no-loss clears while ignoring objectives and pressure.

Unfair:

- Mixed veterans become mandatory because non-retinue and one-veteran routes feel unreasonable.

Unclear:

- The player cannot distinguish earned veteran advantage from required progression tax.

Defer:

- Broader retinue economy changes, new campaign support mechanics, or reward redesign.

## Route E - Retinue + Training Yard II Route

Assumed player choices:

- Deliberately stack the strongest known profile.
- Bring mixed veterans and purchase Training Yard II for active retinue capacity.
- Still make normal production choices so the test can distinguish earned power from trivialization.

Campaign nodes:

- Ashen Outpost.
- Cinderfen Crossing.
- Cinderfen Watch.

What to observe:

- Whether three active veterans flatten map identity.
- Whether objectives and pressure warnings still matter.
- Whether the player ever has to build, train, regroup, or protect veterans.

Too easy:

- Repeated no-loss or near-no-loss clears, fast completion, and no need to respond to pressure/objectives.

Unfair:

- Not likely for this profile; the main risk is overpowered, not too hard.

Unclear:

- The player does not understand that Training Yard II adds active retinue capacity rather than raw unit stats.

Defer:

- Retinue capacity or Training Yard II tuning unless direct human-style evidence shows repeated trivialization.

## Route F - Greedy Economy Route

Assumed player choices:

- Prioritize economy/value and side income.
- Delay final push to build a stronger resource base.
- Build production, but maybe too late or too conservatively.

Campaign nodes:

- Ashen Outpost.
- Cinderfen Crossing.
- Cinderfen Watch.

What to observe:

- Whether timeouts feel fair and self-inflicted.
- Whether the player understands that resources must become army pressure.
- Whether pressure warnings feel like practical prompts or just stress.

Too easy:

- Greedy Economy safely outscales pressure and wins without push timing discipline.

Unfair:

- Greedy Economy loses before its risk/reward tradeoff is visible or before recovery is possible.

Unclear:

- The player floats resources, times out, and the results/guidance does not explain conversion into army/push timing.

Defer:

- Broad economy AI, enemy construction, new sinks, reward redesign, or sweeping timer changes.

## Route G - Fast Army Route

Assumed player choices:

- Prioritize early army and aggression.
- Delay some economy/objective prep.
- Attack quickly and accept possible losses.

Campaign nodes:

- Ashen Outpost.
- Cinderfen Crossing.
- Cinderfen Watch.

What to observe:

- Whether speed is rewarded but risky.
- Whether map identity is skipped too easily.
- Whether pressure warnings are bypassed, noticed, or still meaningful.
- Whether repeat/first-clear reward value makes speed too attractive.

Too easy:

- Fast Army repeatedly clears Cinderfen with low losses, high reward value, and little interaction with shrine/road/pressure identity.

Unfair:

- Fast Army gets crushed despite building plausible early units and attacking a reasonable target.

Unclear:

- The player wins with heavy losses but cannot tell whether that was good aggressive play or sloppy play.

Defer:

- Reward redesign, route redesign, new anti-rush mechanics, broad enemy AI changes, or new map content.
