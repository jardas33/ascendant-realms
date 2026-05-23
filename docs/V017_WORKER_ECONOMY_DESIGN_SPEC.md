# v0.17 Worker Economy Design Spec

Date: 2026-05-23
Status: design only for v0.17

## Goal

Move Ascendant Realms toward a clearer RTS economy loop where the Command Hall anchors the base, workers expand the settlement, production buildings train army units, and buildings unlock upgrades. This document does not authorize implementation in v0.17.

## Proposed Long-Term Model

- Command Hall produces workers, not army units.
- Workers construct and repair buildings.
- Barracks and later training buildings produce army units.
- Tech buildings and upgraded production buildings unlock additional unit options and upgrades.
- Resource sites remain the early map-control lesson, but workers make base growth feel more authored and readable.

## Command Hall Role

The Command Hall should be the base anchor and worker source. Its command surface would focus on:

- train Worker,
- set worker rally,
- emergency/base commands if needed later,
- defensive/base status.

It should stop being the long-term source of Militia, Rangers, Acolytes, or other army units once the worker loop exists.

## Worker Role

Workers would be non-combat or light-support units whose primary job is construction. A first implementation should keep them simple:

- select Worker,
- choose a building command,
- place a building on valid ground,
- worker travels to the site,
- construction completes after a timer,
- worker can be reassigned.

Worker behavior should avoid requiring complex gathering automation in the first pass. Existing capture-site income can remain the main battle economy while workers teach building placement and tech growth.

## Production Buildings

Barracks and training buildings should own army production:

- Barracks: core infantry and basic rally behavior.
- Mystic Lodge or equivalent: magic/support units.
- Future advanced buildings: higher-tier or specialist units.

This makes the player's choices easier to read: workers build the army infrastructure; production buildings train the army.

## Upgrade Unlocks

Buildings can unlock upgrades in two ways:

- Direct research: selecting the building shows upgrades it can research.
- Prerequisite unlocks: completed buildings unlock new unit buttons or upgrade tiers elsewhere.

The first implementation should prefer direct, visible relationships over hidden tech trees.

## Pros For RTS Feel

- Stronger classic RTS identity.
- Clearer separation between economy, construction, and army production.
- Better strategic pacing: expanding the base becomes a decision, not just a Command Hall menu.
- More meaningful enemy pressure: attacks threaten workers, construction sites, and production.
- Better future onboarding path for build orders and tech.

## Cons And Risks

- Tutorial complexity increases immediately if workers arrive too soon.
- Worker pathing and construction state can add failure cases around blocked sites, stuck workers, cancellation, and repairs.
- Existing no-reward Tutorial must avoid becoming too long.
- The current save model does not store mid-battle worker/build-state data, so persistence and migration must be planned carefully before campaign integration.
- AI needs construction logic eventually; otherwise the player and enemy economies diverge in confusing ways.

## Required UI Changes

- Command Hall panel needs Worker training and worker rally commands.
- Worker selection panel needs building commands.
- Placement UI should explain builder requirements, blocked tiles, construction cost, and cancel.
- Construction sites need clear progress and ownership.
- Production-building panels need unit training and upgrade sections that stay readable.
- Tutorial overlay should call out Worker -> build Barracks -> train army as separate steps once the system exists.

## Required AI Changes

- Enemy AI must decide when to create workers, build production, rebuild losses, and protect construction.
- AI pressure plans need to understand worker/building targets.
- Deterministic playtest simulators need worker construction timing and failure modes.
- Content validation must ensure AI build plans reference valid buildings, units, terrain, and prerequisites.

## Save And Migration Concerns

- v0.17 must not change the save format.
- A future implementation should version any persistent campaign/build unlocks explicitly.
- Existing saves should normalize safely when worker-related fields are absent.
- Mid-battle construction state should remain transient unless a future save/resume feature is deliberately scoped.
- Migration tests should cover older saves, campaign node progress, stronghold upgrades, inventory, and tutorial no-save behavior.

## Recommended Phases For v0.18+

1. Design final Worker unit definition, UI command list, construction rules, and validation rules without enabling it in campaign.
2. Add Worker training and one Worker-built Barracks path in a test-only or tutorial-only sandbox.
3. Add focused unit tests for worker orders, construction progress, cancellation, blocked placement, and no-save Tutorial behavior.
4. Add Playwright smoke coverage for Worker -> Barracks -> Militia in a controlled route.
5. Teach enemy AI a minimal authored build plan only after the player loop is stable.
6. Update Tutorial steps and docs after the runtime is reliable.
7. Consider campaign/save migration only after the battle-only loop survives verification.

## v0.17 Boundary

Do not implement worker construction, new worker units, new buildings, production rewrites, global balance changes, save changes, runtime art/assets, or new maps/factions in v0.17. This spec is the design runway for later checkpoints.
