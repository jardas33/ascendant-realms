# v0.37 Ability Upgrade Foundation Spec

Date: 2026-05-28

## Goal

Let a few existing hero skills lightly upgrade existing abilities. This should make skill spending feel more RPG-like without adding a large ability roster, spammable powers, new targeting UI, runtime art/assets, global rebalance, enemy hero parity, or save migration.

## Upgrade Model

Ability upgrades are data on skill nodes:

- target one or more existing ability ids, or all learned abilities for a small support rule;
- adjust only modest numbers such as damage amount, Mana cost, cooldown, radius, or duration;
- apply only while the skill is allocated;
- ignore unknown skill ids safely;
- keep ability cooldown and Mana gates readable.

The base ability definitions remain the source of truth. Runtime code derives an effective ability for the current hero from base ability data plus allocated skill upgrades.

## Initial Upgrade Examples

- Warrior: Cleave gains a small damage increase and slight cooldown reduction.
- Seer: learned abilities get a small Mana or cooldown support bonus.
- Commander: Rally Banner gains a modest radius or duration increase.

The values should be conservative enough that abilities remain supportive, not screen-clearing or mandatory.

## UI Copy

The Hero Inventory skill panel should show each node's ability-upgrade summary before spending. The battle HUD ability button tooltip should reflect the effective ability cost/cooldown and mention active upgrades.

## Tutorial Protection

Tutorial / Proving Grounds can keep the existing simple Rally Banner hint. It does not need a new skill-upgrade step, and it must remain no-save/no-reward.

## Deferrals

- New abilities or spell schools.
- Ability upgrade tiers beyond the current tiny node layer.
- Enemy hero ability upgrades.
- New targeting widgets.
- Balance-wide cooldown or Mana redesign.
