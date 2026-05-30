# v0.81 Lume Network Design Principles

Status: docs-only design principles for the future Lume Site Network. No runtime implementation was added.

## Definition

The Lume Network is the future world-facing territorial strategy layer for the living land power of Salto and the Barrosan Marches. Lume is ancient power flowing beneath mines, springs, shrines, standing stones, roads, caves, ruins, villages, and mountains. It is part fire, part memory, part life-force, and part territorial bond. It is awakened and guided by a Jardas, not mined as a disposable commodity.

Mana remains separate. Mana is the tactical hero ability budget. Do not rename `Mana` or `maxMana`.

The existing `aether` resource id and Aether-labelled legacy IDs remain stable implementation details until a future explicit migration gate.

## Design Pillars

1. Capture: the player first understands Lume through existing captured strategic sites.
2. Binding: future hero binding can express Jardas identity, but the first prototype should not assume it is required.
3. Links: a small pair or chain of eligible sites can become active when conditions are met.
4. Junctions: later maps can treat special sites as stronger Lume junctions, but v0.81 recommends no junction runtime in the first slice.
5. Visible activation: active, inactive, contested, and severed states must be obvious during active RTS play.
6. Clear benefits: the first benefit must be one thing the player can feel, not a pile of invisible modifiers.
7. Enemy severing: enemy recapture must break or suspend the link so counterplay is natural.
8. Player counterplay: the player should respond by recapturing, defending, or repositioning, not by opening a graph screen.
9. Race extensibility: the first slice should establish neutral rules that future races can bend later.
10. Consequence-bearing future choices: later race-specific or oath-specific network choices can carry tradeoffs, but not in the first prototype.

## What The Lume Network Should Be

- A readable territorial strategy layer built from captured sites.
- A reason to care about how sites relate spatially, not only their resource output.
- A tactical objective that works during battle without a separate management screen.
- Compatible with existing Workers, site upgrades, enemy raids, mission modifiers, Retinue, hero skills, relics, and Results.
- Reversible in one checkpoint if the prototype is not fun.

## What It Must Not Become First

- A disconnected minigame.
- A puzzle overlay with constant babysitting.
- A giant graph-management UI.
- A second economy requiring new resource accounting.
- A global map rewrite.
- A save migration.
- A broad AI rewrite.
- A visual-effects spectacle.
- A reason to rename stable IDs.

## Recommended First Slice Philosophy

The first prototype should answer one question:

> Is it fun to capture and hold a small linked territory because the land itself visibly helps you defend or push from it?

That question does not require:

- more than one mission;
- more than three eligible sites;
- more than two active links;
- persistence;
- Living Mines;
- hero-binding UI;
- new units/buildings;
- race asymmetry;
- final art.

## Relationship To Existing Site Economy

Existing resource sites already do three jobs: capture territory, generate resources, and reward Worker/upgraded site care. The Lume Network should add a fourth meaning: spatial continuity. It should not replace site income or Worker assignment.

The first prototype should not make Workers obsolete. Workers can remain valuable because assigned and upgraded sites are still the safest anchors for holding linked territory.

## Relationship To The Jardas

The Lume Network should eventually make the Jardas feel special. However, the smallest runtime prototype should first prove the network itself is enjoyable.

Recommended posture:

- First prototype: capture-only activation.
- Optional teaching copy: "The Jardas senses the linked sites waking beneath the road."
- Deferred variant: a short hero binding interaction if Emmanuel wants stronger hero identity after reviewing v0.81.

This avoids introducing capture plus binding plus link defense all at once.

## Relationship To Future Races

The first slice should use a race-neutral or Barrosan-baseline expression: reliable stewardship of linked territory. Future races can later use the same structural vocabulary differently:

- Barrosan Freeholds: warded territory, recovery, reliable defense.
- Ashen Covenant: overcharged links with instability.
- Moura Court: veiled paths and bargains.
- Granitborn: living stone and durable junctions.
- Wolfveil Clans: trail marking and movement.
- Careto Host: disruption and rhythmic inversion.
- Rootbound Concord: biological spread and regeneration.
- Deepbell League: engineered resonance and tunnels.

None of these future variants should enter the first prototype.

## Naming Posture

For future display copy:

- Prefer `Lume` for living land-power.
- Keep `Mana` for hero abilities.
- Do not rename internal `aether`, `mission_aether_surge`, `aether_surge`, or `aether_lens` in the prototype.
- For `Aether Well Ruins`, the strongest future display direction is `Lume Well Ruins` because it preserves player readability and connects the mission directly to the prototype. `Old Spring Ruins` is warmer and less magical, but less directly teaches the system.

Runtime copy migration is deferred. v0.81 records the recommendation only.

## Rollback Principle

The first runtime Lume slice must be removable by reverting one checkpoint. It should leave no save fields behind and should not mutate stable IDs, campaign rewards, or Tutorial state.
