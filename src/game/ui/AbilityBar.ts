import type { AbilityDefinition } from "../core/GameTypes";

export interface AbilityResourceState {
  disabled: boolean;
  label: string;
  className: "ready" | "cooldown" | "mana";
}

export function abilityLabel(ability: AbilityDefinition, cooldownRemaining: number): string {
  const cooldown = cooldownRemaining > 0 ? ` (${Math.ceil(cooldownRemaining)}s)` : "";
  return `${ability.hotkey}. ${ability.name}${cooldown}`;
}

export function abilityResourceState(
  ability: AbilityDefinition,
  hero: { mana: number; abilityCooldowns: Record<string, number> }
): AbilityResourceState {
  const cooldownRemaining = hero.abilityCooldowns[ability.id] ?? 0;
  if (cooldownRemaining > 0) {
    return {
      disabled: true,
      label: `Cooldown ${Math.ceil(cooldownRemaining)}s`,
      className: "cooldown"
    };
  }
  if (hero.mana < ability.manaCost) {
    return {
      disabled: true,
      label: `Need ${ability.manaCost - Math.floor(hero.mana)} Mana`,
      className: "mana"
    };
  }
  return {
    disabled: false,
    label: "Ready",
    className: "ready"
  };
}
