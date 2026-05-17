# v0.12.1 Human-Paced Playtest Notes

Date: 2026-05-17

Scope: Phase 2 notes for the v0.12.1 Human-Paced Core Feel Playtest Review. Review used the local Vite dev server at `http://127.0.0.1:5173/`, the in-app browser for visible slow interactions, and a disposable Playwright browser context for campaign/results fast-forward hooks after the launch flows were observed.

No gameplay code was changed during this review phase.

## A. First Launch And Main Menu

What felt clear:

- Main menu boot was immediate and stable.
- The primary actions are plain: New Campaign, Continue Campaign, Tutorial, Skirmish, Inventory, Settings.
- The one-line prototype premise still gives a quick RTS/RPG expectation.

What felt confusing:

- `Prototype v0.3` / `Cinderfen Route Baseline` is historically accurate but feels stale beside v0.12/v0.12.1 handoff language.

Feedback timing/noise:

- No status timing issue observed.

What felt satisfying:

- The menu gets to the playable choices without marketing padding.

Visual-art debt:

- Main menu background/emblem quality is future visual polish, not v0.12.1.

Severity:

- Defer: version/baseline copy can be handled in a future release-label cleanup unless README/user-facing version policy changes.

## B. Tutorial / Proving Grounds

What felt clear:

- Step 1 and Step 2 immediately showed selected army/hero context.
- The v0.12 selected-panel changes landed well: `4 selected`, `Commands apply to this group.`, and `Current Orders` made selection state obvious.
- Right-click movement produced both `4 Moving` in Current Orders and `Move order accepted: 4 units`.
- Exit Tutorial returned to main menu cleanly.

What felt confusing:

- Step 1 was already complete on launch because the initial camera/selection state satisfies it. This is acceptable but slightly odd for a human who expects to perform the first instruction.
- The no-save/no-reward rule was not visible in the first few slow interactions. Existing smoke coverage protects the final no-save/no-reward notice, so this is a watch item rather than an immediate change.

Feedback timing/noise:

- Move command feedback stayed readable after the right-click.
- No income-message overwrite was observed during the simple movement step.

What felt satisfying:

- The side panel now tells the player exactly that the group receives commands.

Visual-art debt:

- Selection rings and destination feedback still need future art/VFX if the project wants stronger visual command markers.

Severity:

- Small polish later: consider first-step copy that acknowledges the starting selection state.
- Defer: early no-save/no-reward reminder unless human testers keep missing the final notice.

## C. New Campaign Start

What felt clear:

- Clean save flow opens hero creation before the campaign map.
- Hero creation copy explains that the first battle teaches the RTS loop and rewards feed progression.
- Campaign map guidance clearly says `Start Here`, `Select Border Village`, `Win The Battle`, and `Look At Your Rewards After Victory`.

What felt confusing:

- The Stronghold section appears very early and is text-dense before the player has resources.

Feedback timing/noise:

- No timing issue observed.

What felt satisfying:

- The map guidance after hero creation is more player-facing than a raw node list.

Visual-art debt:

- Campaign map panel density and illustration remain future UI/art polish.

Severity:

- Defer: Stronghold density is real but larger than this tiny polish pass.

## D. Border Village / First Claim

What felt clear:

- Battle starts with selected group, hero panel, command button, minimap, and order summary visible.
- Right-click movement changed Current Orders to `4 Moving` and showed `Move order accepted: 4 units`.
- The selected-order hierarchy is much more readable than pre-v0.12.

What felt confusing:

- First Claim does not show an objective tracker in the same way Ashen/Cinderfen maps do; the player relies on battle-start status and prior campaign guidance.

Feedback timing/noise:

- Move command acknowledgement worked.

What felt satisfying:

- The first real command loop now gives immediate accepted-command feedback.

Visual-art debt:

- First battle terrain/unit silhouettes remain prototype-level.

Severity:

- Defer: adding objective tracker data to First Claim could be useful, but it changes map objective content and result surfaces beyond this tiny pass.

## E. Ashen Outpost

What felt clear:

- Initial objective tracker is strong: `Next` points at `Capture the Burned Shrine`.
- Burned Shrine objective explains the payoff: damaging the gate Watchtower and making the fortress push safer.
- Captain Malrec objective tells the player to save hero abilities until the shrine and barracks are secure.

