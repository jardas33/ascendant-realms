# v0.98 Skills And Equipment UX Spec

Status: implemented presentation-only spec.

## Skills

Skill trees keep the Warrior, Seer, and Commander branches and existing unlock rules. The presentation now emphasizes:

- available / purchased / locked state;
- cost;
- concise effect;
- requirement status;
- rank;
- selected details behind `More Details`.

The `Unlock` / `Improve` action still calls the existing skill allocation path. Disabled buttons still come from existing rule checks.

## Equipment

Equipment now reads as a loadout:

- each slot shows `Equipped` or `Empty`;
- equipped item summary is visible first;
- item instance, affix, flavor, and long text are behind `More Details`;
- unequip actions keep the existing `data-progression-action="unequip"` path.

## Inventory

Inventory now groups:

- Equipped;
- Stored;
- Relics.

Rows show slot, rarity, owned/new state, effect/stat preview, and an equip action first. Instance/source/affix/base/flavor/tags remain available behind `More Details`.

## Relics

Relics remain one-slot equipment. The UI reinforces that relic effects and synergy are active only when equipped. Duplicate and locked behavior remains inherited from existing inventory/reward rules.

## Safety

No stats, item definitions, relic definitions, equipment rules, reward rules, saves, IDs, or sorting semantics changed.
