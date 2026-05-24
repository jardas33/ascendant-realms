# v0.20 Tech Tree Foundation Spec

Date: 2026-05-24
Status: implementation spec

## Baseline

- Starting commit: `a59248c`, `Checkpoint v0.19.1 production architecture verification and role polish`.
- Starting package: `ascendant-realms-private-playtest-a59248c`.
- GitHub Actions CI Release Matrix Dry Run #115 passed on `main` / `a59248c`: Fast confidence, Release simulator, and all hosted release groups succeeded. Optional visual QA and Full release e2e were skipped by input.

## Scope

Build the first clean upgrade and tech-tree foundation without turning v0.20 into a content or economy expansion.

Included:

- Explicit upgrade owner building metadata.
- Upgrade category metadata.
- Upgrade effect summary metadata for HUD readability.
- Small prerequisite/readability improvements.
- One Command Hall core upgrade.
- One Watchtower defensive upgrade.
- Focused tests and hosted browser coverage for building-owned research.

Not included:

- Harvesting.
- Repair.
- Multiple-worker acceleration.
- Enemy construction AI.
- New maps or factions.
- Runtime art/assets.
- Save migration.
- Broad AI/pathing rewrite.
- Global rebalance.
- Patrol or formations.
- Large new upgrade roster.

## Upgrade Categories

- `core`: Command Hall base/core upgrades.
- `infantry`: Barracks upgrades that improve basic melee or staying power.
- `ranger`: Barracks upgrades that improve Rangers.
- `aether`: Mystic Lodge magic/support upgrades.
- `defense`: Watchtower defensive upgrades.
- `faction_trait`: non-player or trait-style upgrade definitions that remain data-only unless a future system wires them in.

## Building Ownership

Command Hall:

- Trains Workers only.
- Owns core/base upgrades.
- v0.20 adds `Camp Foundations I`, a small core armor upgrade for the Command Hall.

Barracks:

- Owns basic army upgrades.
- Keeps Infantry Weapons I, Reinforced Armor I, and Ranger Training I.
- No numeric tuning changes are made to these existing upgrades.

Mystic Lodge:

- Owns Aether Study I.
- No new magic roster or extra Lodge upgrade is added.

Watchtower:

- Remains defensive.
- v0.20 adds `Sentry Bracing I`, a small defensive armor upgrade for Watchtowers.
- `Sentry Bracing I` requires completed Watchtower plus `Camp Foundations I`, creating one readable prerequisite link without changing the early Barracks/Mystic route.

## UI Requirements

Upgrade buttons must show:

- Cost.
- Owner building.
- Requirement/prerequisite copy.
- Short effect summary.
- Researched or researching state when applicable.

Incomplete buildings must keep all research locked and must not expose completed-building research buttons.

Completed buildings should continue to show role text, and role text should mention the building-owned upgrade role where relevant.

## Tutorial Requirements

- Keep Tutorial / Proving Grounds at the same step count.
- Add only light copy that completed buildings can unlock upgrades.
- Do not require a complex tech-tree chain to win or complete Tutorial.

## Deferrals

- Multi-tier army, magic, economy, and tower upgrade trees.
- Upgrade icons or new art.
- Upgrade save persistence outside the current battle.
- Enemy construction or enemy research AI.
- Harvesting or repair tech.
- Broad balance tuning based on upgrade timings or costs.
