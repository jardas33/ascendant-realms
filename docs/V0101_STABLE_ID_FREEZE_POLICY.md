# v0.101 Stable ID Freeze Policy

Status: active for portable content validation.

## Frozen Snapshot

The stable ID snapshot lives at:

```text
src/game/portable/stable-id-snapshot.json
```

It records the current exported id set per category. `npm run validate:portable-content` compares current TypeScript definitions against this snapshot and fails if ids are added, removed, renamed, or reordered without an explicit snapshot update.

## Guarded ID Families

The snapshot and manifest guard the current ids for maps, campaign nodes, factions, hero classes, units, buildings, abilities, skills, relics, equipment, upgrades, Stronghold upgrades, campaign modifiers, battlefield events, enemy doctrines, elite squads, tactical plans, Lume networks, and exported capture sites.

## Allowed Future Changes

Future content may add ids only through an explicit content milestone. The author must update the TypeScript source, rerun the exporter with an intentional snapshot refresh, document why the new id is additive and safe, and rerun validation.

## Disallowed Changes

- Renaming stable ids to match display copy.
- Replacing serialized ids with player-facing labels.
- Hand-editing generated artifact JSON as authoritative content.
- Changing `CURRENT_SAVE_VERSION` for portable export reasons.
- Renaming map/node/site/class/unit/building/relic/skill/modifier/event/doctrine/Lume ids as part of visual or copy polish.

## Manual Review Questions

- Is this id referenced by existing saves, tests, campaign progression, battle launch, rewards, or package fixtures?
- Is the change additive, or is it really a rename?
- Does display copy solve the player-facing problem without changing the id?
- Is a migration needed? If yes, it is outside v0.101 scope.
