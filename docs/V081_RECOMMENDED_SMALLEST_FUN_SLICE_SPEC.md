# v0.81 Recommended Smallest Fun Slice Spec

Status: docs-only future runtime spec. No Lume Network behavior was implemented.

## Recommendation

Use a mission-local Linked Control prototype:

- Mission: `aether_well_ruins` on `broken_ford`.
- Eligible sites: maximum three predefined sites.
- Active links: maximum two.
- Activation: capture-only for the first prototype.
- Benefit: one non-stacking defensive ward near active linked sites.
- State: battle-local only.
- UI: one HUD/objective row, selected-site status, compact Results line.
- Tutorial/no-reward: excluded.
- Save: no save-version bump, no new save fields.

## Candidate Sites

Recommended initial eligible sites:

1. `west_stone_cut`
2. `ford_toll`
3. `north_aether_spring`

Recommended first link:

- `west_stone_cut` <-> `ford_toll`

Optional second link if the first link is readable:

- `ford_toll` <-> `north_aether_spring`

Avoid using `south_iron_cache` in the first prototype unless testing shows the route needs a safer fallback node. Three eligible nodes are already enough.

## Player Goal

Briefing sentence for the future runtime prototype:

> Hold two linked sites to wake a Lume Ward. Enemy recapture severs the link.

This teaches:

- capture;
- relation between sites;
- active/inactive state;
- enemy severing;
- benefit feedback.

## Activation Rules

Future prototype rules:

- A link is inactive until both endpoint sites are player-owned.
- A link becomes active when both endpoints are player-owned at the same update tick.
- A link becomes severed/inactive if either endpoint becomes enemy-owned or neutral.
- Neutral contesting pauses capture as it already does. Lume does not need its own contest meter first.
- Active link count is capped at two.
- Link state is derived from live site ownership and the scenario's link definition.

## Benefit Recommendation

Primary benefit:

> Linked Ward: friendly units and friendly buildings within the radius of an active linked site gain a small defensive readiness bonus while the link remains active.

Recommended tuning for the future prototype:

- Non-stacking.
- Applies only inside endpoint site radii or a small padded radius.
- Defensive only, not a resource multiplier.
- Small enough to be readable without changing global balance.
- Disabled immediately when the link is severed.

Preferred implementation shape later:

- Start with a visible/readable status and modest damage reduction or armor readiness.
- Avoid passive global income, global hero damage, or broad production acceleration.
- If combat-stat hooks are too risky, use a battle-local objective completion bonus instead, but keep that as fallback.

Why not resource production first:

- The current economy already has site income, Worker boosts, upgrades, mission Rich Veins, tactical Resource Push, first-capture bonuses, campaign rewards, and replay rules.
- Another income multiplier risks hidden math and snowballing.
- Defensive warding better expresses living territory and creates a tactical defend/recapture loop.

## Hero Binding Posture

Default first prototype: no separate binding command.

Reason:

- Capture, Worker assignment, site upgrade, active objective, enemy pressure, Retinue, tactical plan, abilities, and relics already compete for attention.
- Binding would need new disabled reasons, progress, interruption behavior, hero pathing expectations, and tests.
- The first prototype should prove the network, not the binding verb.

Deferred option:

- If Emmanuel wants stronger Jardas identity, make binding optional on the same mission after capture-only is proven.
- A future binding action should apply only to eligible captured sites, be interruptible, require the hero, and remain battle-local.

## AI Posture

No new AI system is required.

The first prototype should rely on:

- existing resource-site capture/retake behavior;
- existing Raider/Fortress/Hunter/Warband doctrines;
- existing Site Under Threat event;
- existing enemy pressure plans.

Possible later tiny AI hook:

- Add a small target-score bump toward active linked sites on the selected mission only.

Do not rewrite pathing, enemy formations, or enemy economy.

## UI Posture

Future first runtime UI:

- Campaign briefing: one Lume Network sentence in `aether_well_ruins`.
- HUD/objective row: link title, endpoint names, active/severed/inactive state, one counterplay line.
- Selected site panel: "Lume: linked/inactive/severed" and benefit summary.
- Results: link activated/severed count and whether the Lume objective was completed.

No giant graph overlay, no minimap lines first, no new art.

## Save And Replay

- Do not persist Lume link state.
- Do not add campaign save fields.
- Do not change `CURRENT_SAVE_VERSION`.
- Replay can re-run the battle-local Lume objective, but persistent rewards remain governed by existing campaign reward and optional-objective rules.
- If a future optional objective records "Completed Lume link", use existing optional objective keys only if content validation explicitly allows it.

## Rollback

The runtime prototype should be isolated behind:

- one mission node;
- one scenario-local data definition;
- one small resolver/system;
- one HUD view model row;
- one Results row;
- focused tests.

Reverting that checkpoint should remove all runtime Lume behavior without save cleanup.
