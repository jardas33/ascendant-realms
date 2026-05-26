# v0.29 Hero Abilities And Rewards Spec

Date: 2026-05-26

## Mission

Make active hero abilities and battlefield rewards readable enough to support the stronger v0.24-v0.27 RTS pressure loop. v0.29 uses existing Warlord/Arcanist/Shepherd ability definitions and the existing reward/results flow; it does not add new runtime art, a new inventory layer, enemy hero ability parity, or a large ability roster.

## Active Ability Foundation

The ability foundation must provide:

- cooldown tracking,
- mana costs,
- readiness/disabled states in the existing HUD,
- command buttons for unlocked abilities,
- keyboard hotkeys through the existing `1`, `2`, and `3` input path,
- clear messages for invalid casts such as cooldown, missing mana, or missing targets.

The first safe player-facing examples are already data-backed:

- Rally Banner / Rally Cry style command buff: nearby allies receive a short damage boost.
- Cleave / Heroic Strike style burst: nearby enemies take a small area hit.

Other existing class abilities can remain data-defined, but this checkpoint should not expand the roster.

## Targeting And Effects

- Buff abilities affect living friendly units in range.
- Damage abilities affect hostile living units/buildings in range.
- Ability casts spend mana only when an effect succeeds.
- Cooldowns start only after a successful cast.
- Repeated button presses or hotkeys while cooling down cannot spam the effect.

## Reward Flow

Battlefield rewards remain lightweight:

- live battle XP is summarized on the results screen,
- victory reward XP is listed separately from battle performance XP,
- campaign node XP is shown in the campaign reward block,
- no complex loot, inventory overhaul, or item/relic expansion is part of v0.29.

## Tutorial Impact

Tutorial / Proving Grounds keeps the existing no-reward rule. It may explain ability cooldowns and hero XP, but it should not require extra RPG management or make the tutorial longer than necessary.

## Fairness Rules

- Abilities should help recover from raids and site pressure without trivializing early enemy attacks.
- Cooldowns and mana costs should remain visible and conservative.
- Enemy AI does not gain player-style hero ability usage in this checkpoint.
- Ability UI changes must use existing HUD markup and copy only.

## Deferrals

- Enemy hero progression or skill trees.
- New ability schools, targeting UI, or VFX assets.
- Items, relics, loot rarity changes, or equipment overhaul.
- Save migration.
