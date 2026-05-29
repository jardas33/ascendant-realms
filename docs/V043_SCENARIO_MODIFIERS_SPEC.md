# v0.43 Scenario Modifiers Spec

Date: 2026-05-28

## Goal

Attach small, readable scenario modifiers to existing campaign battles so missions vary without global rebalance, new factions, new maps, or new art.

## Modifier Rules

Scenario modifiers are data-driven campaign modifiers with mission-local launch behavior. Initial examples:

- Rich Veins: resource sites produce slightly more.
- Enemy Patrols: enemy pressure arrives slightly faster.
- Fortified Enemy: enemy defensive posture is slightly stronger.
- Aether Surge: hero mana pacing is slightly favored.

Values must remain conservative, visible in briefing and Results, and easy to test. Multiple modifiers can exist on a mission, but stacking should stay modest and must not become a hidden difficulty spike.

## Runtime Scope

Allowed hooks:

- adjust capture-site income on the affected mission only;
- adjust enemy attack pacing or defensive squad size through existing AI configuration only;
- adjust hero mana through the existing campaign modifier hero effect path.

Not allowed:

- new AI planner or pathing behavior;
- global balance changes;
- new unit definitions;
- Tutorial difficulty changes;
- force-click or DOM fallback changes in browser tests.

## Persistence and Unknown Ids

Scenario modifier ids are declared on campaign node content and passed through existing battle launch modifiers. They are not stored as new save state. Existing active campaign modifier saves still normalize through known modifier ids; unknown ids continue to be ignored by save and validation rules where applicable.

## UI Scope

- Campaign node details list known scenario modifiers with one-line summaries.
- Battle start summary can reuse existing launch modifier copy.
- Results list active mission modifiers and the after-action summary.

## Deferrals

- Low-supply resource penalties.
- Large modifier catalog.
- Randomized modifiers.
- Player-selected difficulty mutators.
- Modifier-specific art, icons, or map decoration.
