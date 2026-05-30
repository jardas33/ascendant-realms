# v0.67 Elite Squad Foundation Implementation Report

## Summary

v0.67 adds occasional battle-only elite enemy squads using existing enemy unit types. Elites are meant to make milestone pressure more legible and memorable without creating a new roster or permanent enemy progression system.

## Runtime Changes

- Added two tiny elite squad definitions: Ash Raider Vanguard and Cinder Iron Guard.
- Limited elite eligibility by doctrine, mission type, milestone/champion/modifier context, and per-battle cap.
- Applied modest per-unit bonuses only: small max HP, small damage, and at most a small armor bonus.
- Tagged elite units with readable name, bonus summary, and counterplay copy.
- Recorded elite squad presence and elite defeats in battle stats for Results after-action copy.

## Balance Limits

- Elites use existing Raider, Brute, and enemy commander unit types.
- Elites are capped and never apply to Tutorial/no-reward or skirmish-training routes.
- No elite persistence, new art, new unit roster, enemy formation rewrite, or broad Act 1 stat tuning was added.

## Verification Notes

- Unit tests validate elite cap/frequency, eligible unit ids, modest stat values, and readable copy.
- Hosted Ashen Outpost coverage verifies Cinder Iron Guard appears in an eligible champion mission, has a modest stat bump, and appears in Results after-action copy.
- Act 1 telemetry remains part of the required release gate.
