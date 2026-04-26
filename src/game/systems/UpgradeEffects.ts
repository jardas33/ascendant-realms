import type { UpgradeDefinition } from "../core/GameTypes";
import { Hero } from "../entities/Hero";
import { Unit } from "../entities/Unit";

export function applyUpgradeToUnit(unit: Unit, upgrade: UpgradeDefinition): boolean {
  if (unit.appliedUpgradeIds.has(upgrade.id)) {
    return false;
  }

  let applied = false;
  upgrade.effects.forEach((effect) => {
    if (effect.type === "unit-stat-mod" && effect.unitIds.includes(unit.definition.id)) {
      unit.upgradeDamageMultiplier *= effect.damageMultiplier ?? 1;
      unit.upgradeRangeMultiplier *= effect.rangeMultiplier ?? 1;
      unit.upgradeAttackCooldownMultiplier *= effect.attackCooldownMultiplier ?? 1;
      unit.armor += effect.armorBonus ?? 0;
      applied = true;
    }
    if (effect.type === "hero-mana-regen" && unit instanceof Hero) {
      unit.manaRegenMultiplier = Math.max(unit.manaRegenMultiplier, effect.multiplier);
      applied = true;
    }
  });

  if (applied) {
    unit.appliedUpgradeIds.add(upgrade.id);
  }
  return applied;
}
