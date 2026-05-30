# v0.61 Pre-Battle Deployment Spec

## Goal

Let the player choose a tiny number of saved Retinue units to bring into eligible campaign battles using the existing campaign map surface.

## Deployment Rules

- Deployment is campaign-battle only.
- Tutorial, skirmish, and rewards-disabled routes do not introduce Retinue deployment complexity.
- Base deployment cap is two Retinue units.
- Training Yard II keeps its existing identity by adding one deployment slot, for a maximum of three deployed units.
- The player can select or reserve Retinue units from the campaign Retinue Camp panel.
- If the deployment cap is reached, additional unselected units show a disabled reason instead of silently exceeding the cap.
- If no units are selected, the next battle launches normally with no Retinue units.

## Spawn Rules

- Selected Retinue units use the existing player-unit creation path.
- They spawn near the player start, close to the hero, using the current safe small offset pattern.
- Retinue units keep saved rank, XP, and kills.
- Retinue units behave like normal units once in battle, including selection, control groups, Patrol, group movement, and combat.

## UI Scope

- Campaign Retinue Camp shows roster count, selected deployment count, role, rank, XP, kills, battles survived, missions deployed, and deployment controls.
- Copy stays short: `Deploy`, `Reserve`, or `Deployment Full`.
- No new art, paper-doll UI, army roster screen, or drag-and-drop deployment board.

## Deferrals

- No deployment positioning editor.
- No per-mission unit restrictions beyond campaign battle eligibility.
- No saved formation or persistent control group linkage.
