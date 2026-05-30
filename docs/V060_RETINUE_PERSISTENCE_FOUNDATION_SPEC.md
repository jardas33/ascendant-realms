# v0.60 Retinue Persistence Foundation Spec

## Goal

Turn the existing opt-in Retinue Camp into the first intentionally documented persistent army-continuity layer without creating a large permanent roster system.

## Rules

- Eligible Retinue entries are player combat units only: Militia, Ranger, and Acolyte.
- Workers, heroes, buildings, enemies, neutral units, and unknown future unit ids are not valid Retinue entries.
- A surviving Seasoned or better campaign unit can join through the existing Results Retinue action.
- The roster cap is small and explicit: five active Retinue units.
- Losses matter: a deployed Retinue unit that dies is removed after battle.
- Persistent identity is intentionally small: id, unit type, display name, rank, XP, kills, source battle, acquired time, status, battles survived, and missions deployed.

## Save Compatibility

- No save-version bump.
- Existing saves without Retinue fields load with an empty Retinue roster.
- Existing saves with older Retinue entries load safely; missing counters default to `0`.
- Unknown Retinue unit ids, invalid unit types, invalid ranks, and duplicate ids normalize away safely.
- Missing deployment selection defaults to the first active Retinue units up to the deployment cap, preserving old-save behavior.

## Deferrals

- No permanent control groups.
- No equipment, traits, injuries, wounded timers, or individual unit skill trees.
- No shop, crafting, mercenary hiring, or army-management overhaul.
- No enemy Retinue or enemy veterancy persistence.
