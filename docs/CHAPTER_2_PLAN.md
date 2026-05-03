# Chapter 2 Plan - v0.3 Vertical Slice

Status: planning/specification plus minimal non-playable scaffold metadata.

Date: 2026-05-03

This document defines a controlled Chapter 2 vertical slice for Ascendant Realms. It is not an implementation task. Do not add maps, factions, units, workers, enemy construction, diplomacy, procedural generation, crafting, or balance changes from this plan alone.

## Minimal Scaffold Added

The current prototype includes only a harmless Chapter 2 scaffold:

- Campaign chapter metadata exists for Chapter 1: Border Marches and Chapter 2: The Cinderfen Road.
- The campaign map can show Chapter 2 as locked/upcoming after Ashen Outpost.
- `cinderfen_overlook` is a non-playable event placeholder explaining that Chapter 2 is future content.
- `cinderfen_crossing` is a locked future battle placeholder with requirements and the future `Cinderfen Causeway` label.
- No Chapter 2 battle map, unit, faction, worker flow, enemy construction, diplomacy, procedural generation, crafting, or balance content has been implemented.
- The future battle placeholder intentionally cannot launch a missing map; tests cover the launch guard.

## Planning Goals

- Keep Chapter 2 small enough to verify end to end.
- Reuse the existing campaign node, battle launch, rival persistence, trophy, Stronghold, retinue, reputation, enemy hero, affixed loot, Results, and playtest simulator systems.
- Add only one new biome/theme and one new battle map when implementation begins later.
- Add at most one new enemy unit type later, and only if the existing Ashen roster cannot carry the map identity.
- Add one new campaign event node later.
- Add one town/service addition later.
- Add one returning-rival consequence later.
- Avoid new save systems unless existing campaign node/choice/town/rival save fields are enough.

## Hard Non-Goals For v0.3

- No workers.
- No enemy construction or rebuilding.
- No full new faction.
- No diplomacy screen or alliance simulation.
- No procedural campaign or procedural maps.
- No crafting, durability, affix rerolling, or broader loot complexity.
- No full trophy room.
- No broad army-management layer.
- No Chapter 3 hooks beyond a simple final node teaser.

## Working Theme

Working title: **The Cinderfen Road**.

Theme: an ash-glass wetland and ruined causeway east of the Border Marches, where old aether runoff has hardened the marsh into black reeds, pale water, and cracked glass flats.

Why this theme fits now:

- It gives Chapter 2 a clear visual and tactical identity without requiring a new faction.
- It can reuse the Ashen Covenant as the primary enemy force.
- It gives Veyra, Gorak, or Malrec a believable reason to reappear without a full nemesis campaign.
- It supports existing systems: fog, capture sites, neutral camps, rival warnings, retinue deployment, Stronghold preparation, reputation choices, and affixed loot.

## Narrative Hook

After Captain Malrec's outpost falls or repels the player, refugees and Marcher scouts report that the eastern causeway through the Cinderfen is still open, but Ashen raiders and hexfire cultists are using old waystones to move supplies. The hero is asked to secure one crossing, recover a route marker, and decide whether to protect civilians, exploit salvage, or press the Ashen route before it hardens into a second front.

The chapter should feel like the hero is leaving the tutorial borderlands and entering contested territory, not like a full new campaign layer.

## Mini-Chain Proposal

Target size: 5 nodes.

| Order | Node concept | Type | Reuses | Purpose |
| --- | --- | --- | --- | --- |
| 1 | Cinderfen Crossing | Battle | One new `cinderfen_causeway` map, existing Ashen Covenant, existing AI personalities, existing enemy hero hooks if clean | Introduce the biome and prove the new battle map. |
| 2 | Ashglass Survey | Event | Existing campaign choice/reputation/resource reward rules | One choice node that previews the chapter's reputation and preparation tradeoffs. |
| 3 | Fenwarden Camp | Town/service | Existing town service rules, campaign resources, campaign modifiers where already supported | One compact service addition for preparation, not a vendor system. |
| 4 | Reedline Ambush | Battle | Same `cinderfen_causeway` map, different difficulty/personality/reward tuning if current data allows | Reuse the single map for a second read on retinue, Stronghold, and rival pressure. |
| 5 | Waystone of the Cinderfen | Shrine/ruin capstone | Existing node reward, reputation, item reward, and unlock rules | Close the slice, grant a measured payoff, and tee up future Chapter 2 expansion without implementing it. |

Implementation note for later: if using the same battle map for two nodes feels too repetitive, keep only one Chapter 2 battle node for v0.3 and let the remaining chain be event/town/shrine. Do not add a second battle map just to pad the slice.

## One Battle Map Concept

Map concept: **Cinderfen Causeway**.

Role: contested wetland crossing with a readable central road, slower side-resource routes, and one risky aether objective.

Intended tactical questions:

