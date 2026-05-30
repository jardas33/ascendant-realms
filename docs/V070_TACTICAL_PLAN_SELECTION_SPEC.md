# V070 Tactical Plan Selection Spec

## Goal

Add one launch-local tactical plan choice before eligible campaign battles. The plan should help the player act on doctrine intelligence without becoming a large strategy layer.

## Plans

### Guarded Advance

- Role: safe default, defensive/readiness support.
- Effect: modest Retinue reinforcement support through the existing battle launch modifier path.
- Counter-doctrine fit: Raider, Hunter, and Warband.
- Copy: protect Workers, sites, hero, and Retinue before committing.

### Resource Push

- Role: economy/site-control opener.
- Effect: small starting resource support through the existing battle launch modifier path.
- Counter-doctrine fit: Fortress and Raider when the player wants sustained production.
- Copy: capture and upgrade sites earlier, then convert economy into army.

### Champion Hunt

- Role: commander-target and ability-readiness support.
- Effect: modest hero readiness support through the existing battle launch modifier path.
- Counter-doctrine fit: Hunter, Warband, and commander milestone missions.
- Copy: keep the army near the hero and commit when the commander is exposed.

## Selection Rules

- Exactly one plan can be active for a campaign battle launch.
- If the player chooses nothing, Guarded Advance is used as the safe default.
- Plans are launch-local. They are not persisted in campaign or hero saves.
- Plan selection can be changed before launch.
- Tutorial/no-reward routes ignore tactical plans.
- Skirmish can omit tactical plans for now.

## Runtime Rules

- Effects are expressed through existing launch modifiers.
- Effects are conservative and non-stackable.
- Unknown tactical plan ids normalize to Guarded Advance for eligible campaign battles.
- Unknown tactical-plan launch modifiers are ignored by systems that do not understand them.

## UI Scope

- Campaign node details show selected plan, effect summary, recommendation fit, and change buttons.
- Battle HUD shows the active plan as a short status/objective line.
- Results show chosen plan and one after-action line.
- No new art, deck-builder, loadout screen, or persistence.

## Deferrals

- Multi-plan loadouts.
- Plan upgrades.
- Per-faction plan variants.
- Long-term strategic policy.
