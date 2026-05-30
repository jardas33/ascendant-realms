# v0.82 Linked Ward Balance And Readability Report

Status: implemented and ready for verification.

## Tuning

Linked Ward uses a conservative defensive benefit:

- Friendly units and buildings near active linked endpoint sites take 8% less incoming damage.
- The runtime damage multiplier is `0.92`.
- The multiplier is applied before armor through the battle-local combat damage adjustment hook.
- The benefit is non-stacking even if two links are active.

This matches the v0.81 preference for a modest defensive ward instead of a resource-income fallback.

## Why Defensive

The current game already has many economy layers: site income, Worker assignment, site upgrades, first-capture bonuses, Rich Veins, Resource Push, campaign resources, and replay reward rules. Adding another resource multiplier would be harder to read and easier to exploit.

Linked Ward instead creates a clear tactical loop:

1. Capture linked sites.
2. Defend near the endpoints.
3. Notice reduced incoming damage.
4. Respond when enemy recapture severs the link.

## Readability

The player sees the system in three places:

- Campaign briefing: one sentence before battle.
- HUD objective row: active/inactive/contested/severed status and counterplay.
- Selected site panel: linked site names and the defensive benefit.
- Results: activated/severed count and battle-local summary.

The copy intentionally stays short:

- `Linked Ward`
- `Hold linked sites`
- `Enemy recapture severs the link`
- `8% less incoming damage`

## Balance Boundaries

The prototype does not:

- change global damage, armor, HP, economy, AI, or rewards;
- stack across links;
- persist across battles;
- apply to enemy units;
- grant persistent objective rewards;
- alter Tutorial/no-reward battles.

## Watchpoints

Manual QA should check:

- Whether the 8% reduction is noticeable enough without feeling mandatory.
- Whether the player understands that recapturing both endpoints restores the link.
- Whether the HUD row stays compact under pressure.
- Whether Aether Well Ruins remains a resource-control mission instead of becoming a passive turtle route.

No tuning should be changed from automation alone unless a clear regression appears.
