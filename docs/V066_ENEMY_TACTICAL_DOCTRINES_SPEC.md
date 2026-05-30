# v0.66 Enemy Tactical Doctrines Spec

## Goal

Add small, readable enemy doctrine profiles that make current battles feel more intentional without new factions, maps, units, art, or global balance changes.

## Doctrine Model

Doctrines are content-driven battle metadata. They are derived from campaign node mission type, active mission modifiers, and enemy commander context. They are not saved and they do not create campaign migration requirements.

Initial doctrines:

- Raider: pressures resource sites, assigned Workers, and exposed economy routes.
- Fortress: keeps reserves near base/sites and favors defensive upgrades.
- Hunter: sends escorted probes toward the hero or deployed Retinue only after a cooldown.
- Warband: adds a modest late mixed-push identity without increasing early spam.

## Mission Hooks

- Control missions prefer Raider unless a specific commander route is better suited to Hunter.
- Assault missions prefer Fortress or Warband depending on fortified modifiers and commander context.
- Defense missions prefer Warband.
- Fortified Enemy strengthens defensive doctrine behavior through existing reserve and AI modifier hooks.
- Enemy Patrols modestly increases doctrine activity cadence.

## Runtime Rules

- Doctrines use existing AI actions: site raids, reserves, tech choices, and attack waves.
- Doctrine actions are cooldown-gated and recorded as battle telemetry labels.
- Tutorial and Skirmish / Training routes do not receive doctrine complexity.
- No doctrine may bypass existing pathing, targeting, selection, or reward rules.

## UI Scope

- Campaign node briefing shows doctrine, threat read, and counterplay line.
- Battle HUD objective panel shows doctrine status and counterplay.
- Results summarizes doctrine actions and elite squad outcomes.

## Deferrals

- No enemy formation rewrite.
- No permanent doctrine progression.
- No new AI planner.
- No hidden difficulty scaling beyond the modest, mission-local hooks documented here.
