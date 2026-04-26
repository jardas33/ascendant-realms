import type { AbilityDefinition } from "../core/GameTypes";

export function abilityLabel(ability: AbilityDefinition, cooldownRemaining: number): string {
  const cooldown = cooldownRemaining > 0 ? ` (${Math.ceil(cooldownRemaining)}s)` : "";
  return `${ability.hotkey}. ${ability.name}${cooldown}`;
}