- Can the player secure a forward resource under fog without overextending?
- Does retinue help the opener without replacing normal Barracks production?
- Do Stronghold paths feel like preparation choices rather than mandatory gates?
- Can a returning rival warning be understood before the fight peaks?

Suggested structure for later implementation:

- Size near Broken Ford or Ashen Outpost, not larger.
- One central causeway lane with blocked marsh/glass terrain shaping movement.
- Two safe-ish side resources and one contested aether or shrine site.
- Existing Free Marches starting roster and buildings.
- Existing Ashen Covenant enemy roster by default.
- Existing `enemy_commander` slot available only if the returning-rival consequence is implemented cleanly.
- No new terrain system; use existing zones, paths, blocked terrain, capture sites, and neutral camps.

Optional enemy unit later: one Cinderfen-themed Ashen unit only if required. Default plan is no new unit. If added, it must be a single data-driven unit with existing combat/status effects and validation coverage, not the start of a new faction roster.

## One Event Node Concept

Event node: **Ashglass Survey**.

Purpose: one compact campaign choice that gives the player a readable role-play and preparation decision.

Possible choices for later implementation:

- Protect the scouts: costs Crowns or Iron, grants Common Folk and Free Marches reputation, modest XP, and a small resource reward.
- Salvage ashglass: grants Stone/Aether, risks Ashen Covenant reputation loss or a minor future pressure modifier if existing rules support it.
- Ask the Old Faith to read the glass: costs Aether, grants Old Faith reputation, previews the next node, and may grant a small support item.

Rules:

- Exactly one new event node for the v0.3 slice.
- Use existing event choice requirements, costs, rewards, reputation previews, and claimed-choice tracking.
- Do not add dialogue trees, procedural events, or multi-step quest state.

## One Town / Service Addition Concept

Town/service concept: **Fenwarden Camp** or one new Marcher Camp service unlocked by Chapter 2.

Preferred compact version: add one service rather than a whole shop.

Possible service:

- Hire Fen Guides: spend Crowns and Aether for a one-battle preparation effect or resource package that helps scouting and staging.

Implementation guardrails for later:

- Prefer existing campaign modifier shapes or simple resource conversion.
- Keep the effect smaller than a Stronghold upgrade.
- Do not add a vendor economy, mercenary roster, repair system, or service tree.
- Show requirements, costs, and one-battle scope clearly in the campaign UI.

## Returning Rival Consequence

Goal: make prior rival state matter once without expanding into a full procedural nemesis system.

Concept: **Rival Shadow**.

Rules for later implementation:

- Look at existing rival state for Gorak Emberhand, Veyra of the Cinders, and Captain Malrec.
- If one rival last escaped or triumphed, the Chapter 2 battle preview and battle-start copy call out that rival's influence.
- Apply at most one existing small modifier style, such as the current +5% HP or +5% damage rival modifier.
- If several rivals qualify, pick one by a simple priority rule: most recent encounter first, then triumphant over escaped.
- If a rival was already defeated and their first-defeat reward/trophy was claimed, show flavor or respect copy without adding another first-defeat reward.
- Repeat rival defeats must not duplicate first-defeat rewards or trophies.

Possible rival reads:

- Gorak Emberhand: raider reprisal copy and melee pressure flavor if he escaped or became emboldened.
- Veyra of the Cinders: hexfire omen copy and a caster-pressure warning if she escaped or became emboldened.
- Captain Malrec: disciplined outpost survivor copy if he triumphed or survived the Ashen Outpost path.

Guardrail: this is one consequence hook, not rival leveling, rival skill trees, capture/recruit outcomes, or procedural rematches.

## Reward Philosophy

Chapter 2 rewards should feel like a new step forward without invalidating the v0.2.1 economy.

Use:

- Moderate hero XP and campaign resources.
- One first-clear item or weighted item table with existing affix generation.
- Reputation shifts that make prior choices visible.
- Existing rival trophy state and duplicate-prevention rules.
- Retinue/veterancy visibility through Results, not broader army persistence.

Avoid:

- Large resource injections that buy too much Stronghold power at once.
- Repeatable rival reward farming.
- Crafting materials, reroll currency, durability, or item-upgrade chains.
- Mandatory rewards that make retinue or Stronghold paths required.

## Telemetry Expectations

Before implementation is accepted later, the simulator should answer:

- No-retinue baseline: can Safe Beginner complete the first Chapter 2 battle?
- One Veteran Militia and one Veteran Ranger: do they help without making the opener automatic?
- Mixed retinue: does it trigger human-review only, not structural too-easy?
- Training Yard II and Quartermaster II paths: do they remain optional preparation advantages?
- Returning rival consequence: does the modifier remain readable and small?
- First contact timing: does the player have time to capture, build, train, and read the rival warning?
- Reward impact: does the Chapter 2 first-clear reward help without making later Stronghold purchases automatic?

Suggested simulator additions later:

