import type {
  AbilityDefinition,
  HeroBuildArchetype,
  ItemDefinition,
  ItemInstance,
  SkillNodeDefinition
} from "../GameTypes";
import type { EquipmentSlots } from "../../save/SaveTypes";
import { findItemInstance } from "./AffixRules";

export interface HeroBuildState {
  allocatedSkills?: Record<string, number>;
  inventory?: ItemInstance[];
  equipment?: EquipmentSlots;
}

export interface HeroBuildSynergyState {
  archetype: HeroBuildArchetype;
  relicName: string;
  skillNames: string[];
  summary: string;
  abilitySummary: string;
}

export interface AbilityUpgradeResult {
  ability: AbilityDefinition;
  upgradeSummaries: string[];
  synergy?: HeroBuildSynergyState;
}

export function applyHeroAbilityUpgrades(
  baseAbility: AbilityDefinition,
  hero: HeroBuildState,
  skillById: Record<string, SkillNodeDefinition>,
  itemById: Record<string, ItemDefinition>
): AbilityUpgradeResult {
  const deltas = {
    amount: 0,
    manaCost: 0,
    cooldown: 0,
    radius: 0,
    duration: 0
  };
  const upgradeSummaries: string[] = [];
  getAllocatedSkillNodes(hero, skillById).forEach(({ node, rank }) => {
    const upgrade = node.abilityUpgrade;
    if (!upgrade || !abilityMatchesUpgrade(baseAbility.id, upgrade.abilityIds)) {
      return;
    }
    deltas.amount += (upgrade.amountDelta ?? 0) * rank;
    deltas.manaCost += (upgrade.manaCostDelta ?? 0) * rank;
    deltas.cooldown += (upgrade.cooldownDelta ?? 0) * rank;
    deltas.radius += (upgrade.radiusDelta ?? 0) * rank;
    deltas.duration += (upgrade.durationDelta ?? 0) * rank;
    upgradeSummaries.push(`${node.name}: ${upgrade.effectSummary}`);
  });

  const synergy = getActiveHeroBuildSynergy(hero, skillById, itemById);
  const synergyBonus = synergy ? synergyAbilityBonus(baseAbility.id, synergy.archetype) : undefined;
  if (synergy && synergyBonus) {
    deltas.amount += synergyBonus.amountDelta ?? 0;
    deltas.manaCost += synergyBonus.manaCostDelta ?? 0;
    deltas.cooldown += synergyBonus.cooldownDelta ?? 0;
    deltas.radius += synergyBonus.radiusDelta ?? 0;
    deltas.duration += synergyBonus.durationDelta ?? 0;
    upgradeSummaries.push(`${synergy.relicName}: ${synergyBonus.summary}`);
  }

  const ability: AbilityDefinition = {
    ...baseAbility,
    description: appendUpgradeSummary(baseAbility.description, upgradeSummaries),
    amount: Math.max(0, baseAbility.amount + deltas.amount),
    manaCost: Math.max(0, Math.round(baseAbility.manaCost + deltas.manaCost)),
    cooldown: Math.max(1, roundTenths(baseAbility.cooldown + deltas.cooldown)),
    radius: Math.max(0, Math.round(baseAbility.radius + deltas.radius)),
    duration: Math.max(0, roundTenths(baseAbility.duration + deltas.duration))
  };

  return { ability, upgradeSummaries, synergy };
}

export function getActiveHeroBuildSynergy(
  hero: HeroBuildState,
  skillById: Record<string, SkillNodeDefinition>,
  itemById: Record<string, ItemDefinition>
): HeroBuildSynergyState | undefined {
  const equippedRelic = getEquippedRelicArchetype(hero, itemById);
  if (!equippedRelic) {
    return undefined;
  }
  const matchingSkills = getAllocatedSkillNodes(hero, skillById)
    .filter(({ node }) => node.buildArchetype === equippedRelic.archetype)
    .map(({ node }) => node.name);
  if (matchingSkills.length === 0) {
    return undefined;
  }
  const label = buildArchetypeLabel(equippedRelic.archetype);
  return {
    archetype: equippedRelic.archetype,
    relicName: equippedRelic.item.name,
    skillNames: matchingSkills,
    summary: `${label} synergy active: ${equippedRelic.item.name} supports ${matchingSkills[0]}.`,
    abilitySummary: synergyCopy(equippedRelic.archetype)
  };
}

