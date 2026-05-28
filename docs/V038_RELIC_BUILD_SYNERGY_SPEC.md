# v0.38 Relic Build Synergy Spec

Date: 2026-05-28

## Goal

Make the v0.34-v0.35 relic build identities lightly interact with the new skill branches. A matching equipped relic should help the player understand their Warrior, Seer, or Commander direction without making relics mandatory or adding more inventory complexity.

## Synergy Rules

- Emberbrand Shard supports Warrior.
- Cinder-Seer Focus supports Seer.
- Outpost Command Signet supports Commander.
- Synergy is active only when a matching relic is equipped and at least one skill in the matching branch is allocated.
- Unequipped relics give no synergy.
- Unknown relic ids and unknown skill ids are ignored.
- Synergy values, when present, must be small and non-stacking beyond the current one relic slot.

## Initial Synergy Scope

The first synergy layer may be copy-forward, tiny numeric support, or both:

- Warrior relic plus Warrior skill: a small Cleave support hint or bonus.
- Seer relic plus Seer skill: a small Mana/cooldown support hint or bonus.
- Commander relic plus Commander skill: a small Rally Banner support hint or bonus.

Relics remain useful without matching skills, and skills remain useful without relics.

## UI Scope

Use existing surfaces only:

- battle HUD: compact equipped relic and active synergy summary;
- Hero Inventory: equipped relic, branch skill, and synergy summary;
- Results: skill point reminder plus current equipped relic/build identity when relevant.

No new art, icon set, modal, build planner, paper-doll UI, shop, crafting, or relic upgrade system is part of this checkpoint.

## Save Compatibility

No save-version bump is required. Synergy is derived from existing `HeroSaveData.inventory`, `HeroSaveData.equipment.relic`, and `HeroSaveData.allocatedSkills`.

## Deferrals

- Multiple relic slots.
- Relic skill trees or relic leveling.
- Build presets, respecs, or class restrictions.
- Larger relic pool.
- Synergy balance pass beyond the first modest foundation.
