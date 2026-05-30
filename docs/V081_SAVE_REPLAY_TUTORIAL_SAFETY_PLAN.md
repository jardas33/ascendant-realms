# v0.81 Save, Replay, Tutorial Safety Plan

Status: docs-only safety plan. No save fields, migrations, or runtime behavior changed.

## Save Format Recommendation

The first Lume Site Network prototype should not change the save format.

Do not:

- bump `CURRENT_SAVE_VERSION`;
- add fields to `CampaignSaveData`;
- add fields to `HeroSaveData`;
- persist site ownership;
- persist link state;
- persist active benefits;
- rename stable IDs;
- migrate `aether`, `mission_aether_surge`, `aether_surge`, `aether_lens`, or `maxMana`.

## Why No Save Fields Are Needed

The recommended first slice is battle-local:

- eligible links come from scenario content;
- active state is derived from live `CaptureSite.owner`;
- severed state is derived during the battle;
- Results can show battle stats;
- campaign completion and rewards already use existing systems.

No persistent network progression is needed to decide whether the prototype is fun.

## Old Save Safety

Existing saves should continue to load because no schema changes are recommended. `src/game/save/SaveNormalization.ts` already normalizes unknown/legacy Retinue, modifier, rival, item, equipment, and optional objective data safely.

If a later runtime prototype adds battle stats, those stats should not be required for loading old saves.

## Replay Safety

Future Lume prototype replay rules:

- Completed battle nodes remain replayable through existing campaign rules.
- Lume link state resets at battle start.
- Lume objective can be attempted again for practice.
- First-clear campaign rewards do not duplicate.
- Unique relic rewards do not duplicate.
- Optional objective credit does not duplicate.
- No persistent Lume reward should be granted in the first prototype.

If a future Lume optional objective is added, record it using the existing optional objective completion model and one-time key rules only after content validation supports it.

## Tutorial And No-Reward Protection

Tutorial must remain excluded.

The future enable check should require:

- `request.mode === "campaign_node"`;
- `request.rewardsDisabled !== true`;
- exact selected campaign node id;
- exact expected map id.

Do not show Lume rows or grant Lume credit in:

- Tutorial / Proving Grounds;
- skirmish;
- no-reward scenarios;
- missing-node fallback launches.

## Reward-Farming Protection

First prototype:

- No persistent Lume reward.
- No repeatable unique item.
- No repeatable campaign resource reward.
- No permanent hero stat reward.

Allowed:

- battle-local ward;
- battle-local objective note;
- Results summary;
- optional first-time objective credit only if a later explicit runtime goal approves it.

## Rollback Safety

The future runtime checkpoint should be rollback-safe if:

- all state is battle-local;
- all definitions are content-driven;
- UI is limited to existing surfaces;
- no save migration is introduced;
- no package/runtime title changes are included;
- no stable IDs are renamed.

Rollback should mean reverting the checkpoint commit, not writing a data migration.

## Test Obligations For The Future Prototype

Minimum tests:

- old saves load without Lume fields;
- Tutorial launch has no Lume state;
- no-reward launch has no Lume state;
- replay does not duplicate rewards;
- unknown Lume site ids are ignored or rejected by content validation;
- link state resets between battles;
- link activation and severing are deterministic;
- Results summary is absent when Lume is disabled.

## Explicit v0.81 Confirmation

v0.81 itself adds no save fields, no save-version bump, no runtime Lume state, no reward rules, and no Tutorial behavior.
