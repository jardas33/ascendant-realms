# v0.78 Display Name Migration Map

Date: 2026-05-30

## Status

This is a migration-safety document only. v0.78 does not rename runtime identifiers, folders, save fields, campaign nodes, abilities, units, buildings, maps, items, relics, or factions.

## Prohibited During v0.78

Do not rename:

- `free_marches`,
- `ashen_covenant`,
- `sylvan_concord`,
- current map IDs,
- current item IDs,
- current node IDs,
- current ability IDs,
- current unit IDs,
- current building IDs,
- current save fields,
- current save-version values.

## Proposed Display-Name Map

| Stable internal identifier | Current prototype-facing name | Proposed future player-facing name | Lore term | Change type | Migration risk | Human approval |
| --- | --- | --- | --- | --- | --- | --- |
| Repository/project folder | Ascendant Realms | JARDAS: Oath of the Barrosan Marches | Jardas | Docs/title only for now | Runtime/repo rename prohibited | Required |
| `free_marches` | Free Marches | Barrosan Freeholds | Salto, Barrosan Marches | Future display copy | Save-safe if display-only; ID rename prohibited | Required |
| `ashen_covenant` | Ashen Covenant | Ashen Covenant | Captain Malrec | No likely change | Low if display remains | Required for lore framing |
| `sylvan_concord` | Sylvan Concord | Rootbound Concord | Root network | Future display copy | Save-safe if display-only; ID rename prohibited | Required |
| `ashen_outpost` | Ashen Outpost Finale | Ashen Outpost Finale | Act 1 - Ashes over Salto | Future chapter/campaign copy | Save-safe if display-only; node ID rename prohibited | Required |
| Hero role/class IDs | Warlord, Arcanist, Shepherd | Marshal/Warden, Seer/Binder, Shepherd | Oath classes | Future design mapping | Save migration likely if IDs change | Required |
| Resource concept | Aether/Mana in places | Lume where appropriate | Lume | Future copy/lore migration | Requires careful UI/content pass | Required |
| Opening village copy | Prototype campaign area | Salto | Salto | Future display/narrative pass | Requires campaign copy review | Required |

## Change Categories

- Internal stable identifiers: must remain as-is until a dedicated migration gate exists.
- Current prototype-facing names: safe to document; not automatically approved for runtime change.
- Proposed future player-facing names: human-review candidates.
- Lore terms: may guide future docs and art, but do not alter runtime now.
- Copy-only future changes: possible only in a scoped text migration.
- Changes requiring migration: any ID, save field, node ID, item ID, class ID, or serialized value.
- Changes requiring save migration: any persisted identifier rename.
- Changes requiring asset updates: title/logo, faction visuals, icons, audio callouts, voice.
- Changes requiring human approval: all public title, race, class, and lore naming.
- Explicitly prohibited during v0.78: all runtime identifier and save changes.

## Future Migration Gate Requirements

Before any runtime display-name migration:

1. list every affected source/data file,
2. separate display strings from serialized IDs,
3. add tests proving old saves load,
4. verify package/build metadata,
5. update tester docs,
6. run a focused browser/readability pass.
