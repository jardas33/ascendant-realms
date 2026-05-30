# v0.67 Elite Squad Foundation Spec

## Goal

Add an occasional enemy elite squad marker using existing units only. Elite squads should make milestone pressure more readable, not create a new roster or inflate every battle.

## Elite Squad Model

Elite squads are battle-only tags applied to a capped number of existing enemy units at scenario spawn. They are not saved, not recruitable, and not a new faction or art pipeline.

Initial squads:

- Ash Raider Vanguard: up to two Raiders in eligible Raider or Hunter battles.
- Cinder Iron Guard: up to two Brutes, Raiders, or the enemy commander in eligible Fortress or Warband battles.

## Stat Rules

- HP multiplier is capped at +8%.
- Damage multiplier is capped at +6% for Raider Vanguard and +5% for Iron Guard.
- Armor bonus is capped at +1 and only used by the defensive squad.
- Elite tags never stack with another elite tag.

## Eligibility

Elite squads are allowed only in eligible campaign battles:

- commander or milestone battles,
- assault or defense battles,
- Fortified Enemy or Enemy Patrols modifier routes.

Tutorial and Skirmish / Training missions do not spawn elite squads.

## UI Scope

- Selected enemy units show elite name, modest bonus summary, and counterplay.
- Battle HUD doctrine panel shows the active elite label when present.
- Results shows elite squad present and defeated counts.

## Deferrals

- No elite art.
- No elite loot.
- No persistent enemy veterans.
- No large elite roster.
