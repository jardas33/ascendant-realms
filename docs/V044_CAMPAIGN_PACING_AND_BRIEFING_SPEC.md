# v0.44 Campaign Pacing and Briefing Spec

Date: 2026-05-28

## Goal

Improve campaign pacing readability by giving each existing battle node a concise briefing, objective emphasis, reward preview, modifier readout, and after-action summary. The player should know why this battle matters and what kind of hero build it naturally supports.

## Pacing Goals

- Early skirmish/training missions stay simple and low-noise.
- Control missions make resource-site play more legible.
- Assault missions emphasize decisive pushes, commanders, or hostile strongpoints.
- Defense missions communicate protection and pressure without adding a new survival mode.
- Recommended build hints can reference Warrior, Seer, or Commander when existing relic/skill identity makes that useful.

## Briefing Copy

Briefing copy should include:

- mission type;
- short mission briefing;
- primary objective;
- optional objective list where already supported;
- reward preview;
- known scenario modifiers;
- recommended build hint when useful.

The copy must stay compact enough for the existing campaign node panel and should not create an in-app tutorial wall.

## Results Copy

Results should show:

- mission type;
- active scenario modifiers;
- primary objective success/failure through existing outcome state;
- optional objective credit from v0.41;
- first-clear or replay reward status;
- short after-action summary.

Existing relic choice, XP, campaign reward, and skill-point reminder flows remain intact.

## Save Compatibility

Briefing and pacing metadata is content-driven. No new save-version bump is required. Existing mission completion, reward-claim, replay, relic, hero skill, and optional-objective save fields remain the persistent source of truth.

## Deferrals

- Full campaign codex.
- Voiceover or cinematic briefing.
- Branching campaign route pacing.
- New maps or factions.
- Dynamic mission-rating system.
