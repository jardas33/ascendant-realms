import type { HeroSaveData } from "../../save/SaveTypes";

export function applyReputationChanges(hero: HeroSaveData, changes: Record<string, number>): HeroSaveData {
  const factionReputation = { ...hero.factionReputation };
  Object.entries(changes).forEach(([factionId, amount]) => {
    factionReputation[factionId] = clampReputation((factionReputation[factionId] ?? 0) + amount);
  });
  return {
    ...hero,
    factionReputation
  };
}

export function clampReputation(value: number): number {
  return Math.max(-100, Math.min(100, Math.round(value)));
}