export function getAllocatedBuildArchetypes(
  hero: HeroBuildState,
  skillById: Record<string, SkillNodeDefinition>
): HeroBuildArchetype[] {
  return [
    ...new Set(
      getAllocatedSkillNodes(hero, skillById)
        .map(({ node }) => node.buildArchetype)
        .filter((archetype): archetype is HeroBuildArchetype => Boolean(archetype))
    )
  ];
}

export function buildArchetypeLabel(archetype: HeroBuildArchetype): string {
  switch (archetype) {
    case "warrior":
      return "Warrior";
    case "seer":
      return "Seer";
    case "commander":
      return "Commander";
  }
}

function getAllocatedSkillNodes(
  hero: HeroBuildState,
  skillById: Record<string, SkillNodeDefinition>
): Array<{ node: SkillNodeDefinition; rank: number }> {
  return Object.entries(hero.allocatedSkills ?? [])
    .map(([skillId, rawRank]) => {
      const node = skillById[skillId];
      if (!node) {
        return undefined;
      }
      const rank = Math.max(0, Math.min(rawRank, node.maxRank));
      return rank > 0 ? { node, rank } : undefined;
    })
    .filter((entry): entry is { node: SkillNodeDefinition; rank: number } => Boolean(entry));
}

function getEquippedRelicArchetype(
  hero: HeroBuildState,
  itemById: Record<string, ItemDefinition>
): { archetype: HeroBuildArchetype; item: ItemDefinition } | undefined {
  const relicInstance = hero.equipment?.relic ? findItemInstance(hero.inventory ?? [], hero.equipment.relic) : undefined;
  const item = relicInstance ? itemById[relicInstance.itemId] : undefined;
  if (!item || item.slot !== "relic") {
    return undefined;
  }
  const archetype = relicArchetypeFromTags(item.tags);
  return archetype ? { archetype, item } : undefined;
}

function relicArchetypeFromTags(tags: string[]): HeroBuildArchetype | undefined {
  if (tags.includes("warrior")) {
    return "warrior";
  }
  if (tags.includes("seer")) {
    return "seer";
  }
  if (tags.includes("commander")) {
    return "commander";
  }
  return undefined;
}

function abilityMatchesUpgrade(abilityId: string, targets: string[] | "all"): boolean {
  return targets === "all" || targets.includes(abilityId);
}

function synergyAbilityBonus(
  abilityId: string,
  archetype: HeroBuildArchetype
): { amountDelta?: number; manaCostDelta?: number; cooldownDelta?: number; radiusDelta?: number; durationDelta?: number; summary: string } | undefined {
  if (archetype === "warrior" && abilityId === "cleave") {
    return { amountDelta: 3, summary: "Warrior synergy: Cleave +3 damage while matching relic is equipped." };
  }
  if (archetype === "seer") {
    return { manaCostDelta: -2, cooldownDelta: -0.5, summary: "Seer synergy: learned abilities cost 2 less Mana and recover 0.5s faster." };
  }
  if (archetype === "commander" && abilityId === "rally_banner") {
    return { radiusDelta: 8, durationDelta: 1, summary: "Commander synergy: Rally Banner +8 radius and +1s duration." };
  }
  return undefined;
}

function synergyCopy(archetype: HeroBuildArchetype): string {
  switch (archetype) {
    case "warrior":
      return "Matching Warrior relic adds a small Cleave damage bonus.";
    case "seer":
      return "Matching Seer relic adds a small Mana and cooldown bonus.";
    case "commander":
      return "Matching Commander relic adds a small Rally Banner aura bonus.";
  }
}

function appendUpgradeSummary(description: string, summaries: string[]): string {
  if (summaries.length === 0) {
    return description;
  }
  return `${description} Upgrades active: ${summaries.join(" ")}`;
}

function roundTenths(value: number): number {
  return Math.round(value * 10) / 10;
}
