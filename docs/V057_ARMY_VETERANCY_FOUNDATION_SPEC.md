# v0.57 Army Veterancy Foundation Spec

## Goal

Make ordinary battle units feel more legible and earned in the moment by exposing the existing live-battle veterancy loop without creating a new permanent army roster or save migration.

## Scope

- Player combat units can earn battle XP from damage, kills, and victory survival.
- Units can reach Seasoned, Veteran, or Elite during a battle.
- Rank bonuses remain modest: small HP and damage increases, with Elite adding a small armor bonus.
- Veteran state is carried by live unit instances and battle summaries. No new save fields are added.
- Existing Retinue Camp behavior remains unchanged and opt-in. This checkpoint does not add a new roster, campaign-wide unit list, or roster reward.
- Tutorial and rewards-disabled battles suppress persistent reward noise and should not become harder.

## XP Rules

- Damage contribution grants a small amount of unit XP.
- Kills grant XP based on the defeated target's existing XP value.
- Surviving a victorious battle grants a small survival bonus.
- Dead units can still appear in rank-up summaries if they ranked up before death, but only surviving units can be notable survivor candidates.

## Bonus Rules

- Recruit: no bonus.
- Seasoned: small HP and damage bonus.
- Veteran: modest HP and damage bonus.
- Elite: modest HP and damage bonus plus a small armor bonus.
- Bonuses apply only to live unit combat stats and should not globally rebalance unit definitions.

## UI Scope

- Selected unit panel shows rank, XP progress, kills, rank bonus, and battle-only status.
- Results can summarize rank-ups and notable surviving veterans.
- Copy should make it clear that normal battle veterancy is earned in the current battle, with no new permanent roster created here.

## Save Compatibility

- No save-version bump.
- No new save fields.
- Existing retinue save normalization continues to ignore unknown unit or rank ids safely.
- Existing old saves without retinue or veterancy data remain safe because normal battle units create fresh live veterancy state at spawn.

## Deferrals

- No permanent army roster expansion.
- No enemy veterancy.
- No per-unit equipment, skill trees, traits, names, or injury tables.
- No balance-wide unit stat overhaul.