What felt confusing:

- No major copy issue in the initial battle view.

Feedback timing/noise:

- No overwrite issue observed at launch.

What felt satisfying:

- The objective tracker reads like a play plan instead of a lore list.

Visual-art debt:

- Fortress/tower threat still needs future landmark and range readability art.

Severity:

- Defer: any stronger tower/commander visual language belongs to the future visual overhaul.

## F. Cinderfen Crossing

What felt clear:

- Objective tracker uses `Next` and gives a usable Cinder Shrine plan.
- Right-click command feedback stayed consistent: Current Orders changed and `Move order accepted: 5 units` appeared.

What felt confusing:

- Skirmish/setup/results use map name `Cinderfen Causeway`, while campaign and player-facing route language use `Cinderfen Crossing`.
- The Cinder Shrine objective is useful but slightly dense: `Cinder Shrine Surge (+20 Aether once)` reads more like an internal mechanic label than a human instruction.

Feedback timing/noise:

- Command acknowledgement was not buried during the initial interaction.

What felt satisfying:

- The shrine objective now gives the player a reason to care about the shrine before pushing.

Visual-art debt:

- Shrine/ash-marsh/causeway landmarks still need future art; do not fix with runtime assets here.

Severity:

- Small polish now: align the player-facing map name with `Cinderfen Crossing`.
- Small polish now: make the shrine payoff sentence more conversational.

## G. Cinderfen Watch

What felt clear:

- Objective tracker points to `Capture the Watch Road`.
- Objective copy explains holding income while scouting the fog around the tower.
- The second and third objectives clearly name the Brute/tower push sequence.

What felt confusing:

- Skirmish/setup/results use `Cinderfen Watchpost`, while campaign/player-facing route language says `Cinderfen Watch`.

Feedback timing/noise:

- No launch-status issue observed.

What felt satisfying:

- Watch Road now reads like a practical first move.

Visual-art debt:

- Fog/tower/raised-road visual salience belongs to the future art overhaul.

Severity:

- Small polish now: align the player-facing map name with `Cinderfen Watch`.

## H. Defeat Case

What felt clear:

- Defeat results now give specific tips and no-save/no-reward honesty.
- Cinderfen-specific tip correctly says to secure side income, then claim the Cinder Shrine.

What felt confusing:

- A skirmish defeat showed `Use Camp Or Chapel Support`, but skirmish has no campaign camp or chapel preparation.
- The Cinderfen defeat title used `Cinderfen Causeway` while a tip used `Cinderfen Crossing`.

Feedback timing/noise:

- Defeat screen is persistent, so no timing issue.

What felt satisfying:

- The defeat screen now reads as advice rather than punishment.

Visual-art debt:

- Results background/panel art remains prototype-level.

Severity:

- Must fix now: campaign-only defeat action should not appear in skirmish.
- Small polish now: Cinderfen map-name consistency.

## I. Victory And Campaign Return Flow

What felt clear:

- Border Village victory results communicate hero level, rewards, node completion, bank resources, and next campaign path.
- Campaign return guidance says `Strengthen Your Hero`, with actions for inventory, items, skill points, and Old Stone Road.

What felt confusing:

- Results are still dense, but the new guidance card makes the top-level next action understandable.

Feedback timing/noise:

- Results and campaign return are persistent.

What felt satisfying:

- Victory now feels like it feeds back into a loop instead of ending abruptly.

Visual-art debt:

- Result panel density and reward-card art can improve later.

Severity:

- Defer: results density is a larger UI pass, not a v0.12.1 tiny fix.

## J. Skirmish Setup And Broken Ford

What felt clear:

- Map, difficulty, and AI personality choices are readable.
- Broken Ford description clearly says the center is dangerous and side resource routes are safer but slower.
- Difficulty descriptions are plain and useful.

What felt confusing:

- `Cinderfen Causeway` and `Cinderfen Watchpost` names are less consistent with the campaign route names than the rest of the setup.

Feedback timing/noise:

- No setup timing issue observed.

What felt satisfying:

- Skirmish setup is usable as a quick map-picker without extra explanation.

Visual-art debt:

- Map thumbnails/icons would help later but are outside scope.

Severity:

- Small polish now: Cinderfen setup naming consistency.
