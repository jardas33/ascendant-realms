# v0.96 Contextual Onboarding Spec

Status: implementation spec.

## Goals

- Present one useful action at a time.
- Keep default copy to at most two short visible sentences.
- Put longer explanations behind `More Help`.
- Let players hide, reopen, and reposition guidance.
- Allow player-initiated camera focus where it reduces confusion.
- Preserve current objective tracker hierarchy and battle controls.

## Presenter Model

The first implementation uses the existing Tutorial panel as the reusable onboarding presenter. Tutorial steps may optionally define:

- `reason`: one short visible sentence explaining why the action matters.
- `moreHelp`: longer help text hidden behind disclosure.
- `focusTarget`: a safe target for a player-initiated Focus Objective button.

The presenter shows:

- title;
- one action sentence;
- optional one reason sentence;
- progress;
- Focus Objective when a target is available;
- More Help disclosure;
- Dismiss and Reopen;
- Next Objective only when complete;
- Exit Tutorial.

## Rules

- No Tutorial modal should block combat controls.
- Camera focus happens only when the player clicks Focus Objective.
- More Help is collapsed by default.
- Completed steps are not repeated after advancing.
- Tutorial remains no-save/no-reward.
- Lume controls remain absent from Tutorial.
- The default battle HUD remains usable at 1366x768.

## Campaign Use

Fresh-campaign Salto guidance uses a compact campaign card rather than the Tutorial overlay. It shows:

- `Start with Salto`;
- one action sentence;
- one reason sentence;
- a few short help chips;
- optional details behind disclosure.

It does not write saves beyond the existing campaign selection save and does not alter campaign progression.

## Help Surface

The shared help surface is collapsed by default and grouped by:

- Camera;
- Selection;
- Movement;
- Combat;
- Workers and sites;
- Construction and training;
- Control groups;
- Patrol;
- Lume, only in campaign/eligible contexts.

## Accessibility

- Buttons are native DOM controls.
- `details` / `summary` disclosures are keyboard reachable.
- Guidance avoids color-only state where possible by using labels and borders.
- Motion remains limited; camera focus is user initiated.

## Deferrals

- No persistent "do not show again" save field.
- No first-run analytics.
- No blocking step gates beyond the existing Tutorial objective completion check.
