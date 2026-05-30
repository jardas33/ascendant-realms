# V069 Pre-Battle Intelligence Spec

## Goal

Turn enemy doctrine readability into actionable preparation before launch. Intelligence stays on existing campaign/pre-battle surfaces and does not create new scouting, map, save, shop, crafting, or art systems.

## Scope

- Eligible campaign battle nodes show a compact intelligence block.
- Tutorial and no-reward routes stay simple and do not show doctrine planning complexity.
- Intelligence is content-derived from existing mission type, scenario modifiers, enemy commander, doctrine, elite squad, Retinue, hero build, relic, and skill data.
- No save-version bump is needed because intelligence is computed at render/launch time.

## Player-Facing Fields

- Expected doctrine: Raider, Fortress, Hunter, Warband, or standard pressure.
- Doctrine summary: short threat read from the doctrine definition.
- Elite squad risk: expected elite squad label and counterplay if eligible.
- Mission modifiers: existing scenario modifier names and effects.
- Recommended counterplay: doctrine-specific, short, and non-binding.
- Retinue reminder: deployed/reserve units, recovery blockers, and once-per-battle reinforcement reminder.
- Hero build/relic hint: existing Warrior, Seer, Commander, equipped relic, and skill-point context when available.

## Rules

- Intelligence is shown only for campaign battle nodes that can use the existing battle launch path.
- Tutorial/no-reward launch mode suppresses doctrine and tactical-plan complexity.
- Unknown doctrine, elite, modifier, relic, or skill ids fall back to readable generic copy.
- Replays show the same mission intelligence, but rewards remain governed by existing replay-safe rules.

## UI Scope

- Use the existing campaign node details panel.
- Prefer one compact guidance card plus existing grid rows.
- No new art, modal, large strategy screen, or separate scouting UI.

## Deferrals

- Fog-of-war scouting reports.
- Mission-specific enemy build order reveals.
- Persistent intelligence upgrades.
- Spy/agent systems.
