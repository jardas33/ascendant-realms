# v0.62 Survivor Continuity And Results Spec

## Goal

Make Retinue survivor continuity readable at battle end while keeping normal unit veterancy and persistent Retinue identity clearly separated.

## Survivor Rules

- Normal trained units still use battle-only veterancy unless the player opts to add an eligible survivor to the Retinue.
- Retinue units retain modest persistent rank identity through saved XP/rank/kills.
- Surviving deployed Retinue units update missions deployed and battles survived.
- Lost deployed Retinue units are removed from the active roster and deployment selection.
- Replay battles cannot create infinite Retinue growth because recruitment is opt-in, roster-capped, and duplicate ids are blocked.

## Results UI

- Results continues to show notable battle veterans.
- Retinue Camp Results copy shows roster capacity, eligible recruits, current Retinue, deployment selection, and loss permanence.
- After a successful Retinue recruit, the unit is added to the roster and auto-selected for deployment only if a slot is open.
- Tutorial and no-reward routes show no Retinue recruitment.

## Balance Limits

- Persistent bonuses remain the existing small veterancy rank bonuses only.
- No new Retinue-only stat multipliers.
- No enemy buffs or global balance changes.
- Act 1 telemetry must remain green.

## Deferrals

- No injury table.
- No squad traits.
- No Retinue reward currencies.
- No replacement/recruitment economy.
- No large post-battle roster-management flow.
