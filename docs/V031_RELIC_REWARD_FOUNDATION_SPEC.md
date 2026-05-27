# v0.31 Relic Reward Foundation Spec

Date: 2026-05-27

## Goal

Add a tiny relic/reward foundation that gives rival champion victories a readable RPG reward hook without creating a full inventory, equipment, persistence, or loot-table system.

## Relic Model

v0.31 relics are data-only reward previews:

- each relic definition has an id, name, source rival champion, description, effect copy, preview XP, preview resources, tags, and `preview_only` persistence status;
- the definitions are validated by content validation;
- the results screen can show a relic candidate after a victorious rival champion defeat;
- relics are not added to hero inventory;
- relics are not equipped;
- relics are not saved;
- no save migration is required.

## Initial Definitions

The foundation includes three small relic candidates:

- `Emberbrand Shard` from Gorak Emberhand;
- `Cinder-Seer Focus` from Veyra of the Cinders;
- `Outpost Command Signet` from Captain Malrec.

Their preview effects stay modest and future-facing: small XP plus a small resource amount if relic persistence is added later.

## Reward Rules

A relic preview appears only when:

- the battle outcome is victory;
- rewards are not disabled;
- the launch mode is not Tutorial;
- a known rival champion was present;
- that rival champion was defeated.

The preview does not grant resources, XP, inventory items, equipment, or campaign state in v0.31.

## Results UI Copy

The results screen uses existing result block styling and shows:

- `Relic Reward Preview`;
- relic candidate name;
- source champion;
- preview effect copy;
- explicit persistence warning: `Future persistence pending: this relic is shown for reward-readability testing only and is not added to inventory or saved.`

Tutorial results must not show this block.

## Deferrals

Deferred beyond v0.31:

- persisted relic collection;
- relic equipment slot behavior;
- inventory UI expansion;
- loot rarity expansion;
- random relic rolls;
- starting-resource bonuses in future battles;
- hero stat bonuses from relics;
- save migration.
