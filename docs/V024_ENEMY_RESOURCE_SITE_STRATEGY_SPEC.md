# v0.24 Enemy Resource Site Strategy Spec

Date: 2026-05-25

## Mission

Add the first controlled enemy strategy layer for the v0.22 and v0.23 resource-site economy. The enemy should now understand that capture sites are strategic territory: neutral sites are worth taking, lost sites are worth retaking, enemy-held sites can be defended, and upgraded sites are more valuable.

## Scope

v0.24 extends the existing `EnemyAIController` and `ResourceSystem` behavior. It does not add classic carry/dropoff harvesting, new maps, factions, units, buildings, runtime art, save migration, Patrol, formations, broad pathing work, or global balance changes.

## Site Awareness

The enemy classifies resource sites from its own perspective:

- Neutral: unowned sites that can be captured by moving a small squad into the ring.
- Friendly: enemy-owned sites that produce battle resources for the enemy.
- Enemy: player-owned sites that can be contested or retaken by moving a small squad into the ring.

The AI scores sites by:

- resource type and income amount,
- current site level,
- owner,
- distance from the enemy base or available squad,
- nearby player threat,
- nearby enemy support,
- whether the site was previously enemy-owned and is now player-owned.

## Expansion And Retake Rules

- The enemy may send small squads to neutral resource sites during expansion windows.
- The enemy may prioritize retaking a player-owned site that it previously controlled.
- The enemy should prefer high-value sites, but not blindly ignore distance and threat.
- The enemy should avoid site attacks when the nearby player force heavily outmatches the available squad.
- Site capture uses the existing movement and capture-ring systems. No direct ownership mutation is added for normal gameplay.

## Defense Rules

- The enemy should defend valuable enemy-owned sites when player units threaten the site ring.
- Upgraded enemy sites and high-income sites receive stronger defense priority.
- Defense uses existing attack commands against the threatening unit.
- Base defense still takes priority over site defense.

## Upgrade Rules

- Enemy site upgrades are allowed only for enemy-owned captured sites.
- The enemy uses the existing resource-site upgrade rules and pays from the enemy battle resource bank.
- Enemy upgrades are paced by cooldown and resource budget, so a newly captured set of sites cannot all upgrade instantly.
- Neutral and player-owned sites cannot be upgraded by the enemy.

## Readability

Readable feedback should come from existing status text, minimap pings, capture rings, and selected-site details. No new art or runtime assets are added.

Player-facing messages should be useful but not spammy:

- enemy capture or retake alerts are paced,
- enemy upgrade alerts are paced by the upgrade cooldown,
- site-under-attack warnings reuse the existing cooldown.

## Deferrals

- No enemy construction AI.
- No enemy Worker unit construction, hauling, cargo, or drop-off loop.
- No new resource buildings or site-building progress bars.
- No save persistence for site ownership, site upgrades, or enemy logistics.
