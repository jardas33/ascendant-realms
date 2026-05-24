# v0.18 Worker Construction Foundation Spec

Date: 2026-05-23
Status: foundation implementation spec

## Goal

Implement the first safe vertical slice of worker construction without turning the battle economy into a full worker economy yet.

The v0.18 player loop is:

1. Train one basic Worker from the Command Hall.
2. Select the Worker.
3. Use the Worker to place a Barracks.
4. The Barracks starts as an incomplete construction site.
5. The assigned Worker travels near the site.
6. Construction progresses over time only while that assigned Worker is alive and nearby.
7. The completed Barracks unlocks its normal production commands.

## Hard Scope

Included:

- one Worker unit for the Free Marches,
- Worker training from the existing Command Hall,
- Worker build command for Barracks only,
- assigned-worker construction progress,
- construction status/progress UI,
- validation for unit build options,
- focused unit/UI/browser tests.

Not included:

- multiple new factions,
- new maps,
- new art or runtime asset replacement,
- save migration,
- broad enemy AI construction,
- global economy rewrite,
- Patrol runtime,
- formations,
- harvesting,
- repairs,
- multiple workers per construction site,
- production-building rebalance.

## Baseline Assumptions

- v0.17.5 is the clean baseline.
- Existing Command Hall direct building placement remains available as the fallback route.
- Existing capture-site income remains the battle economy.
- Existing building art/placeholders remain authoritative for v0.18.
- Existing incomplete-building behavior already blocks production and upgrade queues, and v0.18 extends that behavior with Worker assignment.
- Tutorial remains stable and does not require Worker construction yet.

## Worker Data

Worker is a Free Marches unit with light combat stats and a construction role:

- role: Builder,
- cost: 50 Crowns,
- train time: 3 seconds,
- build options: Barracks,
- existing unit rendering conventions only.

The Worker is intentionally not a full harvester. Resource collection stays on capture sites.

## Command Hall

The Command Hall gains Worker training.

The existing Command Hall building-placement fallback remains available so older Tutorial and skirmish paths can still place Barracks directly while the Worker path proves stable.

No existing army-production fallback is removed in this pass. In the current data model, army production already belongs to Barracks/Mystic Lodge rather than Command Hall, so v0.18 does not move army unit production.

## Worker Build Command

Selecting a Worker shows a Build Barracks command using the same command panel conventions as building-owned build commands:

- visible cost,
- disabled when resources are insufficient,
- source id bound to the Worker,
- placement ghost anchored near the Worker,
- no train or upgrade queues on Worker selection.

## Construction Site

A Worker-placed Barracks stores:

- construction state,
- construction progress,
- assigned Worker id,
- assigned Worker display name,
- construction status detail.

Status examples:

- Worker assigned,
- Worker traveling,
- Worker building,
- Worker missing,
- Complete.

## Progress Rules

Construction progresses only when:

- the building is alive,
- the building is under construction,
- the assigned Worker exists,
- the assigned Worker is alive,
- the assigned Worker is near the building footprint.

For v0.18, one construction site has one assigned Worker. Additional worker acceleration is deferred.

Sites without assigned workers keep the legacy construction path so Command Hall fallback placement and existing test setups remain stable.

## Pathing And Blockers

Incomplete buildings remain normal building blockers for movement/pathing.

Worker construction movement uses the existing pathfinding grid and chooses a nearby walkable approach point outside live building footprints. The proximity check is footprint-based rather than center-radius based so a Worker held slightly short by friendly-unit separation near the Command Hall/Barracks cluster can still build when clearly adjacent to the site.

## UI Feedback

The UI must show:

- Worker training cost from the Command Hall,
- Worker Build Barracks cost,
- incomplete-building production lock copy,
- construction progress percentage,
- assigned Worker label,
- construction status,
- completed Barracks train commands after construction finishes.

Incomplete buildings must not show train or upgrade buttons.

## Save Format

No save format migration is included.

Current mid-battle construction state remains transient battle runtime state. Future persistent battle resume, campaign build queues, or worker economy saves must be separately scoped and versioned.

## Tutorial Impact

Tutorial does not require Worker construction in v0.18.

Tutorial can keep using existing Command Hall placement/training steps until the Worker path has survived human retest and a dedicated onboarding pass.

## Deferred Work

- worker repair,
- worker harvesting,
- multiple workers per site,
- cancellation/refund UI,
- enemy worker construction,
- full Command Hall role change,
- Tutorial Worker onboarding,
- save migration,
- production tech-tree rebalance.