- Add a Chapter 2 profile group only after the map and nodes exist.
- Track `chapterId`, `returningRivalId`, `returningRivalConsequence`, retinue profile, Stronghold path, first contact timing, commander/rival defeated state, and structural verdict.
- Keep existing no structural `too_hard` and no structural `too_easy` gates.
- Treat mixed-retinue sweeps as human-review warnings before changing numbers.

## Implementation Phases For Later

1. Baseline gate
   - Confirm v0.2.1 tests, build, full e2e, playtest simulator, and rival/retinue readability report are current.

2. Content data skeleton
   - Add Chapter 2 node definitions behind existing campaign prerequisites.
   - Add content validation before any tuning.
   - Do not add new save fields unless existing campaign state is insufficient.

3. Battle map vertical slice
   - Add only `cinderfen_causeway`.
   - Use existing units, buildings, capture sites, neutral camps, terrain zones, objectives, AI personalities, and reward table structure.
   - Avoid the optional new enemy unit unless the map identity is failing with existing units.

4. Event and service slice
   - Add exactly one event node.
   - Add exactly one town/service addition.
   - Use existing choice, reputation, campaign bank, and modifier display rules.

5. Returning rival consequence
   - Add one compact rule path based on existing rival state.
   - Keep modifiers at the current tiny rival scale.
   - Cover duplicate reward prevention.

6. Rewards, telemetry, and docs
   - Add a small reward table and first-clear reward.
   - Extend simulator reporting only as needed for the new chapter fields.
   - Update design, balance, content guide, roadmap, QA, handoff, and telemetry docs.

7. Verification and human review
   - Run unit tests, build, full e2e, and playtest simulator.
   - Perform a short human-paced pass focused on map readability, retinue usefulness, rival warning clarity, and reward pacing.

## Risks

- Scope creep into a full new faction because the new biome invites new enemies.
- One battle map may feel repetitive if reused for two battle nodes.
- Retinue plus Training Yard II could trivialize the first Chapter 2 battle.
- Quartermaster II could make the early build order too forgiving if Chapter 2 starting resources are too generous.
- Returning rival logic could become a hidden dynamic system if not kept to one simple consequence.
- Rival/trophy Results copy could crowd the existing Results screen.
- New event/town choices could make campaign resources too abundant.
- Fog and captured-site readability may regress on a new map if resource sites sit too far from player vision.

## Test Plan For Later Implementation

Unit/content tests:

- Chapter 2 campaign node references are valid.
- New map id, reward table id, faction id, AI personality id, enemy hero id, item ids, resource ids, and reputation ids validate.
- Event choices show requirements, costs, reputation previews, claimed state, and rewards.
- Town/service addition shows costs, repeat/once-only behavior, and one-battle scope.
- Returning rival consequence selects at most one rival and applies only supported small modifiers.
- Repeat rival defeats do not duplicate first-defeat rewards or trophies.

Save tests:

- Old saves normalize safely.
- Existing campaign node, choice, town service, retinue, rival, and trophy state continues to load.
- Chapter 2 node completion and reward claiming do not duplicate rewards.

E2E tests:

- Seed a post-Ashen campaign and verify Chapter 2 nodes are visible/locked/unlocked correctly.
- Open the event node and verify choice costs, reputation preview, and completion or kept-open behavior.
- Open the town/service addition and verify service copy, cost, and claimed/use state.
- Launch the Chapter 2 battle and verify the map boots, retinue deploys, battle-start copy appears, and no console errors occur.
- Seed a known rival state and verify node preview, battle-start warning, Results outcome, and Campaign Map Rival Intel after return.
- Verify Results shows Chapter 2 reward, affix copy, notable veterans, retinue eligibility, and duplicate rival reward prevention where relevant.

Simulator tests:

- Add Chapter 2 scenarios to the deterministic simulator after content exists.
- Include no retinue, one Veteran Militia, one Veteran Ranger, mixed retinue, Training Yard II, and Quartermaster II profiles.
- Confirm no structural too-hard or too-easy nodes.
- Confirm any mixed-retinue sweep becomes human-review rather than an automatic numeric nerf.

Manual/browser review:

- Verify the new biome reads clearly without final art.
- Check fog, minimap, capture-site visibility, side-panel scrolling, command hover stability, rival warning clarity, and Results readability.
- Time the first 10 minutes with and without retinue.

## Acceptance Criteria For Future v0.3 Implementation

- Chapter 2 adds exactly one new battle map.
- Chapter 2 uses existing factions by default.
- Chapter 2 adds no workers, enemy construction, diplomacy, procedural generation, or crafting.
- Chapter 2 contains a compact 4-6 node mini-chain.
- The event/town/rival/reward additions are visible and test-covered.
- Retinue and Stronghold help but are not mandatory.
- Returning rivals add drama without unfair snowballing.
- Unit tests, build, full e2e, and playtest simulator pass.
