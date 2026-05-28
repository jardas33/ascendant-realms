# v0.36 Hero Skill Tree Foundation Spec

Date: 2026-05-28

## Goal

Turn the existing hero skill-point panel into a tiny build-shaping foundation. The player should be able to spend saved hero skill points into Warrior, Seer, or Commander branches without adding a class tree, enemy hero tree, new maps, factions, runtime art/assets, shop, crafting, broad inventory UI, save-version bump, global rebalance, Patrol, formations, or broad AI/pathing changes.

## Skill Point Rules

- Skill points still come from the existing hero level-up flow.
- Skills are persisted through the existing `HeroSaveData.allocatedSkills` map.
- Spending a point decrements `HeroSaveData.skillPoints` through the current allocation rule.
- Unknown skill ids are ignored by stat, ability, and synergy helpers.
- Existing saves without `allocatedSkills` still normalize to an empty map.
- No save-version bump is required.

## Build Branches

The visible tree has three branches, each capped at a tiny 2-3 node surface:

- Warrior: damage, durability, and melee ability support.
- Seer: mana, cooldown, and ability support.
- Commander: army support, durability, and leadership aura support.

Existing rank support may remain for old passive nodes, but the branch surface must stay small. Any legacy compatibility nodes that are not part of the current visible foundation should stay hidden from the panel instead of expanding the player-facing tree.

## Node Scope

Each visible node should show:

- branch,
- name,
- cost,
- rank or unlocked state,
- effect summary,
- disabled reason when locked or unaffordable.

Class-specific ability unlocks may remain, but they should be modest and use existing ability definitions only.

## UI Scope

Use the existing Hero Inventory / Hero Progression screen. Do not add a large skill-tree canvas, graph layout, new art, icons, or modal.

The battle HUD and Results screen may show a compact reminder when skill points or build synergy are relevant, but Tutorial / Proving Grounds should not require skill-tree interaction.

## Deferrals

- Full class system.
- Large tree graph.
- Enemy hero skill tree.
- Respecs, skill refunds, or build presets.
- Skill-gated relic requirements.
- Runtime art, icons, portraits, VFX, or sound pass.
