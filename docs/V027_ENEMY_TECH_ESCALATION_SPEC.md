# v0.27 Enemy Tech Escalation Spec

Date: 2026-05-26

## Mission

Let enemy strategy escalate from early site pressure into tech-backed mid and late pressure. The enemy should spend its economy through existing upgrade rules, respect prerequisites, and become more coordinated only when its economy and map control justify it.

## Tech Priorities

Enemy tech priorities use existing upgrades and existing research queues:

- Core fortification: `camp_foundations_1` through the enemy base hub role.
- Military pressure: `infantry_weapons_1` and `reinforced_armor_1` through the enemy barracks role.
- Aether pressure: `aether_study_1` through the enemy hexfire support role when Aether income or Hexer pressure is relevant.
- Defense: `sentry_bracing_1` through existing enemy Watchtowers when the base or tower area is threatened.

The enemy must not research upgrades from neutral or player buildings. It must not bypass locked prerequisites such as `sentry_bracing_1` requiring `camp_foundations_1`.

## Escalation Stages

| Stage | Behavior |
| --- | --- |
| Early | Capture neutral sites, defend immediate base threats, launch only small readable raids. |
| Mid | Upgrade sites, defend high-value sites, begin core/military/aether tech if affordable, train mixed squads. |
| Late | If economy is healthy, coordinate stronger attacks from existing units while preserving a defensive reserve. |

Escalation depends on elapsed time, enemy site control, improved sites, stockpile health, and researched tech. It is not random spam.

## Cooldowns And Budgets

- Enemy tech research is delayed after battle start.
- Only one enemy tech plan may be queued per cooldown window.
- Active enemy upgrade queues block additional tech spending until the current plan has room to breathe.
- The enemy must pay normal upgrade costs from its battle resource bank.
- Site upgrades, abstract logistics, raids, and tech research each keep separate pacing so one healthy economy does not trigger everything at once.

## Pressure Limits

- Late pressure can select a slightly stronger wave only when economy/site control is healthy.
- The enemy does not globally increase unit stats outside researched upgrades.
- Raids continue to use existing units, movement, capture rings, and combat.
- Weak raids should regroup when outmatched.
- Base or high-value site defense can override attacks and raids.

## Readability

Useful player-facing status lines may include:

- `Enemy is fortifying.`
- `Enemy raid forming.`
- `Enemy defending site.`
- `Enemy pressure is escalating.`

These lines should be short, infrequent, and backed by visible movement, research, defense, or attack behavior.

## Testing Requirements

Focused tests should prove:

- enemy stage selection changes from early to mid or late from economy/site/time inputs,
- enemy tech choices depend on economy and site control,
- enemy uses existing upgrade queues and pays costs,
- prerequisites block locked upgrades,
- impossible or unsupported upgrades are not researched,
- base and site defense override risky raids,
- raids and attacks remain cooldown-paced,
- v0.24-v0.25 resource-site strategy and v0.22-v0.23 Worker/site behavior remain green.
